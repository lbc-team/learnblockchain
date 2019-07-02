---
title: Libra 源码分析：Libra 中数据存储的 Schema
permalink: Schema-for-data-storage-in-Libra
date: 2019-06-30 10:53:48
categories: Libra
tags: 
    - Libra源码分析
    - schemadb
author: 白振轩
---

Libra数据存储使用的RocksDB这个KV数据库.并且[Libra](https://learnblockchain.cn/docs/libra/docs/welcome-to-libra/)存储和以太坊基本上思路是一样的,就是一个MPT树来保存Libra这个超级状态机.

因为RocksDB中除了KV以外,还存在着ColumnFamilyName这一项,这个用起来有点像Bucket.

<!-- more -->

## schemadb

### 数据的读写

```
/// This DB is a schematized RocksDB wrapper where all data passed in and out are typed according to
/// [`Schema`]s.
#[derive(Debug)]
pub struct DB {
    inner: rocksdb::DB,
}
impl DB {
        /// Reads single record by key.
    pub fn get<S: Schema>(&self, schema_key: &S::Key) -> Result<Option<S::Value>> { //从数据库中读取KV
        let k = schema_key.encode_key()?; //用的是哪里的encode_key?如何关联起来的?
        let cf_handle = self.get_cf_handle(S::COLUMN_FAMILY_NAME)?;

        self.inner
            .get_cf(cf_handle, &k)
            .map_err(convert_rocksdb_err)?
            .map(|raw_value| S::Value::decode_value(&raw_value))//用的是哪里的decode_value?如何关联起来的?
            .transpose()
    }

    /// Writes single record.
    pub fn put<S: Schema>(&self, key: &S::Key, value: &S::Value) -> Result<()> { //向数据库中写
        let k = <S::Key as KeyCodec<S>>::encode_key(&key)?;
        let v = <S::Value as ValueCodec<S>>::encode_value(&value)?;
        let cf_handle = self.get_cf_handle(S::COLUMN_FAMILY_NAME)?;

        self.inner
            .put_cf_opt(cf_handle, &k, &v, &default_write_options())
            .map_err(convert_rocksdb_err)
    }
}

```

### 数据的批量写SchemaBatch

为了提供写入的效率,Libra还提供了`SchemaBatch`,用于批量更新数据.

```
pub struct SchemaBatch {
    rows: Vec<(ColumnFamilyName, Vec<u8> /* key */, WriteOp)>,
}
```

一般的用法是：

```
let db = TestDB::new();

    for i in 0..1000 {
        let mut db_batch = SchemaBatch::new();
        db_batch
            .put::<TestSchema1>(&TestField(i), &TestField(i))
            .unwrap();
        db_batch
            .put::<TestSchema2>(&TestField(i), &TestField(i))
            .unwrap();
        db.write_schemas(db_batch).unwrap();//一次性提交到数据库中
    }

    db.flush_all(/* sync = */ true).unwrap();  //刷到硬盘
```

正如我在代码注释中提到的,其实这里的关键问题就是Rust中的数据类型很丰富,但是RocksDB中无论是Key还是Value都只能是字节序列, 因此在存取的时候必然涉及到不断地编码和解码(`KeyCodec`和`ValueCodec`). 如何更方便的实现呢?

### 编码和解码

在Libra中针对KV中的Key和Value两个字段分别设计了编解码接口. Key的编码解码trait是`KeyCodec,Value`的编解码trait则是`ValueCodec`. 下面是接口,具体的实现则可以[参考AccountState](#AccountState的存取过程)的存取过程.

```
/// This trait defines a type that can serve as a [`Schema::Key`].
pub trait KeyCodec<S: Schema + ?Sized>: Sized + PartialEq + Debug {
    /// Converts `self` to bytes to be stored in DB.
    fn encode_key(&self) -> Result<Vec<u8>>;
    /// Converts bytes fetched from DB to `Self`.
    fn decode_key(data: &[u8]) -> Result<Self>;
}

/// This trait defines a type that can serve as a [`Schema::Value`].
pub trait ValueCodec<S: Schema + ?Sized>: Sized + PartialEq + Debug {
    /// Converts `self` to bytes to be stored in DB.
    fn encode_value(&self) -> Result<Vec<u8>>;
    /// Converts bytes fetched from DB to `Self`.
    fn decode_value(data: &[u8]) -> Result<Self>;
}

Rust
```

### 编解码器的使用

为了降低SchemaBatch中put,get,delete这些函数的参数形式的复杂度以及提供COLUMN_FAMILY_NAME,因此提供了`Schema`这个trait.

```
/// This trait defines a schema: an association of a column family name, the key type and the value
/// type.
pub trait Schema {
    /// The column family name associated with this struct.
    /// Note: all schemas within the same SchemaDB must have distinct column family names.
    const COLUMN_FAMILY_NAME: ColumnFamilyName;

    /// Type of the key.
    type Key: KeyCodec<Self>;
    /// Type of the value.
    type Value: ValueCodec<Self>;
}
```

他没有任何成员函数,就是为了提供Key,Value的类型以及COLUMN_FAMILY_NAME. 通过`Schema`在`SchemaBatch`和`DB`中使用`KeyCodec`以及`ValueCodec`就比较方便了.

为了实现方便,还提供了宏`define_schema`

```
#[macro_export]
macro_rules! define_schema {
    ($schema_type: ident, $key_type: ty, $value_type: ty, $cf_name: expr) => {
        pub(crate) struct $schema_type;

        impl $crate::schema::Schema for $schema_type {
            const COLUMN_FAMILY_NAME: $crate::ColumnFamilyName = $cf_name;
            type Key = $key_type;
            type Value = $value_type;
        }
    };
}
```

### 说说`define_schema`这个宏

顺便为了学习宏,这里把这个宏展开一下.

```
//输入:
define_schema!(TestSchema, TestKey, TestValue, "TestCF");

struct TestKey(u32, u32, u32);

struct TestValue(u32);

Rust
```

对应的内容宏展开后就是:

```
impl crate::schema::Schema for TestSchema {
    const COLUMN_FAMILY_NAME: crate::ColumnFamilyName = "TestCF";
    type Key = TestKey;
    type Value = TestValue;
}
```

是不是宏看起来也很简单这里就是为了避免重复写这种可以自动生成的代码,因此提供了宏.
好处是减少了代码的重复,坏处是目前IDE都不能很好识别宏,导致代码跳转都有问题,

## AccountState的存取过程

为了方便学习,这里选取一个真实的例子,看看上面的内容是如何使用的.
```
define_schema!(
    AccountStateSchema,
    HashValue,
    AccountStateBlob,
    ACCOUNT_STATE_CF_NAME
);
//这是对HashValue的编解码,这么写的好处是在put和get中用起来清晰
//但是同一个HashValue在不同的Schema中反复出现,则需要反复实现
//具体可以参考StateMerkleNodeSchema,他里面的Key也是HashValue,
//但是不得不把HashValue的编解码重复了一遍
impl KeyCodec<AccountStateSchema> for HashValue { 
    fn encode_key(&self) -> Result<Vec<u8>> {
        Ok(self.to_vec())
    }

    fn decode_key(data: &[u8]) -> Result<Self> {
        Ok(HashValue::from_slice(data)?)
    }
}

impl ValueCodec<AccountStateSchema> for AccountStateBlob {
    fn encode_value(&self) -> Result<Vec<u8>> {
        Ok(self.clone().into())
    }

    fn decode_value(data: &[u8]) -> Result<Self> {
        Ok(data.to_vec().into())
    }
}
```

以`SchemaBatch`调用过程为例.

1. SchemaBatch.put 放入缓存Vec中
2. >>SchemaBatch.put中调用Key的encode_key,Value的encode_value编码成字节序列
3. DB.write_schemas 写入到磁盘

SchemaBatch put的实现

```
/// Adds an insert/update operation to the batch.
//这的S可以看做是`AccountStateSchema`,S::Key就是KeyCodec<AccountStateSchema>,
//S::Value则是ValueCodec<AccountStateSchema>,注意他们都是trait类型
pub fn put<S: Schema>(&mut self, key: &S::Key, value: &S::Value) -> Result<()> {
    let key = key.encode_key()?;
    let value = value.encode_value()?;
    self.rows
        .push((S::COLUMN_FAMILY_NAME, key, WriteOp::Value(value)));
    Ok(())
}
```

前面通过宏`define_schema`生成的辅助代码`XXSchema`就是为了这里使用,否则参数类型会特别长,并且之间没有强制关联.

## 数据在数据库中存储

主要是依据`storage/libradb/src/schema`中的定义

```
pub(super) const ACCOUNT_STATE_CF_NAME: ColumnFamilyName = "account_state";
pub(super) const EVENT_ACCUMULATOR_CF_NAME: ColumnFamilyName = "event_accumulator";
pub(super) const EVENT_BY_ACCESS_PATH_CF_NAME: ColumnFamilyName = "event_by_access_path";
pub(super) const EVENT_CF_NAME: ColumnFamilyName = "event";
pub(super) const SIGNATURE_CF_NAME: ColumnFamilyName = "signature";
pub(super) const SIGNED_TRANSACTION_CF_NAME: ColumnFamilyName = "signed_transaction";
pub(super) const STATE_MERKLE_NODE_CF_NAME: ColumnFamilyName = "state_merkle_node";
pub(super) const TRANSACTION_ACCUMULATOR_CF_NAME: ColumnFamilyName = "transaction_accumulator";
pub(super) const TRANSACTION_INFO_CF_NAME: ColumnFamilyName = "transaction_info";
pub(super) const VALIDATOR_CF_NAME: ColumnFamilyName = "validator";
```

#### account_state

HashValue=>AccountStateBlob的映射 HashValue应该是账户地址

#### event_accumulator (EventAccumulatorSchema)

(Version,Position)=>HashValue
使用方法见`libradb/src/event_store`中的`put_events`

#### event_by_access_path

(AccessPath, SeqNum)=> (Version, Index)

#### event

(Version, Index)=>ContractEvent

#### signed_transaction

Version=>SignedTransaction

#### state_merkle_node

HashValue=>sparse_merkle::node_type::Node

#### transaction_accumulator

types::proof::position::Position=>HashValue

#### transaction_info

Version=>TransactionInfo

#### validator

(Version,PublicKey)=>()空
这个为什么这样定义呢?

#### ledger_info

Version=>LedgerInfoWithSignatures
注意这个是放在`DEFAULT_CF_NAME`中的

## schema的使用

### state_store

位于storage/libradb/src/state_store:

```
pub(crate) struct StateStore {
    db: Arc<DB>,
}

impl StateStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }

    /// Get the account state blob given account address and root hash of state Merkle tree
    pub fn get_account_state_with_proof_by_state_root(
        &self,
        address: AccountAddress,
        root_hash: HashValue,
    ) -> Result<(Option<AccountStateBlob>, SparseMerkleProof)> {
        let (blob, proof) =
            SparseMerkleTree::new(self).get_with_proof(address.hash(), root_hash)?; //去数据库中读取在指定roothash情况下的这个地址的状态
        debug_assert!(
            verify_sparse_merkle_element(root_hash, address.hash(), &blob, &proof).is_ok(),
            "Invalid proof."
        );
        Ok((blob, proof))
    }

    /// Put the results generated by `keyed_blob_sets` to `batch` and return the result root hashes
    /// for each write set.
    pub fn put_account_state_sets(
        &self,
        account_state_sets: Vec<HashMap<AccountAddress, AccountStateBlob>>,
        root_hash: HashValue,
        batch: &mut SchemaBatch,
    ) -> Result<Vec<HashValue>> {
       ...
    }
}

impl TreeReader for StateStore {
    fn get_node(&self, node_hash: HashValue) -> Result<Node> {
        Ok(self
            .db
            .get::<StateMerkleNodeSchema>(&node_hash)? //使用上面的编解码器进行自动解码
            .ok_or_else(|| format_err!("Failed to find node with hash {:?}", node_hash))?)
    }

    fn get_blob(&self, blob_hash: HashValue) -> Result<AccountStateBlob> {
        Ok(self
            .db
            .get::<AccountStateSchema>(&blob_hash)?//使用上面的编解码器进行自动解码
            .ok_or_else(|| {
                format_err!(
                    "Failed to find account state blob with hash {:?}",
                    blob_hash
                )
            })?)
    }
}
```

尤其是下面的get_node和get_blob就非常清晰的看出来,直接使用了StateMerkleNodeSchema和AccountStateSchema进行decode.

### transaction_store

上一个state_store可能看起来稍显复杂,下面的则更清晰直接.

```
pub(crate) struct TransactionStore {
    db: Arc<DB>,
}

impl TransactionStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }

    /// Get signed transaction given `version`
    pub fn get_transaction(&self, version: Version) -> Result<SignedTransaction> {
        self.db
            .get::<SignedTransactionSchema>(&version)? //get是直接从db读取
            .ok_or_else(|| LibraDbError::NotFound(format!("Txn {}", version)).into())
    }

    /// Save signed transaction at `version`
    pub fn put_transaction(
        &self,
        version: Version,
        signed_transaction: &SignedTransaction,
        batch: &mut SchemaBatch,
    ) -> Result<()> {
        batch.put::<SignedTransactionSchema>(&version, signed_transaction) //put则使用的是batch操作
    }
}
```

### event_store和ledger_store

```
pub(crate) struct EventStore {
    db: Arc<DB>,
}
pub(crate) struct LedgerStore {
    db: Arc<DB>,
}
```

两者稍微复杂一点,这就不一一列举了，但是思路是完全一样的。

本文作者为深入浅出共建者：白振轩，欢迎大家关注他的[博客](http://stevenbai.top) 。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
