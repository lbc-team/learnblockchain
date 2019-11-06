---
title: 零知识证明-zkSNARK应用场景分析
permalink: zkSNARK-scene
un_reward: true
date: 2019-11-06 10:14:20
categories: 区块链安全
tags:
    - zkSNARK
    - 零知识证明
author: Star Li
---

前几天在魔笛社区分享了三个zk-SNARK技术应用的场景，可以让大家zk-SNARK（Groth16）技术和场景的结合有初步的认识。
<!-------more-------->
## 隐私：ZCash项目

Zcash项目，大家都知道是“隐私交易”。Zcash代表了zk-SNARK的一个应用方向：隐私。隐私有不同的程度，ZCash的隐私交易指的是隐藏交易的发送方，接收方以及交易金额。Zcash已经经历过三个版本：Sprout， Overwinter，Sapling。这三个版本本质上都没有太大的变化，只是支持的功能更多，生成证明更快，体验更好。

![三个版本](https://img.learnblockchain.cn/2019/11/06/001.jpg)

一笔转账用Note来表示，包括转账的金额v和一个随机数。Note有两个外在的表现形式：一个是Commitment，一个是Nullifier。Commitment和Nullifier都是通过不同的Hash函数生成。Commitment代表一次金额转入，Nullifier代表一次消费。注意，对于一个Note，Commitment和Nullifier都是唯一的。因为Commitment和Nullifier是Hash的结果，即使这两个数据公开，其他人也无法推断出Commitment和Nullifier之间存在联系。也就是说，提供一个Commitment，能说明进行了一笔转账（具体信息其他人未知）。能提供对应的Nullifier，就能消费。

区块链，作为一个隐私转账平台，将所有的Commitment（cm），组成一个Merkle树：

![Merkle树](https://img.learnblockchain.cn/2019/11/06/002.jpg)

某个用户需要消费某个cm，必须向区块链提供**零知识证明**：

* 他知道一个Note，并能生成一个cm，而且这个cm在以rt为树根的Merkle树上
* 用同样的Note信息，能生成一个nullfier，而且这个nullfier之前没有生成过。

以上只是最简单的概括Zcash零知识证明的大体思路，ZCash的设计非常复杂和严谨，有很多细节。顺便说一句，理解ZCash，只需要看ZCash的白皮书protocol.pdf。理解了白皮书的设计，看源代码非常直接。

这就是零知识证明的一个重要的运用方向 - **隐私**，现实中还有很多应用类似技术的项目：EYBlockchain(EY，安永)，Quorum(JPMorgan)。

## 链上数据压缩：Filecoin项目
Filecoin是存储行业比较热门的项目。Filecoin想搭建一个去中心化的存储交易平台。去中心化的存储，有个核心问题，怎么证明存储提供方，真实有效的存储了指定的数据。Filecoin是通过PoREP以及PoST算法实现（其中就包括零知识证明）。

PoREP是数据存储证明算法（证明用户数据被正确的处理）。PoRep算法的全称是ZigZag-DRG-PoRep。

![ZigZag-DRG-PoRep](https://img.learnblockchain.cn/2019/11/06/003.jpg)

Sector中未Seal的原始数据首先依次分成一个个小数据，每个小数据32个字节。这些小数据之间按照DRG（Depth Robust Graph）建立连接关系。按照每个小数据的依赖关系，通过VDE（Verifiable Delay Encode）函数，计算出下一层的所有小数据。整个PoRep的计算过程分为若干层（目前代码设置为4层），仔细观察每一层的DRG关系的箭头方向，上一层向右，下一层就向左，因此得名ZigZag（**Z字型**）。

![ZigZag](https://img.learnblockchain.cn/2019/11/06/004.jpg)

每一层的输入称为d（data），每一层的VDE的结果称为r（replica）。对每一层的输入，建构默克尔树，树根为comm_d, 整个树的数据结构称为tree_d。对每一层的输出，建构默克尔树，树根为comm_r，整个树的数据结构称为tree_r。

简单的说，PoREP通过零知识证明，证明每一层的数据都经过VDE计算生成，并提供最后结果的Merkle树的树根。

在数据处理并存储后，每隔一段时间，需要提交存在性证明，也就是PoST算法。PoST算法的基本思想，随机挑选一个Merkle树的叶子节点位置，需要提供出一条Merkle路径的零知识证明。

这个零知识证明的第二个应用方向：**链上数据压缩**。PoREP算法，通过零知识证明证明数据已经正确处理，并提供了处理后数据形成的Merkle树的树根。PoST，每隔一段时间，随机抽选一个叶子数据，需要存储提供者在一定的时间内提供从该叶子数据到Merkle树根的路径证明。如果，处理完的数据没有保存在一个可靠的存储上，无法在合理的时间内重建整个Merkle树，也就无法提供证明。

## 扩展性：Loopring DEX 3.0项目

从2017年，路印从“环路撮合”的最初设计，经过了1.0，2.0以及3.0的三个大的版本的协议升级。1.0/2.0，相对来说，受限以太坊本身性能的限制，交易流程复杂，体验和中心化交易所相比，有较大的差距。路印协议3.0，通过zk-SNARK技术，在zk Rollup的基础上，结合DEX的业务场景开发设计，兼顾去中心化和交易性能。

相对1.0，2.0来说，路印协议3.0将所有的撮合逻辑都在链下完成。每一笔撮合（Settlement）都会生成证明并提交到链上，证明链下的撮合正确无误。

路印协议采用和以太一致的“账户”模型，所有的账户的“状态”（余额）都记录在链下。

所有和状态相关的操作，都是在链下更改，提交Proof到链上记录。因为存在链上链下的状态同步，账户的任何操作有三个状态：

* Committed （操作已经提交）2/ Verified （该操作已经提供了相应的Proof）3/ Finalized（之前的所有的操作都已经提交正确的Proof）

以用户Deposit“充值”的操作为例：

![充值](https://img.learnblockchain.cn/2019/11/06/005.jpg)

用户转账到路印协议的智能合约，转账在链上确认（链上完成充值）。该操作的状态就是“Committed”。链下的Relay，监测到“Committed”的状态后，更改链下的状态，生成Proof，并将证明提交到链上，此时该“充值”操作的状态为“Verified” - 链下也已经完成充值。如果之前的所有操作都是Verified，那该操作的状态就是Finalized（也就是这个状态是确定的，不会被篡改的）。

链下的状态用三层的四叉Merkle树来表示：

![三层的四叉Merkle树](https://img.learnblockchain.cn/2019/11/06/006.jpg)

路印3.0，采用的是zk-SNARK的Groth16算法提供零知识证明。针对每种操作，Relay都会提供对应的ZKP证明电路。以链下撮合为例，相应的电路证明的逻辑如下：

![电路证明的逻辑](https://img.learnblockchain.cn/2019/11/06/007.jpg)

假设Account X链下转账给Account Y。ZKP证明电路，包括：

* TradeHistory中Order Ox的变化导致TraderHistory的树根的变化
* TradeHistory中Order Oy的变化导致TraderHistory的树根的变化
* Balance Bx变化导致Balance的树根的变化
* Balance By变化导致Balance的树根的变化
* 两个账户的Balance的变化一致
* Account X和Account Y账户的变化导致的Account树根的变化

这个是零知识证明的第三个方向：**扩展性**。在足够多的交易的情况下，路印3.0的TPS在目前的以太坊上达到了350。在君士坦丁堡升级后，TPS能达到1400。每笔交易平均下来的费用大约在1美分。

![交易平均下来的费用](https://img.learnblockchain.cn/2019/11/06/008.jpg)

其他还有一些有意思的项目：其他还有 Coda（零知识递归证明），Mixer（混币），zkPOD（通用数据的交易）等等有意思的场景和应用。

总的来说，零知识证明的技术非常有意思，零知识证明就像一座桥梁，实现现实世界到数字世界的映射。欢迎大家和我一起讨论零知识证明的技术和应用。


本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
