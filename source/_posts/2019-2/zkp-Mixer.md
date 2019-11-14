---
title: 零知识证明-Mixer(混币)应用分析
permalink: zkp-Mixer
un_reward: true
date: 2019-11-14 09:42:19
categories: 零知识证明
tags:
    - 零知识证明
    - Mixer
author: Star Li
---



交易隐私是零知识证明的一个应用方向。除了通过公链或者侧链实现交易的发送方/接收方以及金额隐藏外，Mixer，江湖人称“混币”，是在已有公链上实现交易的发送方的隐藏（匿名）。Mixer，就是将一些账户的资金“混”在一起，由公开的第三方代替发送方发起转账。这个第三方，被称为Mixer或者Relayer。本文分析以太坊上的三个Mixer项目的设计和性能。
<!---more---->

## MicroMix
![MicroMix](https://img.learnblockchain.cn/2019/11/14/002.jpg)

[MicroMix的源代码Github](https://github.com/weijiekoh/mixer),核心逻辑实现在contracts/solidity/Mixer.sol文件中。

MicroMix在Semaphore项目之上，提供混币服务，整个框架如下：

![框架](https://img.learnblockchain.cn/2019/11/14/003.jpg)

对Semaphore项目不熟悉的小伙伴，可以查看我的另外一篇文章：[零知识证明 - Semaphore源代码导读](https://learnblockchain.cn/2019/11/08/zkp-Semaphore/)。

整个MicroMix生态存在三种角色：发送方，接收方以及Relayer。使用MicroMix，需要两个步骤：

1）Deposit（存钱）

2）Mix（提钱）。

### Deposit

在使用Mixer服务之前，发送方需要Deposit（存入）**固定数量**的代币（ETH或者ERC20代币）。Deposit同时要求发送方生成Semaphore对应的Identity。也就是说，每“混”一笔交易，发送方需要创建一个Identity。

### Mix

Mix接口实现”提钱“的功能。Mix接口由“Relayer”（中继）调用，而不是由发送方调用。因为每个Identity在external nullfier不变的情况下，能且只能发送一次Signal，从而保证每笔存入的代币都能Mix。每个需要“提钱”的账户，提供Identity的证明给Relayer，同时在Signal中指定Relayer，接收方以及费用，从而Relayer可以发起交易，调用Mix接口转账给接收方。

![Mix接口](https://img.learnblockchain.cn/2019/11/14/004.jpg)

### 性能

MicroMix使用Semaphore构建了**20层**的Identity的Merkle树。Deposit大约消耗110w的GAS，Mix大约消耗77w的GAS费用（主要是zkSNARK的验证）。

## Tornado Mixer

![Tornado](https://img.learnblockchain.cn/2019/11/14/005.jpg)

[Tornado Mixer的源代码](https://github.com/peppersec/tornado-mixer),Tornado Mixer的核心逻辑在contracts/Mixer.sol文件中：一个是deposit函数，一个是withdraw函数。Tonado Mixer的框架如下图：

![框架](https://img.learnblockchain.cn/2019/11/14/006.jpg)

大体逻辑和MicroMix类似，发送方（Sender）首先向智能合约转账（固定金额），并在智能合约上创建commitment。接下来，发送方（Sender）将零知识证明发送给Mixer，Mixer确认证明后，通过withdraw函数向接收方转账。

### Commitment Merkle树

所有的Commitment在智能合约中组织成一个Merkle树：

![Merkle树](https://img.learnblockchain.cn/2019/11/14/007.jpg)

叶子节点的计算采用Pedersen Hash算法，中间节点采用MiMC Hash算法。整个树高为16。也就是说，Tornado Mixer一个智能合约，支持2^16次转账。

### 性能

Commitment Merkle树高为16。Deposit函数大约消耗88.8w的GAS，Withdraw函数大约消耗69.2w的GAS。证明电路的Contraint为22617。生成一次证明的时间大约为6.1秒。

## Hopper

![Hopper](https://img.learnblockchain.cn/2019/11/14/008.jpg)

Hopper的源代码地址：https://github.com/argentlabs/hopper。Hopper的核心逻辑在solidity/contracts/Mixer.sol中：一个是commit函数，一个是withdraw函数。大体思路和Tornado Mixer一致，不再详细描述。相比较其他两个项目，Hopper有个明显的特色，实现了手机端的Mixer的功能。

### Commitment Merkle树

从安全性角度考虑，叶子节点仍然采用sha256的计算。但是，为了降低证明电路的大小，中间节点采用MiMC Hash算法。Commitment Merkle树高为15。也就是说，Hopper一个智能合约，支持2^15=32768次转账。

### 性能

Commitment Merkle树高为15。GAS消耗和生成证明的时间没有实测。从理论上计算，GAS消耗会比Tornado Mixer略低一些，生成时间会比Tornado Mixer高。

## 总结

Mixer，混币，是零知识证明的一种应用，隐藏转账的发送方。目前，在以太坊上的Mixer实现的思路大体一致：发送方，首先转账固定金额给智能合约，同时提交的Commitment构造上一棵Merkle树。需要转账时，发送方链下将零知识证明的信息发送给Mixer或者Relayer。Mixer或者Relayer，将证明相关信息提交到智能合约。智能合约验证后转账给接收方。Mixer或者Relayer赚取一定的服务费。


本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。