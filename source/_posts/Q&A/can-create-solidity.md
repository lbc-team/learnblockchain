---
title: 为什么要创建新的合约语言 Solidity，而不是使用现有的其他语言
permalink: can-create-solidity
date: 2019-03-01 09:25:59
categories: 问与答
tags: 
    - Solidity
    - go
author: Tiny熊
---


{% cq %}
创建一门新的合约语言，如：Solidity 有什么样的优缺点，相对于使用一门现有的其他语言如： Golang 或 Python？
{% endcq %}

<!-- more -->

每种编程语言都是为特定的操作环境和目标任务而设计的,而这些约束推动了几乎所有设计决策：支持哪些功能和舍弃哪些功能。

前段时间, 我花费了相当多的时间来创建一个 Go -> EVM 交叉编译器。我确实设法运行了一些琐碎的程序，这绝对是一个很大的乐趣, 但很快我就开始发现 [EVM](https://learnblockchain.cn/2019/04/09/easy-evm/) 的局限性与Go背后的核心假设发生冲突：

* 每个 goroutine 都需要至少 64KB 的内存。如今, 对于任何像样的硬件来说, 都是微不足道的低, 但对于 [EVM](https://learnblockchain.cn/2019/04/09/easy-evm/)  来说却高得离谱, 价格也很高。

* Go 依赖于操作系统级别的内存管理器。这意味着, 要在 EVM 上运行 Go 程序, 我们需要在 EVM 的基础上开发一个微内存管理器, 以支持 Go 所需的操作。我设计了一个[Buddy Memory Allocation](https://en.wikipedia.org/wiki/Buddy_memory_allocation) 算法的 POC 版本，但该算法基于有限和固定内存的情形, 并在其中分配任意块。另一方面, EVM 是 "无限" 和按每个分配的最大偏移量收费。因此, 所有通常的内存分配算法都会受到影响, 因为它们假设内存成本是恒定的, 而 EVM 是按位置的（甚至是指数相关）。

* Go 是一种垃圾回收语言, 因此每个内存分配还需要维护引用计数器, 这需要很好地使用内存分配器。同样不是不可能解决的, 但相关的操作码和非线性内存成本使得开销非常大。

* 即使内存问题得到解决, 您仍然需要为如同步原语、操作系统中断以及其他我们倾向于理所当然但 EVM 没有的结构 找到解决方案。

这些挑战是我决定不再继续移植Go到EVM的主要原因，但他们确实表明现代语言基于底层操作系统支持的无数功能，而这些功能本身是基于对底层硬件能力和相关成本的假设。

在这方面，EVM 则是非常不同，因此应用相同的假设会导致高度次优的代码执行。因此, 这也是为什么需要开发一种专门针对 EVM 执行环境的语言，这确实可能是比移植现有的语言语法需要做更多的工作, 但它可以更好的产生一个可用的环境而不是有各种 "限制" Go 代码（尽管是有效的）。

也需要注意, 最初的EVM设计可能很糟糕，如果有人找到更好的解决方案时，它将被扩展，升级甚至完全替换。但这是未来的可能性，而 Solidity 是当前的需要。

原问答[链接](https://ethereum.stackexchange.com/questions/3112/what-is-the-merit-of-creating-new-smart-contract-languages-like-solidity-instead)

深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
