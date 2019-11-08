---
title: 二层扩容新秀 - ZK Rollup 简介
permalink: zk-rollup
un_reward: true
date: 2019-11-07 13:55:22
categories: 
    - 扩容技术
    - Rollup
tags: 
    - ZK Rollup
    - 零知识证明
author: PPLabs
---

本文来自PPLabs， PPIO 是为开发者打造的去中心化存储与分发平台，让数据更便宜、更高速、更隐私。官方网站是 [https://pp.io](https://pp.io/)。

<!-- more -->

![Rollup](https://img.learnblockchain.cn/2019/11/15731198384395.jpg)

## 背景

区块链公链自诞生以来，虽然大大降低了信任的门槛，但一直面临着一个效率问题：即 TPS 不高。例如比特币每秒仅支持7笔交易，而目前的以太坊也仅支持每秒 15 笔左右的交易。这样的 TPS 很支持大型应用。因此业界很多技术人员尝试为区块链扩容。目前扩容方案主要有两类：


* Layer 1 扩容方案，即直接增加链上的交易处理能力，这种方式也被称为链上扩容。常见的技术方案有：Sharding 和 DAG；

* Layer 2 扩容方案，即将链上的相当一部分工作量转移到链下来完成。常见的技术有：State Channel, [Plasma](https://learnblockchain.cn/categories/scaling/Plasma/), [Truebit](https://learnblockchain.cn/categories/scaling/TrueBit/) 和 最近比较火的 zk Rollup。

ZK Rollup 并非新概念，@barrywhitehat 在一年前提出，目前由 Matter Lab 和 den3 进行工程实现。

## 原理

* 那么，zk Rollup 背后的原理是什么？

zk Rollup 的本质是将链上的用户状态压缩存储在一棵 Merkle 树中，并将用户状态的变更转移到链下来，同时通过 zkSNARK 的证明来保证该链下用户状态变更过程的正确性。在链上直接处理用户状态的变更成本是比较高的，但是仅仅利用链上的智能合约来验证一个零知识证明的 PROOF 是否正确，成本是相对低很多的。另外必要的转账信息也会被和证明一起提交到合约，方便用户查账。

## **两类角色**

zkRollup 系统中包含两类角色：transactor 和 relayer。

* transactor，即普通用户，对应以太坊上的外部账户。用户构建转账交易并用私钥签名，然后将交易发送给 relayer。

* relayer 负责收集并验证用户的 transaction，之后将 transaction 批量打包，并生成 zkSNARK 的 PROOF，最终将用户 transaction 中的核心数据和 zkSNARK 的 PROOF 以及新的全局用户状态的 Merkle 根提交到链上的智能合约。

当然 relayer 不会免费为 transactor 提供服务，毕竟 relayer 向链上提交证明和数据是需要消耗 gas 的。因此，transactor 向 relayer 发送的交易里，也必须包含相应的手续费。

## **状态迁移函数**

当 relyer 收到 transaction 后，必须 “执行” 它。transaction 的执行，本质上是改变相关账户的状态，而 STF 就是改变账户状态的函数。STF 是状态迁移函数(state transition function)的缩写。

状态是针对状态机而言的，每个状态机在某一时刻都有一个状态。我们可以假设某状态机的初始状态是 S[0]。当某个 Action T[1] 作用在该状态机上时，状态机的状态发生了迁移。我们可以用以下式子来表示迁移过程。

```
S[1] = STF(S[0], T[1])
```

这里，S[0] 是初始状态，S[1] 是状态机执行 Action T[1] 之后的状态。

紧接着有新的若干 Action T[2], T[3], ..., T[n] 继续作用在该状态机上，则状态机的状态依次发生迁移。


```
S[2] = STF(S[1], T[2])
S[3] = STF(S[2], T[3])
...
S[n] = STF[S[n-1], T[n]]
```


简单地，我们也可以将 T[1], T[2], ..., T[n] 看作一个整体，则状态迁移过程可以简化为：

```
S[n] = STF(S[0], T[1], T[2], ..., T[n])
```



更一般地，假设当前状态机的状态是 PRE_STATE，然后有 n 个 Action T[1], T[2], ..., T[n] 依次作用到状态机上，之后状态机的状态是 POST_STATE，此可以表示为：



```
POST_STATE = STF(PRE_STATE, T[1], T[2], ..., T[n])
```


如果将以上 Action 换成转账交易 transaction，把 系统中的账户集合看作是一个状态机，那么整个过程也就是链上交易执行的过程了。交易的执行，使得整个链上的全局状态发生变化。链上的全局状态也就是各个账户的状态集合，将所有账户的状态组成一棵 Merkle 树，树的叶子节点是账户状态，树的根可以直接用来表示状态集合。因此，上述的 PRE_STATE 和 POST_STATE 也就是全局账户状态树的根。

## **账户状态模型**

刚才我们提到链上的整个系统中的账户状态，可由一棵 Merkle 树来管理。Merkle 树的叶子节点，即用户的状态信息。同样，链下扩容方案 zk Rollup 也可以用类似的 Merkle 树来组织其账户状态。

![由Merkle树管理的账户](https://img.learnblockchain.cn/2019/11/15731759495151.jpg)



最简单的账户状态可以包含：账户的 public key，nonce 和 balance。而叶子节点在Merkle 树中是有唯一位置的，因此位置的索引信息可间接引用这个账户信息。

如果我们用3个字节来表示这个索引信息的话，那么这棵 Merkle 树总共可以支持 2^24 = 16,777,216 个账户。这对于一般的系统来说已经足够。因此，以太坊为例，账户地址可以由 address 的 20个字节 转为 Merkle 树的叶子节点索引 3 个字节。这样账户地址就被“压缩”了。

除了对账户地址进行压缩，我们也可以对转账金额数据进行压缩。例如，在以太坊上金额用256位的大整型来表示，但是实际使用过程中几乎很少用到超大金额和超小的金额。因此如果我们就假设系统中转账的最小单位是 0.001 ETH，并且用 4 个字节来表示转账金额的话，我们就可以支持 0.001 ~ 4,294,967.295 ETH 的转账，这对于一般的系统来说也已经够了。如果还不够可以适当再增加字节来表示金额，或者引入浮点数表示方式。

手续费与转账金额类似，实际手续费会在一定的范围之内浮动，因此我们也可以为手续费设定一个最小单位，例如：0.001 ETH。然后用 1 个字节来表示 0.001 ~ 0.255 ETH 的手续费。这里的手续费也就是 transactor 向 relayer 支付的手续费。

同样，我们假设在正常使用环境下一个账户的转账次数不会达到上万次，因此用2个字节来表示账户的 nonce 也差不多够了，因为 2 个字节 可以表示的范围达到 0~65535。

最后签名字段不能压缩，以以太坊为例，签名 (r, s, v) 总共需要 65 个字节。但实际的zk Rollup 系统中使用 EdDSA的较多。

因此，一个 transaction 的格式大体如下：

![zk Rollup交易格式](https://img.learnblockchain.cn/2019/11/15731765563034.jpg)


以上 transaction 各字段的长度仅作参考，在实现具体系统的时候需要根据实际情况调整字段长度，以防止发生字段溢出的情况，但原则上还是能省则省。因为交易数据越少，在相同存储容量的前提下，所能容纳的交易数也就越多。

## **证明和验证**

了解了状态迁移函数和账户状态模型后，我们再来了解下 relayer 收集 transaction 后做了些什么。

我们刚才提到在 zk Rollup 的系统里，所有用户的账户信息由一棵 Merkle 树管理。而 Merkle 树的根被记录在了链上的智能合约里，这个根的值也代表着整个系统当前所有账户的状态。当有用户发起转账 transaction 时，这个状态就要发生改变。但改变必须依照规则进行。

* 首先，必须要确保 transaction 的合法性：
    * 转出账户是否有足够的钱支付转账金额和手续费
    * 转出账户的 nonce 是否正确
    * 转账 transaction 的签名是否正确

* 接着，relayer  执行该转账 transaction，修改 Merkle 树中的转出账户和转入账户的叶子节点，然后重新计算新的 Merkle 树的根。

* 重复第二步，relayer 会按照先后顺序一次性处理多个 transaction，然后将最后计算得到的 Merkle 树的根作为新的状态提交到链上合约中。

    
但上述流程存在问题：如果仅提交状态树的根到合约，那么用户如何相信新的状态根是如实地根据上述逻辑计算出来的。万一 relayer 作恶，故意调大 transaction 的手续费呢？

解决这个问题的一个方法是：要求 relayer 提交状态树的根到合约时，同时也将所有 transaction 提交到合约，这样任何人都可以根据这些 transaction 来验证 relayer 在计算新的状态树时，有没有作弊。但这等于是将所有链下的数据搬回了链上，没有实现 layer 2 扩容的目的。

利用[零知识证明](https://learnblockchain.cn/categories/zkp/)就可以很好地解决这个问题。zk Rollup 中的 zk 也就是 zero-knowledge 的缩写。relayer 在收集了一系列的 transactions 后，需要用预先定义好的 ZK circuits 来生成一个 PROOF：

* 确保每个交易 T[1], T[2], ..., T[n] 中的 nonce, value, fee 等值都没有问题，且 signature 正确。

* 确保状态迁移过程没有问题，即 `STF(PRE_STATE, T[1], T[2], ..., T[n]) = POST_STATE`

* 然后将这个 PROOF 与 POST_STATE, t[1], t[2], ..., t[n] 一起提交到链上合约。其中 t[1], t[2], ..., t[n]是 transaction 的简化信息，不包含 nonce 和 signature。所以 t[i] 比 T[i] 更小。

然后智能合约只需要验证这个 PROOF 是否正确。如果 PROOF 正确且合约中保存的状态与 PRE_STATE 相等，那么新的状态 POST_STATE 将会被记录到合约中，替换原有状态。

由于 relayer 必须生成 zkSNARK 的 PROOF，然后才能向合约提交，因此如果 relayer 作恶 修改用户的 transaction，那么 PROOF 将无法被验证通过。

另外，由于提交到链上的交易 t[1], t[2], ..., t[n] 是不包含 nonce 和 signature 的，因此上链的数据将会变得更小（上例中每个 transaction 仅会有11个字节上链）。

此时，relayer 由于证明的限制，已经无法修改用户的 transaction。但是 恶意的 relayer 依然可以拒绝为某个 transactor 服务，不搜集该 transactor 的 tranaction。为了防止这种行为，合约上必须支持 on-chain withdrawal，也就是任何一个 transactor 都可以从链上将自己的 token 提走。

## **zk Rollup 目前的应用**

目前一个典型的 zk Rollup 应用场景是去中心化的交易所，其代表是 [Loopring DEX Protocol (v3)](https://github.com/Loopring/protocols/blob/master/packages/loopring_v3/DESIGN.md)。有兴趣的小伙伴可以深入研究一下。

此外，开源的 zk Rollup 框架还有：

* [barryWhiteHat/roll_up -C++](https://github.com/barryWhiteHat/roll_up)

* [matter-labs/rollup - rust](https://github.com/matter-labs/rollup)

## **总结**

zk Rollup 是一种新型的 Layer 2 扩容方案，该技术的核心思想是：

* 将主链作为存储媒介，而非共识引擎 ；

* 将交易压缩，并在链下达成状态共识 ；

* 用零知识证明保证链下状态共识的安全性。

目前，zk Rollup 最典型的应用场景是去中心化的交易所。

PPIO 也在积极探索 zk Rollup 技术，并尝试将其应用到 去中心化的带宽和存储交易领域中去。

## **参考文献**

* [ZK Rollup: scaling with zero-knowledge proofs](https://pandax-statics.oss-cn-shenzhen.aliyuncs.com/statics/1221233526992813.pdf)

* [Transcript: Scalable blockchains as data layers | Vitalik Buterin](https://medium.com/@trenton.v/transcript-scalable-blockchains-as-data-layers-vitalik-buterin-11aa18b37e07)

* [The Dawn of Hybrid Layer 2 Protocols](https://vitalik.ca/general/2019/08/28/hybrid_layer_2.html)

* [Scalable blockchains as data layers](https://docs.google.com/presentation/d/1EVjrZhoxw-ikzelFGGv7czxuJsIIWfl5I-CPIlnjsME/edit#slide=id.g5274d763f8_0_24)

* [ZK Rollup: Ethereum Scalability with ZKPs](https://www.youtube.com/watch?v=QyM9qdFKsEA)

* [On-chain scaling to potentially ~500 tx/sec through mass tx validation](https://ethresear.ch/t/on-chain-scaling-to-potentially-500-tx-sec-through-mass-tx-validation/3477)

* [去中化心交易所loopring 3 ](https://github.com/Loopring/protocols/blob/master/packages/loopring_v3/DESIGN.md)



想了解更多有关 PPIO 的信息，可以移步官网：[pp.io](http://pp.io/) 或关注公众号：

![](https://img.learnblockchain.cn/2019/11/15731800506349.jpg)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客。
