---
title: libra的mempool模块解读-1
permalink: Interpretation-of-libra-mempool-module1
date: 2019-07-01 10:23:48
categories: Libra
tags: 
    - Libra源码分析
author: 白振轩
---

Mempool模块主要用于缓存未打包的合法交易,该模块和比特币,以太坊源码中的TxPool功能等价,只要包含两个功能:

1.接收本地收到的Tx并验证
2.和其他节点之间互相同步Tx.
因为Libra使用的是不会分叉的PBFT共识,所以缓冲池的实现以及管理要简单许多.

## 基本功能

mempool的功能主要是接收来自AC模块的交易,同时和其他节点之间通过网络同步交易.
mempool主要用于保存可能打包的交易,主要是指验证合法的交易(包括签名合法,账户金额足够). 可以简单分类:

1.各方面都齐备,可以进入下一块的交易. 主要是seq_number连起来的.
2.因为seq_number没有连续不能被打包的交易 (比如当前AccountA的Tx中包含了[2,3,4,7,8]交易,但是5没有,所以[7,8]是不可能被打包的)

同时libra中也有和以太坊一样的GasPrice概念(功能也一样),因此如果对于同一账号,seq_number相同的情况下,会选择GasPrice高的那个Tx.
根据以上讨论,可以看出实际上Libra唯一的ID可以不认为是交易数据的哈希值,可以把(Address,seq_number)作为唯一的ID,当然这个在比特币以太坊等公链中也行的通.
因为在Libra中把(Address,seq_number)二元组作为Tx唯一的ID,所以其代码设计中对于Tx的管理和以太坊也不太一样.

那么什么是mempool呢?
可以通俗的认为就是一个
`HashMap <AccountAddress, BTreeMap<u64, MempoolTransaction>>`, 其中这里的u64就是对应账户的seq_number.
其所有功能都是围绕着这个数据结构展开.

## mempool的对外接口

```
pub trait Mempool {
    //主要用于接受来自AC的新增Tx
    fn add_transaction_with_validation(&mut self, ctx: ::grpcio::RpcContext, req: super::mempool::AddTransactionWithValidationRequest, sink: ::grpcio::UnarySink<super::mempool::AddTransactionWithValidationResponse>);
    //服务于consensus模块,从mempool中获取下一块可以打包的交易
    fn get_block(&mut self, ctx: ::grpcio::RpcContext, req: super::mempool::GetBlockRequest, sink: ::grpcio::UnarySink<super::mempool::GetBlockResponse>);
    //服务于consensus模块,当交易被打包以后,缓存的相关Tx就可以移除了.
    fn commit_transactions(&mut self, ctx: ::grpcio::RpcContext, req: super::mempool::CommitTransactionsRequest, sink: ::grpcio::UnarySink<super::mempool::CommitTransactionsResponse>);
    //健康检查,主要是检查缓冲区是否放得下更多Tx
    fn health_check(&mut self, ctx: ::grpcio::RpcContext, req: super::mempool::HealthCheckRequest, sink: ::grpcio::UnarySink<super::mempool::HealthCheckResponse>);
}
```

MempoolService的实现位`于mempool/src/mempool_service.rs`,这里的实现就是对于grpc接口数据的处理,真正的处理逻辑位于`CoreMempool`

```
#[derive(Clone)]
pub(crate) struct MempoolService {
    pub(crate) core_mempool: Arc<Mutex<CoreMempool>>,
}
pub struct Mempool {
    // stores metadata of all transactions in mempool (of all states)
    transactions: TransactionStore, //这是系统的核心

    sequence_number_cache: LruCache<AccountAddress, u64>, //这里保存的是AccountAddress对应的下一个可以打包的Tx对应的seq_number
    // temporary DS. TODO: eventually retire it
    // for each transaction, entry with timestamp is added when transaction enters mempool
    // used to measure e2e latency of transaction in system, as well as time it takes to pick it up
    // by consensus
    metrics_cache: TtlCache<(AccountAddress, u64), i64>, //这个是为了
    //一个交易在缓冲池中不能呆的太久,如果迟迟不能被打包会被定期清理掉.这个时间就是其在缓冲池中呆的最长时间
    pub system_transaction_timeout: Duration,
}
/// TransactionStore is in-memory storage for all transactions in mempool
pub struct TransactionStore {
    // main DS
    transactions: HashMap<AccountAddress, AccountTransactions>, /* 地址=>{seq=>Tx} 二重map,所有收集到的合法的Tx */

    // indexes
    priority_index: PriorityIndex, /* 按照gas_price,expiration_time,address,
                                    * sequence_number顺序排序的所有可以打包的Tx */
    // TTLIndex based on client-specified expiration time
    expiration_time_index: TTLIndex, /* 这个过期时间是用户提交的,这个时间虽然是Duration,
                                      * 但是其实也是绝对时间,保存所有合法的Tx */
    // TTLIndex based on system expiration time
    // we keep it separate from `expiration_time_index` so Mempool can't be clogged
    //  by old transactions even if it hasn't received commit callbacks for a while
    system_ttl_index: TTLIndex, /* 这个时间是由mempool控制,
                                 * 在进入缓冲池的时候会设置成当时的时间加上过期时间,
                                 * 保存所有的合法Tx */
    timeline_index: TimelineIndex, /* 里面保存的timeline_id,用于mempool之间的Tx同步,
                                    * 这里面按序保存着可以打包的Tx */
    // keeps track of "non-ready" txns (transactions that can't be included in next block)
    parking_lot_index: ParkingLotIndex, //暂时不满足条件,不能打包的Tx

    // configuration
    capacity: usize,
    capacity_per_user: usize,
}
```

