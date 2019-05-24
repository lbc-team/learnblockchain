---
title: 如何在智能合约中安全地生成随机数？
permalink: securely-random
date: 2019-02-10 11:25:59
categories: 问与答
tags: Solidity
author: Tjaden Hess
---


{% cq %}
[以太坊智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)中经常需要随机数（尤其是博彩应用），我怎样才能安全地生成一个随机数？ 有什么好的做法和安全权衡需要考虑？
{% endcq %}

<!-- more -->


## 铭记在心

1. 用户做出任何影响结果的决定都会给用户带来不公平的优势。 如:

    1. 使用blockhash、时间戳或其他矿工定义的值。 要明确一点，矿工有选择是否发布一个块，所以他们有机会选择有利的区块。
    2. 任何用户提交的随机数。 即使用户预先提交了一个号码，他们也可以选择是否透露号码。

2. 一切**合约上的数据都是公开的**。

    1. 这意味着，直到进入抽奖后已经关闭之前，随机号码都不应该被生成。

3. EVM不会快过物理计算机。

    1. 合同生成的任何数字可以在该块结束之前知道。 在生成数字和使用数字之间留出时间。


## 一个技术方案

**完全去中心的彩票方案（也许扩展不要）**：

1. 赌场为一个随机数字预留了奖励
2. 每个用户生成自己的秘密随机数 `N`
3. 用户计算`N`和地址的Hash : `bytes32 hash = sha3(N,msg.sender)`  
    > 注意: 2 和 3 应该在离线的安全环境下执行
4. 发送上一步生产的 hash 给合约（尽管可能hash数据量比 `N` 大）
5. 其他的用户继续按同样的方法提交各自的hash， 知道回合结束。

    *需要所有的提交完成之后，才进行开奖环节。*

1. 每个用户向合约提交之前生成的随机数 `N` 。
2. 合约根据hash值验证随机数 `N` ，使用同样的方法 `sha3(N,msg.sender)` ，无法通过验证的 `N` ，可以没收罚金。 
3. 可以考虑所有有效的 `N` 在一起生成一个最终的随机数。
4. 用这个随机数来决定谁可以获奖。


一个例子: [RANDAO](https://github.com/randao/randao)

原问答链接：
https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链的都在这里，打造最好的区块链技术博客。


