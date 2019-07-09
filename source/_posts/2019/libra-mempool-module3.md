---
title: Libra 源码分析：内存池mempool模块解读-3
permalink: libra-mempool-module3
date: 2019-07-05 08:23:48
categories: Libra
tags: 
    - Libra源码分析
    - mempool
author: 白振轩
---

内存池mempool模块解读第三篇，这部分我主要研究mempool中的节点间Tx同步. 关键代码都位于`shared_mempool.rs`中.

<!-- more -->

## 1. 启动过程

先从mempool的启动过程说起,这里可以把前面两部分内容串联起来.
启动代码位于`runtime.rs`中,

```rust
/// Handle for Mempool Runtime
pub struct MempoolRuntime { 
    /// gRPC server to serve request from AC and Consensus
    pub grpc_server: ServerHandle, //这个是对外提供grpc服务接口
    /// separate shared mempool runtime
    pub shared_mempool: Runtime, //这是因为内部使用了tokio的异步编程框架.
}

impl MempoolRuntime {
    /// setup Mempool runtime
    pub fn bootstrap(
        config: &NodeConfig,
        network_sender: MempoolNetworkSender,
        network_events: MempoolNetworkEvents,
    ) -> Self {
        //访问是加锁的
        //这个mempool就是前两部分我们重点讨论的内部缓冲池管理.
        let mempool = Arc::new(Mutex::new(CoreMempool::new(&config)));

        // setup grpc server
        let env = Arc::new(
            EnvBuilder::new()
                .name_prefix("grpc-mempool-")
                .cq_count(unsafe { max(grpcio_sys::gpr_cpu_num_cores() as usize / 2, 2) })
                .build(),
        );
        let handle = MempoolService {
            core_mempool: Arc::clone(&mempool),
        };
        //对外提供grpc服务的接口,是对自动生成的proto中描述的serice的实现
        let service = mempool_grpc::create_mempool(handle);
        let grpc_server = ::grpcio::ServerBuilder::new(env)
            .register_service(service)
            .bind(
                config.mempool.address.clone(),
                config.mempool.mempool_service_port,
            ) //监听的端口和ip
            .build()
            .expect("[mempool] unable to create grpc server");

        // mempool要访问DB,注意也是通过grpc接口进行访问,没有直接访问DB
        let storage_client: Arc<dyn StorageRead> = Arc::new(StorageReadServiceClient::new(
            Arc::new(EnvBuilder::new().name_prefix("grpc-mem-sto-").build()),
            "localhost",
            config.storage.port,
        ));
        //验证Tx合法性的工具,
        let vm_validator = Arc::new(VMValidator::new(&config, Arc::clone(&storage_client)));
        //这是我们这篇文章的核心,如何与其他节点之间进行通信全都发生在SharedMempool
        //这里实际上就返回了一个Runtime,这时候tokio的调度器已经启动完成
        let shared_mempool = start_shared_mempool(
            config,
            mempool,
            network_sender,
            network_events,
            storage_client,
            vm_validator,
            vec![],
            None,
        );
        Self {
            grpc_server: ServerHandle::setup(grpc_server),
            shared_mempool,
        }
    }
}
```

### 1.1 start_shared_mempool

