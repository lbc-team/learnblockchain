---
title: Libra 源码分析：Libra 的准入控制(AC)模块
permalink: AC-module
date: 2019-07-02 10:23:48
categories: Libra
tags: 
    - Libra源码分析
author: 白振轩
---

根据Libra的架构图，准入控制模块（AC：admission control，本文中简称AC模块）是位于验证器（Validator）与普通用户交互的入口。

<!-- more -->

## 准入控制 
参考 [Libra文档-交易的生命周期](https://learnblockchain.cn/docs/libra/docs/life-of-a-transaction/) ，准入控制模块是验证器的唯一外部接口。 客户端向验证器发出的任何请求都会先转到AC，如图：

![Libra准入控制](https://learnblockchain.cn/docs/libra/docs/assets/illustrations/validator-sequence.svg)

因此AC基本上就干了两件事，提供了两个接口.一个是`SubmitTransaction`，另一个`是UpdateToLatestLedger`.

主要代码位于`admission_control_service\admission_control_service.rs` 这个是对`admission_control.proto`的`service AdmissionControl`的实现。

## SubmitTransaction

这个模块主要是接受来自普通用户的Tx，如果合理有效则提交给MemPool模块，最终会进入到block中。
工作流程:

1. 校验Tx，包括三个部分一个是签名是否有效，另一个则是gas是否有效，第三个则是执行Tx中的code是否能够通过。
2. 校验账户余额是否足够，然后通过grpc链接发送给mempool模块
3. 将mempool结果返回给用户

需要说明的是[Libra官方文档](https://learnblockchain.cn/docs/libra/docs/crates/admission-control/)与代码并不完全相符，实际上校验Tx都是在`VMValidator1`中进行的。 相关代码都不在AC模块

### 相关代码简单分析

```rust
/// Validate transaction signature, then via VM, and add it to Mempool if it passes VM check.
    /// 流程非常简单
    /// 1. 交由本地validator验证Tx执行能否通过,如果不通过报错,否则继续2
    /// 2. 获取账户最新状态,组装`AddTransactionWithValidationRequest`
    /// 3. 调用mempool grpc接口,添加Tx到mempool中
    pub(crate) fn submit_transaction_inner(
        &self,
        req: SubmitTransactionRequest,
    ) -> Result<SubmitTransactionResponse> {
        // 就是校验mempool服务是否正常
        if !self.can_send_txn_to_mempool()? {
            debug!("Mempool is full");
            OP_COUNTERS.inc_by("submit_txn.rejected.mempool_full", 1);
            let mut response = SubmitTransactionResponse::new();
            response.set_mempool_status(MempoolIsFull);
            return Ok(response);
        }

        let signed_txn_proto = req.get_signed_txn();
        //利用`FromProto`这个trait将grpc 类型转换为内部类型.
        let signed_txn = match SignedTransaction::from_proto(signed_txn_proto.clone()) {
            Ok(t) => t,
            Err(e) => {
                security_log(SecurityEvent::InvalidTransactionAC)
                    .error(&e)
                    .data(&signed_txn_proto)
                    .log();
                let mut response = SubmitTransactionResponse::new();
                response.set_ac_status(AdmissionControlStatus::Rejected);
                OP_COUNTERS.inc_by("submit_txn.rejected.invalid_txn", 1);
                return Ok(response);
            }
        };
        //交由vm_validator校验Tx是否合法.实际对应的是`VMValidator`这个struct
        //签名校验是否有效实际上是在vm_validator中.
        let gas_cost = signed_txn.max_gas_amount();
        let validation_status = self
            .vm_validator
            .validate_transaction(signed_txn.clone())
            .wait()
            .map_err(|e| {
                security_log(SecurityEvent::InvalidTransactionAC)
                    .error(&e)
                    .data(&signed_txn)
                    .log();
                e
            })?; //Validator验证Tx是否有效,注意该调用也是一个grpc调用,因此走的是异步,wait模式
        if let Some(validation_status) = validation_status {
            let mut response = SubmitTransactionResponse::new();
            OP_COUNTERS.inc_by("submit_txn.vm_validation.failure", 1);
            debug!(
                "txn failed in vm validation, status: {:?}, txn: {:?}",
                validation_status, signed_txn
            );
            response.set_vm_status(validation_status.into_proto());
            return Ok(response);
        }
        let sender = signed_txn.sender();
        let account_state = block_on(get_account_state(self.storage_read_client.clone(), sender));
        let mut add_transaction_request = AddTransactionWithValidationRequest::new();
        add_transaction_request.signed_txn = req.signed_txn.clone();
        add_transaction_request.set_max_gas_cost(gas_cost);

        if let Ok((sequence_number, balance)) = account_state {
            add_transaction_request.set_account_balance(balance);
            add_transaction_request.set_latest_sequence_number(sequence_number);
        }
        //这个函数非常简单,就是调用mempool的grpc接口`add_transaction_with_validation` 来试图添加一个Tx到mempool中去
        self.add_txn_to_mempool(add_transaction_request)
    }
```

## UpdateToLatestLedger

AC的另一个功能就是提供查询功能，这个包括账户状态，交易，ContractEvent等的查询。 这实际上可以看做libra所有对外能够提供的服务了。

### 请求参数

主要有四类请求，深刻理解了这四类请求的所有数据结构，基本上就掌握了如何使用libra了。

```rust
#[derive(Arbitrary, Clone, Debug, Eq, PartialEq)]
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

从这些请求里面没有看到任何block相关字样，这也说明了libra有意弱化block概念，直接针对的是transaction。

### 返回结果

请求和返回都位于types/src/get_with_proof.rs， types/src目录下就是系统的核心数据结构所在。
如果能够把这里面的数据结构都理解透了，理解整个libra不在话下啊。

```
#[allow(clippy::large_enum_variant)]
#[derive(Arbitrary, Clone, Debug, Eq, PartialEq)]

pub enum ResponseItem {
    GetAccountTransactionBySequenceNumber {
        signed_transaction_with_proof: Option<SignedTransactionWithProof>,
        proof_of_current_sequence_number: Option<AccountStateWithProof>,
    },
    // this can't be the first variant, tracked here https://github.com/AltSysrq/proptest/issues/141
    GetAccountState {
        account_state_with_proof: AccountStateWithProof,
    },
    GetEventsByEventAccessPath {
        events_with_proof: Vec<EventWithProof>,
        proof_of_latest_event: Option<AccountStateWithProof>,
    },
    GetTransactions {
        txn_list_with_proof: TransactionListWithProof,
    },
}
```

### 具体实现

实现非常简单，实际上就是一个请求转达，是直接调用的storage模块的grpc服务，所以阅读storage模块相关文章即可，参考：[打通Libra CLI客户端与libradb模块](https://learnblockchain.cn/2019/07/01/Proficient-client-and-libradb-modules/), [Libra 中数据存储的 Schema](https://learnblockchain.cn/2019/06/30/Schema-for-data-storage-in-Libra)。

```rust
   /// Pass the UpdateToLatestLedgerRequest to Storage for read query.
    fn update_to_latest_ledger_inner(
        &self,
        req: UpdateToLatestLedgerRequest,
    ) -> Result<UpdateToLatestLedgerResponse> {
        let rust_req = types::get_with_proof::UpdateToLatestLedgerRequest::from_proto(req)?;
        let (response_items, ledger_info_with_sigs, validator_change_events) = self
            .storage_read_client
            .update_to_latest_ledger(rust_req.client_known_version, rust_req.requested_items)?;
        let rust_resp = types::get_with_proof::UpdateToLatestLedgerResponse::new(
            response_items,
            ledger_info_with_sigs,
            validator_change_events,
        ); //直接读取本地数据库,注意这个接口是查询而不是更新
        Ok(rust_resp.into_proto())
    }
```

## 启动流程

AC模块是一个独立的grpc服务，也是一个独立的可执行程序。
入口处位于`main.rs`。
这里简单分析一下启动流程

### main.rs

```rust
/// Run a Admission Control service in its own process.
/// It will also setup global logger and initialize config.
fn main() {
    let (config, _logger, _args) = setup_executable(
        "Libra AdmissionControl node".to_string(),
        vec![ARG_PEER_ID, ARG_CONFIG_PATH, ARG_DISABLE_LOGGING],
    );

    let admission_control_node = admission_control_node::AdmissionControlNode::new(config);

    admission_control_node
        .run()
        .expect("Unable to run AdmissionControl node");
}
```

首先核心是使用`setup_executable`来解析参数，获取系统配置以及日志。 这个函数做整个libra所有的服务中都是这么使用的。

### AdmissionControlNode

第二步则是创建`AdmissionControlNode`

```rust
/// Struct to run Admission Control service in a dedicated process. It will be used to spin up
/// extra AC instances to talk to the same validator.
pub struct AdmissionControlNode {
    /// Config used to setup environment for this Admission Control service instance.
    node_config: NodeConfig,
}
```

从定义中无法直接看出依赖，在run函数中可以看出启动过程。

```rust
/// Setup environment and start a new Admission Control service.
    pub fn run(&self) -> Result<()> {
        logger::set_global_log_collector(
            self.node_config
                .log_collector
                .get_log_collector_type()
                .unwrap(),
            self.node_config.log_collector.is_async,
            self.node_config.log_collector.chan_size,
        );
        info!("Starting AdmissionControl node",);
        // Start receiving requests
        let client_env = Arc::new(EnvBuilder::new().name_prefix("grpc-ac-mem-").build());
        let mempool_connection_str = format!(
            "{}:{}",
            self.node_config.mempool.address, self.node_config.mempool.mempool_service_port
        );
        let mempool_channel =
            ChannelBuilder::new(client_env.clone()).connect(&mempool_connection_str);

        self.run_with_clients(
            client_env.clone(),
            //依赖两个服务,一个是mempool服务
            Arc::new(MempoolClient::new(mempool_channel)),
            //另一个是storage服务,正如我们上面的分析
            Some(Arc::new(StorageReadServiceClient::new(
                Arc::clone(&client_env),
                &self.node_config.storage.address,
                self.node_config.storage.port,
            ))),
        )
    }
```

实际上在`run_with_clients`中还创建了vm_validator，只不过这个不是独立的服务罢了。
通过`run_with_clients`我们也可以学习构建grpc服务的流程。

```rust
/// This method will start a node using the provided clients to external services.
    /// For now, mempool is a mandatory argument, and storage is Option. If it doesn't exist,
    /// it'll be generated before starting the node.
    pub fn run_with_clients<M: MempoolClientTrait + 'static>(
        /*
        若是有where T：'static 的约束，意思则是，类型T⾥⾯不包含任何指向短⽣命周期的借⽤指针，
        意思是要么完全不包含任何借⽤，要么可以有指向'static的借⽤指针。
        */
        &self,
        env: Arc<Environment>,
        mp_client: Arc<M>,
        storage_client: Option<Arc<StorageReadServiceClient>>, /* storage_client是和后端的storage服务进行通信
                                                               libra实现的各个服务之间都是通过grpc服务交互*/
    ) -> Result<()> {
        // create storage client if doesn't exist
        let storage_client: Arc<dyn StorageRead> = match storage_client {
            Some(c) => c,
            None => Arc::new(StorageReadServiceClient::new(
                env,
                &self.node_config.storage.address,
                self.node_config.storage.port,
            )),
        };

        let vm_validator = Arc::new(VMValidator::new(&self.node_config, storage_client.clone()));

        let handle = AdmissionControlService::new(
            mp_client,
            storage_client,
            vm_validator,
            self.node_config
                .admission_control
                .need_to_check_mempool_before_validation,
        );
        let service = admission_control_grpc::create_admission_control(handle);

        let _ac_service_handle = spawn_service_thread(
            service,
            self.node_config.admission_control.address.clone(),
            self.node_config
                .admission_control
                .admission_control_service_port,
            "admission_control",
        );
        //这个debug服务与我们说的上述内容无关,纯粹是为了调试需要.
        // Start Debug interface
        let debug_service =
            node_debug_interface_grpc::create_node_debug_interface(NodeDebugService::new());
        let _debug_handle = spawn_service_thread(
            debug_service,
            self.node_config.admission_control.address.clone(),
            self.node_config
                .debug_interface
                .admission_control_node_debug_port,
            "debug_service",
        );

        info!(
            "Started AdmissionControl node on port {}",
            self.node_config
                .admission_control
                .admission_control_service_port
        );

        loop {
            thread::park();
        }
    } 
```


本文作者为深入浅出共建者：白振轩，欢迎大家关注他的[博客](http://stevenbai.top) 。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。