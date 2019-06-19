---
title: 利用 EYBlockchain 在以太坊上创建隐私币
permalink: EYBlockchain
un_reward: true
hide_wechat_subscriber: true
date: 2019-06-13 15:10:54
categories: 基础理论
tags: 
    - 密码学
    - EYBlockchain
    - 零知识证明
author: Star Li
---


前一段时间，介绍了几篇零知识证明文章：[入门zkSNARK](https://learnblockchain.cn/2019/04/18/learn-zkSNARK/)， [从 QSP 到 QAP](https://learnblockchain.cn/2019/05/07/qsp-qap/)，[Groth16 算法介绍](https://learnblockchain.cn/2019/05/27/groth16/)， 今天这篇文章分享下利用 EYBlockchain 在以太坊上创建隐私币。

<!-- more -->

## EYBlockchain 简介

EYBlockchain是在以太坊的基础上，提供隐私交易的能力。EYBlockchain目前的实现并不是传统意义上的链，并没有修改以太坊的代码。而是在ZoKrates（以太坊上 [zkSNARKs](https://learnblockchain.cn/2019/04/18/learn-zkSNARK/) 的工具箱）的基础上，利用以太坊上的智能合约，提供了以太坊上的比较完整的隐私交易的服务。在[以太坊智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)中，隐私交易的管理类似[Zcash](https://learnblockchain.cn/2019/05/23/anonymous-coin/)。

EYBlockchain的源代码为[Nightfall](https://github.com/EYBlockchain/nightfall), 白皮书在[这里](https://img.learnblockchain.cn/pdf/nightfall-v1.pdf) 。

[白皮书](https://img.learnblockchain.cn/pdf/nightfall-v1.pdf) 对EYBlockchain的愿景以及实现细节解释的比较清楚。

EYBlockchain在`ZoKrates`的DSL(Domain Specific Language)的基础上，提供了更人性化一些的语法。ZoKrates 使用`DSL`语言，也就是`.code`文件描述R1CS（门电路）。EYBlockchain 使用`.pcode`文件，先预处理成`.code`文件。EYBlockchain针对门电路预处理的代码[zokrates-preprocessor](https://github.com/EYBlockchain/zokrates-preprocessor)。

## 整体框架

![合约框架](https://img.learnblockchain.cn/2019/06/15604808029330.jpg)

EYBlockchain的核心模块是`offchain`和`ZKP`。`offchain`又分为两个功能模块：`whisper`提供了p2p通讯的能力，pkd（public key directory）存储了公钥。公钥包括两部分：1\. whisper本身的公钥 2\. 隐私交易的公钥（地址）。简单的说，offchain模块维护了线下的公钥，并提供了相互查询的功能。

ZKP是隐私交易的核心模块，在ZoKrates的基础上，实现零知识证明的证明和验证服务。EYBlockchain还提供了account模块，实现以太坊地址的生成。非链上的数据都存储在database模块中（目前用MangoDB实现）。

EYBlockchain采用的零知识证明的算法是GM17，也就是在2017年发表的[Groth16](https://learnblockchain.cn/2019/05/27/groth16/)的增强版本。


## EYBlockchain 源代码结构

EYBlockchain的源代码目录结构如下：

![Nightfall 代码结构](https://img.learnblockchain.cn/2019/06/code.jpg)

主要包含了一下几个部分：

* API-Gateway：API调用接口。
* accounts：以太坊账户地址创建。
* database：数据存储，用MangoDB数据库实现。
* offchain：实现whisper以及公钥的管理。
* zkp：隐私交易的核心逻辑，主要是零知识证明和验证的服务。
* ui：示例UI。

## 初始设置

在隐私代币生成和流通之前，必须进行初始设置。初始化设置包括两部分：

1. 零知识证明的证明密钥/验证密钥对；
2. 以太坊上部署智能合约。

注意，零知识证明的证明密钥和验证密钥对，必须由可信机制生成。

### 零知识证明的证明密钥/验证密钥对

EYBlockchain的隐私操作目前包括3个：隐私代币生成，转账和销毁。EYBlockchain目前支持[ERC20](https://learnblockchain.cn/2018/01/12/create_token/)/[ERC721](https://learnblockchain.cn/2018/03/23/token-erc721/)两种代币，所以目前总共有6种操作：`ft-mint`, `ft-transfer`, `ft-burn`, `nft-mint`, `nft-transfer`, `nft-burn` 。

> 注： ft 表示 Fungible Tokens,  nft 表示：Non-Fungible Tokens

![mint_pcode](https://img.learnblockchain.cn/2019/06/mint_pcode.jpg)

在生成证明密钥/验证密钥之后，在每个操作目录下会生成几个文件：

![mint_pcode2](https://img.learnblockchain.cn/2019/06/mint_pcode2.jpg)

* nft-mint-vk.json - 验证密钥的json文件
* verification.key - 验证密钥的原始数据
* proving.key - 证明密钥
* xxx-mint.pcode - pcode描述的门电路
* verifier.sol - ZoKrates生成的零知识验证智能合约。目前已经废弃。所有的零知识验证，通过统一的GM17.sol完成。

### 以太坊智能合约部署

在以太坊上部署如下的智能合约：

![部署隐私币合约](https://img.learnblockchain.cn/2019/06/0df7b9b3f163b79fb778dfd29bdfab45.jpg)


**FToken** - EY发行的[ERC20](https://learnblockchain.cn/2018/01/12/create_token/)的代币合约，EY OPs Coin，简称OPS。
**FTokenShield** - ERC20对应的隐私交易合约，管理所有隐私交易信息。
**NFToken** - EY发行的[ERC721](https://learnblockchain.cn/2018/03/23/token-erc721/)的代币合约，EYToken，简称EYT。
**NFTokenShield** - ERC721对应的隐私交易合约，管理所有隐私交易信息。
**GM17** - 零知识验证智能合约。
**Verifier Registry** - 提供两个功能：1\. 所有零知识验证的验证密钥注册 2\. 所有证明信息的存储。

在向Verifier Registry注册一个验证密钥后，智能合约会返回一个验证密钥编号（vkId）。

以下以ERC20为例，说明隐私交易的生成/转账/销毁逻辑。注意的是，隐私交易涉及的智能合约的交易计算量都比较大，目前代码中建议使用**6500000**的[Gas](https://learnblockchain.cn/2019/06/11/gas-mean/)油费。

## 隐私代币生成（Mint）

隐私代币生成的过程，就是从非隐私的OPS代币，到隐私代币的过程。注意的是，mint的过程本身并不是隐私的，发起账户和金额都是公开的。
![隐私币生成](https://img.learnblockchain.cn/2019/06/隐私币.jpg)

* **Step1** - 通过ft-mint的vkId，生成证明。公开信息为转账金额和（c，pk，r）三元组生成的hash值。私有信息为pk和r。r为随机数。

* **Step2** - 调用FTokenShield智能合约的mint接口，提交proof/公开信息以及vkId。

* **Step3/4** - 调用GM17以及Verifier Registry存储和验证proof。

* **Step5** - 在验证proof后，调用FToken智能合约，从发起者账户转账到FTokenShield。

值得一提的是，（c，pk，r）三元组生成的hash值，在FTokenShield会被组织成merkle树。hash值，也称为commitment，作为merkle树的叶子节点。

![merkle-t](https://img.learnblockchain.cn/2019/06/merkle-t.jpg)

## 隐私代币转账（Transfer）

转账的模型，类似UTXO模型。从两个属于同一个账户的隐私交易中（交易金额分别是c和d），生成两个隐私交易：其中一个属于转账对象的（交易金额为e），另外一个（余额为f）返回转账发起账户。其中，c+d=e+f。
![隐私代币转账](https://img.learnblockchain.cn/2019/06/ac149ea567701996b78a86bc1ca70cb0.jpg)

* **Step1** - 通过ft-transfer的vkId，生成证明。生成e和f的commitment，c和d的nullifier。

* **Step2** - 调用FTokenShield智能合约的transfer接口，提交proof/公开信息以及vkId。

* **Step3/4** - 调用GM17以及Verifier Registry存储和验证proof。

* **Step5** - 通过whisper告知转账对象：转账金额e，随机数r1，z1以及在merkle树上的叶子的index。

## 隐私代币销毁（Burn）

隐私代币的销毁，就是将代币从隐私账户转回普通账户的过程。

![隐私代币销毁](https://img.learnblockchain.cn/2019/06/burn.jpg)

* **Step1** - 通过ft-burn的vkId，生成证明。

* **Step2** - 调用FTokenShield智能合约的burn接口，提交proof/公开信息以及vkId。

* **Step3/4** - 调用GM17以及Verifier Registry存储和验证proof。

* **Step5** - 在验证proof后，调用FToken智能合约，从FTokenShield转账到发起者账户。

简单的说，就是在证明拥有某个commitment中pk指定的sk的情况下，可以生成nullifier。在隐私智能合约中销毁隐私代币后，可以将资产恢复到普通账户。

## UI部分

EYBlockchain还提供了已有功能的简单UI，方便开发人员验证功能。UI的界面如下图：

![](https://img.learnblockchain.cn/2019/06/15604814566958.jpg)

很清楚分为四个部分：EYT（ERC721），EYT对应的隐私代币，OPS（ERC20），OPS对应的隐私代币。

## 总结：

EYBlockchain运行在以太坊上，在ZoKrates零知识证明的基础上，利用以太坊上的智能合约提供隐私交易的能力。在智能合约中，隐私交易的管理类似Zcash。目前，EYBlockchain在以太坊上发行两种代币：EYT（ERC721）和OPS（ERC20），并针对这两种代币提供隐私交易的能力。

本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
