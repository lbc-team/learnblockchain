---
title: Devcon5 有哪些开发者应该了解的内容
permalink: devcon5-tech
date: 2019-10-16 11:41:03
categories: 资讯
tags: DEVCON
author: Tiny熊
---

Devcon 是以太坊年度开发者大会，每年的大会会介绍以太坊的最新发展以及开发者生态情况，今年是第五届，10月8日至11日在日本大阪举行，今年的主题主要围绕 ETH2.0 、DeFi以及ETH1.0 上的扩容。

<!-- more -->

## Optimistic Rollup 一个新的扩容解决方案

Uniswap 和 Plasma Group 展示了一个 Optimistic Rollup 的去中心化交易所(DEX) Demo，这一个全新的去中心化交易所解决方案，旨在提升交易处理速度和网络拥堵问题。

Optimistic Rollup 可以实现线下对智能合约交易的扩容，本次演示的这个Demo是在太坊 Ropsten 测试网上运行的，每秒可处理约250笔交易。 更多可[查看](https://decrypt.co/10030/plasma-group-and-uniswap-release-new-ethereum-scaling-solution-at-devcon)， 相比Plasma，它利用[零知识证明](https://learnblockchain.cn/categories/zkp/)，是更去信任的方式，非常值得大家继续关注。


## V神：POS 及 Eth2

POS 会让潜在的攻击的成本更高，让以太坊更安全。  更多可[查看](https://decrypt.co/10093/vitalik-buterin-proof-of-stake-will-make-ethereum-safer)

V神 还介绍了 Eth2 的技术进展，他在会议期间还发表了几遍文章介绍：
1. [eth1 到 eth2 迁移](https://ethresear.ch/t/the-eth1-eth2-transition/6265)
2. [eth1 与 eth2 的双向桥接](https://ethresear.ch/t/two-way-bridges-between-eth1-and-eth2/6286)
3. [Formalizing and improving eth2’s approach toward finalization of invalid shard blocks](https://ethresear.ch/t/formalizing-and-improving-eth2s-approach-toward-finalization-of-invalid-shard-blocks/6263)
4. [Cross-shard DeFi composability](https://ethresear.ch/t/cross-shard-defi-composability/6268)
5. [Partially sharding single-threaded apps: a design pattern](https://ethresear.ch/t/partially-sharding-single-threaded-apps-a-design-pattern/6287)
6. [On-beacon-chain saved contracts](https://ethresear.ch/t/on-beacon-chain-saved-contracts/6295)

## TrueBlocks: 构建真正去中心化的应用程序

TrueBlocks 可以加速和链上数据的交互（如获取以太坊地址和合约的数据），速度可以比直接使用RPC接口快上100倍，不像 etherscan 这样的由中心化服务器提供服务， TrueBlocks 是去中心化的，他直接和自己的本地节点交互（如果想要的话，也可以和Infura 这样的基础设施通信）。

TrueBlocks 还开源了代码[GitHub](https://github.com/Great-Hill-Corporation/trueblocks-core)， [官网](http://trueblocks.io)


## Brownie: 基于Python的智能合约开发框架

Truffle 大家已经使用的很多，[Truffle 中文文档](https://learnblockchain.cn/docs/truffle/)，Truffle 是基于Node(JavaScript)的框架，Brownie 则是一款Python的智能合约开发框架， 方便我们进行合约的编译、测试、部署等。

Brownie 的[官方文档](https://eth-brownie.readthedocs.io/
)， 喜欢python 的朋友可以试试。

## LeapDao: DApp扩容

LeapDao希望弥合区块链与人类之间的鸿沟，提高DApp用户体验，LeapDao（基于[Plasma](https://learnblockchain.cn/categories/scaling/Plasma/)
）可以实现:

 - 快速确认时间（2秒）。
 - 最终用户无需支付gas费。
 - 高安全性。

LeapDao 代码库在： https://github.com/leapdao

## Arbitrum:（二层）扩容网络

Arbitrum 是 Offchain Labs（普林斯顿大学）的研究成果，其声称Arbitrum可以轻松集成到任何以太坊应用中，将处理速度提高到每秒500多笔交易，代码和交易可以通过侧链或状态通道在链下执行。

如果有不想在公有区块链上运营的企业，又希望使用以太坊技术且获得比以太坊等平台更快地处理交易。可以了解一下。[Arbitrum官网](https://offchainlabs.com/)



## Lexon: 让建立智能合约更简单

Lexon 是一个新类型的编程语言，像自然语言一样通俗易懂， 这样可以方便专业人士来编写如商业协议，法律合约等。

通过跨专业语言系统，Lexon可以实现通讯在商业-法律-开发者之间自由流动，同时允许其进行验证、优化和测试。

Lexon 官网: http://www.lexon.tech/


## 探讨 EIP-1884 可能的安全问题

[EIP-1884](https://learnblockchain.cn/docs/eips/eip-1884.html) 对一些操作码重新定义了gas 消耗， 鉴于 EIP-1884 已经被[Istanbul分叉](https://learnblockchain.cn/docs/eips/eip-1679.html)接受，原有的合约最佳编写实践可能会 EIP-1884 而变得不再试用。

## MYKEY：智能钱包

MYKEY是一款基于KEY ID协议的智能钱包，KEY ID协议目前具有以下特点：
 1. 基于智能合约的账户模型
 2. 账户权限分层设计
 3. 可信的账号恢复机制
 4. 网络费代理支付模型
 5. 多链统一的身份

[MYKEY Lab GitHub](https://github.com/mykeylab)， 这是国内Ricky胖哥搞的， 貌似现在只支持EOS 。


##  Chainlink: 区块链与外部世界的桥梁

Chainlink 是 Devcon的常客，Chainlink 将在以太坊主网上启动 7 个新的价格参考数据预言机网络（ 如:ETH(原有)， BTC，DAI，USDC，ZRX，REP，WBTC，BAT），开发人员轻松访问已通过去中心化预言机网络验证的高质量价格数据来发展 DeFi 生态系统。开发 DeFi 可以了解下。

Chainlink 官网： https://chain.link/

## Pepo 用户体验感最好区块链社交应用

Pepo的创始人Jason Goldberg及首席开发者Ben Bollen为大家现场演示了Pepo的使用，并表示Pepo是区块链行业有史以来用户体验感最好的社交应用，Pepo 基于一个 OST 的二层网络构建，OST 官网地址： https://ost.com/


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。