---
title: 在Solidity 函数中是否可以获得交易的hash?
permalink: can-get-tx-hash
date: 2019-02-25 11:25:59
categories: 问与答
tags: 
    - Solidity
author: arodriguezdonaire
---


{% cq %}
是否有全局函数（诸如 tx.hash）获得交易的Hash? 目前我的想法是交易在被挖出之前，hash应该是不存在的，不知道时候正确？
{% endcq %}

<!-- more -->

## Solidity 全局变量与函数

通过这个[文档](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#special-variables-and-functions)（查看[英文文档](https://solidity.readthedocs.io/en/v0.5.9/units-and-global-variables.html#special-variables-and-functions)）我们可以查询到[有关区块可交易属性](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-2)的 接口有：

* blockhash(uint blockNumber) returns (bytes32)：指定区块的区块哈希——仅可用于最新的 256 个区块且不包括当前区块

* block.coinbase ( address ): 挖出当前区块的矿工地址

* block.difficulty ( uint ): 当前区块难度

* block.gaslimit ( uint ): 当前区块 gas 限额

* block.number ( uint ): 当前区块号

* block.timestamp ( uint): 自 unix epoch 起始当前区块以秒计的时间戳

* gasleft() returns (uint256) ：剩余的 gas

* msg.data ( bytes ): 完整的 calldata

* msg.sender ( address ): 消息发送者（当前调用）

* msg.sig ( bytes4 ): calldata 的前 4 字节（也就是函数标识符）

* msg.value ( uint ): 随消息发送的 wei 的数量

* now (uint): 目前区块时间戳（ block.timestamp 的别名 ）

* tx.gasprice (uint): 交易的 gas 价格

* tx.origin (address payable): 交易发起者（完全的调用链）

所有正如问题描述，交易在被挖出之前，hash是不存在的。


原问答[链接](https://ethereum.stackexchange.com/questions/2664/is-it-possible-to-get-the-transaction-hash-from-within-a-solidity-function-call)

深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
