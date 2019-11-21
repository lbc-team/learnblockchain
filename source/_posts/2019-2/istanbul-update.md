---
title: 即将到来的以太坊伊斯坦布尔有哪些更新
permalink: istanbul-update
date: 2019-11-21 15:10:54
categories: 资讯
tags:
    - 伊斯坦布尔
author: Tiny熊
---

以太坊网络计划将于9069000区块号进行代号为：伊斯坦布尔（Istanbul）的升级。该块预计将于 2019 年 12 月 7 日，周六挖出。

<!--more-->

以太坊每次升级都有一个代号，在[以太坊发展简史](https://learnblockchain.cn/2019/06/15/eth-history1/) 也介绍过，今年年初就进行过一次代号为[君士坦丁堡的升级](https://learnblockchain.cn/2019/06/15/eth-history1/#大都会：君士坦丁堡（Constantinople）硬分叉-2019年2月28日)。

## 伊斯坦布尔涉及的EIPs

以太坊每次升级都是围绕EIP（[以太坊升级提案](https://learnblockchain.cn/docs/eips/)）来进行。这也以太坊的社区治理方式，每个人都可以提出自己的改进计划给社区讨论，达成共识的EIP改进，就可以进入到网络升级中。

> 伊斯坦布尔升级涉及到哪些EIP，也是用EIP管理，见[伊斯坦布尔硬分叉元提案1679](https://learnblockchain.cn/docs/eips/eip-1679.html)

伊斯坦布尔升级包含的EIP有：

### [EIP-152: 加入了 Blake2 函数函数的预编译实现](https://learnblockchain.cn/docs/eips/eip-152.html)

添加了在以太坊合约中验证Equihash PoW的功能，可以实现与[Zcash](https://z.cash/)交互验证及原子交易。

### [EIP-1108: 减少 alt_bn128 预编译的gas消耗](https://learnblockchain.cn/docs/eips/eip-1108.html)

使zk-SNARK更加便宜，从而允许构建更便宜的扩展和隐私应用程序。 示例可以参考 [Matter labs](https://matter-labs.io/), [Aztec Protocol](https://www.aztecprotocol.com/), [Rollup](https://github.com/barryWhiteHat/roll_up) 以及 [Zether](https://crypto.stanford.edu/~buenz/papers/zether.pdf) 。

### [EIP-1344: 加入ChainID 操作码](https://learnblockchain.cn/docs/eips/eip-1344.html)

合约可以有方法来跟踪它运行在哪一条以太坊链上。如可用于第2层网络（状态通道，[Plasma](https://plasma.group/)）的合约跟踪一层网络的分叉。

### [EIP-1884: 对 trie-size-dependent 操作码重定价](https://learnblockchain.cn/docs/eips/eip-1884.html)


更改某些EVM操作码的成本，以防止垃圾交易攻击，并更好地平衡每个块中的计算量。
以太坊中每个操作必须支付的手续费和操作所需的计算相匹配。随着状态的增长，如 SLOAD，BALANCE 和 EXTCODEHASH 需要更多的成本。

### [EIP-2028: 减少交易数据的gas消耗](https://learnblockchain.cn/docs/eips/eip-2028.html)


通过降低交易 calldata 数据（用于交易的参数传递）的成本，使zk-SNARK和zk-STARK更加便宜。 这将使[第二层解决方案](https://wiki.learnblockchain.cn/ethereum/layer-2.html)能够提高吞吐量。 有关示例可参考 [Starkware](https://starkware.co/)。


### [EIP-2200: 重定义了 SSTORE gas 净值费用](https://learnblockchain.cn/docs/eips/eip-2200.html)

更改了EVM中存储的成本计算，将使合约能够引入新功能，包括重入锁定和同合约的multi-send。


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学习区块链技术](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