```rust
/// bootstrap of SharedMempool
/// creates separate Tokio Runtime that runs following routines:
///   - outbound_sync_task (task that periodically broadcasts transactions to peers)
///   - inbound_network_task (task that handles inbound mempool messages and network events)
///   - gc_task (task that performs GC of all expired transactions by SystemTTL)
pub(crate) fn start_shared_mempool<V>(
    config: &NodeConfig,
    mempool: Arc<Mutex<CoreMempool>>,
    network_sender: MempoolNetworkSender, //向外他推送新发现的Tx的Channel
    network_events: MempoolNetworkEvents, //接受来自其他节点的Mempool事件的Channel
    storage_read_client: Arc<dyn StorageRead>,
    validator: Arc<V>,
    subscribers: Vec<UnboundedSender<SharedMempoolNotification>>,//这个是通知其他模块mempool发生了什么他们感兴趣的事
    timer: Option<IntervalStream>,
) -> Runtime
where
    V: TransactionValidation + 'static,
{
    //因为tokio的宏if_runtime,所以无法识别
    let runtime: tokio::runtime::Runtime = Builder::new()
        .name_prefix("shared-mem-")
        .build()
        .expect("[shared mempool] failed to create runtime");
        //获取tokio的Executor,这样后续就可以启动task了.
    let executor: tokio::runtime::TaskExecutor = runtime.executor();

    let peer_info = Arc::new(Mutex::new(PeerInfo::new()));

    let smp = SharedMempool {
        mempool: mempool.clone(),
        config: config.mempool.clone(),
        network_sender,
        storage_read_client,
        validator,
        peer_info,
        subscribers,
    };

    let interval =
        timer.unwrap_or_else(|| default_timer(config.mempool.shared_mempool_tick_interval_ms));
    //在线程池中执行? actor模型?
    executor.spawn(
        outbound_sync_task(smp.clone(), interval)
            .boxed()
            .unit_error()
            .compat(),
    );
    //在线程池中执行?
    executor.spawn(
        inbound_network_task(smp, network_events)
            .boxed()
            .unit_error()
            .compat(),
    );
    //在线程池中执行?
    executor.spawn(
        gc_task(mempool, config.mempool.system_transaction_gc_interval_ms)
            .boxed()
            .unit_error()
            .compat(),
    );

    runtime
}
```

## SharedMempool中的各个子任务

在`start_shared_mempool`中看到有三个关键地方,分别是:

1. `network_sender`是向外推送Tx的通道
2. `network_events` 接受其他节点Tx以及状态变化等信息的通道
3. `subscribers` 通知其他模块mempool发生了什么他们感兴趣的事

这三个都是future这个crate中的channel,这里的channel和golang中的chan是基本上等价的.简化起见,直接看成通信通道就ok了.

### 接受来自底层Network模块的信息推送

主要有三种消息:

1. NewPeer有新的Peer上线
2. LostPeer Peer下线
3. Message 主要是就是其他节点推送来的新的Tx

```rust
/// This task handles inbound network events.
/// This task handles inbound network events.
async fn inbound_network_task(smp: SharedMempool, network_events: MempoolNetworkEvents)
where
V: TransactionValidation,
{
let peer_info = smp.peer_info.clone();
let subscribers = smp.subscribers.clone();
let max_inbound_syncs = smp.config.shared_mempool_max_concurrent_inbound_syncs;

// Handle the NewPeer/LostPeer events immediatedly, since they are not async
// and we don't want to buffer them or let them get reordered. The inbound
// direct-send messages are placed in a bounded FuturesUnordered queue and
// allowed to execute concurrently. The .buffer_unordered() also correctly
// handles back-pressure, so if mempool is slow the back-pressure will
// propagate down to network.
let f_inbound_network_task = network_events
```

```rust
//filter & map,有必要filter么?
.filter_map(move |network_event| {
    trace!("SharedMempoolEvent::NetworkEvent::{:?}", network_event);
    match network_event {
        Ok(network_event) => match network_event {
            Event::NewPeer(peer_id) => {
                OP_COUNTERS.inc("smp.event.new_peer");
                new_peer(&peer_info, peer_id); //记录新发现了节点,用于后续推送Tx给他
                notify_subscribers(
                    SharedMempoolNotification::PeerStateChange,
                    &subscribers,
                ); //同时以PeerStateChange告诉相关订阅方
                future::ready(None) //会被过滤掉,这样就不会包含在下面的for_each_concurrent中
            }
            Event::LostPeer(peer_id) => {
                //节点下线,就不要继续推送Tx了
                OP_COUNTERS.inc("smp.event.lost_peer");
                lost_peer(&peer_info, peer_id);
                notify_subscribers(
                    SharedMempoolNotification::PeerStateChange,
                    &subscribers,
                ); //同时以PeerStateChange告诉相关订阅方
                future::ready(None)
            }
            // Pass through messages to next combinator
            // 收到了来自其他节点的Tx,这个是后续`for_each_concurrent`
            Event::Message((peer_id, msg)) => future::ready(Some((peer_id, msg))),
            _ => {
                //RpcRequest消息不应该传递到这里
                security_log(SecurityEvent::InvalidNetworkEventMP)
                    .error("UnexpectedNetworkEvent")
                    .data(&network_event)
                    .log();
                unreachable!("Unexpected network event")
            }
        },
        Err(e) => {
            security_log(SecurityEvent::InvalidNetworkEventMP)
                .error(&e)
                .log();
            future::ready(None)
        }
    }
})
// Run max_inbound_syncs number of `process_incoming_transactions` concurrently
.for_each_concurrent(
    //处理收到其他节点推送过来的Tx,具体机制有赖于底层network模块
    max_inbound_syncs, /* limit */
    move |(peer_id, mut msg)| {
        //todo 这块逻辑很复杂,还是要研究一下
        OP_COUNTERS.inc("smp.event.message");
        let transactions: Vec<_> = msg
            .take_transactions()
            .into_iter() //这里实际上是一个简单的将grpc Message简单转换成内部的SignedTransaction的过程
            .filter_map(|txn| match SignedTransaction::from_proto(txn) {
                Ok(t) => Some(t),
                Err(e) => {
                    security_log(SecurityEvent::InvalidTransactionMP)
                        .error(&e)
                        .data(&msg)
                        .log();
                    None
                }
            })
            .collect();
        OP_COUNTERS.inc_by(
            &format!("smp.transactions.received.{:?}", peer_id),
            transactions.len(),
        );
        //验证Tx有效性,然后添加到自己的缓冲池中,添加过程调用的是`add_txn`,
        // 和处理来自AC的Tx是一样的逻辑
        process_incoming_transactions(smp.clone(), peer_id, transactions)
    },
);
```

