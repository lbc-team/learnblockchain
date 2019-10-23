---
title: CREATE2 在广义状态通道中的使用
permalink: create2-statechannel
date: 2019-10-23 11:41:03
categories: 
    - 扩容技术
    - 状态通道
tags: 
    - 扩容
    - CREATE2
author: Tiny熊
---

君士坦丁堡硬升级中引入了一个[新操作码 CREATE2](https://learnblockchain.cn/docs/eips/eip-1014.html) ，它使用新的方式来计算常见的合约地址，让生成的合约地址更具有可控性，通过 CREATE2 可以延伸出很多新的玩法，这篇文章来探讨下，在广义状态通道中的妙用。

<!-- more -->

关于合约地址与状态通道，先科普一下相关知识点。

## 合约地址如何计算出来的?

在 CREATE2 以前，CREATE指令创建的合约地址是通通过交易发起者（sender）的地址以及交易序号（nonce）来计算确定的。 sender 和 nonce 进行 RLP 编码，然后用 Keccak-256 进行 hash 计算（伪码）：

```python
keccak256(rlp([sender, nonce]))
```

而 CREATE2 指令则主要是根据创建合约的初始化代码(init_code)及盐（slat） 生成(伪码)：
> init_code 代码是用来创建合约的，合约创建完成后将返回运行时字节码（runtime bytecode）。通常init_code代码包括合约的构造函数及其参数，以及合约代码本身。

```
keccak256(0xff + sender + salt + keccak256(init_code))
```

CREATE创建的合约地址依赖于一个跟随交易者发起的交易数量不断的增长的nonce变量，这种方式很难确定一个未来要部署的合约地址（比如提前使用一个还未部署的合约地址），而使用 CREATE2 只需要确定了创建合约的代码（init_code）及盐（slat），则合约地址就是确定的（实际上让地址变成了对合约代码的**验证**）。

## 状态通道

状态通道由支付通道演进而来，我们先通过一个简单的例子介绍下支付通道，假设晓娜经常要去楼下的咖啡店喝咖啡，晓娜每次除了支付0.1 eth 咖啡费用之外，还需要支付一笔小费给矿工。为了节约小费，晓娜可以在她与咖啡店之间创建一个支付通道，通过加密签名可以重复安全的转移以太币，而不用支付手续费。晓娜可以这样做：

1. 创建一个支付通道智能合约，并存入20个以太币（链上）。
2. 每次买咖啡时签名一条交易信息给老板，交易信息包含内容有：第几次购买咖啡、总共要支付多少钱给老板及签名数据本身。（链下）
3. 晓娜重复步骤2，而老板任何时候都可以把晓娜的签名信息发送给链上支付通道智能合约，取回资金。
4. 晓娜不想喝咖啡了，取回支付通道的余额。

通过这样的方式，晓娜可以节约大量的手续费。这里例子的代码可以参考[编写一个简单的支付通道](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id8)及[simple-payment-channel](https://github.com/eolszewski/simple-payment-channel)。
本例没有考虑一些极端条件，在[比特币闪电网络白皮书](https://lightning.network/lightning-network-paper.pdf) 有关于支付通道详细的阐述。

状态通道则可以基于特定应用程序的状态进行链下交互（而不仅仅是支付信息）， 如果可以部署一个游戏合约定义游戏规则并抵押资金，玩家可以在链下玩游戏（每进行一步游戏签名发给对方）， 游戏结束时，只需要把最后的状态提交给合约，合约进行输赢判断，并奖励。 
> [Force-Move 游戏框架](https://github.com/magmo/force-move-protocol) 就是让开发者可以模块化的、可扩展的方式，开发基于状态通道的的回合制游戏。


##  广义状态通道

感觉才进入主题，广义状态通道的意思是，用户可以用同一个通道做多种不同的事情。
刚刚上面介绍的状态通道，都是基于特定目的的通道，抵押的资金只能根据实现定义好的合约逻辑进行分配，而广义状态通道则是使用一个强大的多签钱包，可以根据**其他合约定义的规则**来进行资金的分配，从而实现更加通用的目的。

举个例子： Tiny熊和晓娜拥有一个抵押的资金的多签钱包，然后定义一个剪刀石头布的游戏合约，每次输方向赢方支付1个以太币，玩游戏可以在链下进行，结束后，最终的状态提交给游戏合约，并触发多签钱包根据状态分配资金。

通过使用 **CREATE2**，可以在游戏合约不上链的情况下进行游戏，因为只要游戏的规则代码确定了，就可以确定游戏合约的地址，在链下就可以基于这个确定的合约地址进行签名玩游戏，甚至我们根本不需要部署游戏合约，仅仅在有游戏玩家作弊的时候，部署游戏合约进行链上仲裁。

如果不能理解上面这一点，就当作剪刀石头布游戏，Tiny熊和晓娜赢的次数一样多，这样谁也不用给对方支付费用，对于链上的多签钱包，相当于什么也没有发生，这样也同样不需要部署游戏合约。

### Counterfactual 技术

有一个专门的项目 [Counterfactual](https://www.counterfactual.com/technology/) 研究广义状态通道想想扩容技术，现在中文资料里把 Counterfactual 直译为“反事实”，非常的晦涩，我认为应该翻译成“拟上链”。为了方便大家阅读 Counterfactual 相关文档，对 Counterfactual 相关的术语进行下解释，这个概念本身有一点“哲学”。

Counterfactual 官方的一个介绍是，在状态通道中，一个“Counterfactual X” 代表：

* X 可以在链上发生，但它并没有。
* 任何参与者都可以单方面使得 X 在链上发生。
* 参与者们能够假设“ X 已经在链上发生”，并基于此进行其他行动。

Counterfactual 表达为**拟上链**还是比较准确，充分表达了可以上链，却没有上链。 

Counterfactual instantiation 是另一个常用术语，通过 Counterfactual instantiation 可以扩展状态通道的功能，
我把翻译为拟上链实例化，它表示**实例化一个并没有实际上链的合约**，尽管它没有上链，各方却都会在假设合约已经被部署上链进而进行交互。


## 参考文章

* [Counterfactual: Generalized State Channels on Ethereum](https://medium.com/statechannels/counterfactual-generalized-state-channels-on-ethereum-d38a36d25fc6)
* [State Channels for Dummies: Part 5](https://medium.com/blockchannel/state-channels-for-dummies-part-5-6238f83f8da3)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。



 






