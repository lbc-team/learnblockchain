---
title: 零知识证明 - 再谈EYBlockchain
permalink: EYBlockchain2
un_reward: true
hide_wechat_subscriber: true
date: 2019-07-08 15:10:54
categories: 基础理论
tags: 
    - 密码学
    - EYBlockchain
    - 零知识证明
author: Star Li
---

上次我写了一篇[ EYBlockchain 在以太坊上创建隐私币](https://learnblockchain.cn/2019/06/13/EYBlockchain/),
最近有点时间，重新看了看EYBlockchain的源代码，对EYBlockchain的理解又深入了不少。画了一些图，分享给有需要的小伙伴 :)

整个EYBlockchain是基于Ethereum的Web3接口之上搭建，主要由五个模块组成：accounts（账户管理），database（数据存储），whisper（节点间消息交互），PKD（存储public key），zkp（零知识证明处理）。zkp是EYBlockchain核心逻辑，提供了[以太坊上智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)的实现，几种操作的电路描述，以及使用ZoKrates实现零知识证明。在这些模块之上，提供了统一的API-Gateway。UI调用API-Gateway完成相关功能。



<!-- more -->

## 架构图

![架构图](https://img.learnblockchain.cn/2019/07/09_351547453.webp)


## 账号
从用户的角度（UI）来看，EYBlockchain只需要用户名和密码。EYBlockchain内部会根据用户密码生成以太坊公钥和私钥以及whisper的公钥和私钥。

![账号体系](https://img.learnblockchain.cn/2019/07/09_933940070.webp)

## 合约

EYBlockchain在以太坊上需要部署7个智能合约。PKD实现公钥的查询，GM17实现零知识证明的验证。FToken是ERC20智能合约（也就是OPS代币合约），FTokenShield是ERC20对应的隐私交易合约。NFToken是ERC721智能合约，NFTokenShield是ERC721对应的隐私交易合约。Verifier Registry智能合约实现零知识证明验证密钥的注册。

![合约](https://img.learnblockchain.cn/2019/07/09_416250984.webp)

EYBlockchain采用UTXO模型。在FTokenShield智能合约中，生成一个UTXO称为commitment，消耗一个UTXO称为nullifier。在FTokenShield合约中，主要维护了两个数据结构：

1. 所有commitment组成的merkle树（commitment作为树的叶子节点）
2. 所有nullifier数组。

![ERC20 Shield ](https://img.learnblockchain.cn/2019/07/09_626635509.webp)

以下是ERC20代币的三种操作：Mint（从普通的ERC20代币生成隐私的代币），Transfer（隐私代币转账），Burn（从隐私代币转回为普通ERC20代币）。每一种操作都会通过零知识证明生成相应电路的证明。


![Mint](https://img.learnblockchain.cn/2019/07/09_488375166.webp)
![Transfer](https://img.learnblockchain.cn/2019/07/09_662360197.webp)


以Transfer为例，相应的证明电路需要证明如下一系列的等式成立。

![Transfer-zk_SNARK](https://img.learnblockchain.cn/2019/07/09_608303935.webp)

![Token Burn](https://img.learnblockchain.cn/2019/07/09_88390361.webp)


理解zk-SNARK，需要了解一些术语：Circuit（电路），R1CS，QAP，Groth16。一个计算可以由一系列的“乘法门”和”加法门“组成，称之为”电路“。每个门电路可以通过向量点乘的方式生成R1CS。R1CS通过一定的转换可以生成QAP问题。一旦有了[QAP问题](https://learnblockchain.cn/2019/05/07/qsp-qap/)的描述，Groth16能生成相应的证明。对这些术语还不太了解的小伙伴，可以查看之前的文章深入了解零知识证明算法。[Groth16](https://learnblockchain.cn/2019/05/27/groth16/)是Groth在16年提出的算法，GM17是Groth在17年提出的增强算法。

![](https://img.learnblockchain.cn/2019/07/09_186067194.webp)

EYBlockchain使用ZoKrates的工具生成零知识证明。ZoKrates集成了libsnark和bellman代码库，实现电路的生成和Groth16的生成。使用ZoKrates需要提供相应的电路的描述（DSL语言）。提供了电路，就能使用ZoKrates设计的5个接口生成证明和验证。EYBlockchain使用了BN128椭圆曲线以及GM17零知识证明算法。

![ZoKrates](https://img.learnblockchain.cn/2019/07/09_51035365.webp)

EYBlockchain实现了基于以太坊的隐私交易，但目前还有一些值得探讨的点：

1. zk-SNARK需要预先生成CRS，也就是可信的预先设置。

2. Whisper目前不支持持久化消息存储，可能需要Whisper的MailServer功能来解决。

3. EYBlockchain使用的Hash算法是sha256算法，但是裁剪为216位。

4. EYBlockchain生成一个交易在一般的机器上需要10分钟左右。Gas的消耗大约为650w。可能用Zcash使用的BLS12_381椭圆曲线能提升性能。

![](https://img.learnblockchain.cn/2019/07/09_957694073.webp)

总结：
EYBlockchain在ZoKrates零知识证明的基础上，实现了以太坊上隐私交易的能力。EYBlockchain在以太坊上发行两种代币：EYT（ERC721）和OPS（ERC20），并针对这两种代币提供隐私交易的能力。EYBlockchain存在一些需要进一步考虑的问题：可信设置，Whisper消息的持久化，性能较低等等。




本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
