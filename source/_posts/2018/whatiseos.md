---
title: 什么是EOS（柚子）
permalink: whatiseos
date: 2018-07-17 14:25:44
categories: EOS
tags:
    - EOS
author: Tiny熊
---

是时候给写写EOS了，现在EOS主网已经上线，尽管我个人不是很喜欢EOS项目（不过也一直在关注EOS），但是不可否认EOS这个争议性很大的项目给区块链世界带来的变化。

<!-- more -->

## 写在前面

阅读本文前，如果了解过比特币及以太坊，可以更好的理解本文。欢迎订阅专栏：[区块链技术](https://xiaozhuanlan.com/blockchaincore)
指引你从头开始学区块链技术。

本文出现EOS是指EOS.io公链项目，不是指[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)上的EOS Token。


## EOS 简介

EOS: Enterprise Operation System 中文意思为：商业级区块链操作系统。

尽管以太坊创造性引入[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)概念，极大的简化了区块链应用的开发，但以太坊平台依然有一个很大的限制，就是交易确认时间及交易吞吐量比较小，从而严重影响了以太坊进行商业应用。

> 交易吞吐量有一个专门的词：TPS （transaction per second 每秒的交易量） 比特币的TPS 是大概7，并且最少几十分钟交易才能被确认，以太坊的TPS大概是20左右，交易的确认一般需要几分钟的时间。
> 不过比特币以太坊也在不断进化以提高TPS，比如比特币的闪电网络，以太坊的Sharding技术（分片）以及Plasma技术（分层）。

EOS 项目的目标是建立可以承载商业级智能合约与应用的区块链基础设施，成为区块链世界的“底层操作系统”。
EOS通过**石墨烯技术**解决延迟和数据吞吐量问题，TPS可达到数千，交易的确认时间也只有数秒。同时声称未来使用并行链的方式，最高可以达到数百万TPS。

EOS 设计了一套账户权限管理系统，EOS不再使用的地址作为账户，可以直接使用字符作为账户名，并设计了一套的账户权限体系。

此外，在 EOS 上转账交易及运行智能合约不需要消耗 EOS代币。而是EOS 系统当中，抵押代币获取对应的资源，来执行相应交易，在EOS运行程序完全免费的说是不准确的。


> 值的一提的是EOS项目其ICO也是基于以太坊[ERC20 Token](https://learnblockchain.cn/2018/01/12/create_token/)进行的，其ICO 时间长达355天，作为一个当时还未上线的项目，融资额达到40亿美元是前所未有。


### 充满争议的技术天才BM

EOS的主要开发者为丹尼尔·拉瑞莫（Daniel Larimer）, 绰号BM(GitHub的昵称：ByteMaster), 它是EOS的项目方，BlockOne公司的CTO。
和V神一样，也是一个神奇的人物，网络上两人因理念不合有多次论战。BM有一句牛B 轰轰的话：我终生的使命，是致力于找到一些加密经济的解决方案，给所有人的财产、自由、平等带来保障。

BM成功创立过三个区块链项目：BitShares、Steem 以及EOS，是一个技术天才，也是一个多变的人。
2009年的BM也准备的数字货币一展身手，在其研究比特币之后，2010年BM提出了一些比特币的问题，并想要改进，结果比特币的创始人中本聪（Satoshi Nakamoto）怼会了他“If you don't believe me or don't get it, I don't have time to try to convince you, sorry.”（懂不懂随你，我可没时间理你）。
于是BM开始着手创建自己的区块链项目，这就是2013年发布的 BitShares 比特股，世界上第一个数字货币去中心化交易所。

BitShares在2014年上线时，是当时的明星项目，也由于bug太多、糟糕的体验以及BM在进行个别版本升级的时候都不提供向下兼容，用户逐渐流失，更要命的是，BM利用自己超过1/3的记账节点，在没有达成社区共识的情况下，强行分叉增发了BitShares发行总量。尽管BM在技术提供了改进，发布了石墨烯工具集，不过最终社区投票决定让BM离开了BitShares。

离开BitShares的BM，于2016年创立了区块链项目Steem，去中心化社交网站Steemit就是基于Steem创建，在Steemit的运营期间，BM和Steemit的CEO Ned有过多次口水战。
在2017年，BM离开了自己创建的Steem项目（也许除了BM自己，没有人能知道他离开Steem的真实原因），选择与布鲁默联合创办了BlockOne公司打造EOS项目。


## 石墨烯（Graphene）与 DPOS

和BitShares、Steem 一样，EOS底层使用的也是石墨烯技术，石墨烯是一个开源的区块链底层库，也出自BM之手，它采用的是 DPOS（Delegated Proof-of-Stake 股份授权证明机制 ）的共识机制。
在比特币及以太坊网络中，任何人都可以参与记账，而DPOS为了提高出块速度TPS，限制了参与记账了人数，在DPOS中，记账者不在称为矿工，而是改称为见证人 Witness，现在EOS中，又有一个新词：Block Producer，简称BP，大家翻译为超级节点（本文中依旧会使用见证人这个词，超级节点更像是一个市场营销用词）。

在EOS中，见证人的个数是21个，BitShares中是101个，BitShares的出块时间打开是 1.5秒，在EOS中，出块时间提高到了0.5秒。

和Pow及Pos共识机制矿工可以自由选择参与挖矿不同，DPOS下节点需要参与见证人选举，只有赢得选举的节点才能负责出块，在EOS中，赢得选举21个节点见证人轮流出块。
另外还有100个备用见证人（候选节点），在21个见证人出现问题后做替补。EOS的发行总量是10亿， 见证人在完成打包交易区块后，可以领取到区块的奖励，区块的奖励来自对发行量的通胀增发，通胀率每年接近5%。


## BM特色的去中心化

我个人理解的区块链，它最大的革命性就是他的中立性，其运行不应该受到任何人的干扰，在POW共识中，矿工、项目方（开发者）以及交易方他们是相互独立的存在。

在EOS中，BM本人拥有巨量的选票，他可以在一定程度上左右见证人的选举，同时BM还为EOS制定了宪法，要求所有的见证人必须遵照宪法。因此BM某种程度上可以左右EOS系统的运行。

本文是个人对EOS的理解，受我自己视野局限也许理解有偏差，欢迎大家批准指正，我的微信： xlbxiong。


## EOS相关资料：
* [EOS开发者资源](https://developers.eos.io/)
* [官方网站](https://eos.io)
* [Github 代码](https://github.com/EOSIO)

我们为区块链爱者这提供了系统的区块链视频教程，觉得文章学习不过瘾的同学可以戳[区块链视频教程](https://learnblockchain.cn/course/)。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，打造最好的区块链技术博客。
我的**[知识星球](https://learnblockchain.cn/images/zsxq.png)**为各位解答区块链技术问题，欢迎加入讨论。