```rust
// drive the inbound futures to completion
f_inbound_network_task.await; //永远不结束

crit!("SharedMempool inbound_network_task terminated");
}
```

上面这段代码很长,有接近100行,但是如果仔细分析的话基本上就是一句代码,不过这一条语句很复杂,占用了从16行到84行基本上70行.
我不知道该说这是rust语言的表达能力强还是该诟病rust阅读体验极糟.

还有一个需要说明就是这里async和await搭配使用. 因为函数的声明中使用了async关键字,因此实际上函数的返回值会是一个Future.
还有就是第94行的`f_inbound_network_task.await`并不是一个死循环,你可以把他想象成一个goroutine,当`network_events`这个channel读不出来数据的时候他会放弃CPU占用. 实际上这也是tokio这个框架在做的事.

#### 2.1.1 process_incoming_transactions

这个函数值得一说到就是他添加Tx到缓冲池中的方式是`TimelineState::NonQualified`,这意味着这种Tx不会再被广播给其他节点.
好处当然是极大的降低了数据传输量. 这种方式在以太坊中肯定是不会采用的,因为这很不利于Tx的快速广播.
当然Libra采用这种方式有他的道理,他是联盟链,节点数量有限,他采用的假设应该是:
有N个节点的联盟链,这个N个节点彼此之间两两互连,总共有N(N−1)/2个连接.

因为Network模块没有研读,所以只是猜测.

### 向外广播来自AC的Tx

```rust
/// This task handles [`SyncEvent`], which is periodically emitted for us to
/// broadcast ready to go transactions to peers.
async fn outbound_sync_task<V>(smp: SharedMempool<V>, mut interval: IntervalStream)
where
    V: TransactionValidation,
{
    let peer_info = smp.peer_info;
    let mempool = smp.mempool;
    let mut network_sender = smp.network_sender;
    let batch_size = smp.config.shared_mempool_batch_size;
    let subscribers = smp.subscribers;
    //定时死循环,这个执行到await的
    /*
    当代码执⾏到await！ （read_from_network（））⾥⾯的时候，发现异步操作还没有完成，
    它会直接退出当前这个函数，把CPU让给其他任务执⾏。当这个数据从⽹络上 传输完成了，调度器会再次调⽤这个函数，
    它会从上次中断的地⽅恢复执⾏。所以⽤async/await的语法写代码，异步代码的逻辑在源码组织上跟同步代码的逻辑差别
    并不⼤。这⾥⾯状态保存和恢复这些琐碎的事情，都由 编译器帮我们完成了。
    */
    while let Some(sync_event) = interval.next().await {
        trace!("SyncEvent: {:?}", sync_event);
        match sync_event {
            Ok(_) => {
                sync_with_peers(&peer_info, &mempool, &mut network_sender, batch_size).await;
                notify_subscribers(SharedMempoolNotification::Sync, &subscribers);
            }
            Err(e) => {
                error!("Error in outbound_sync_task timer interval: {:?}", e);
                break;
            }
        }
    }

    crit!("SharedMempool outbound_sync_task terminated");
}
```

