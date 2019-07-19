---
title: POA网络
permalink: poa-network
date: 2019-07-19 20:41:20
categories:
    - 扩容技术
    - POA
tags:
    - Loom
    - 智能合约
author: Tiny熊
---

由于以太坊又慢又贵的POW共识（尽管如此，以太坊依旧是最受欢迎的DApp平台），催生了各种以太坊测链的方案用来减少以太主网的拥塞，前面我们介绍了Loom SDK， 这篇博客介绍下POA Network。


<!-- more -->


## 什么是POA 网络

POA 网络定位于以太坊的侧链（兼容以太坊协议），它使用一个全新的POA的共识机制。

> 备注：POA项目官方现在更愿意把POA作为自治证明共识（Proof of Autonomy）的缩写，而不是使用权威证明（Proof of Authority）

POA共识是一种更直接有效的POS共识形式，它的验证者必须经过身份验证（貌似还会签署法律文件），在POS上通常是需要获得足够的选票（代币）来提高作恶成本，而POA则是靠验证者的信誉来做担保，作为一个二层网络，通常只有较小额的交易，追求性能而牺牲一些网络安全性可以理解，这也是二层网络通常的做法。

POA网络启动时有12个验证者（现在有20多个）,这些验证者通过智能合约来管理，智能合约也加入了治理模式，验证者可以投票添加或删除验证者甚至是更新治理合约。验证者验证者出块的几率均等，每产生一个块可以过得一个POA币（侧链的原生代币）以及所有的手续费。

PoA网络平均每5秒出一个块， 区块大小是800万Gas，Gas price 固定为1GWei（1POA＝1,000,000,000Gwei）， 因此可以推算PoA网络大概比以太坊快３倍，而运行DApp的gas费用则大大降低，当前一个POA的价格不到0.2元，历史最高时也只有６元，不像一个以太几千上万的价格。

PoA网络出块信息可以在[blockscout浏览器](https://blockscout.com/poa/core) 查看详情， 值得提一下，BlockScout 是POA Network的另一个贡献，这是一个功能强大的开源的区块浏览器，支持所有以太坊协议的网络。[Github库](https://github.com/poanetwork/blockscout)

POA 网络的主网称为POA Core，他还有一个测试网络为POA Sokol。其实以太坊主网也有一个POA共识的测试网叫 Kovan 。
从Metamask 连接到POA Core　只需要加入一个Custom RPC，　加入一下 RPC URL： https://dai.poa.network


## POA的桥接技术(TokenBridge)

**POA最大的价值在于其桥接技术**，TokenBridge是一个互操作性协议，它使得以太坊网络和POA网络之间可以相互通信（交互）。

> 备注：TokenBridge 之前为 POA Bridge， 因此很多文档里没有及时跟随更改， TokenBridge[代码库](https://github.com/poanetwork/tokenbridge)。

目前桥接技术已经完成的功能有：

1. 允许用户把自己在POA网络的原生代币 POA 转移到以太坊网络，在以太坊网络生成对应的POA20代币，POA20是以太坊网络的ERC 20代币。

2. 允许把以太坊网络的ERC 20代币转移到POA 网络（或其他链），这些转移并不会重复产生新的币，它会在接收链创建对应的币而在发起链销毁对应的币。
3. 不同网络之间的ERC20代币相互转移，有了这个技术我们就可以把昂贵的链上交易转移价格低廉的侧链，让区块链落地有了更多的可能。


https://bridge.poa.net

![](https://img.learnblockchain.cn/2019/07/19_poa-tokenbrige.png!wl)


其实，POA桥接技术不仅仅可以用于以太坊网络和POA网络相互通信，也有其他的项目使用TokenBridge来进行token的转移，如：Sentinel Chain 和 Virtue Poker。


## 稳定币链 xDai Chain

最近Libra关注度太高，很多朋友知道它是Facebook发行的一个稳定币链，稳定币链要排个辈分的话，Libra应该叫xDai一声大哥。

DAI是以太坊上通过抵押数字资产发行的稳定币，一个Dai=1美元，  不熟悉的同学可以看我一篇文章理解[去中心化稳定币 DAI](https://learnblockchain.cn/2019/03/19/understand_dai/), xDai Chain是DAI背后的团队MakerDAO和POA Network合作推出的一条基于稳定币的POA共识链，xDai Chain 也是POA 共识机制及TokenBridge相结合的最好的一个例子。

xDai链和POA Core一样是以太坊网络上的侧链，XDAI是侧链上原生代币（用来支付链上交易的Gas），DAI是对应在以太坊的ERC20代币，注意，xDai链是不支持挖矿的，而是必须通过把Dai通过TokenBridge转移到xDai链产生XDAI币。其他的特性和POA Core一样， 如5秒的块生成时间，每笔交易的gas成本为1Gwei，这样在xDai链上的交易成本就非常低。

xDai解决了阻碍数字货币用于日常交易的两个主要因素：价格波动大及手续费高，把一些应用部署到xDai链上来会是个不错的选择。　后面我们会有文章介绍。

xDai网络出块信息可以在[blockscout浏览器](https://blockscout.com/poa/dai/) 查看详情。


如何将你的钱包连接到 xDai 链

- 从Metamask 连接到 xDai 链的JSON RPC 终端

https://dai.poa.network



- TokenBridge: 将Dai从以太坊主网转换为xDai链上的xDai

https://dai-bridge.poa.network/

- Netstats: xDai Chain节点概述

http://dai-netstat.poa.network



POA 的开源浏览器和钱包创建了一个完整的功能生态系统,游戏在这里有机会发展和成长。




## Deploying your DApp to POA Network
https://forum.poa.network/t/tutorial-deploying-your-dapp-to-poa-network/1804



### 通过合约实例调用合约函数


## 参考文章

What is POA and How is it Unique?
https://dgaming.com/media/what-is-poa-and-how-is-it-unique/


https://forum.poa.network/c/tokenbridge/poa20-bridge

https://forum.poa.network/t/getting-started-with-poa-products/2595

https://github.com/poanetwork/wiki/wiki/POA-Network-Whitepaper

https://poa.fund/1299.html
https://poabridge.com

白皮书：https://github.com/poanetwork/wiki/wiki/POA-Network-Whitepaper

POA Network partners with MakerDAO on xDai Chain, the first ever USD-Stable Blockchain!
https://medium.com/poa-network/poa-network-partners-with-makerdao-on-xdai-chain-the-first-ever-usd-stable-blockchain-65a078c41e6a


加入[知识星球](https://learnblockchain.cn/images/zsxq.png)，和一群优秀的区块链从业者一起学习。
[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


