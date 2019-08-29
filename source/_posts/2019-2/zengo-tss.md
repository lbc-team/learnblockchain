---
title: 了解下不用助记词的ZenGo钱包及门限签名技术
permalink: zengo-tss
date: 2019-07-27 15:10:54
categories: 基础理论
tags:
    - 阈值签名
    - 私钥
    - 钱包
    - 密码学 
author: Tiny熊
---

区块链钱包作为数字货币世界的入口，它糟糕的体验把大部分人挡在门外，说的就是你：助记词备份（或私钥备份）。
现在一个激动人心的签名方案让体验提升一大步，也是博客的主角：门限签名技术(Threshold signatures: 也可翻译为阈值签名)及ZenGo钱包。

ZenGo钱包不需要备份助记词，交易也不需要输入密码，一切只需要FaceID/TouchID。

<!-- more -->

## 私钥是一切

在数字货币里拥有账户的私钥就表示拥有了资金的所有权，助记词则是推倒出私钥的一种方式，我有另一遍文章介绍过[助记词与私钥的推倒关系](https://learnblockchain.cn/2018/09/28/hdwallet/)，这里不复述。

为了保证资金的安全，助记词（或私钥）的保管就需要足够的小心， 一方面我们要进行备份，乙方私钥丢失，另一方面由于备份也会增加被盗风险，这也是钱包糟糕的体验的一大原因（貌似安全和体验无法兼得）。

为了提高资产的安全性，尤其是大额资产，目前通常有这两个方案：多签签名（MultiSig）和 密钥共享（Secret Sharing）模式。

> 门限签名(TSS)方案可以理解为是这两个方式的结合，所以先介绍这两个方案。

## 多签签名 MultiSig

如果大额的资产，通常会使用多签（MultiSig）的方式来分担风险与责任，多签通常需要有多个私钥（N），只有当其中的M个私钥参与的签名，才可以动用资产，因此正确使用（不把私钥放在一起，由不同的人保管），确实可以提高安全性，因为即使部分私钥被盗或丢失，资产依然是安全的。

![多签签名](https://img.learnblockchain.cn/2019/07/15641053844650.jpg)
<p class="image-caption">多签：一个有多把钥匙的保险柜</p>

使用多签签名时，还应该避免私钥复用，私钥复用会增加私钥泄漏的风险。

多签签名通常使用链上合约（或脚本）实现，这也给多签带来一个缺点：需要支付更高的交易费用以及多人异步签名导致的更长的交易确认时间。

## 密钥共享（Secret Sharing Scheme）模式

密钥共享模式 (简称：SSS) 通过将密钥**分成多个部分并以冗余方式分开保管**，发起交易则将一定数量的密钥重新组装为密钥进行签名，这个方案也可以密钥被盗的分享，同时解决了上述多签费用高的缺点。不过SSS 有一个主要缺点:当密钥被重新组装时，会为攻击者提供了获取密钥的可乘之机。

![](https://img.learnblockchain.cn/2019/07/15641056644736.jpg)
<p class="image-caption">密钥共享：一个把钥匙分层多个部分</p>

## 门限签名(Threshold signatures)方案

门限签名方案(简称：TSS）则结合 SSS 和多签的优点，它基于多方安全计算 (MPC: Multi-Party Computation ) 使用多个分片(目前是两个部分)的秘钥轮流进行（交易）签名，生成最终有效的签名。大家可以理解为：**先用一个钥匙旋转一个角度，再用另一个钥匙旋转一个角度才可以打开保险柜。**

> 技术细节可以阅读[ZenGo 说明](https://zengo.com/security-in-depth/)和[论文：Fast Secure Two-Party ECDSA Signing](https://eprint.iacr.org/2017/552.pdf)

门限签名方案跟前面多签和 SSS 方案不同的是：

* 多签通常是需要 M/N 个签名，而门限签名（目前）需要多方都参与签名。
* 多签通常是链上进行的，费用较高，并且不同的链多签的实现方案差别很大。而门限签名是链下的纯密码学的计算生成签名，兼容性更强。
* 多签是可以异步进行签名，而门限签名要求所有参与方在操作过程中都同时在线。
* 和 SSS 也不一样，SSS虽然分片密钥，但是最终要重构出密钥来签名，那么就存在单点故障和重构出的密钥被泄露的可能。而门限签名不需要重构出密钥。


## ZenGo 钱包

ZenGo 钱包则运用了门限签名方案，它使用两个独立（部分）秘钥来取代传统的单个私钥模式。其中一个秘钥保存在手机上（用 TouchID/FaceID 授权访问），另一个存储在 ZenGo 服务器上，在进行交易的时候，手机和 ZenGo 服务器通信共同完成签名。

实际使用时，ZenGo体验很好，强调 Keyless 概念，只需要touchID或faceID 授权就可以进行交易。

![](https://img.learnblockchain.cn/2019/07/15641073232482.jpg)

**注意**：ZenGo仅用来做交易签名，服务器和设备进行通信签署交易，通信过程不会相互暴露秘钥，仅仅是对签名后的数据进行通信。

ZenGo的方案只要两部分不同时发生问题（如泄漏），可以确保资产总是安全的， 我们分别考虑下设备丢失和ZenGo服务关停的问题。

### 设备丢失（或盗窃）怎么办？

当设备丢失（或盗窃）时，获得设备的人由于没有我们的 `TouchID/FaceID` ，可以确保我们的资金不会被转移。

那么如何取回自己的资产呢？ ZenGo 钱包提供了一个对设备部分的秘钥备份的方案：设备秘钥通过加密之后存储在 ZenGo 服务器上, 而对应的解密秘钥则单独存储在个人 iCloud 帐户中，通过两步认证授权恢复解密秘钥。

因此只要设备丢失和icloud关停两件事情不同时发生，就可以还原出设备部分秘钥，从而取回资产。


### ZenGo 服务关停怎么办？

尽管ZenGo宣称有最好的安全性和稳定性，ZenGo同样提供了方案应对ZenGo服务关停的风险：

ZenGo 构建了**第三方独立**的托管服务 [Escrow](https://www.escrowtech.com) 和 监听服务[Trustee](https://jrgtax.co.il/en/) 。

Escrow 可以理解为是ZenGo服务器的一个备份，而 Trustee 则会监听 ZenGo 服务的状态，当 Trustee 发现ZenGo 服务关停时，它会请求 Escrow 把对应的秘钥转移到每个用户Github账号。这种情况ZenGo钱包（客户端）会进入恢复模式，从而还原私钥，这个私钥可以直接进行交易签名进行资产转移，也可以把这个私钥导入到其他的钱包。

细节可阅读参考文章4和5, 以下是一个恢复模式的示意图：

![ZenGo 恢复模式](https://img.learnblockchain.cn/2019/07/15641092601378.jpg)


## ZenGo 开源与悬赏

ZenGo 可谓业界良心，不单提供了解决方案还开源了代码[Github](https://github.com/KZen-networks)
同时为了提高安全性，ZenGo 开启了[悬赏计划](https://zengo.com/the-zengo-challenge-win-1-btc-and-prove-us-wrong/)，如果你发现什么漏洞，1个BTC在等着你。


## 参考文章
1. [Threshold Signatures: The Future of Private Keys](https://medium.com/zengo/threshold-signatures-private-key-the-next-generation-f27b30793b)
2. [Threshold Signatures Explained](https://www.binance.vision/security/threshold-signatures-explained)
3. [Keyless security in a nutshell](https://zengo.com/security/)
4. [Guaranteed access](https://zengo.com/how-zengo-guarantees-access-to-customers-funds/)
5. [Guaranteed access solution](https://zengo.com/a-deep-dive-into-zengo-guaranteed-access-solution/)

加入最专业的[区块链问答社区](https://learnblockchain.cn/images/zsxq.png)，和一群优秀的区块链从业者一起学习。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态，有问题到[区块链问答社区](https://learnblockchain.cn/images/zsxq.png)。

