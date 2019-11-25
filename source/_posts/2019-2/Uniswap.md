---
title: 区块链-深入理解Uniswap协议
permalink: Uniswap
un_reward: true
date: 2019-11-25 10:36:18
categories: Uniswap
tags:
    - Uniswap
author: Star Li
---

最近想换换脑子，看了看Uniswap协议。Uniswap协议是一种通过智能合约实现代币间自动交易的协议。本文介绍Uniswap协议，生态，交易价格以及流动性收益的计算。

<!---more---->

## Uniswap协议基本介绍

Uniswap协议通过智能合约实现了代币之间的自动交易。目前，Uniswap协议已经在以太坊上部署，可以实现ETH和代币以及代币和代币的之间交易。Uniswap协议的整个框架如下图所示：

![Uniswap协议](https://img.learnblockchain.cn/2019/11/25/001.jpg)

Uniswap Exchange Factory以及Uniswap Exchange都是由以太坊上的智能合约（vyper语言）实现，相关的代码的github地址如下：

https://github.com/Uniswap/contracts-vyper

通过UniswapExchangeFactory可以创建Uniswap Exchange。每个Uniswap Exchange实现一种代币和ETH之间的交易。

在多种代币都能和ETH交易的前提下，代币和代币之间也能交易，如下图所示：

![代币和代币之间](https://img.learnblockchain.cn/2019/11/25/002.jpg)

两个Exchange，一个提供了ABC和ETH的交易，一个提供了XYZ和ETH的交易。通过Uniswap协议，一个用户可以先通过ABC to ETH Exchange将ABC转成ETH，接着再通过XYZ to ETH Exchage将ETH转换成XYZ。整个过程Uniswap自动完成，从用户的角度来看，ABC代币直接转换成了XYZ代币。

## Uniswap生态

Uniswap交易生态中，除了需要交易的用户外，还有一个特别重要的角色：流动性提供者。对一个Exchange来说，流动性提供者提供了ETH以及相应的Token。只有有足够多的流动性，用户才能顺畅的交易，并能保持价格在合理的范围。

![Uniswap生态](https://img.learnblockchain.cn/2019/11/25/003.jpg)

普通交易用户，通过Exchange，实现一个代币和ETH之间的交换。流动性提供者，同时提供代币和ETH。交易的用户每笔交易需要支付一定的交易费用（0.3%）。这些费用被流动性提供者均分。

## x-y-k做市商模型

Uniswap协议使用的是x-y-k做市商模型，实现x和y之间的自动交易。[Uniswap协议在github上有对x-y-k模型的详细介绍](https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf)

### x-y-k模型

所谓的x-y-k模型，是因为在这个模型下，x*y = k。可以想象成x和y，分别是两种代币的数量。在x和y交易时，在没有交易费用的情况下，x*y永远等于k，不变：

![x-y-k模型](https://img.learnblockchain.cn/2019/11/25/004.jpg)

alpha和beta分别是每次交易的变化量。从上面的公式可以看出，变化前（x*y）和变化后（x‘*y'）是相等的。

Uniswap协议在该模型的基础上，引入了交易费用，新的模型计算公式如下：

![模型计算公式](https://img.learnblockchain.cn/2019/11/25/005.jpg)

引入交易费用，增加了rho变量。很容易可以看出，引入交易费用后，x'*y'是比x*y的乘积大。

### 交易价格计算

交易价格的计算分成两种：一种是给定X的数量，计算能买到的Y的数量（Input）；一种是给定Y的数量，计算需要的X数量（Output）。

getInputPrice的计算公式如下：

![getInputPrice的计算公式](https://img.learnblockchain.cn/2019/11/25/006.jpg)

也就是说，Delta X的代币能换取Delta Y的其他代币。此时，Y代币的价格为：

![Y代币的价格](https://img.learnblockchain.cn/2019/11/25/007.jpg)

简单的说，买入越多X，alpha越大，价格也越高。如果alpha为1的话（用当前流动性中X总额相等的X代币买入），也只能买差不多流动性中的一半的Y代币。如果把x/y视作当前Exchange的价格的话，一次买入后，价格变化为：

![价格变化](https://img.learnblockchain.cn/2019/11/25/008.jpg)

也就是说，“价格”是随着买卖的比例二次函数变化：

![二次函数变化](https://img.learnblockchain.cn/2019/11/25/009.jpg)

getOutputPrice的计算公式如下：

![getOutputPrice的计算公式](https://img.learnblockchain.cn/2019/11/25/010.jpg)

也就是说，Delta Y的代币能换取Delta X的X代币。此时，Y代币的价格为：

![Y代币的价格](https://img.learnblockchain.cn/2019/11/25/011.jpg)

简单的说，买入越多Y，beta越大，价格也越高。如果beta为1/2的话（买入当前流动性中一半的Y代币），大约需要当前流动性中等量的X代币。getInputPrice和getOutputPrice分别从两种代币角度计算价格，具体的价格是一致的。注意，价格计算公式只区分价格计算的两种方向，并没有制定X，Y具体代表的代币类型。举个例子，如果一个Exchange支持的是ETH和ABC交易，你可以把ETH当作X，ABC当作Y，同样你可以将ABC当作X，ETH当作Y。

### 流动性计算

流动性提供者可以随时增加/删除流动性。Uniswap协议文档，用一个三元组（e, t, l)来代表Exchange的状态，其中e代表ETH的数量，t代表Token的数量，l代表当前流动性总量。

增加流动性（addLiquidity）的计算公式如下：

![增加流动性](https://img.learnblockchain.cn/2019/11/25/012.jpg)

增加流动性，就是增加同等比例的e和t。

删除流动性（removeLiquidity）的计算公式如下：

![删除流动性](https://img.learnblockchain.cn/2019/11/25/013.jpg)

删除流动性，就是依据流动性的占比，等比例的减少e和t。

很容易看出，增加流动性和删除流通性时都是按照x/y的价格计算的。需要指出的是，在智能合约实现时，需要考虑计算的精度。

### 流动性收益计算

到目前为止，我们已经知道，增加流动性和删除流通性都是按照当时x/y的价格计算的。Exchange的买卖会导致x/y的波动。先不考虑交易费用的情况下，可以先将模型退化到x*y=k的情况，看看流动性提供者的收益：

假设初始时，Exchange的代币流通性是e和t，经过一些交易后变成e'和t'，e*t=e'*t'。

![流动性收益计算](https://img.learnblockchain.cn/2019/11/25/014.jpg)

假设P'/P=x, 则收益曲线如下：

![收益曲线](https://img.learnblockchain.cn/2019/11/25/015.jpg)

很容易看出，只要x/y有变化，在没有交易费用的情况下，没有盈利可能。最好的情况，e/t不变的话，没有损失。在有交易费用的情况下，只有交易费用足够多，能抵消价格波动的损失的情况下，才有可能盈利。

## 总结

Uniswap协议是一种通过智能合约实现代币间自动交易的协议。Uniswap协议采用x-y-k交易商模型。交易的价格随着交易金额的比例成二次函数变化。流动性提供者在没有交易费用的情况下，没有盈利的可能性。只有足够多的交易费用的情况下，才有可能盈利。

本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
