---
title: 打通client与libradb模块的任督二脉
permalink: Proficient-client-and-libradb-modules
date: 2019-07-01 10:23:48
categories: Libra
tags: Libra
author: 白振轩
---



这篇文章目的是打通client命令行工具与底层数据库模块libradb之间的管理. `client`指的是 [一分钟上手Libra](http://stevenbai.top/libra%E7%B3%BB%E5%88%97/1.-%E4%B8%80%E5%88%86%E9%92%9F%E4%B8%8A%E6%89%8Blibra/) 中提到的client命令行工具. `libradb`指的是`storage/libradb`模块.

## client实现

client本身主要提供了`account`,`transfer`和`query`三个命令,其中每个命令还有若干子命令. 这些命令中除了transfer是修改账本以外,其他都是直接查询的账本数据库.

### 一个具体例子

这里就绕开client模块的枝枝蔓蔓,直接关注它最核心大部分. 我们找一个具体的子命令,追踪他的执行,然后看看他是怎么实现的.
`account create`命令对应的就是`AccountCommandCreate`这个结构体,当我们敲下回车,在参数解析完毕以后就会进入execute函数.

#### 1. execute

`fn execute(&self, client: &mut ClientProxy, _params: &[&str])`
第一个参数可以忽略,没有任何内容,第二个client是一个grpc client,就是与服务器的链接.` _params`则是空了,因为我们没有任何附加参数了.
这个函数会直接调用ClientProxy.create_next_account

#### ClientProxy.create_next_account

1.调用wallet.new_address获取新的地址, 这里的Wallet使用的是`WalletLibrary`,这个钱包中的私钥生成以及管理机制和比特币中的BIP32原理是完全一样,只是细节稍微不同. 我会在其他文章专门介绍钱包的实现.
2.调用get_account_data_from_address从服务器上获取该新生成地址的账户信息.
`rust fn get_account_data_from_address( client: &GRPCClient, address: AccountAddress, key_pair: Option<KeyPair>, ) -> Result<AccountData>`
这个函数很简单就是调用get_account_blob然后对返回的信息封装成`AccountData`.
3.调用GRPCClient的get_account_blob 获取AccountStateBlob以及Version信息

```
pub(crate) fn get_account_blob(
    &self,
    address: AccountAddress,
) -> Result<(Option<AccountStateBlob>, Version)>{
    let req_item = RequestItem::GetAccountState { address };

    let mut response = self.get_with_proof_sync(vec![req_item])?;
    ...//处理返回结果

}
```

这个函数组装请求参数`GetAccountState`,然后就是调用`get_with_proof_sync`然后解码response.

4.调用GRPCClient的get_with_proof_sync
```
pub(crate) fn get_with_proof_sync(
    &self,
    requested_items: Vec<RequestItem>,
) -> Result<UpdateToLatestLedgerResponse> 
```
这个函数功能非常简单,就是调用`get_with_proof_async`,将异步转换为同步,同时会多次尝试.
具体代码也很简单就是一句话:
```
let mut resp: Result<UpdateToLatestLedgerResponse> =
        self.get_with_proof_async(requested_items.clone())?.wait();
```
这里其实也体现了怎么使用future库.

5.GRPCClient.get_with_proof_async

```
fn get_with_proof_async(
    &self,
    requested_items: Vec<RequestItem>,
) -> Result<impl Future<Item = UpdateToLatestLedgerResponse, Error = failure::Error>> 
```

这个函数做了两件事,一个是调用`update_to_latest_ledger_async_opt`发出请求,然后对结果进行验证,如果符合要求(主要是指validator的签名是否正确以及足够数量).
`update_to_latest_ledger_async_opt`是一个protobuf自动生成的函数,可以直接忽略.

6.服务端处理
客户端的请求发出以后,服务端处理代码位于`storage\storage_service`中
```
impl Storage for StorageService {
fn update_to_latest_ledger(
    &mut self,
    ctx: grpcio::RpcContext<'_>,
    req: UpdateToLatestLedgerRequest,
    sink: grpcio::UnarySink<UpdateToLatestLedgerResponse>,
) {
    debug!("[GRPC] Storage::update_to_latest_ledger");
    let _timer = SVC_COUNTERS.req(&ctx);
    let resp = self.update_to_latest_ledger_inner(req);
    provide_grpc_response(resp, ctx, sink);
}
```
其中的`update_to_latest_ledger_inner`简单处理以后就会走到`storage\libradb\lib.rs`中的`update_to_latest_ledger`.

## libradb

所有libra中需要持久化存储的数据入口都在这里.

```
/// This holds a handle to the underlying DB responsible for physical storage and provides APIs for
/// access to the core Libra data structures.
pub struct LibraDB {
    db: Arc<DB>,
    ledger_store: LedgerStore,
    transaction_store: TransactionStore,
    state_store: StateStore,
    event_store: EventStore,
}

impl LibraDB {
    /// This creates an empty LibraDB instance on disk or opens one if it already exists.
    pub fn new<P: AsRef<Path> + Clone>(db_root_path: P) -> Self 

      /// Persist transactions. Called by the executor module when either syncing nodes or committing
    /// blocks during normal operation.
    ///
    /// When `ledger_info_with_sigs` is provided, verify that the transaction accumulator root hash
    /// it carries is generated after the `txns_to_commit` are applied.
    pub fn save_transactions(
        &self,
        txns_to_commit: &[TransactionToCommit],
        first_version: Version,
        ledger_info_with_sigs: &Option<LedgerInfoWithSignatures>,
    ) -> Result<()>  ;
 
     /// This backs the `UpdateToLatestLedger` public read API which returns the latest
    /// [`LedgerInfoWithSignatures`] together with items requested and proofs relative to the same
    /// ledger info.
    pub fn update_to_latest_ledger(
        &self,
        _client_known_version: u64,
        request_items: Vec<RequestItem>,
    ) -> Result<(
        Vec<ResponseItem>,
        LedgerInfoWithSignatures,
        Vec<ValidatorChangeEventWithProof>,
    )> 

     /// Gets an account state by account address, out of the ledger state indicated by the state
    /// Merkle tree root hash.
    ///
    /// This is used by the executor module internally.
    pub fn get_account_state_with_proof_by_state_root(
        &self,
        address: AccountAddress,
        state_root: HashValue,
    ) -> Result<(Option<AccountStateBlob>, SparseMerkleProof)>;

       /// Gets information needed from storage during the startup of the executor module.
    ///
    /// This is used by the executor module internally.
    pub fn get_executor_startup_info(&self) -> Result<Option<ExecutorStartupInfo>>;

       /// Gets a batch of transactions for the purpose of synchronizing state to another node.
    ///
    /// This is used by the State Synchronizer module internally.
    pub fn get_transactions(
        &self,
        start_version: Version,
        limit: u64,
        ledger_version: Version,
        fetch_events: bool,
    ) -> Result<TransactionListWithProof>;
```

`LibraDB`只提供了有限的几个公共函数,

### save_transactions

这是共识模块达成共识以后,生成了新的block,需要将这些Tx存储到账本中.
从参数中可以看出他既包含了Tx也包含了这些Tx的相关证明(Validator的签名).

### get_account_state_with_proof_by_state_root

用来查询账户在指定Merkle树下的状态.

### get_executor_startup_info

这个是`executor`内部使用.

### get_transactions

这个是`Synchronizer`内部使用

### update_to_latest_ledger

这个函数式我们重点分析的对象.
```
/// This backs the `UpdateToLatestLedger` public read API which returns the latest
    /// [`LedgerInfoWithSignatures`] together with items requested and proofs relative to the same
    /// ledger info.
    pub fn update_to_latest_ledger(
        &self,
        _client_known_version: u64,
        request_items: Vec<RequestItem>,
    ) -> Result<(
        Vec<ResponseItem>,
        LedgerInfoWithSignatures,
        Vec<ValidatorChangeEventWithProof>,
    )> {
       ...
        // Fulfill all request items
        let response_items = request_items
            .into_iter()
            .map(|request_item| match request_item {
                RequestItem::GetAccountState { address } => Ok(ResponseItem::GetAccountState {
                   ... //处理GetAccountState请求  query balance|sequence|account_state等命令 
                }),
                RequestItem::GetAccountTransactionBySequenceNumber {
                    account,
                    sequence_number,
                    fetch_events,
                } => {
                   ... //处理GetAccountTransactionBySequenceNumber请求 query txn_acc_seq命令
                }

                RequestItem::GetEventsByEventAccessPath {
                    access_path,
                    start_event_seq_num,
                    ascending,
                    limit,
                } => {
                   ... //query event
                }
                RequestItem::GetTransactions {
                    start_version,
                    limit,
                    fetch_events,
                } => {
                   //query txn_range命令
                }
            })
            .collect::<Result<Vec<_>>>()?;
            ...
    }
```

这里针对用户的请求,分成四类分别处理. 实际上这正是RequestItem的定义.

```
pub enum RequestItem {
    GetAccountTransactionBySequenceNumber {
        account: AccountAddress,
        sequence_number: u64,
        fetch_events: bool,
    },
    // this can't be the first variant, tracked here https://github.com/AltSysrq/proptest/issues/141
    GetAccountState {
        address: AccountAddress,
    },
    GetEventsByEventAccessPath {
        access_path: AccessPath,
        start_event_seq_num: u64,
        ascending: bool,
        limit: u64,
    },
    GetTransactions {
        start_version: Version,  
        limit: u64,
        fetch_events: bool,
    },
}
```

## AccountState请求是如何处理的

```
fn get_account_state_with_proof(
        &self,
        address: AccountAddress,
        version: Version,
        ledger_version: Version,
    ) -> Result<AccountStateWithProof> 
```

该请求的处理,调用的是LibraDB的get_account_state_with_proof

1.调用get_latest_version读取数据库,或者最新的latest_version
2.验证传递进来的ledger_version必须小于等于latest_version
3.调用LedgerStore的get_transaction_info_with_proof获取指定Version的`txn_info`和`txn_info_accumulator_proof`
4.调用StateStore.get_account_state_with_proof_by_state_root获取指定地址的`account_state_blob`和`sparse_merkle_proof`
5.组装返回结果

走到这里我们终于把client命令和数据库之间的关联起来了. 至于如何读取数据库的内容,请参考[3.Libra中数据存储的Schema一文](http://stevenbai.top/libra%E7%B3%BB%E5%88%97/3.libra%E4%B8%AD%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E7%9A%84schema/)

## 结束语

整个文章分文两部分,一个是grpc的client实现,一个是grpc服务端实现, 整体框架还是非常清晰的. Libra作为一个联盟链,其数据结构设计尤其独特之处,整个过程我没有看到任何Block相关字样,都是围绕着Tx展开,这应该是他为了提高TPS所做的优化吧. 虽然Libra称之为BlockChain,但是这里面既没有Block也没有Chain,实际上是一个基于稀疏默克尔树的大状态机.
