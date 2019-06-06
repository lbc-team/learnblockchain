---
title: 区块链上的随机性（二） - Algorand、Cardano、Dfinity、Randao 项目分析
permalink: randomness-blockchain-2
date: 2019-04-22 20:47:58
categories: 区块链安全
mathjax: true
tags: 
    - 随机数
    - Algorand
    - Cardano
    - Dfinity
    - Randao
author: PRIEWIENV
---

本篇文章是上一篇文章[区块链上的随机性（一）概述与构造](https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/)的延续。作为区块链上的随机性系列文章的第二部分，本文介绍了目前主流的应用在区块链项目中的随机数协议，例如 Algorand、Cardano，Dfinity 和 Randao，并分析他们是如何使用第一部分所介绍的随机数协议核心以及它们的组合。

<!-- more -->

## 区块链项目中的应用

本本会介绍以下四个项目：`Algorand`、`Cardano`，`Dfinity` 和 `Randao` 分别是如何利用上述三种基本的方案构建随机数生成协议的。注意本文并不会专门详细解释这四个项目的共识算法，只会介绍最基本的框架以帮助读者理解共识协议和随机数算法之间的联系。

## Algorand


Algorand （参考[1]）项目使用了基于 PoS 的混合共识协议，其共识过程利用了随机抽签。它的随机抽签所依赖的种子，从本质上讲，是通过取前 $t(t=1)$ 个输入来生成的，对应 [随机性 概述与构造 文中的 v3.0b 版本](https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/#v3-0b)的第一种方式。如下图 1 所示，Algorand 的共识过程要求节点先在本地抽签，即通过一个**可验证随机函数 (Verifabale Random Function, VRF)** 在节点的本地算出来一个**可验证的确定的随机数**。

{% fi https://img.learnblockchain.cn/2019/15568093518095.jpg, 图 1：Algorand 的共识协议 %}
> 图 1：Algorand 的共识协议


VRF 可以被看作是一种特殊的伪随机数发生器，如下图 2 所示，输入为消息 $m$ 和用户的私钥 $sk$，输出为结果 $y$ 和证明 $π$。需要补充的一点是，这里的“确定”指的是，这样的随机数是无法被用户操纵的，因为输入是根据上一轮随机数生成过程的公共信息 $m$ 以及每个节点自己的私钥 $sk$，这些都是被确定下来而不受用户操纵的。其中私钥是可以被公钥验证的；公共信息是每个人都可以看到，是唯一确定的，并且可被其他人验证。本地抽签得到本地随机数之后，每个人会立马知道自己是否被选中（结果是否落在某些区间内）。
之后，被选中的人广播抽签结果、证明和候选区块到全网节点，根据区块的 priority (可被看作是依赖于抽签结果和用户所提交的区块的编号的一个函数) 大小选出来候选区块，而确定哪个区块的 priority 更大是需要做拜占庭共识的。这个时候，就需要再进行一轮本地抽签，所有的节点会自己知道是否被选中去做 BA（一个拜占庭类型的共识协议），即投票选自己认为的 priority 最高的候选区块。这样的 BA 投票会进行很多轮，每一轮都要重新进行一次本地抽签，以增加安全性，直到选出区块。

可以看出，Algorand 共识的本质就是我们每个人都生成一个确定的随机数，但是我们最终只想要一个随机数，这样我们才能根据最后确定的唯一的随机数去决定哪个块会被全网接受。这个时候的方案就是根据某种确定的规则从众多备选结果中取一个，方法是通过拜占庭共识达成一致。


{% fi https://img.learnblockchain.cn/2019/15568098326418.jpg, 伪随机数发生器 VRF %}
> 图 2：伪随机数发生器 VRF


## Cardano

Cardano （参考[2]） 是基于 Ouroboros （参考[3]） 的一个项目，采用了基于 PoS 的共识协议。Ouroboros 这篇论文给出了一个可证明安全的 PoS 协议框架，但是并没有给出具体的实现，实现由 Cardano 完成。因此这里主要讲解 Cardano 在工程上采用的一个具体的方案。
Cardano 所采用的方案也在[第一篇]((https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/))所讲的三种方式之中。如图 4 所示，它的方案其实就是就是无分发者的秘密分享 + 承诺，也就是 v2.0 和 v3.0b 中的第二种方法的结合版。图 3 简单描述了它的共识协议，在它的 Genesis Block 里面会初始化一个随机数 $η$ ，这个随机数 $η$ 会在接下来的一个 epoch 里发挥作用，再下一个 epoch 会重新抽取新的随机数。这样就可以利用确定的抽签算法以这个随机数作为随机信标来确定谁的区块会在之后的某个 slot (简单来讲，指的是按照时间等量划分的时间窗口) 里被接受。一个 epoch 里的 slot 的数量是固定的，因此，有可能有的 slot 中会有不止一个节点被抽中，也有可能没有节点被抽中，具体解决方案不在本文讨论范围内。那么，初始化的随机数是怎么生成的呢？

Cardano 协议首先采用了标准的承诺-揭示方案，不过在之后多了一个将随机数做一次无分发者的公开可验证秘密分享 (Publicly Verifiable Secret Sharing, PVSS) 的步骤。即分发碎片并且广播证明之后揭示随机数。这时也许有参与者会跑路，没有揭示随机数，但是没有关系，这个时候剩下的参与者可以通过广播碎片把跑路的参与者的随机数恢复了。
因此，这是一个有一定冗余度的随机数生成机制，但是同时带来了一定的健壮性。通过这个机制，只要恶意节点不超过一半，一定可以生成一个随机数。
 
 {% fi https://img.learnblockchain.cn/2019/15568100958144.jpg, Cardano 的共识协议  %}
> 图 3：Cardano 的共识协议

{% fi https://img.learnblockchain.cn/2019/15568101028575.jpg, 图 4：Cardano 的 DRB 模型 %}
> 图 4：Cardano 的 DRB 模型


## Dfinity

Dfinity （参考[4]） 的共识算法和 Algorand 很像，如图 5 所示，协议里同样需要选举一个委员会，委员会会运行**分布式随机信标 (Distributed Randomness Beacon, DRB) 协议**得到随机数种子。这个协议后文会讲，为了理清共识协议的基本步骤，我们先假设 DRB 协议可以达成这些功能。
通过这个随机数种子，加上每个节点自己的私钥，每个节点通过运行可验证随机函数 (VRF) 就可以算出自己的排名（这一点和 Algorand 一样）。同时，由于所有节点都会被分组，那么每一个节点应该被分配到哪一个组也是由随机数种子决定的。在所有的组中，再次通过随机数种子（上一轮）随机挑选出一个组，称之为该轮的委员会。每个节点有了自己的节点排名后，所有节点都可以提交候选区块，广播给所有的节点，但是大家在广播的过程中，诚实节点就会根据排名，给目前为止它收到的排名最高的块签名，签好后，广播给所有的节点，如果某一个区块获得 $1⁄2$ 以上的合法签名，这个区块被称之为已验证的区块。一旦诚实节点收到已验证的区块，这一轮就会立马结束，并将这个已验证区块广播给所有其他节点。

{% fi https://img.learnblockchain.cn/2019/15568102621410.jpg , Dfinity 的共识协议 %}
> 图 5: Dfinity 的共识协议

由此可见，DRB 协议生成的随机数种子至关重要。Dfinity 所采用的 DRB 协议实际上就是 v3.0b 的第三种方法——分布式密钥生成 + 门限签名。首先要有一个 DKG 协议来生成符合一定要求的总密钥对和密钥对份额，这个协议同样可以是 $(t,n)$ 门限的。通过这个协议，每个人获得密钥对份额，但是没有人知道总私钥是什么。每个节点使用自己的私钥份额对再上一个轮次的随机数和轮次进行签名，签完名将签名结果广播，每个节点都可以用总公钥验证每个签名。然后通过门限签名的恢复算法使用 $t$ 个签名恢复出来这一轮的总签名（相当于是使用总密钥对直接进行签名的结果）。整个过程的算法都是完全确定的，唯一不确定的是每个节点不知道其他节点的私钥份额是什么。Dfinity 比较特殊的地方在于采用基于 BLS 的门限签名，比起其他的门限签名方案，好处有两个。第一个好处就是一次购买，终生免费。协议只需要在一开始的阶段运行一次 DKG，进行密钥生成。之后的阶段只需要 $n$个人中 $t$ 个人提交有效的签名就可以生成随机数，协议就可以运行下去，这个过程是异步的。第二个好处就是确定性，无论哪 $t$ 个人提交，最后生成的随机数都是一样的确定的结果，没有节点可以操纵最后的结果（不超过安全边界的情况下）。
 
 {% fi https://img.learnblockchain.cn/2019/15568102786802.jpg , 图 6: Dfinity 的 DRB 模型 %}
> 图 6: Dfinity 的 DRB 模型 


## Randao

Randao （参考[5]） 是基于[以太坊合约](https://learnblockchain.cn/2017/11/20/whatiseth/)的，用于在链上生成智能合约可用的随机数的一个项目。它采用的是 [区块链上的随机性概述与构造 文中的 v3.0a ](https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/#v3-0a)的方案。每个人在提交承诺的时候，都需要提交 $m$ 个 ETH 的押金，揭示过程会持续 $w$ 个区块时间。
这里有三件事需要说明:
第一点是，同一个地址的多个承诺只接受第一次。
第二点是收集的全网提交的承诺数有最小数量的要求，如果没有收集到最够的数量，整个协议就会以失败的状态结束，然后再重新开始。
第三点就是不按时揭示的地址的押金会被没收，并且一旦有人不揭示，协议就会以失败的状态结束，这样做为了确保随机数的公平性。协议的最后一步是 Randao 特别加入的——返还押金，给参与者奖励的步骤，其目的是给出激励，构建生态。
 
 {% fi https://img.learnblockchain.cn/2019/15568103073888.jpg, 图 7：Randao 的 DRB 模型 %}
> 图 7：Randao 的 DRB 模型


## 随机数与共识


随机数生成与共识协议有着千丝万缕的关系，主要体现为以下两点。

防止女巫攻击的方法之一是不可预测的随机抽签。不论是 PoW，还是 PoS，我们都可以理解为一种随机抽签的方法。不管公有链上的共识协议再怎么设计，包括比特币在内，都是在通过某种方式产生一定的随机性。矿工通过 PoW 竞争出块，使得出块的人变得不确定，从而防止了通过伪装大量节点获利的女巫攻击。

> **女巫攻击**
> 简单来讲，指的是一种网络内的少数节点控制多重身份以消除冗余备份的作用的攻击方式

区块链上的随机数安全依赖于共识协议。以 Randao 为例，针对 Fomo3D 的攻击同样对 Randao 有效。由于[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)的激励机制和共识协议的特点，矿工会优先打包手续费高的交易，所以攻击者可以通过 Censorship Attack，人为调整打包区块时包含的交易，或者制造高手续费的垃圾交易，迅速的把区块的 Gas Limit 耗光，阻止其他人的特定交易上链。当 Randao 即将计算出的结果不理想时，可以通过这种方式强行将协议终止，令无辜的节点蒙受损失，自己从中获利。尽管这样的手段有时成本较高，但这样的攻击仍然有无法忽略的可能性发生，而这样的攻击之所以成立的原因，实际上根植于共识协议的设计。再例如 Grinding Attack。Fomo3D 采用了取上一个块的哈希值作为种子的方法生成随机数。这种情况下，矿工可以把所有的区块组织的可能性都试验出来，然后选择一种对自己最有利的方式打包交易。这种攻击手段就是 Grinding Attack。尽管这样的攻击手段有一定的成本，但是如果随机数所牵涉的利益足够，例如用在某些赌博游戏里，矿工想要从中获利非常容易。

因此，区块链上随机数的生成是需要上下文环境的，必须要给定情景。拿 Randao 来讲，如果它的某一个随机数的生成，只和 0.01 个 ETH 相关，那么攻击者将没有足够的理由去破坏它的公平性。如果押金不够多，那么 Randao 就有可能是不安全的。

## 参考文献

[1] Gilad, Yossi, et al. “Algorand: Scaling byzantine agreements for cryptocurrencies.” Proceedings of the 26th Symposium on Operating Systems Principles. ACM, 2017.
[2] “Cardano Settlement Layer Documentation.” Cardano. Web. 21 Apr. 2019.
[3] Kiayias, Aggelos, et al. “Ouroboros: A provably secure proof-of-stake blockchain protocol.” Annual International Cryptology Conference. Springer, Cham, 2017.
[4] Hanke, Timo, Mahnush Movahedi, and Dominic Williams. “Dfinity technology overview series, consensus system.” arXiv preprint arXiv:1805.04548 (2018).
[5] Youcai Qian. “Randao: Verifiable Random Number Generation.” Randao. Web. 21 Apr. 2019.


本文依照 BY-NC-SA 许可协议转载，[原文链接](https://blog.priewienv.me/post/randomness-blockchain-2/)。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。

