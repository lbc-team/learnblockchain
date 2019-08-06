---
title: 开发一款Substrate应用 - 抛硬币游戏(一)
date: 2019-08-06 22:48:34
permalink: substrate-toss
category:
    - 跨链
    - Polkadot
tags: 
    - Substrate
    - Polkadot
author: 孙凯超
---

**当我们应用区块链解决生活中问题的时候，它的价值就产生了。**如果还不清楚Substrate的基本概念，在开始本文的阅读之前，我希望你能大概浏览[Substrate开发者中心的文档](https://substrate.dev)或者参考之前的教程[使用Substrate搭建你的第一条区块链](https://learnblockchain.cn/2019/05/30/create-chain-on-substrate/)来了解Substrate相关的基础知识。本文会从零开始开发一条承载具体业务的区块链应用，即抛硬币游戏。

<!-- more -->

## 预备

1. 快速安装Substrate依赖，详细内容参考开发者中心文档[《Installing Substrate》](https://substrate.dev/docs/en/getting-started/installing-substrate#fast-installation)：
    
    ```bash
    curl https://getsubstrate.io -sSf | bash -s -- --fast
    ```

2. 更新[substrate-up](https://link.zhihu.com/?target=https://github.com/paritytech/substrate-up)脚本，它提供了初始化节点、创建新模块等功能：

    ```bash
    git clone https://github.com/paritytech/substrate-up
    cd substrate-up
    cp -a substrate-* ~/.cargo/bin
    cp -a polkadot-* ~/.cargo/bin
    ```

## 创建区块链节点

Substrate作为一个通用的区块链开发框架，Substrate提供了用于构建区块链的所有组件，**开发者要做的只是将需要的组件组装起来**。为了帮助开发者从繁杂的组装工作中解放出来，Substrate提供了两类的节点程序来快速实现组装工作：

* [模板节点(Template Node)](https://github.com/paritytech/substrate/tree/v1.0/node-template): 包含了所需用到的最少组件，但是依然具备完善的区块链功能。可以在其上快速开发应用，添加新的功能模块。
* [Node](https://link.zhihu.com/?target=https://github.com/paritytech/substrate/tree/v1.0/node): 基本上包含了Substrate提供的所有组件，让你能够测试内置的各种功能。

> 这里所说的**节点**通常也被称为**点对点节点**或者**全节点**，承载了区块链的所有功能，你可以把它想象成传统互联网开发中的后端，但是它不是运行在中心化的服务器上，而是分布式的运行在世界的各个角落里。

本文我们将会用模板节点(Template Node)作为我们的节点程序，承载我们的抛硬币游戏。

### 初始化节点

`substrate-up`脚本提供的初始化节点命令是`substrate-node-new`，通过下载和编译模板节点(Template Node)来生成我们的节点程序。运行下面的命令来生成节点，替换`demo-node`为你自己的节点名，替换`yourname`为你的团队或个人名字：

```bash
substrate-node-new demo-node yourname
```

启动刚刚生成的节点：

```bash
cd demo-node
./target/release/demo-node --dev
```

如果在控制台看到这些内容，证明你的节点创建成功：

```plaintext
2019-07-27 18:03:45 Substrate Node
2019-07-27 18:03:45   version 1.0.0-2857a44-x86_64-macos
2019-07-27 18:03:45   by demo-author, 2017, 2018
2019-07-27 18:03:45 Chain specification: Development
2019-07-27 18:03:45 Node name: safe-tin-6167
2019-07-27 18:03:45 Roles: AUTHORITY
2019-07-27 18:03:45 Initializing Genesis block/state (state: 0x79b0…3c01, header-hash: 0xacb5…bb17)
2019-07-27 18:03:45 Loaded block-time = 10 seconds from genesis on first-launch
2019-07-27 18:03:45 Best block: #0
2019-07-27 18:03:45 Using default protocol ID "sup" because none is configured in the chain specs
2019-07-27 18:03:45 Local node identity is: QmZH4oHKH4nwaP4apeYCM7EJXkxAjv4AqnJt29MrMNhWBV
2019-07-27 18:03:45 Libp2p => Random Kademlia query has yielded empty results
2019-07-27 18:03:46 Listening for new connections on 127.0.0.1:9944.
2019-07-27 18:03:46 Using authority key 5FA9nQDVg267DEd8m1ZypXLBnvN7SFxYwV7ndqSYGiN9TTpu
2019-07-27 18:03:48 Libp2p => Random Kademlia query has yielded empty results
2019-07-27 18:03:49 Accepted a new tcp connection from 127.0.0.1:62636.
2019-07-27 18:03:50 Starting consensus session on top of parent 0xacb55b52944dff23e2aa99326cc20b1f9c091556516d15db9ffcffd7d159bb17
2019-07-27 18:03:50 Prepared block for proposing at 1 [hash: 0x2d84be81477309b475af22c457f850174c498d1b0d19032f18fe7f7656233dad; parent_ha
sh: 0xacb5…bb17; extrinsics: [0xb1d4…9362]]
2019-07-27 18:03:50 Pre-sealed block for proposal at 1\. Hash now 0x1d70dc9d4299519880cc5824cee49ffa0c5a74ec5a9bb238012ae5ff65055302, previ
ously 0x2d84be81477309b475af22c457f850174c498d1b0d19032f18fe7f7656233dad.
2019-07-27 18:03:50 Imported #1 (0x1d70…5302)
2019-07-27 18:03:50 Idle (0 peers), best: #1 (0x1d70…5302), finalized #0 (0xacb5…bb17), ⬇ 0 ⬆ 0
```

以上输出的内容包含了一些有价值的信息如：

* Chain specification: `Development` ，表明我们使用的是内置开发模式的chain spec。
* Node identity: `QmZH4oHKH4nwaP4apeYCM7EJXkxAjv4AqnJt29MrMNhWBV`, 节点ID。
* Authority key: `5FA9nQDVg267DEd8m1ZypXLBnvN7SFxYwV7ndqSYGiN9TTpu`, 验证人的公钥。
* WebSocket RPC 的 IP 和端口: `127.0.0.1:9944`。
* Current block: `best: #1 (0x1d70…5302)` 当前区块.
* Current finalized block: `finalized #0 (0xacb5…bb17)`。一直显示 `0` 是由于 **Template Node** 并没有引入最终性模块 [GRANDPA finality gadget](https://wiki.polkadot.network/en/latest/polkadot/learn/consensus/#what-is-grandpababe)。

> Substrate 默认的共识机制是基于BABE和GRANDPA的混合共识，详细信息参考[Polkadot Consensus](https://wiki.polkadot.network/en/latest/polkadot/learn/consensus/)。

启动之后，你就拥有了一个由单个节点维护的"区块链"网络。下面我们通过UI与刚创建的节点进行交互。

### 节点交互

Substrate生态里提供了一个UI工具 [Polkadot/Substrate UI](https://github.com/polkadot-js/apps) 来帮助开发者与Substrate编写的区块链进行交互。你可以根据项目README的指示在本地运行，或者访问官方host的网页[应用](https://polkadot.js.org/apps)。

在 **Settings**页面，配置`remote node`为之前的WebSocket RPC IP及端口`127.0.0.1:9944`。保存配置后，会有更多的功能在侧边栏出现，供大家使用。

转到`Extrinsics`页：

* 使用内置的`ALICE`用户，
* 配置 **submit the following extrinsic** 为 `template` `doSomething(something)`,
* 配置 **something** 为任意整数,
* 点击提交 **Submit Transaction**. 几秒钟之后，你将会看到交易成功的提示信息。

接着，转到 **Chain state** 页面: *配置 **selected state query** 为 `template`* *`something(): Option<u32>`* 点击➕按钮，你会看到刚刚输进入的数字。

以上就是我们与节点程序的基本交互操作。如果你还不熟悉UI的其它功能，可以多多练习，有助于后面的操作和理解。

## 添加功能模块

使用Substrate编写区块链应用，数据存储、可调用函数和事件都被封装在自定义的Runtime模块中。以刚刚创建的节点程序为例，预先定义的template模块，代码位于`runtime/src/template.rs`, 内容包含：

* 数据存储（Storage）: `Something get(something): Option<u32>`
* 可调用函数（Callable Function）: `rust pub fn do_something(origin, something: u32) -> Result { // --snip-- }`
* 事件（Event）: `SomethingStored(u32, AccountId)`

下面我们在编写自定义的功能模块时会逐一对上面的内容进行介绍。

### 创建新模块

`substrate-up`提供了命令`substrate-module-new`来帮助我们创建一个template模块，里面包含了一些基本的依赖引入，以及上面提到的数据存储项、可调用函数、事件等示例代码，其中的一些注释可以很好地帮助初学者理解Substrate runtime模块的构成。在节点程序目录下执行如下命令（替换`mymodule`为你自己的模块名）：

```bash
cd runtime/src
substrate-module-new mymodule
```

执行完成后，你会看到一个新生成的`mymodule.rs`文件，这就是你的模块程序文件。为了使用这一模块，我们还需要修改当前目录下的`lib.rs`：

* 引入我们新定义的模块:


```bash
mod mymodule;
```

* 实现模块的配置接口：

```rust
impl mymodule::Trait for Runtime {
    type Event = Event;
}
```

* 添加模块到`construct_runtime!`宏：

```rust
construct_runtime!(
    pub enum Runtime with Log(InternalLog: DigestItem<Hash, AuthorityId, AuthoritySignature>) where
        Block = Block,
        NodeBlock = opaque::Block,
        UncheckedExtrinsic = UncheckedExtrinsic
    {
        // --snip--
        MyModule: mymodule::{Module, Call, Storage, Event<T>},
    }
);

```

> **[宏](https://en.wikipedia.org/wiki/Metaprogramming)**通常被称为元编程，根据提供的代码可以生成新的代码，实现代码复用。Substrate使用了大量的宏来减轻开发人员的工作，让人"又爱又恨"，更多可了解[construct_runtime!](https://substrate.dev/docs/en/runtime/macros/construct_runtime)。

接下来，重新编译我们的节点程序：

```bash
# 编译runtime的wasm版本
./scripts/build.sh

# 编译runtime的本地二进制版本，并构建可执行的客户端
cargo build --release

# 删除链上的历史数据
./target/release/demo-node purge-chain --dev

# 启动本地测试网络
./target/release/demo-node --dev
```

请通过 [Polkadot/Substrate UI](https://github.com/polkadot-js/apps) 简单测试一下新创建模块的功能。

### 添加业务功能

本文，我们实现的业务是"抛硬币"游戏，用户可以付费玩游戏，如果抛出的结果为"正面朝上"，则用户胜利，获取奖池里的奖金；如果用户失败，则什么都拿不到。无论胜负，用户支付的游戏费用都要存进奖池，以备后面的用户使用。

### 添加Storage Item

Runtime开发的第一步是设计你的存储数据结构，比如这里需要的游戏花费和奖池，在模块的`decl_storage!`宏中添加如下存储项：

```rust
decl_storage! {
    trait Store for Module<T: Trait> as mymodule {
        // --snip--
        Payment get(payment): Option<T::Balance>;
        Pot get(pot): T::Balance;
        Nonce get(nonce): u64;
    }
}

```

> 这里我们使用的`decl_storage!`宏使代码变得简单易懂，由Substrate负责生成更多和数据库进行交互的辅助代码，开发者只需设计存储的数据模型。

这里有三个存储项：

* `Payment` 类型为 `Option<T::Balance>` ，保存着游戏的花费。使用`Option`表明该费用是否已经被初始化。
* `Pot` 类型为 `T::Balance` ，保存了上次获胜者之后累积的所有奖励。
* `Nonce` 为`u64`类型的整数，我们将会在生成随机数的时候用到。

`Balance` 类型是由 [SRML balances](https://substrate.dev/rustdocs/v1.0/srml_balances/index.html) 模块提供的，用来表示账户的余额。要使用它，需要将我们模块的配置接口修改为依赖 [balances Trait](https://substrate.dev/rustdocs/v1.0/srml_balances/trait.Trait.html):

```rust
pub trait Trait: balances::Trait {
    // --snip--
}
```


代码中`get(payment)`是用来定义`Payment`存储项的另一种getter函数，下面的章节我们再介绍如何使用这些getter函数。

### 定义可调用函数Callable Function

本节我们将会定义Runtime开发所需的可调用函数。这里所说的可调用函数，是那些可以被用户调用，并且与区块链系统进行交互的函数。函数本身是不可以被代码之外进行调用的，但是由于Substrate的封装开放了对应的RPC接口，更多细节这里我们不过多的讨论。我们为"抛硬币"游戏定义了两个函数：一个用来初始化游戏花费；另一个用来开始游戏并生成游戏结果。

```rust
decl_module! {
    pub struct Module<T: Trait> for enum Call where origin: T::Origin {
        fn set_payment(_origin, value: T::Balance) -> Result {
            // Logic for setting the game payment
        }

        play(origin) -> Result {
            // Logic for playing the game
        }
    }
}
```

上面的代码显示了我们的可调用函数位于`Module`结构体中，下面我们将会为函数添加真正的逻辑。对于 `set_payment` 函数:

```rust
// This function initializes the `payment` storage item
// It also populates the pot with an initial value
fn set_payment(origin, value: T::Balance) -> Result {
    // Ensure that the function call is a signed message (i.e. a transaction)
    let _ = ensure_signed(origin)?;

    // If `payment` is not initialized with some value
    if Self::payment().is_none() {
        // Set the value of `payment`
        <Payment<T>>::put(value);

        // Initialize the `pot` with the same value
        <Pot<T>>::put(value);
    }

    // Return Ok(()) when everything happens successfully
    Ok(())
}

```

我们的 `set_payment` 函数需要两个参数， `origin`， 类型为 [SRML system](https://substrate.dev/rustdocs/v1.0/srml_system/type.Origin.html) 模块定义的`T::Origin`，包含了函数调用的发出方。这个参数总是作为可调用函数的第一个参数。Substrate允许我们为这个参数缺省类型签名来简化工作。参考这里[Origin的定义](https://substrate.dev/docs/en/overview/glossary#origin)。 `value` ，类型为 `T::Balance`，用来初始化 `Payment` 和`Pot`。

接下来，我们来实现 `play` 函数：

```rust
// This function is allows a user to play our coin-flip game
fn play(origin) -> Result {
    // Ensure that the function call is a signed message (i.e. a transaction)
    // Additionally, derive the sender address from the signed message
    let sender = ensure_signed(origin)?;

    // Ensure that `payment` storage item has been set
    let payment = Self::payment().ok_or("Must have payment amount set")?;

    // Read our storage values, and place them in memory variables
    let mut nonce = Self::nonce();
    let mut pot = Self::pot();

    // Try to withdraw the payment from the account, making sure that it will not kill the account
    let _ = <balances::Module<T> as Currency<_>>::withdraw(&sender, payment, WithdrawReason::Reserve, ExistenceRequirement::KeepAlive)?;

    // Generate a random hash between 0-255 using a csRNG algorithm
    if (<system::Module<T>>::random_seed(), &sender, nonce)
      .using_encoded(<T as system::Trait>::Hashing::hash)
      .using_encoded(|e| e[0] < 128)
    {
        // If the user won the coin flip, deposit the pot winnings; cannot fail
        let _ = <balances::Module<T> as Currency<_>>::deposit_into_existing(&sender, pot)
          .expect("`sender` must exist since a transaction is being made and withdraw will keep alive; qed.");

        // Reduce the pot to zero
        pot = Zero::zero();
    }

    // No matter the outcome, increase the pot by the payment amount
    pot = pot.saturating_add(payment);

    // Increment the nonce
    nonce = nonce.wrapping_add(1);

    // Store the updated values for our module
    <Pot<T>>::put(pot);
    <Nonce<T>>::put(nonce);

    // Return Ok(()) when everything happens successfully
    Ok(())
}

```

上面的 `play` 函数只接收 `orgin` 这一个参数。然后做一些预置条件检查如，交易应当被签名，并且`payment`存储项不能为空。这里我们使用了 `Self::payment()` 来获取存储项中的具体值，这就是我们上面说到的getter函数的具体使用方法，另一种获取存储项的方法为 `<Payment<T>>::get()`。

在真正"抛硬币"之前，我们需要将游戏所需的花费从用户账户取出，当游戏结束之后将这些费用放入奖池中。代码中使用的 `withdraw` 函数还需要引入下面的依赖: `rust use support::traits::{Currency, WithdrawReason, ExistenceRequirement};`

当硬币被抛出之后，用户有百分之五十的几率获胜。为了模拟这样的情况，首先生成一个0到255的随机数，再拿这个随机数跟128进行比较，如果小于128，那么用户获胜并获得奖池中的奖金；反之失败，用户什么都没有得到。最后更新存储项，为下一次游戏做准备。关于更多的随机数生成，请参考 [Generating Random Data](https://substrate.dev/substrate-collectables-workshop/#/2/generating-random-data) 页面

最后还需要引入的依赖有:

```rust
use runtime_primitives::traits::{Zero, Hash, Saturating};
use parity_codec::Encode;
```


### 生成事件Event

客户端通过监听区块中的Event来更新链下的存储状态或与用户交互。

当Payment被更新之后我们希望产生一个包含Payment信息的Event，由于用到了`Balance`类型，我们需要修改Event enum，添加泛型约束`Balance = <T as balances::Trait>::Balance`：


```rust
decl_event!(
    pub enum Event<T> where
        AccountId = <T as system::Trait>::AccountId,
        Balance = <T as balances::Trait>::Balance {
        // --snip--
    }
);

```

之后，在Event enum中定义我们的Event，并修改`set_payment`函数来生成这一事件：

```rust
PaymentSet(Balance),
fn set_payment(origin, value: T::Balance) -> Result {
    // --snip--
    if Self::payment().is_none() {
        // --snip--
        Self::deposit_event(RawEvent::PaymentSet(value));
    }
    // --snip--
}

```

当用户完成游戏之后，我们希望产生一个包含用户信息以及获胜信息的事件，同样我们需要添加我们的Event到Event enum中，并在合适的时机触发事件：


```rust
PlayResult(AccountId, Balance),
// This function is allows a user to play our coin-flip game
fn play(origin) -> Result {
    let sender = ensure_signed(origin)?;
        // --snip--
    let mut winnings = Zero::zero();

    if (<system::Module<T>>::random_seed(), &sender, nonce)
      .using_encoded(<T as system::Trait>::Hashing::hash)
      .using_encoded(|e| e[0] < 128)
    {
        // --snip--

        // Set the winnings
        winnings = pot;

        // Reduce the pot to zero
        pot = Zero::zero();
    }

    // --snip--

    // Raise event for the play result
    Self::deposit_event(RawEvent::PlayResult(sender, winnings));

    // Return Ok(()) when everything happens successfully
    Ok(())
}

```


这里我们定义了新的变量`winnings`保存获胜信息，初始值为`0`，如果获胜则更新为`pot`即奖池中的值。在函数返回`Ok(())`之前触发该事件。

## 总结

现在已经完成了所有的代码，可以进行简单的测试。同样地，访问 [Polkadot/Substrate UI](https://github.com/polkadot-js/apps) 在Extrinsics页面中调用上面定义的函数；之后在Chain state页面查询对应的存储项。遇到问题可以参考这里的 [“抛硬币”完整代码](https://github.com/shawntabrizi/substrate-package/blob/gav-demo/substrate-node-template/runtime/src/demo.rs)。

后续文章将会介绍如何添加测试和编写UI。更多内容请关注，

本文来自孙凯超的知乎专栏：[Substrate区块链开发](https://zhuanlan.zhihu.com/p/76815437)，他的公众号：
沐风自语


## 参考引用

* [Using the Substrate Scripts](https://substrate.dev/docs/en/getting-started/using-the-substrate-scripts)
* [Creating Your First Substrate chain](https://substrate.dev/docs/en/tutorials/creating-your-first-substrate-chain)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