#### 2.2.1 向外广播Tx

相比之下`sync_with_peers`要复杂一些,但是其功能非常简单,就是针对每个节点推送所有来自自身[AC模块](https://learnblockchain.cn/docs/libra/docs/crates/admission-control/)的Tx.
稍微复杂的一点就是为了避免重复,使用了`timeline_id`这个技术.
前面文章也介绍过,就是一个非常简单的针对每一个Tx都有一个编号,并且这个编号是单增的.这样在向节点A推送的时候只需要记住上次推送到了第35个,那么下次就从第36个开始即可.

```rust
/// sync routine
/// used to periodically broadcast ready to go transactions to peers
async fn sync_with_peers<'a>(
    peer_info: &'a Mutex<PeerInfo>,  //这个peer_info一个所有其他节点的Map
    mempool: &'a Mutex<CoreMempool>, //自己的内存池
    network_sender: &'a mut MempoolNetworkSender, //广播消息的通道
    batch_size: usize,
) {
    // Clone the underlying peer_info map and use this to sync and collect
    // state updates. We do this instead of holding the lock for the whole
    // function since that would hold the lock across await points which is bad.
    let peer_info_copy = peer_info
        .lock()
        .expect("[shared mempool] failed to acquire peer_info lock")
        .deref()
        .clone();

    let mut state_updates = vec![];

    for (peer_id, peer_state) in peer_info_copy.into_iter() {
        if peer_state.is_alive {
            let timeline_id = peer_state.timeline_id; //timeline_id是给来自自身AC模块的Tx一个唯一的单增编号,避免重复推送
                                                      //读取本地的Tx,这些mempool之间的timeline_id都是一样的?
            let (transactions, new_timeline_id) = mempool
                .lock()
                .expect("[shared mempool] failed to acquire mempool lock")
                .read_timeline(timeline_id, batch_size);

            if !transactions.is_empty() {
                OP_COUNTERS.inc_by("smp.sync_with_peers", transactions.len());
                let mut msg = MempoolSyncMsg::new();
                msg.set_peer_id(peer_id.into());
                msg.set_transactions(
                    transactions
                        .into_iter()
                        .map(IntoProto::into_proto)
                        .collect(),
                );

                debug!(
                    "MempoolNetworkSender.send_to peer {} msg {:?}",
                    peer_id, msg
                );
                // Since this is a direct-send, this will only error if the network
                // module has unexpectedly crashed or shutdown.
                network_sender //向指定的`peer_id`推送`transactions`数组
                    .send_to(peer_id, msg)
                    .await
                    .expect("[shared mempool] failed to direct-send mempool sync message");
            }

            state_updates.push((peer_id, new_timeline_id));
        }
    }

    // Lock the shared peer_info and apply state updates.
    let mut peer_info = peer_info
        .lock()
        .expect("[shared mempool] failed to acquire peer_info lock");
    for (peer_id, new_timeline_id) in state_updates {
        peer_info
            .entry(peer_id) //更新相应节点的timeline_id,不要重复推送了
            .and_modify(|t| t.timeline_id = new_timeline_id);
    }
}
```

### 2.3  gc_task 过期交易回收机制

```rust
/// GC all expired transactions by SystemTTL
async fn gc_task(mempool: Arc<Mutex<CoreMempool>>, gc_interval_ms: u64) {
    let mut interval = Interval::new_interval(Duration::from_millis(gc_interval_ms)).compat();
    while let Some(res) = interval.next().await {
        match res {
            Ok(_) => {
                mempool
                    .lock()
                    .expect("[shared mempool] failed to acquire mempool lock")
                    .gc_by_system_ttl();
            }
            Err(e) => {
                error!("Error in gc_task timer interval: {:?}", e);
                break;
            }
        }
    }

    crit!("SharedMempool gc_task terminated");
}
```

从代码来看就非常简单,就是定期调用`gc_by_system_ttl`,这个函数我们前面介绍过,就是避免Tx在缓冲池中呆太久,占用空间,从而导致可以打包的交易进不到缓冲池中.

在以太坊中如果是直接收到的Tx会保存在`transactions.rlp`这个文件中,就算是发生拥堵也不会丢失.
不知道Libra这种设计,如果发生了拥堵,交易丢失了如何解决.
我的一个猜想可能是:

1. libra的client要相信`validator`,他会去`validator`上查询自己账户的`seq_number`.
2. libra中Tx是有过期机制的,一旦过期,client就应该认为交易失败了,如果想要继续,就应该重新发送.

## 3 mempool之间的同步

简化起见,我直接从测试代码中看libra是如何测试多个mempool之间的同步的.相关代码位于`mempool/src/core_mempool/unit_tests/shared_mempool_test.rs`

### 3.1 发现节点之间的链接方式

```rust
#[derive(Default)]
struct SharedMempoolNetwork {
    mempools: HashMap<PeerId, Arc<Mutex<CoreMempool>>>,
    network_reqs_rxs: HashMap<PeerId, channel::Receiver<NetworkRequest>>,
    network_notifs_txs: HashMap<PeerId, channel::Sender<NetworkNotification>>,
    runtimes: HashMap<PeerId, Runtime>,
    subscribers: HashMap<PeerId, UnboundedReceiver<SharedMempoolNotification>>,
    timers: HashMap<PeerId, UnboundedSender<SyncEvent>>,
}

impl SharedMempoolNetwork {
    fn bootstrap_with_config(peers: Vec<PeerId>, mut config: NodeConfig) -> Self {
        let mut smp = Self::default();
        config.mempool.shared_mempool_batch_size = 1;

        for peer in peers {
            let mempool = Arc::new(Mutex::new(CoreMempool::new(&config)));
            //消息是一条通道
            let (network_reqs_tx, network_reqs_rx) = channel::new_test(8);

            //通知是另一条通道
            let (network_notifs_tx, network_notifs_rx) = channel::new_test(8);
            let network_sender = MempoolNetworkSender::new(network_reqs_tx);
            let network_events = MempoolNetworkEvents::new(network_notifs_rx);
            //unbounded是创建没有缓冲区大小限制的channel
            let (sender, subscriber) = unbounded();
            let (timer_sender, timer_receiver) = unbounded();

            let runtime = start_shared_mempool(
                &config,
                Arc::clone(&mempool),
                network_sender, //network_reqs_tx 是我向外发送,其他人接收
                network_events, /* network_notifs_rx
                                 * 是我接受来自别人的event,其他人通过network_notifs_tx发给我 */
                Arc::new(MockStorageReadClient),
                Arc::new(MockVMValidator),
                vec![sender], //向外发布订阅
                Some(
                    timer_receiver
                        .compat()
                        .map_err(|_| format_err!("test"))
                        .boxed(),
                ),
            );

            smp.mempools.insert(peer, mempool);
            smp.network_reqs_rxs.insert(peer, network_reqs_rx);
            smp.network_notifs_txs.insert(peer, network_notifs_tx);
            smp.subscribers.insert(peer, subscriber);
            smp.timers.insert(peer, timer_sender);
            smp.runtimes.insert(peer, runtime);
        }
        smp
    }
```

根据上面的代码,如果我想给peerA发送消息,只需直接向其对应的`network_notifs_rxsender`消息即可.
同样如果我想接收peerA向外广播了哪些Tx,只需从`network_reqs_rx`接收即可.
时尚测试代码正式这么做的.


### 3.2 向指定Peer发送事件

这里测试代码没有覆盖到广播Tx这种情形.
这个情形在`deliver_message`中被覆盖到.

```rust
//send_event,都是发送的NewPeer或者LostPeer事件,是peer向外发送说自己发现了NewPeer(xx)
    fn send_event(&mut self, peer: &PeerId, notif: NetworkNotification) {
        let network_notifs_tx = self.network_notifs_txs.get_mut(peer).unwrap();
        /*
        block_on与async,await的区别
        1. block_on在普通函数中使用,await只能在标有async的函数中使用
        2. block_on会真实的堵塞所在线程,而await只会堵塞所在task,actor可以调度其他任务来运行
        */
        block_on(network_notifs_tx.send(notif)).unwrap();
        //通过peer关联的network_notifs_tx发出去,peer就会收到,然后产生动作,
        // 就是向订阅方提供peerStateChange通知
        self.wait_for_event(peer, SharedMempoolNotification::PeerStateChange);
    }

```

### 3.3 接收Peer广播出来的Tx

```rust
/// deliveres next message from given node to it's peer
    /// 这个函数实际上是触发peer向外推送自己缓冲池中的Tx,然后通过`network_reqs_rx`接受推送
    /// 验证推送内容是否符合预期
    fn deliver_message(&mut self, peer: &PeerId) -> (SignedTransaction, PeerId) {
        // emulate timer tick,`struct SharedMempool<V>`会向外推送自己的Tx
        self.timers
            .get(peer)
            .unwrap()
            .unbounded_send(SyncEvent)
            .unwrap();

        // await next message from node
        let network_reqs_rx = self.network_reqs_rxs.get_mut(peer).unwrap();
        let network_req = block_on(network_reqs_rx.next()).unwrap();

        match network_req {
            NetworkRequest::SendMessage(peer_id, msg) => {
                let mut sync_msg: MempoolSyncMsg =
                    ::protobuf::parse_from_bytes(msg.mdata.as_ref()).unwrap();
                let transaction: SignedTransaction =
                    SignedTransaction::from_proto(sync_msg.take_transactions().pop().unwrap())
                        .unwrap();
                // send it to peer,手工转发给相应的接收方
                let receiver_network_notif_tx: &mut channel::Sender<NetworkNotification> =
                    self.network_notifs_txs.get_mut(&peer_id).unwrap();
                block_on(
                    receiver_network_notif_tx.send(NetworkNotification::RecvMessage(*peer, msg)),
                )
                .unwrap(); //测试代码可以简化,直接等待发送完毕.
                           // 我的理解是在async函数中可以使用await,普通函数中等待只能block_on,
                           // 而这个会真的阻塞线程.

                // await message delivery
                self.wait_for_event(&peer_id, SharedMempoolNotification::NewTransactions); //peer_id这个接收方收到Tx后会向订阅方发布`NewTransactions`事件

                // verify transaction was inserted into Mempool
                let mempool = self.mempools.get(&peer).unwrap();
                let block = mempool.lock().unwrap().get_block(100, HashSet::new());
                //确保这个广播出去的Tx会被打包,也就是不会广播自己认为无效的Tx,自己认为seq不连续的tx
                assert!(block.iter().any(|t| t == &transaction)); //SignedTransaction实现了eq
                (transaction, peer_id)
            }
            _ => panic!("peer {:?} didn't broadcast transaction", peer),
        }
    }
}
```

#### 3.3.1 一个基本测试case

```rust
#[test]
fn test_basic_flow() {
    let (peer_a, peer_b) = (PeerId::random(), PeerId::random());
    //建立起每个节点的通信Channel
    let mut smp = SharedMempoolNetwork::bootstrap(vec![peer_a, peer_b]);
    // peer_a 主动添加了三笔连续交易
    smp.add_txns(
        &peer_a,
        vec![
            TestTransaction::new(1, 0, 1),
            TestTransaction::new(1, 1, 1),
            TestTransaction::new(1, 2, 1),
        ],
    );

    // A discovers new peer B
    smp.send_event(&peer_a, NetworkNotification::NewPeer(peer_b));

    for seq in 0..3 {
        // A attempts to send message,因为指定的
        let transaction = smp.deliver_message(&peer_a).0;
        assert_eq!(transaction.sequence_number(), seq);
    }
}
```

## 结束语

从整体来说Libra的mempool和以太坊相比,简单了很多,我觉得有两个原因:

1. 本身是一个联盟链,对于节点的工作环境可以有更高的要求.同时不会发生分叉.
2. Tx引入了超时概念,可以大幅简化处理逻辑

从整体功能来说,这个模块和其他公链的TxPool模块又是非常相似的,基本上就是收集管理Tx,为共识模块提供可以打包的Tx.

同时我们也看到rust进步神速,目前的tokio异步框架已经非常完善,再加上async,await关键字的加持,编写异步程序已经比较简单直接了.


本文作者为深入浅出共建者：白振轩，[原文地址：libra的mempool模块解读-3](http://stevenbai.top/libra%E7%B3%BB%E5%88%97/8.libra%E7%9A%84mempool%E6%A8%A1%E5%9D%97%E8%A7%A3%E8%AF%BB-3/)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。