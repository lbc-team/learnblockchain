# The Libra Blockchain开发者文档-翻译一

标签（空格分隔）： 文章分享
---

## 欢迎



欢迎来到Libra开发者网站！ Libra的使命是为全球数十亿人建立一个简单的全球货币和金融基础设施。

> 世界真正需要的是一种可靠的数字货币和为其提供服务的基础设施，该货币和基础设施可实现“货币互联网”的承诺。在移动设备上简单直观的保护您的金融资产。在全球范围内不论在哪里，做什么、赚多少钱，那么资金的转移应该像发送短信或者分享照片一样简单且具有成本效益，甚至更加安全可靠。
>

Libra建立在安全、可扩展且可靠的区块链上，它由一系列旨在赋予其内在价值的资产来支持，独立的Libra协会负责管理发展Libra相关生态。

> Libra区块链的目标是成为金融服务的坚实基础，包括了可以满足全球数十亿人日常财务需求的全新的全球货币。区块链是从零开始构建的，构建中优先考虑扩展性、安全性、存储及吞吐量效率及未来的适应性--来自[Libra白皮书](https://libra.org/en-US/white-paper/)
>


Libra货币建立在Libra区块链上。称之为Libra Core，基于Libra协议的开源项目，该项目为这个新的区块链提供支持，同时有testnet，这是新系统的一个演示环境，和未来Libra上线的主网对比，testnet使用的数字货币没有真实世界的价值。

文档讨论：
* 如何在testnet通过发送交易来验证一手试验原型
* 去哪里了解新的技术：Libra协议、Move语言，LibraBFT
* 如何围绕这个新生态系统建立社区并成为社区一部分

> **注意**：该项目目前处于早期原型阶段。Libra协议和Libra Core API不是最终正式版。原型演变的关键任务之一就是正式的协议和API。目前，我们的重点是基础架构和构建CLI客户端。我们的直接路线图中包含公共API和相关的库。我们欢迎在testnet对软件进行相关测试，但开发人员应该在使用这些API来发布应用程序中做一些工作，作为定期沟通交流的一部分，我们也会发布稳定的APIs的发展进展。
>

---

## Move：一种新的区块链编程语言

Move是一种新的编程语言，用于在Libra区块链上实现自定义的事务逻辑和“智能合约”。由于Libra的目标是在有朝一日为数十亿人服务，故Move的设计安全性和安全等级是最高优先级。
通过借鉴过去智能合约安全事件，创建了新的语言Move，该语言使得作者编写代码更加容易。这样可降低意外错误或者安全事件的风险。具体来说，Move旨在防止资产被克隆。它使得“资源类型”能够将数字资产限制为与物理资产相同的属性：资源只有单一所有者，且只能使用一次，并且新资源的创建受到限制。
Move使得关键交易代码的开发更加容易，它可以安全地实施Libra生态中的治理策略，例如对Libra货币和验证节点网络的管理。我们预计开发人员创建可用合约的能力将随时间的推移不断加强。这将为Move提供演变的验证的支持。
有关详细信息，请参阅[“Move入门”](https://developers.libra.org/docs/move-overview)

## Libra系统生态

Libra生态系统由不同类型的实体组成：

* [客户端](https://developers.libra.org/docs/welcome-to-libra#clients)
* [验证器节点](https://developers.libra.org/docs/welcome-to-libra#validator-nodes)
* [开发者](https://developers.libra.org/docs/welcome-to-libra#developers)

---

### 客户端

Libra客户端：

* 是一种能够与Libra Blockchain交互的软件
* 由最终用户或者代表最终用户来运行（例如：一个保管客户端）
* 允许用户构建，签名并将交易提交给[验证程序节点](https://developers.libra.org/docs/reference/glossary#validator-node)
* 可以向Libra区块链发出查询（通过验证程序节点），请求交易或帐户的状态，并验证响应。

Libra Core包含一个客户端，可以将事务提交到testnet。 [我的第一个交易](https://developers.libra.org/docs/my-first-transaction)指导您使用Libra CLI客户端在Libra区块链上执行您的第一个交易。

### 验证器节点

[验证器节点](https://developers.libra.org/docs/reference/glossary#validator-node)是Libra生态系统中的实体，它们共同决定将哪些交易添加到Libra区块链中。 验证器使用[共识协议](https://developers.libra.org/docs/reference/glossary#consensus-protocol)，以便它们可以容忍恶意验证器的存在。 验证器节点维护区块链上所有交易的历史记录。 在内部，验证器节点需要保持当前状态以执行交易并计算下一个状态。 我们将在[交易生命周期](https://developers.libra.org/docs/life-of-a-transaction)中了解有关验证器节点组件的更多信息。
testnet是一组公开可用的验证器节点，可用于尝试系统。您也可以使用Libra Core自行运行验证程序节点。

### 开发者

Libra生态系统支持各种各样的开发人员，从贡献Libra Core的人到构建使用区块链的应用程序的人。 术语“开发者”包括所有这些组。 开发人员可能如下：

* 建立Libra客户端
* 构建应用程序与Libra客户端进行交互
* 编写智能合约以在区块链上执行。
* 为Libra区块链软件做出贡献。

此站点适用于开发人员。

---

## 参考

* [Libra协议](https://developers.libra.org/docs/libra-protocol)：关键概念 - 向您介绍Libra协议的基本概念。
* [我的第一笔交易](https://developers.libra.org/docs/my-first-transaction) - 指导您使用Libra CLI客户端在Libra区块链上执行您的第一笔交易。
* [Move入门](https://developers.libra.org/docs/move-overview) - Move新区块链编程语言。
* [交易的生命周期](https://developers.libra.org/docs/life-of-a-transaction) - 提供交易提交和执行时“幕后”发生的事情。
* [Libra核心概述](https://developers.libra.org/docs/libra-core-overview) - Libra核心组件的概念和实现细节。
* [CLI指南](https://developers.libra.org/docs/reference/libra-cli) - 列出Libra CLI客户端的命令及其用法。
* [Libra 词汇表](https://developers.libra.org/docs/reference/glossary)  - 提供Libra术语的快速参考。





