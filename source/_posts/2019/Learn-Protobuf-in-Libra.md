---
title: 通过 Libra 学习 Protobuf
permalink: Learn-Protobuf-in-Libra
date: 2019-06-29 10:23:48
categories: Libra
tags: 
    - Libra
    - Protobuf
author: 白振轩
---

Protobuf是一种平台无关、语言无关、可扩展且轻便高效的序列化数据结构的协议，可以用于网络通信和数据存储，本文看看它如果应用在 [Libra](https://learnblockchain.cn/docs/libra/docs/welcome-to-libra/) 中。

> Libra 是Facebook 牵头发布的基于稳定币的区块链项目，大家可以通过社区翻译的[Libra 中文文档](https://learnblockchain.cn/docs/libra/docs/welcome-to-libra/)入门Libra。

<!-- more -->

## 编译安装相关依赖

通过执行`./scripts/dev_setup.sh`是可以自动安装相关依赖以及编译整个libra系统的，参考[Libra环境搭建](https://learnblockchain.cn/docs/libra/docs/my-first-transaction/#克隆并编译-libra-core)。
如果想自己手工安装protobuf相关依赖可以安装如下步骤:

```
cargo install protobuf
cargo install protobuf-codegen
```

* 注意:我当前使用的是v2.6.2

## 找一个文件试试

这是我从libra中抠出来的非源文件，位于transaction.proto 。

```
syntax = "proto3";

package types;
// Account state as a whole.
// After execution, updates to accounts are passed in this form to storage for
// persistence.
message AccountState {
    // Account address
    bytes address = 1;
    // Account state blob
    bytes blob = 2;
}
```

运行下面的命令:

```bash
protoc --rust_out . accountstate.proto 
```

可以看到目录下会多出来一个accountstate.rs
简单看一下生成的AccountState结构体

```rust
#[derive(PartialEq,Clone,Default)]
pub struct AccountState {
    // message fields
    pub address: ::std::vec::Vec<u8>,
    pub blob: ::std::vec::Vec<u8>,
    // special fields
    pub unknown_fields: ::protobuf::UnknownFields,
    pub cached_size: ::protobuf::CachedSize,
}

impl<'a> ::std::default::Default for &'a AccountState {
    fn default() -> &'a AccountState {
        <AccountState as ::protobuf::Message>::default_instance()
    }
}

impl AccountState {
    pub fn new() -> AccountState {
        ::std::default::Default::default()
    }

    // bytes address = 1;


    pub fn get_address(&self) -> &[u8] {
        &self.address
    }
    pub fn clear_address(&mut self) {
        self.address.clear();
    }

    // Param is passed by value, moved
    pub fn set_address(&mut self, v: ::std::vec::Vec<u8>) {
        self.address = v;
    }

    // Mutable pointer to the field.
    // If field is not initialized, it is initialized with default value first.
    pub fn mut_address(&mut self) -> &mut ::std::vec::Vec<u8> {
        &mut self.address
    }

    // Take field
    pub fn take_address(&mut self) -> ::std::vec::Vec<u8> {
        ::std::mem::replace(&mut self.address, ::std::vec::Vec::new())
    }

    // bytes blob = 2;


    pub fn get_blob(&self) -> &[u8] {
        &self.blob
    }
    pub fn clear_blob(&mut self) {
        self.blob.clear();
    }

    // Param is passed by value, moved
    pub fn set_blob(&mut self, v: ::std::vec::Vec<u8>) {
        self.blob = v;
    }

    // Mutable pointer to the field.
    // If field is not initialized, it is initialized with default value first.
    pub fn mut_blob(&mut self) -> &mut ::std::vec::Vec<u8> {
        &mut self.blob
    }

    // Take field
    pub fn take_blob(&mut self) -> ::std::vec::Vec<u8> {
        ::std::mem::replace(&mut self.blob, ::std::vec::Vec::new())
    }
}
```

除了这些，还为AccountState自动生成了protobuf::Message，protobuf::Clear和std::fmt::Debug接口。

* 注意如果是Service的话，一样会自动生成一个_grpc.rs文件，用于服务的实现。

## 利用build.rs自动将proto编译成rs

rust在工程化方面做的非常友好，我们可以编译的过程都可以介入。
也就是如果我们的项目目录下有build.rs，那么在运行 `cargo build` 之前会自动编译然后运行此程序。 相当于在项目目录下运行 `cargo run build.rs` 然后再去build。
这看起来有点类似于go中的`//go:generate command argument...`， 但是要更为强大，更为灵活。

### build.rs

在Libra中包含了proto的子项目都会在项目根目录下包含一个build.rs. 其内容非常简单。

```
fn main() {
    let proto_root = "src/proto";
    let dependent_root = "../../types/src/proto";

    build_helpers::build_helpers::compile_proto(
        proto_root,
        vec![dependent_root],
        false, /* generate_client_code */
    );
}
```

这是storage_proto/build.rs， 主要有两个参数是`proto_root`和`dependent_root`:

1. `proto_root` :表示要自动转换的proto所在目录
2. `dependent_root` :表示编译这些proto文件import所引用的目录，也就是protoc -I参数指定的目录. 当然编译成的rs文件如果要正常工作，那么也必须编译dependent_root中的所有proto文件才行

至于第三个参数`generate_client_code`， 则表示是否生成client代码，也就是如果proto中包含Service，那么是否也生成grpc client的辅助代码。

### 简单解读 build_helper

build_helper 位于`common/build_helper`，是为了辅助自动将proto文件编译成rs文件。

```rust
pub fn compile_proto(proto_root: &str, dependent_roots: Vec<&str>, generate_client_code: bool) {
   let mut additional_includes = vec![];
   for dependent_root in dependent_roots {
       // First compile dependent directories
       compile_dir(
           &dependent_root,
           vec![], /* additional_includes */
           false,  /* generate_client_code */
       );
       additional_includes.push(Path::new(dependent_root).to_path_buf());
   }
   // Now compile this directory
   compile_dir(&proto_root, additional_includes, generate_client_code);
}

// Compile all of the proto files in proto_root directory and use the additional
// includes when compiling.
pub fn compile_dir(
   proto_root: &str,
   additional_includes: Vec<PathBuf>,
   generate_client_code: bool,
) {
   for entry in WalkDir::new(proto_root) {
       let p = entry.unwrap();
       if p.file_type().is_dir() {
           continue;
       }

       let path = p.path();
       if let Some(ext) = path.extension() {
           if ext != "proto" {
               continue;
           }
           println!("cargo:rerun-if-changed={}", path.display());
           compile(&path, &additional_includes, generate_client_code);
       }
   }
}

fn compile(path: &Path, additional_includes: &[PathBuf], generate_client_code: bool) {
   ...
}
```

build.rs 直接调用的就是`compile_proto`这个函数，他非常简单就是先调用`compile_dir`来编译所有的依赖，然后再编译自身.

而compile_dir则是遍历指定的目录，利用`WalkDir`查找当前目录下所有的proto文件，然后逐个调用compile进行编译.

### rust中的字符串处理

```rust
fn compile(path: &Path, additional_includes: &[PathBuf], generate_client_code: bool) {
    let parent = path.parent().unwrap();
    let mut src_path = parent.to_owned().to_path_buf();
    src_path.push("src");

    let mut includes = Vec::from(additional_includes);
    //写成additional_includes.to_owned()也是可以的
    let mut includes = additional_includes.to_owned(); //最终都会调用slice的to_vec
    includes.push(parent.to_path_buf());
    ....
}
```

要跟操作系统打交道，⾸先需要介绍的是两个字符串类型：`OsString` 以及它所对应的字符串切⽚类型`OsStr`。它们存在于std::ffi模块中。

Rust标准的字符串类型是String和str。它们的⼀个重要特点是保证了内部编码是统⼀的utf-8。但是，当我们和具体的操作系统打交道时，统⼀的utf-8编码是不够⽤的，某些操作系统并没有规定⼀定是⽤的utf-8编码。所以，在和操作系统打交道的时候，String/str类型并不是⼀个很好的选择。 ⽐如在Windows系统上，字符⼀般是⽤16位数字来表⽰的。

为了应付这样的情况，Rust在标准库中又设计了OsString/OsStr来处理这样的情况。这两种类型携带的⽅法跟String/str⾮常类似，⽤起来⼏乎没什么区别，它们之间也可以相互转换。

Rust标准库中⽤PathBuf和Path两个类型来处理路径。它们之间的关系就类似String和str之间的关系：⼀个对内部数据有所有权，还有⼀个只是借⽤。实际上，读源码可知，PathBuf⾥⾯存的是⼀个OsString，Path⾥⾯存的是⼀个OsStr。这两个类型定义在std::path模块中。

通过这种方式可以方便的在字符串和Path，PathBuf之间进行任意转换。
在compile_dir的第23行中，我们提供给WalkDir::new一个&str，rust自动将其转换为了Path。

## FromProto和IntoProto

出于跨平台的考虑，proto文件中的数据类型表达能力肯定不如rust丰富，所以不可避免需要在两者之间进行类型转换. 因此Libra中提供了`proto_conv`接口专门用于实现两者之间的转换.

比如:

```
/// Helper to construct and parse [`proto::storage::GetAccountStateWithProofByStateRootRequest`]
///
/// It does so by implementing `IntoProto` and `FromProto`,
/// providing `into_proto` and `from_proto`.
#[derive(PartialEq, Eq, Clone, FromProto, IntoProto)]
#[ProtoType(crate::proto::storage::GetAccountStateWithProofByStateRootRequest)]
pub struct GetAccountStateWithProofByStateRootRequest {
    /// The access path to query with.
    pub address: AccountAddress,

    /// the state root hash the query is based on.
    pub state_root_hash: HashValue,
}
/// Helper to construct and parse [`proto::storage::GetAccountStateWithProofByStateRootResponse`]
///
/// It does so by implementing `IntoProto` and `FromProto`,
/// providing `into_proto` and `from_proto`.
#[derive(PartialEq, Eq, Clone)]
pub struct GetAccountStateWithProofByStateRootResponse {
    /// The account state blob requested.
    pub account_state_blob: Option<AccountStateBlob>,

    /// The state root hash the query is based on.
    pub sparse_merkle_proof: SparseMerkleProof,
}
```

针对`GetAccountStateWithProofByStateRootRequest`可以自动在`crate::proto::storage::GetAccountStateWithProofByStateRootRequest`和`GetAccountStateWithProofByStateRootRequest`之间进行转换，只需要`derive(FromProto,IntoProto)`即可。
而针对`GetAccountStateWithProofByStateRootResponse` 则由于只能手工实现。

```
impl FromProto for GetAccountStateWithProofByStateRootResponse {
    type ProtoType = crate::proto::storage::GetAccountStateWithProofByStateRootResponse;

    fn from_proto(mut object: Self::ProtoType) -> Result<Self> {
        let account_state_blob = if object.has_account_state_blob() {
            Some(AccountStateBlob::from_proto(
                object.take_account_state_blob(),
            )?)
        } else {
            None
        };
        Ok(Self {
            account_state_blob,
            sparse_merkle_proof: SparseMerkleProof::from_proto(object.take_sparse_merkle_proof())?,
        })
    }
}

impl IntoProto for GetAccountStateWithProofByStateRootResponse {
    type ProtoType = crate::proto::storage::GetAccountStateWithProofByStateRootResponse;

    fn into_proto(self) -> Self::ProtoType {
        let mut object = Self::ProtoType::new();

        if let Some(account_state_blob) = self.account_state_blob {
            object.set_account_state_blob(account_state_blob.into_proto());
        }
        object.set_sparse_merkle_proof(self.sparse_merkle_proof.into_proto());
        object
    }
}
```


本文作者为深入浅出共建者：白振轩，欢迎大家关注他的[博客](http://stevenbai.top) 。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。