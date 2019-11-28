---
title: 区块链 - Filecoin为什么需要GPU？
permalink: filecoin-GPU
un_reward: true
date: 2019-11-28 09:35:16
categories:
    - FileCoin
tags:
    - FileCoin
author: Star Li
---

今天IPFS/Filecoin的各种群炸开了锅，原因是Filecoin内部开发人员透露，下一个Filecoin的测试网络需要搭配GPU。而且Filecoin内部测试使用的是2080ti的显卡。

<!-- more -->

![消息](https://img.learnblockchain.cn/2019/11/28/001.jpg)

同时，聊天记录表明，下一个测试网络需要在一个区块时间内完成PoST的计算。晚上下了一下最新的go-filecoin的代码，看了看。奇怪的是，最新代码的共识部分（EC）以及节点选举流程和之前没有多大的差别。

## 目前节点选举流程

核心逻辑在go-filecoin/internal/pkg/mining/worker.go文件中的Mine函数，由以下几步组成：

* 创建下一个区块的Ticket

  获取上一个Tipset中的最小的Ticket，并使用NextTicket函数生成下一个区块的Ticket。计算方式非常简单，就是对上一个Tipset中的最小的Ticket进行签名。目前签名支持两种算法：BLS以及SECP256K1。默认采用SECP256K1算法。

![签名](https://img.learnblockchain.cn/2019/11/28/002.jpg)

* 延迟一个区块时间

  一个区块时间（BlockTime）默认是30秒。目前的代码实现直接采用Delay。从TODO可以看出，这一部分设计中是想采用VDF。但是，目前代码还没有完全实现。

![TODO](https://img.learnblockchain.cn/2019/11/28/003.jpg)

* 从前面一些区块获取Election Ticket

  从前面一些区块中获取最小的Ticket，作为Election Ticket。从前面一些区块选举，是为了保证随机性。

![获取最小的Ticket](https://img.learnblockchain.cn/2019/11/28/004.jpg)

* 生成Election Proof

  获取了Election Ticket，并对其签名，生成Election Proof。

![生成Election Proof](https://img.learnblockchain.cn/2019/11/28/005.jpg)

* 确定是否是Winner

  通过IsElectionWinner函数判断是否是Winner。逻辑也非常明了，查看Election Proof是否小于有效存储率。如果小于，说明是Winner，可以生产区块。

![确定是否是Winner](https://img.learnblockchain.cn/2019/11/28/006.jpg)

整个逻辑非常清楚，计算过程也没有复杂的计算，最复杂的计算也就是签名。目前的区块生成流程没有必要使用GPU。问题来了，下一版本的区块生成流程变了。

## 下一版本的节点选举流程

下一版本的区块链生成流程，没有公开源代码。但是，在[Filecoin的设计文档](https://filecoin-project.github.io/specs/#algorithms__proof_of_spacetime__election_post)已经有体现：

![Filecoin的设计文档](https://img.learnblockchain.cn/2019/11/28/007.jpg)

PoST的部分多了一个算法：Election PoST。Election PoST，目的是在生成区块的时候，绑定PoST的计算。也就是说，一个节点需要生成区块，必须提供PoST的计算和证明。

设计文档给出了大致的生成区块的算法：

* 随机数生成（Sample randomness）

  也就是从前面一些区块获取一个Ticket，并签名，签名结果作为随机数。

* 确定Partial Ticket

  从上述获取的随机数，确定K次挑战的Sector以及相应的数据。由这些数据，上一步骤生成的随机数和节点的ID生成Partial Ticket。

* 生成PoST证明

  如果Partial Ticket的系数小于节点的存储率的话，说明节点是Winner，可以生成区块。在生成区块前，必须生成PoST证明。

显而易见，新的区块生成流程，需要在一个区块时间内，生成PoST证明。PoST证明生成，涉及K次零知识证明（zk-SNARK）的证明计算，相当来说，计算时间较长。通过GPU加速，可以缩短PoST证明的时间。

## 总结：

Filecoin采用了新的节点选举算法，在区块生成时，必须提供PoST的证明。新的设计导致对PoST证明的性能有要求。GPU是目前加速PoST证明生成的可行方案。

本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。