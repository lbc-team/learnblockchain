---
title: Nightfall的系统结构、铸币实现及以太坊上通证的转移实现
permalink: nightfull
un_reward: true
hide_wechat_subscriber: true
date: 2019-07-09 15:10:54
categories: 基础理论
tags: 
    - Nightfull
    - EYBlockchain
    - 零知识证明
author: 乐扣
---


## 摘要

Nightfall是一种零知识证明的实现， 它使用zk-SNARKS让同质化[ERC20](https://learnblockchain.cn/2018/01/12/create_token/)和[非同质化的通证ERC721](https://learnblockchain.cn/2018/03/23/token-erc721/)系列的通证进行隐私化转移，使得交易能够完成但是又能足够的匿名。本文主要是通过对架构设计、承兑型资产铸造、转移和销毁这几个层面进行了详细的理论和实现的分析。


**关键字** : 零知识证明；Ngihtfall；zk-SNARKS；承兑型资产；铸造；转移；销毁；

<!-- more -->

## Nightfall的高层级架构设计抽象

![img](https://img.learnblockchain.cn/2019/07/09_338669390.png)  

根据上图可以看到主要由以下模块组成：
1. 链下两个交易模块发送者Allice服务模块 和接收者Bob服务模块；
2. 以太坊网络中的盾牌合同；同质化ERC20智能合约模块；
3. 非同质化ERC721智能合约；
4. 验证智能合约GM17_v0等

主要功能为：通证ERC20铸币、转移和销毁与通证721铸币、转移和销毁。 

Nightfall中的六个主要子协议为以下：
1. Mint ERC-20 Token Commitment ERC20铸币承兑协议；
2. Transfer ERC-20 Token Commitment ERC20转移承兑协议；
3. Burn ERC-20 Token Commitment ERC20销毁承兑协议；
4. Mint ERC-721 Token Commitment ERC721铸币承兑协议；
5. Transfer ERC-721 Token Commitment ERC721转移承兑协议；
6. Burn ERC-721 Token Commitment ERC721销毁承兑协议。

## 何为铸造(Mint)一个ERC20/721承兑通证协议及其作用

即通过一个ERC20/721通证转换为一个对等承兑通证（ Commitment Token ），而承兑通证，该承兑通证拥有与原通证类似的价值和ID。在转换的过程中，承兑（Commitment）即一种通过密码学处理，实现原通证的价值和ID的隐藏和保密，同时也让交易的接收者和对应的价值实现了保密。

## 如何铸造(Mint)一个承兑型通证？

当Alice给Bob通过Nightfall进行转账的时候，Alice使用公共输入(unit256[]_proof )和私人输入（unit256[]_input）在她的α 服务器上生成zk-SNARK证据(proof)π（链下完成）。 然后她将它提交给盾牌合同。 详细过程是： Alice通过提供散列通证α的值即令牌ID，Alice的公钥和32位的随机值（用来提供提供承兑通证的唯一性）最终铸造了承兑型通证Z_A。

![img](https://img.learnblockchain.cn/2019/07/09_170121959.png!/scale/40%) 

## 盾牌合约如何验证承兑型通证是否已经正确创建？

盾牌合同收到承兑型通证Z_A，通过在核查合同中的调用验证功能（Verify）以及公共输入π来验证并且仅在成功验证时验证该通证Z_A已经被成功创建。 详细过程如下：
1. 调用ERC-20或ERC-721合同的转移功能，将Alice的令牌值/令牌ID α 转移到盾牌合同的地址中。 
2. 将承兑型通证Z_A哈希散列到其承诺的merkle树中。

##  如何实现承兑型通证资产的转移呢？

一个承兑型通证资产转移的例子如下：
Alice目前拥有两个承兑型通证资产Z’_A，分别持有10α和5α，她想转移到Bob。她在她的线下服务器上生成一个zk-SNARK证明π，并从一个以太坊地址提交给盾牌合约。 
详细过程如下：
1. 她通过连接和散列值拿到两个承兑型通证资产Z’*A和 Z’’A 分别价值10α和5α ，她的公钥pk_A，以及与承兑型通证资产相关的随机数σ_1和σ_2。
   分别表示为以下：
![img](https://img.learnblockchain.cn/2019/07/09_395263711.png!/scale/40%)
2. 承兑型通证资产存储在承兑型merkle树中，可用来显示承兑型merkle树中的这些承兑型通证资产存在于何处，揭示正在使用哪些承兑型通证资产。逆着原过程看，她可以从叶子节点即已经证明了的Z’A和Z’’ A开始，她可以通过反复哈希（树的深度-1次），以产生承兑型通证资产merkle树的根R。最终通过重复地与每个级别的兄弟节点连接并进行散列来完成此操作。
![img](https://img.learnblockchain.cn/2019/07/09_853500099.png!/scale/40%)
3. 她通过使用她的私钥sk_A和相应的承兑随机数σ_1和σ_2来为Z’A创建了无效清单List of Nullifiers N10α和N5α。
![img](https://img.learnblockchain.cn/2019/07/09_474710332.png!/scale/40%)
4. 承兑型通证资产Z’ A和Z’’ A使用的公钥pk_A是从各自的无效列表List of Nullifiers中使用的相同秘密密钥sk_A导出的。
![img](https://img.learnblockchain.cn/2019/07/09_241051951.png!/scale/40%)
5. Alice分别使用公钥pk_A为Alice和Bob创建了两个新的承兑型通证资产Z’’’* A和Z_B。
![img](https://img.learnblockchain.cn/2019/07/09_491693224.png!/scale/40%) 
6. 无效器List of Nullifiers中的价值等价于创造的新承诺的价值，即10α+5α=3α+12α。
7. 通过预设的值可以设定不超过最大额度的交易流，用来实施过载检测。
 
等待七个步骤完成后，盾牌合同在收到转账交易时，通过在验证合同中调用验证功能以及公共输入来验证并且仅在成功验证时验证该承兑型资产转移是否已经成功。

简而言之就是： 
1. 将N_10α和N_5α添加到其无效列表List of Nullifiers中 
2. 将Z’’’_ A和Z_B添加到其承兑的merkle树中。

此时Bob通过链下的通信被告知信息：Z_B，12α和秘密输入σ_4。
完成此功能后：一个新的Etheruem地址（可能可以追溯到Alice）在许多令牌承诺中无效，无论是铸造还是接收。 他们还可以看到它创建了两个新的承兑型资产Z’’’_ A和Z_B。 但他们无法看到谁拥有这些新的承兑型资产或者花了两个承兑型资产。 此外，未披露花费和转移的价值。


## 承兑型通证资产的销毁

继续上述的流程，当Alice想要销毁她拥有的承兑型通证资产Z_A时，她在她的链下服务器上生成zk-SNARK证据（proof）π并将其提交给盾牌合约（Shield Contract），详细步骤如下： 

1. 她通过连接和散列处理令牌ID α，她的公钥pk_A和与承诺相关的随机数σ来承兑型通证资产Z_A的输入。 
![img](https://img.learnblockchain.cn/2019/07/09_617070977.png!/scale/40%) 
2. 这个承兑型通证存在于承兑型merkle树中，通过显示从Z_A开始，她可以反复散列（树的深度-1次）以产生承兑型merkle树的根R。通过重复地与每个级别的兄弟节点连接并进行散列迭代处理来完成此操作。 
![img](https://img.learnblockchain.cn/2019/07/09_451524107.png!/scale/40%) 
3. 她使用她的密钥sk_A为Z_A创建了一个无效器nullifier Nα。
![img](https://img.learnblockchain.cn/2019/07/09_809437454.png!/scale/40%) 
4. 从其无效器中通过使用的相同密钥导出承兑型通证Z_A中使用的公钥pkA。
![img](https://img.learnblockchain.cn/2019/07/09_820219435.png!/scale/40%) 
5. Alice想要发送公共ERC-20通证到地址payTo_address 相当于传送到了私有通证地址payTo_address_private。即payTo_address 实质上等价于payTo_address_private。 同时还会通过一个用来确认的检查程序来确保整个过程中没有矿工/中介用其自己的地址替换payTo_address地址，形成篡改攻击。在上述整个过程中，对于收到销毁交易时的盾牌合同，通过调用verier合约中的验证功能以及公共输入来验证且仅在成功验证时验证销毁成功。

 简而言之做了以下两块处理： 
 1. 将N_α添加到其无效列表中。
 2. 调用ERC-20或ERC-721合同的转移功能，将α的值/令牌ID从盾牌合同的地址转移到Alice指定的目标地址（可能是Alice或其他人的）。 
   
这样做的好处就是通过一个新的以太坊合约地址（可能跟踪到Alice）对目标承兑型通证进行处理包含了铸造、转移和验证。 他们还可以看到Alice /其他人已收到α的值/令牌ID。 

但他们无法看到整个过程到底关联了多少用来做具体业务的承兑型通证，以此实现隐私性。

##  结语

Nightfall作为零知识证明的一个区块链智能合约处理系统的实现，让商业级应用隐私处理的矛盾得到了根本性的解决。虽然该方案和代码已经开源，但任然还处于早期阶段，其处理的复杂度、gas消费对于时间和资金成本都还有很大的改进空间，但整个方案非常精妙，类似于通过合约层做了数据复杂的混淆处理，处于level2的解决方案。非常期待Nightfall的成长。 

PS：特别感谢安永创新中心的技术支持。

### 参考文献：
1. https://medium.com/@chaitanyakonda/ 
2. https://zkp.science/ —A brilliant collection of papers, articles, libraries etc related to Zero Knowledge Proofs 
3. （德）JOSEF PIEPRZYK THOMAS HARDJONO JENNIFER SEBERRY．计算机安全基础：中国水利水电出版社，2006年10月

作者：乐扣老师， 原文： https://bihu.com/article/1909887631 ,深入迁出区块链授权转载。


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