### 接受新的Tx

在`add_transaction_with_validation`中只是简单解析一下参数就很快进入到`CoreMempool`的`add_txn`中,我们重点解析一下这个函数.

```
/// Used to add a transaction to the Mempool
    /// Performs basic validation: checks account's balance and sequence number
    pub(crate) fn add_txn(
        &mut self,
        txn: SignedTransaction,
        gas_amount: u64,
        db_sequence_number: u64, //已经确认的txn's sender的seq_number
        balance: u64,//这个账户的金额
        timeline_state: TimelineState,
    ) -> MempoolAddTransactionStatus {
        debug!(
            "[Mempool] Adding transaction to mempool: {}:{}",
            &txn.sender(),
            db_sequence_number
        );
        println!("signedTransaction:{:?}", txn);
        //账户余额都不够付gas费了,直接护额略
        if !self.check_balance(&txn, balance, gas_amount) {
            return MempoolAddTransactionStatus::InsufficientBalance;
        }

        let cached_value = self.sequence_number_cache.get_mut(&txn.sender());
        let sequence_number = match cached_value {
            Some(value) => max(*value, db_sequence_number),
            None => db_sequence_number,
        };
        self.sequence_number_cache
            .insert(txn.sender(), sequence_number); //可能sequence_number需要更新了. 如果发生了expiration呢?

        // don't accept old transactions (e.g. seq is less than account's current seq_number)
        if txn.sequence_number() < sequence_number {
            return MempoolAddTransactionStatus::InvalidSeqNumber;
        }

        //交易在缓冲池中的过期时间
        let expiration_time = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("init timestamp failure")
            + self.system_transaction_timeout;
        self.metrics_cache.insert(
            (txn.sender(), txn.sequence_number()),
            Utc::now().timestamp_millis(),
            Duration::from_secs(100),
        );
        //MempoolTransaction指的就是在缓冲池中的Tx,为了缓冲池管理方便,增添了过期时间以及TimelineState,还有gasAmount,
        //主要是为了索引
        let txn_info = MempoolTransaction::new(txn, expiration_time, gas_amount, timeline_state);
        //真正的Tx,无论能否立即被打包,都在TransactionStore中保存着
        let status = self.transactions.insert(txn_info, sequence_number);
        OP_COUNTERS.inc(&format!("insert.{:?}", status));
        status
    }
```

### remove_transaction 移除已打包交易

```
/// This function will be called once the transaction has been stored
    /// 共识模块确定Tx被打包了,那么缓冲池中的Tx就可以移除了. is_rejected表示没有被打包
    /// 同时is_rejected为false的时候,sequence_number也告诉mempool目前sender之前的Tx都被打包了,
    /// 本地的seqence_number也要更新到这里了
    pub(crate) fn remove_transaction(
        &mut self,
        sender: &AccountAddress,
        sequence_number: u64,
        is_rejected: bool,
    ) {
        debug!(
            "[Mempool] Removing transaction from mempool: {}:{}",
            sender, sequence_number
        );
        self.log_latency(sender.clone(), sequence_number, "e2e.latency");
        self.metrics_cache.remove(&(*sender, sequence_number));

        // update current cached sequence number for account
        let cached_value = self
            .sequence_number_cache
            .remove(sender)
            .unwrap_or_default();

        let new_sequence_number = if is_rejected {
            min(sequence_number, cached_value)
        } else {
            max(cached_value, sequence_number + 1)
        };
        //sequence_number_cache保存的就是下一个有效的seq_number
        self.sequence_number_cache
            .insert(sender.clone(), new_sequence_number);
        //核心处理其实还在`TransactionStore`中
        self.transactions
            .commit_transaction(&sender, sequence_number);
    }
```


