# Interpretation-of-libra-mempool-module2

标签（空格分隔）： 文章分享

---

title: libra的mempool模块解读-2
permalink: Interpretation-of-libra-mempool-module2
date: 2019-07-08 10:23:48
categories: Libra
tags: Libra
author: 白振轩

---

[原文地址：libra的mempool模块解读-2](http://stevenbai.top/libra%E7%B3%BB%E5%88%97/7.libra%E7%9A%84mempool%E6%A8%A1%E5%9D%97%E8%A7%A3%E8%AF%BB-2/)

mempool模块对于Tx的管理核心全部集中在`TransactionStore`这个结构,他对外对接的是`CoreMemPool`结构.
从`TransactionStore`可以清楚看出缓冲池中Tx增删改查的逻辑.

作为缓冲池,我们先大致说一下这几个功能要考虑的问题.

## 1. `TransactionStore`中的增删改查

### 1.1 增以及改

增就是向缓冲池中添加新的Tx,改则是修改已经在缓冲池中的Tx了.
先说为什么会有修改,主要因素实际上只有一个就是GasPrice,对于同一个账户的同一个`Sequence_number`(就是以太坊中的Nonce)的Tx,如果存在Gas更高的,就会被替换. 对于公链有这样的需求,比如想被更快打包. 那么对于联盟链也有这样的需求? 并且Libra号称是1000TPS. **为什么有这个功能希望大家能够一起来讨论这个问题.**

说完了改,我们重点考虑增:
增主要是因为收到了用户提交的新的Tx,增的时候就要进行分类,分成两类:可以立即被打包的Tx和不能被立即打包的Tx.原因也只有一个就是`Sequence_number`是否连得起来.
增的时候还要考虑其他问题,主要就是为了服务删查,如同数据库一样,因为如果没有删查需求,那很简单,一个文件追加写就ok了. 正是因为了有了删查需求,才会有各种索引.

`TransactionStore`六中索引来查找删除Tx,后面我们会展开.

### 1.2 删

1.当缓冲池中的Tx被打包以后,肯定要删
2.当一个Tx用户指定的过期时间到了,也要删. (每个Tx都有一个过期时间,这个是Libra的独创,在比特币以太坊源码中是没有的).
3.当一个Tx在缓冲池中呆很久都不能被打包,也要删
    
### 1.3 查

1.新的Tx来的时候要做重复性检查,这是要查
2.当共识模块需要下一块可以被打包的交易,这时候要快速查
3.节点之间需要同步Tx,那么要查哪些Tx已经同步,哪些没有,同步到了什么位置.

## 2. 增删改查的实现

### 2.1 用到的索引

为了管理Tx,在`TransactionStore`同时用到了好几种索引方式,简单介绍一下.

#### 2.1.1 PriorityIndex

看名字,就是一个优先级队列. 它内部用BTreeSet进行组织,排序方式则是gas_price,expiration_time,address,sequence_number. 也就是gas_price高的优先,其次是expiration_time等.

```
pub struct PriorityIndex {
    data: BTreeSet<OrderedQueueKey>,
}
```

顺便说一下rust中的运算符重载,这个和C++中是一样的,如果一个自定义结构想实现`<,>,==`,那么可以实现`Ord`这个trait,为了直观,我们这里展示一下`OrderedQueueKey`对Ord的实现. 其他几种索引方式大同小异.

```
#[derive(Eq, PartialEq, Clone, Debug, Hash)]
pub struct OrderedQueueKey {
    pub gas_price: u64,
    pub expiration_time: Duration,
    pub address: AccountAddress,
    pub sequence_number: u64,
}

impl PartialOrd for OrderedQueueKey {
    fn partial_cmp(&self, other: &OrderedQueueKey) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for OrderedQueueKey {
    fn cmp(&self, other: &OrderedQueueKey) -> Ordering {
        match self.gas_price.cmp(&other.gas_price) {
            Ordering::Equal => {}
            ordering => return ordering,
        }
        match self.expiration_time.cmp(&other.expiration_time).reverse() {
            Ordering::Equal => {}
            ordering => return ordering,
        }
        match self.address.cmp(&other.address) {
            Ordering::Equal => {}
            ordering => return ordering,
        }
        self.sequence_number.cmp(&other.sequence_number).reverse()
    }
}
```

#### 2.1.2 TTLIndex

这个是按照过期时间排序,过期时间总共有两种,一种是在缓冲池中呆太久了,另一种是用户指定的过期时间.
```
pub struct TTLIndex {
    data: BTreeSet<TTLOrderingKey>,
    get_expiration_time: Box<dyn Fn(&MempoolTransaction) -> Duration + Send + Sync>,
}
```
其中get_expiration_time这个回调函数就是用来`从MempoolTransaction`获取不同的时间用的.

#### 2.1.3 TimelineIndex

这个索引方式主要是服务节点间同步,为每一个Tx都给与一个唯一的编号,这样向其他节点推送Tx的时候只需记住一个整数就知道下次从什么位置开始推送了.
```
/// TimelineIndex is ordered log of all transactions that are "ready" for broadcast
/// we only add transaction to index if it has a chance to be included in next consensus block
/// it means it's status != NotReady or it's sequential to other "ready" transaction
///
/// It's represented as Map <timeline_id, (Address, sequence_number)>
///    where timeline_id is auto increment unique id of "ready" transaction in local Mempool
///    (Address, sequence_number) is a logical reference to transaction content in main storage
///  //按照添加顺序对Tx排序,用于节点间的mempool的同步
pub struct TimelineIndex {
    timeline_id: u64, //无异这个结构是单线程的,单增
    timeline: BTreeMap<u64, (AccountAddress, u64)>,
}
```


这里的`timeline_id`则是那个唯一的编号,`timeline`这是`timeline_id`到Tx ID的映射. 上一篇文章我们提到了Libra中Tx的这个特征.

#### 2.1.4 ParkingLotIndex

ParkingLotIndex主要是记录那些因为seq_number不连续还不能被打包的Tx. 一旦来了新的交易就有可能让不连续的seq_number变成连续的. 或者打包的块中更新了seq_number,从而也可能连起来.
后一种情况可能不太直观,比如我本地缓冲池中有AccountA的Tx[2,3,5,6,7],因为4不存在,导致[5,6,7]不可能被打包. 但是突然链上已经被打包的交易中出现了4,这就意味着[5,6,7]都已经Ready了,4只是因为同步延迟我没有收到而已.
```
/// ParkingLotIndex keeps track of "not_ready" transactions
/// e.g. transactions that can't be included in next block
/// (because their sequence number is too high)
/// we keep separate index to be able to efficiently evict them when Mempool is full
/// 暂时不能打包的交易,seq没有连起来,有间隔
pub struct ParkingLotIndex {
    data: BTreeSet<TxnPointer>,
}
/// Logical pointer to `MempoolTransaction`
/// Includes Account's address and transaction sequence number
pub type TxnPointer = (AccountAddress, u64);
```


### 2.2 TransactionStore的定义

有了上面的脚手架,再来看`TransactionStore`就会容易理解的多.
说句题外话,有了Map这个结构,数据组织以及管理真是轻松了很多,怪不得Go要把Map作为内置的.
我们提到的各种Index,都是用的有序`BTreeMap`, `BTreeSet`本身就是一个特殊的BTreeMap.

```
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
                                    * 这里面只会保存来自AC模块的交易,
                                    * 而对来自其他节点推送来的交易不在进行广播 */
    // keeps track of "non-ready" txns (transactions that can't be included in next block)
    parking_lot_index: ParkingLotIndex, //暂时不满足条件,不能打包的Tx

    // configuration
    capacity: usize,
    capacity_per_user: usize,
}
```

## TransactionStore完整的实现

### 3.1 按照 Tx ID查

```
/// fetch transaction by account address + sequence_number
    pub(crate) fn get(
        &self,
        address: &AccountAddress,
        sequence_number: u64,
    ) -> Option<SignedTransaction> {
        if let Some(txns) = self.transactions.get(&address) {
            if let Some(txn) = txns.get(&sequence_number) {
                return Some(txn.txn.clone());
            }
        }
        None
    }
```

### 3.2 增,改的实现

增很容易,关键是增的时候要考虑删查,所以各种索引都要考虑好.
```
/// insert transaction into TransactionStore
    /// performs validation checks and updates indexes
    pub(crate) fn insert(
        &mut self,
        txn: MempoolTransaction,
        current_sequence_number: u64, /* current_sequence_number-1表示已经达成共识的seq
                                       * number,之前的都没必要缓存了. 这是下一个ready的number */
    ) -> MempoolAddTransactionStatus {
        //增删改查中的改
        let (is_update, status) = self.check_for_update(&txn);
        if is_update {
            return status;
        }
        if self.check_if_full() {
            return MempoolAddTransactionStatus::MempoolIsFull;
        }

        let address = txn.get_sender();
        let sequence_number = txn.get_sequence_number();

        let txns = self
            .transactions
            .entry(address)
            .or_insert_with(AccountTransactions::new);

        // capacity check
        if txns.len() >= self.capacity_per_user {
            return MempoolAddTransactionStatus::TooManyTransactions;
        }

        //新增很容易,关键是各种索引也要跟着建立
        // insert into storage and other indexes
        println!("insert system ttl");
        self.system_ttl_index.insert(&txn); // 
        println!("insert expiration time");
        self.expiration_time_index.insert(&txn);
        txns.insert(sequence_number, txn);
        OP_COUNTERS.set("txn.system_ttl_index", self.system_ttl_index.size());

        self.process_ready_transactions(&address, current_sequence_number);
        MempoolAddTransactionStatus::Valid
    }

    /// fixes following invariants:
    /// all transactions of given account that are sequential to current sequence number
    /// supposed to be included in both PriorityIndex (ordering for Consensus) and
    /// TimelineIndex (txns for SharedMempool)
    /// Other txns are considered to be "non-ready" and should be added to ParkingLotIndex
    fn process_ready_transactions(
        &mut self,
        address: &AccountAddress,
        current_sequence_number: u64, /* 表示当前已经ready的那个sequence_number,
                                       * 后续可能还有也可能没有tx
                                       * ready,比如3ready了,那么本来没有ready的4,5都应该ready */
    ) {
        if let Some(txns) = self.transactions.get_mut(&address) {
            let mut sequence_number = current_sequence_number;
            while let Some(txn) = txns.get_mut(&sequence_number) {
                self.priority_index.insert(txn);

                if txn.timeline_state == TimelineState::NotReady {
                    self.timeline_index.insert(txn);
                }
                sequence_number += 1;
            }
             //这个有必要进行?原来的没有ready的,肯定也是没有ready
            //增的时候没必要做,但是`commit_transaction`的时候可能会让没有ready的变成ready
            for (_, txn) in txns.range_mut((Bound::Excluded(sequence_number), Bound::Unbounded)) {
                match txn.timeline_state {
                    TimelineState::Ready(_) => {}
                    _ => {
                        self.parking_lot_index.insert(&txn);
                    }
                }
            }
        }
    }
```

### 3.3 删

#### 3.3.1 删被打包的交易

``` 
  /// handles transaction commit
    /// it includes deletion of all transactions with sequence number <= `sequence_number`
    /// and potential promotion of sequential txns to PriorityIndex/TimelineIndex
    pub(crate) fn commit_transaction(&mut self, account: &AccountAddress, sequence_number: u64) {
        if let Some(txns) = self.transactions.get_mut(&account) {
            // remove all previous seq number transactions for this account
            // This can happen if transactions are sent to multiple nodes and one of
            // nodes has sent the transaction to consensus but this node still has the
            // transaction sitting in mempool
            //小于等于sequence_number都需要移除了
            let mut active = txns.split_off(&(sequence_number + 1));
            let txns_for_removal = txns.clone();
            txns.clear();
            txns.append(&mut active);

            for transaction in txns_for_removal.values() {
                self.index_remove(transaction);
            }
        }
        self.process_ready_transactions(account, sequence_number + 1);
    }
```

#### 3.3.2 删迟迟不能被打包的交易

```
    /// GC old transactions
    pub(crate) fn gc_by_system_ttl(&mut self) {
        //清除所有过期的交易,这里虽然设置的是now,
        // 但是因为加入的时候都会在过期时间上加上一段时间`system_transaction_timeout`,
        // 因此不用担心会清理掉所有的交易
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("init timestamp failure");

        self.gc(now, true);
    }
     fn gc(&mut self, now: Duration, by_system_ttl: bool) {
        let (index_name, index) = if by_system_ttl {
            ("gc.system_ttl_index", &mut self.system_ttl_index)
        } else {
            ("gc.expiration_time_index", &mut self.expiration_time_index)
        };
        OP_COUNTERS.inc(index_name);

        for key in index.gc(now) {
            if let Some(txns) = self.transactions.get_mut(&key.address) {
                // mark all following transactions as non-ready
                //比如本来seq={3,4,5},但是3过期了,那么{4,5}也不能打包了
                for (_, t) in txns.range((Bound::Excluded(key.sequence_number), Bound::Unbounded)) {
                    self.parking_lot_index.insert(&t);
                    self.priority_index.remove(&t);
                    self.timeline_index.remove(&t);
                }
                if let Some(txn) = txns.remove(&key.sequence_number) {
                    let is_active = self.priority_index.contains(&txn);
                    let status = if is_active { "active" } else { "parked" };
                    OP_COUNTERS.inc(&format!("{}.{}", index_name, status));
                    self.index_remove(&txn);
                }
            }
        }
        OP_COUNTERS.set("txn.system_ttl_index", self.system_ttl_index.size());
    }
```

#### 3.3.3 删过了用户指定时间

这里需要说的是这里比较的时间并不是本地时间,而是经过Validator集体参与生成的块中的时间.
虽然Libra中Block的概念被弱化了很多,但是块时间这个因素还是要所有`Validator`签名的.
```
    /// GC old transactions based on client-specified expiration time
    pub(crate) fn gc_by_expiration_time(&mut self, block_time: Duration) {
        self.gc(block_time, false);
    }
```

## 结语

不得不说大厂出来的代码质量高,很精炼. 也没多少行core_mempool总共也就五个文件,一千行代码不到.
其次是因为是联盟链,也不用考虑分叉,所以这部分代码相比以太坊简化了不少. 所谓的好与不好,主要看能不能满足需求吧.
