---
title: Zcash - 图解Transaction结构
permalink: nullifier-hash
date: 2019-08-01 10:10:54
categories: Zcash
tags: 
    - Zcash
    - 零知识证明
author: Star Li
---

最近又重新看了看ZCash的白皮书。话说，看ZCash的白皮书需要一点耐心，144页的白皮书形式化太多，通篇就只有一张图（地址和Key生成关系图）。本文画图总结了Sprout和Sapling的交易Transaction的数据结构。

<!-- more -->

经过Sprout和Sapling两次升级，目前ZCash中Transaction中集成了三种交易：
1. 透明交易
2. JoinSplit（Sprout）
3. Spend/Output （Sapling）

## Sprout

![](https://img.learnblockchain.cn/2019/08/15646253495027.jpg)

Sprout使用JoinSplit结构表示一笔交易。JoinSplit中的Vold和Vnew实现了隐私和透明交易的交易金额的平衡。rt是Note commit形成merkle树的树根。nf和cm分别是Nullifier和Note的commitment（在Sprout都是使用的sha256算法）。Note，Note Plaintext， 以及Nullifier相对直白。

### JoinSplitSig

JoinSplitSig对整个Transaction数据使用私钥进行签名，保证Transaction的数据不被篡改。签名的数据要被验证，必须提供“公钥”。在ZCash的框架中，隐私考虑，转账双方的“公钥”都不能公开。为了能提供签名，就只能重新生成临时的“公钥”/“私钥”对（JoinSplitPublicKey, JoinSplitPrivateKey）。用JoinSplitPrivateKey对整个Transaction的“SIGHASH_ALL"的结果进行签名，生成JoinSplitSig。

### hsig 和 h

hsig是一个比较有意思的设计。试想，如果只有JoinSplitSig机制，虽然保证了Transaction数据的完整性，但并没有保证签名本身不能变。完全可以在Transaction其他数据不变的情况下，重新生成JoinSplitPublicKey，从而生成新的JoinSplitSig。hsig就是为了解决这个问题。hsig“绑定”所有的nf的数据和当前使用的JoinSplitPublicKey。并且，使用每个nf中对应的“私钥”，对hsig进行hash计算，生成h。也就是说，每个nf对应的私钥都“授权”使用当前的JoinSplitPublicKey。这样，JoinSplitPublicKey就不能随意修改，要做改动，必须知道每个nf对应的“私钥”。

### Cenc

Sprout使用的是"In-band secret distribution"。简单的说，需要传输给转账对方的信息（Note plaintext），加密后存储在链上。采用这种方式，转账对方不需要实时在线，任何时候都能同步链上数据确认交易。和JoinSplitSig一样的思想，转账对方的信息不能直接作为加密密钥。先随机生成epk/esk，再和pkenc结合，生成加密密钥。

## Sapling

![](https://img.learnblockchain.cn/2019/08/15646287642674.jpg)


Sapling是一个比较大的升级，零知识证明的性能提升了十几倍。Sapling不用JoinSplit结构表示交易，而是用SpendDescription和OutputDescription直接表示“花费”和“支出”。一个比较重要的设计是：valueBalance，SpendDescription中的cv以及OutputDescription中的cv都是value的同态commit。所谓的同态commit，就是value的计算后的commit和commit再计算的结果相等。

### spendAuthSig

SpendDescription中的spendAuthSig是对整个SpendDescription进行签名。和Sprout签名的思想类似。先随机出rsk和rk密钥对，再使用rsk进行签名，同时把rk放在SpendDescription中。

### Cenc和Cout

Sapling同样使用的是"In-band secret distribution"。Cenc是对Note Plaintext进行加密的结果。和Sprout类似，加密的密钥由esk和pkd生成。Sapling比Sprout设计了更多的密钥“权限”。众多密钥中，有个ovk（outgoing viewing key），也就是拥有ovk，可以查看outgoing的交易。原理很简单，就是用ovk将esk和pkd加密，生成Cout。

### bindingSig

bindingSig也是整个Transaction数据的签名。签名使用的公钥/私钥（bvk/bsk）是通过cv以及生成cv时采用随机数生成。因为同态commit的算法保证bvk=bsk*R (R是生成元)，所以，bsk和bvk存在公钥/私钥关系。bingdingSig就是用bsk对整个Tansaction签名的结果。

## 总结：

ZCash的白皮书形式化描述比较多，看完整理需要耐心。ZCash已经经过了三个阶段：Overwinter，Sprout和Sapling。画图总结了Sprout和Sapling的交易数据结构，更直观理解ZCash的隐私设计。



本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