### 为consensus模块提供下一块交易数据

get_block功能非常简单,就是跳出来下一块可以打包的交易,主要就是seq_number连起来的交易.因为不合法的交易早就已经被踢了.

```
/// Fetches next block of transactions for consensus
    /// `batch_size` - size of requested block
    /// `seen_txns` - transactions that were sent to Consensus but were not committed yet
    ///  Mempool should filter out such transactions
    /// 共识模块需要从mempool中拉取下一个块可用的Tx集合
    pub(crate) fn get_block(
        &mut self,
        batch_size: u64,
        mut seen: HashSet<TxnPointer>,
    ) -> Vec<SignedTransaction> {
        /*
           get_block 实际上是找寻可以进入下一块的交易:
           1. 已经送到共识模块中,但是还没有确认(确认后会从缓冲池中移除)
           2.  这个Tx的seq刚好就是下一个可以打包的.比如上一块中AccountA的seq是3,那么现在seq=4的Tx就可以进入block
           3. 或者当前块中已经包含了seq=4的,那么seq=5的就可以进入
        */
        let mut result = vec![];
        // Helper DS. Helps to mitigate scenarios where account submits several transactions
        // with increasing gas price (e.g. user submits transactions with sequence number 1, 2
        // and gas_price 1, 10 respectively)
        // Later txn has higher gas price and will be observed first in priority index iterator,
        // but can't be executed before first txn. Once observed, such txn will be saved in
        // `skipped` DS and rechecked once it's ancestor becomes available
        let mut skipped = HashSet::new();

        // iterate over the queue of transactions based on gas price
        //带标签的break用法
        'main: for txn in self.transactions.iter_queue() {
            if seen.contains(&TxnPointer::from(txn)) {
                continue;
            }
            let mut seq = txn.sequence_number;
            /*
            这里打包是按照地址选,尽可能的把同一个地址的Tx都打包到一个block中去
            */
            let account_sequence_number = self.sequence_number_cache.get_mut(&txn.address);
            let seen_previous = seq > 0 && seen.contains(&(txn.address, seq - 1));
            // include transaction if it's "next" for given account or
            // we've already sent its ancestor to Consensus
            if seen_previous || account_sequence_number == Some(&mut seq) {
                let ptr = TxnPointer::from(txn);
                seen.insert(ptr);
                result.push(ptr);
                if (result.len() as u64) == batch_size {
                    //batch_size表示这块最多有多少个交易
                    break;
                }

                // check if we can now include some transactions
                // that were skipped before for given account
                //这是回头遍历,比如先走过了seq=7的,那么发现seq=6合适的时候,就还可以再把seq=7加入
                let mut skipped_txn = (txn.address, seq + 1);
                while skipped.contains(&skipped_txn) {
                    seen.insert(skipped_txn);
                    result.push(skipped_txn);
                    if (result.len() as u64) == batch_size {
                        break 'main;
                    }
                    skipped_txn = (txn.address, skipped_txn.1 + 1);
                }
            } else {
                skipped.insert(TxnPointer::from(txn));
            }
        }
        // convert transaction pointers to real values
        let block: Vec<_> = result
            .into_iter()
            //filter_map 行为等于filter & map
            .filter_map(|(address, seq)| self.transactions.get(&address, seq))
            .collect();
        for transaction in &block {
            self.log_latency(
                transaction.sender(),
                transaction.sequence_number(),
                "txn_pre_consensus_ms",
            );
        }
        block //就是一个Tx的集合,没有任何附加信息
    }
```

### 其他几个函数

`gc_by_system_ttl`: 就是为了清除在mempool中呆的太久的交易,否则mempool因为空间已满而无法进来有效的交易
`gc_by_expiration_time`: 是在新的一块来临的时候,依据新块时间可以非常确定**那些用户指定的在这个之前必须打包的交易**必须被清理掉,因为再也不可能被打包了.
`read_timeline`: 主要用于节点间mempool中的Tx同步用,就是为每一个Tx都给一个本地唯一的单增的编号,这样推送的时候就知道推送到哪里了,避免重复.

下一篇我会讲解`TransactionStore`,他是维护mempool中Tx的核心数据结构.
[原文链接-libra的mempool模块解读-1 ](http://stevenbai.top/libra%E7%B3%BB%E5%88%97/6.libra%E7%9A%84mempool%E6%A8%A1%E5%9D%97%E8%A7%A3%E8%AF%BB-1/)



