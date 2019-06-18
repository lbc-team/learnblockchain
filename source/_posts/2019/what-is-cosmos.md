---
title:  Cosmos 是什么? 一文了解Cosmos的来龙去脉
date: 2019-05-21 15:03:59
permalink: what-is-cosmos
category:
    - 跨链
    - Cosmos
tags: 
    - Cosmos
author: Tiny熊
---

本文从技术角度全面了解 Cosmos 项目， Tendermint 是什么，Cosmos SDK 要解决什么，如何进行跨链，如何解决扩展性问题。

<!-- more -->

## Cosmos 简介

严格来说，**Cosmos是一个独立并行区块链的去中心化网络，每个区块链都由[Tendermint](https://cosmos.network/intro#what-is-tendermint-core-and-the-abci)共识这样的BFT共识算法构建**。

> BFT 代表拜占庭容错(Byzantine Fault-Tolerance)。 分布式系统中的拜占庭故障是一些最难处理的问题。 一个拜占庭容错共识算法是一个共识算法，可以保证多达三分之一的拜占庭或恶意行为者的情况下分布式系统的安全。

换句话说，Cosmos是一个区块链生态系统，可以相互扩展和互操作。 在Cosmos之前，区块链是孤立的、无法相互通信。同时很难建立这样的网络，并且只能处理每秒少量的交易。Cosmos通过新的技术愿景解决了这些问题。 为了理解这个愿景，我们需要回到区块链技术的基本原理。

## 什么是区块链?

区块链可以被描述为由一组验证者（矿工）维护的分布式数字账本，即使一些验证者（少于三分之一）是恶意的，账本也是正确的。 每个参与者在其计算机上存储总账本的副本，并在收到交易块时根据协议定义的规则对其进行更新。 区块链技术的目标是确保总账本正确复制，这意味着每个诚实的参与者在任何给定时刻都看到相同版本的总账本。

区块链技术的主要好处是各方无需依赖中央权威即可共享账本。 区块链是**去中心化**的。 今天区块链技术的第一个也是最着名的应用是比特币，一种去中心化的货币。

现在，我们从高层次的角度更好地理解区块链，让我们从更多的技术角度来看待区块链的定义。 区块链是一个在全节点上复制的**确定性状态机**，只要其维护者不到三分之一是拜占庭式（恶意）节点，即可保持**共识安全**， 让我们来分解一下。

* **状态机**只是一个程序的“花哨词”，它保存一个状态，在接收到输入时修改它。 这个状态可以代表不同的东西，取决于应用程序（例如加密货币的余额）和修改状态的交易（例如从一个账户减去余额并将其添加到另一个账户）。
* **确定性**意味着，如果您从同一个创世纪（genesis）状态重播相同的交易，始终得到相同的结果状态。
* **共识安全**是指状态机复制的每个诚实节点都应该同时看到相同的状态。 当节点收到交易块时，会验证它是否有效，意味着每个交易都确保有效，并且该块本身由超过三分之二的称为验证器的维护者进行验证。 只要不到三分之一的验证者是拜占庭式（恶意）节点，安全就会得到保证。

从体系结构的角度来看，区块链可以分为三个概念层:

![Layers of a blockchain: application, consensus, and networking](https://img.learnblockchain.cn/2019/05/15585161546781.jpg!wl!wl/scale/60%)


* **应用程序:** 负责更新给定的一组交易，即处理交易的状态。
* **网络:** 负责交易和共识相关消息的传播。
* **共识:** 使节点能够就系统的当前状态达成一致。

状态机与应用层类似，它定义了应用程序的状态和状态转换函数。 其他层负责在连接到网络的所有节点上复制状态机。

## Cosmos 如何打造更广泛的区块链生态系统？

### 比特币的故事 (区块链 1.0)

![Bitcoin is monolithic](https://img.learnblockchain.cn/2019/05/15585163316819.jpg!wl/scale/60%)

要了解 Cosmos 如何打造区块链生态系统，我们需要从区块链故事开始。 第一个区块链是比特币，这是2008年创建的点对点数字货币，使用一种称为[工作证明（PoW）](https://learnblockchain.cn/2017/11/04/bitcoin-pow/#工作量证明)的新型共识机制。 这是第一个去中心化应用。 不久，人们开始意识到去中心化应用的潜力，并希望在社区中建立新的应用。

当时，有两种选择来开发去中心化应用：要么分叉比特币代码库，要么建立在它之上。 然而，比特币代码库是非常耦合的;所有的三层—网络、共识和应用耦合在一起。 此外，比特币脚本语言功能有限，也不用户友好。 因此需要更好的工具。


### 以太坊的故事 (区块链 2.0)

![Ethereum has smart contracts](https://img.learnblockchain.cn/2019/05/15585163785237.jpg!wl/scale/60%)


在2014中，以太坊提出了构建去中心化应用的新愿景。 构建一个人们可以部署任何类型应用的区块链。 以太坊通过将应用层转换为称为[以太坊虚拟机(EVM)](https://learnblockchain.cn/2019/04/09/easy-evm/)的虚拟机来实现这一点。 该虚拟机能够处理称为智能合约的程序，任何开发人员都可以以*无许可*的方式部署到以太坊区块链。 这种新的方法允许成千上万的开发人员开始[构建去中心化应用（dApps）](https://learnblockchain.cn/2018/01/12/first-dapp/)。 然而，这种方法的局限性很快就显现出来，至今仍然存在。

> 备注：无许可系统是一个开放的系统，每个人都可以加入和参与。


#### 限制1：可扩展性(Scalability)

第一个限制是*扩展性（scaling）*-建立在[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)之上的去中心化应用程序被每秒15交易数的共享速率所抑制。 这是因为以太坊仍然使用工作证明，并且以太坊dApps竞争单个区块链的有限资源。

> 扩展性(scaling): 一个可扩展的系统是一个能够容纳越来越多的请求的系统。

#### 限制2：可用性（Usability）

第二个限制是开发人员只有相对较低的灵活性。 由于EVM是一个需要容纳所有用户场景的沙盒，因此它针对常用场景（average use case）进行了优化。 这意味着开发人员必须对其应用程序的设计和效率进行折衷（例如，需要在可能首选UTXO模型的支付平台中使用帐户模型）。 除此之外，它们仅限于一些编程语言，并且不能实现**代码自动执行**。

> 备注：[以太坊智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)的执行需要有外部账号的触发动作。

#### 限制3：主权（Sovereignty）

第三个限制是每个应用程序在主权方面都受到限制，因为它们都共享相同的基础环境。 本质上，这会创建两层治理：应用治理和底层的治理。 前者受到后者的限制。 如果应用程序中存在错误，无法对其进行任何操作，除非经以太坊平台本身的治理批准（参考[Dao事件](https://learnblockchain.cn/2019/04/07/dao/)。 如果应用程序在EVM中需要一个新功能，那么它再次必须完全依靠以太坊平台的治理来接受它。

这些限制不是特定于以太坊，而是所有试图创建一个适合所有使用情况的单一平台的区块链。 这也是 Cosmos 发挥作用的地方。

### COSMOS 愿景 (区块链 3.0)

![Cosmos is composed of three layers](https://img.learnblockchain.cn/2019/05/15585164205028.jpg!wl/scale/60%)

Cosmos的愿景是让开发人员轻松构建区块链，并通过允许他们彼此进行交易（通信）来打破区块链之间的障碍。 最终目标是创建一个**区块链网络，一个能够以去中心化方式相互通信的区块链网络**。 通过Cosmos，区块链可以保持主权，快速处理交易并与生态系统中的其他区块链进行通信，使其成为各种场景的最佳选择。


Cosmos通过一系列开源工具实现这个愿景，如*Tendermint*，*[Cosmos SDK](https://learnblockchain.cn/docs/cosmos/)* 和 *IBC*，旨在让人们快速构建自定义、安全、可扩展和可互操作的区块链应用。 后面会有工具以及 Cosmos 网络的技术架构的分析。 

> *Tendermint* 是一个**共识引擎和BFT共识算法**。 在Tendermint之上可以使用任何编程语言构建一个状态机，Tendermint 将负责信息的（按照共识要求的一致性和安全性）复制。

> *Cosmos SDK* 是一个**模块化框架**，用来简化构建安全的区块链应用。

> *IBC*是区块链之间的**通信协议**，可以被认为是区块链的TCP/IP。 它允许快速最终性（fast-finality）的区块链以去中心化的方式相互交换价值和数据。

##  什么是 Tendermint BFT 和  ABCI

之前创建一个区块链需要从头开始构建所有三层：网络、共识和应用程序。 以太坊通过提供虚拟机区块链简化了去中心化应用的开发，任何人都可以以[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)的形式部署自定义逻辑。 但是，它并没有简化区块链本身的开发。 就像比特币一样，Go-Ethereum 仍然是整体耦合的系统，不易自定义。2014年Jae Kwon 创建 Tendermint 就是想要解决这个问题。

Tendermint BFT 将区块链网络和共识层打包成通用引擎的解决方案，允许开发人员专注于应用程序开发，而不是复杂的底层协议。 因此，Tendermint可节省大量的开发时间。 
> Tendermint BFT引擎中使用的[拜占庭容错（bft）](https://github.com/tendermint/tendermint/wiki/Byzantine-Consensus-Algorithm)共识算法这个名称是Tendermint命名的，想了解更多的共识协议和BFT的历史，可以关Tendermint联合创始人伊桑-布克曼注的[播客](https://softwareengineeringdaily.com/2018/03/26/consensus-systems-with-ethan-buchman/)）。

[Tendermint BFT引擎](https://github.com/tendermint/tendermint)通过使用 [ABCI（Application Blockchain Interface）](https://github.com/tendermint/abci) 套接字（socket）协议连接到应用程序。 这个协议可以用任何编程语言进行封装，开发者可以选择适合他们适合的语言。

![Diagram for Tendermint BFT](https://img.learnblockchain.cn/2019/05/15585164680922.jpg!wl/scale/60%)

这还不是全部，下面这些属性使Tendermint BFT成为先进的区块链引擎:

* **公有链或私有链均可：** Tendermint BFT只处理区块链*网络*和*共识*，它帮助节点传播交易和验证追加交易到区块链。 应用层的角色是定义如何构成验证者集合。 因此，开发人员可以在Tendermint BFT引擎之上构建公有链或私有链。 如果应用根据他们有多少Token来选取验证者，那么区块链就称为权益证明PoS（Proof-of-Stake）。 应用也可以只有经过许可或授权才能成为验证者，那么区块链则是许可或私有链。 开发人员可以自由定制区块链验证者集的规则。

* **高性能：** Tendermint BFT 具有 1 秒数量级的出块时间，每秒处理数千个交易。
* **即时最终确定性：** Tendermint共识算法的一个属性是即时最终确定性（Instant finality）。 只要三分之一以上验证者是诚实的（拜占庭下），就永远不会分叉。 用户可以确保他们的交易一旦创建到区块就是最终（确定）的（这不是比特币和以太坊等工作区块链的情况）。
* **安全：** Tendermint 共识不仅是容错的，同时也有问责（accountable）。 如果发生分叉，有[一种方法来确定责任（liability）](https://github.com/tendermint/tendermint/wiki/Byzantine-Consensus-Algorithm#proof-of-fork-accountability)。

## Cosmos SDK 和其他应用层框架

Tendermint BFT 将区块链的开发时间大大缩减，但从头构建一个安全的 ABCI应用（实现ABCI协议）仍然是一项艰巨的任务。 这就是为什么需要 Cosmos SDK 。

[Cosmos SDK](https://cosmos.network/sdk) Cosmos SDK是一个通用框架，简化了在Tendermint BFT之上构建安全区块链应用的过程，它基于两个主要原则：

![Diagram for Cosmos SDK](https://img.learnblockchain.cn/2019/05/15585165287192.jpg!wl/scale/60%)

* **模块化**：Cosmos SDK 的目标是创建一个模块生态系统，允许开发人员轻松地创建特定应用的区块链，而无需从头开始编写应用的每个功能。 任何人都可以在自己的区块链里为 Cosmos SDK 创建一个模块或利用现成的模块。 例如，Tendermint团队正在构建一组Cosmos Hub所需的基础模块。 这些模块可以在构建自己的应用时使用。 此外，开发人员可以创建新的模块来自定义其应用程序。 随着Cosmos网络的发展，SDK模块的生态系统将扩大，使得开发复杂的区块链应用程序变得越来越容易。
* **基于功能的安全性**：功能约束模块之间的安全边界，使开发人员能够更好地了解模块的可组合性，并限制恶意或意外交互的范围。 要深入了解，点击[这里](https://cosmos.network/docs/intro/ocap.html)。

Cosmos SDK还附带了一组有用的开发者工具：控制台命令行(CLI)、REST服务和各种其他常用工具库。

总结一句话：与所有其他的 Cosmos 工具一样，Cosmos SDK 也是模块化设计。 现在它允许开发者在 Tendermint BFT 共识引擎之上构建应用。以后也可以用于其他实现 ABCI 协议的共识引擎之上。 随着时间的推移，预计将出现多个不同的架构模型的SDK，与多个共识引擎兼容，所有这些都在Cosmos 网络生态系统中。

参考这份[教程](https://cosmos.network/docs/tutorial)学习在 Cosmos SDK 开发应用。

### ETHERMINT

Cosmos SDK 很棒的地方在于它的模块化，允许开发人员移植现有的区块链（Go 编写）代码在它上面运行。 例如，*Ethermint*是一个将[以太坊虚拟机](https://learnblockchain.cn/2019/04/09/easy-evm/)移植到 SDK 模块中的项目。 *Ethermint*的工作原理完全像以太坊，具有Tendermint BFT 的共识属性。 所有现有的以太坊工具（Truffle，Metamask等））与Ethermint兼容，很容易将已有智能合约移植过来。

> *Ethermint* 将以太坊虚拟机转换为Cosmos-SDK模块。 该模块可以与其他SDK模块（如staking）相结合，能够运行以太坊智能合约的全功能的POS区块链。 Ethermint 链与 Comos 兼容。

**我已经可以在（虚拟机）区块链上部署去中心化应用了，为什么要用Cosmos SDK创建一个区块链？**

这个问题是有道理的，考虑到今天大多数去中心化的应用都是在像以太坊这样的虚拟机区块链之上开发的。 首先，这种现象的（部分）原因是，创建区块链比智能合约要困难得多。 有了Cosmos SDK之后就不再是这样。开发人员可以轻松地开发整个特定应用的区块链，这有几个优点。 除次之外，还将拥有更多的**灵活性**，**安全性**，**性能**和**主权**。 要了解更多有关特定应用的区块链的信息，请阅读这篇[文章](https://medium.com/@gautier_md/why-application-specific-blockchains-make-sense-32f2073bfb37)。 当然，如果不想建立自己的区块链，仍然可以通过在[Ethermint](https://ethermint.zone/)上部署你的智能合约来与Cosmos兼容（通信）。


## IBC 把区块链连接在一起

现在，开发人员已经有了一种快速构建定制区块链的方法，让我们来看看如何将这些区块链连接在一起。 区块链之间的连接是通过[区块链间通信协议（IBC：Inter-Blockchain Communication protocol）](https://blog.cosmos.network/developer-deep-dive-cosmos-ibc-5855aaf183fe)来实现的。 IBC利用Tendermint共识的“即时最终性”（其他的具有“即时最终性”共识引擎也可以），以允许**异构链之间相互转移价值（如token）或数据**。


### 什么是异构链（HETEROGENEOUS CHAINS）？

本质上它归结为两件事:

* **不同的层**：异构链有不同的层，这意味着它们在如何实现网络，共识和应用部分方面可能有所不同。 为了与IBC兼容，区块链只需要遵循几个要求，主要是共识层必须具有快速的最终确定性。 工作量证明链（如比特币和以太坊）不属于这个类别，因为它们的确定性是概率性的。
* **主权**：每个区块链都由一组验证者维护，他们的工作是同意下一个区块提交给区块链。 在工作量证明区块链中，这些验证者被称为矿工。 主权区块链是一个拥有自己的验证者集合的区块链。 在许多情况下，区块链的主权是很重要的，因为验证者最终负责修改状态。 在以太坊中，应用程序都是由一组通用验证者（矿工）运行的。 正因为如此，每个应用程序只有有限的主权。


IBC 允许异构链之间转移价值（如token）和数据，这意味着具有不同应用程序和验证人集合的区块链是可互操作的。 例如，它允许公有链和私有链间相互转移token。

### IBC 是怎么工作？

IBC背后的原理相当简单。 我们以链A上的一个帐户想要发送10个Token（假设是ATOM）到链B为例介绍。
> Atom 是 Cosmos Hub 的原生货币。 持有Atom可以获得投票权，可以委托给维护 Cosmos Hub 网络的验证者。

#### 跟踪（Tracking）

链B会不间断地接收链A的报头，反之亦然。 这允许每个链跟踪其他链的验证者集合。 从本质上讲，每个链运行一个其他链的轻客户端。

> 轻客户端是一个区块链客户端，只下载块头。 它通过Merkle Proof来验证查询结果。 这为用户提供了一个轻量级的替代全节点又具有良好的安全性的方案。

#### 锁定（Bonding）

当IBC转移被启动时，ATOM 被锁定（Bonding）在链A上。
![How IBC Works #1 锁定](https://img.learnblockchain.cn/2019/05/15585165990253.jpg!wl/scale/50%)

#### 中继证明（Proof Relay）

然后，需要一个从链A转移到链B的 10个ATOM 被锁定的证明。
![How IBC Works #2 中继证明](https://img.learnblockchain.cn/2019/05/15585166394519.jpg!wl/scale/50%)

#### 验证（Validation）

链B上针对链A的区块头的证明进行验证，如果有效，则在链B上创建 10 个 ATOM 凭证（ATOM-vouchers）。

![How IBC Works #4 验证](https://img.learnblockchain.cn/2019/05/15585166909541.jpg!wl/scale/50%)


注意, 在链 B 上创建的 ATOM 不是真正的 ATOM, 因为 ATOM 仅存在于链 A 上。它们是链 A 中 ATOM在 链 B 上的表示形式, 同时还证明了这些 ATOM 被冻结在链 A 上。

当他们回到其原始链时, 也使用类似的机制来解锁 ATOM。有关 IBC 协议的更全面的描述, 可以查看这个[规范](https://github.com/cosmos/cosmos-sdk/tree/master/docs/spec/ibc)。

## "区块链互联网”的设计

IBC 是一种协议, 允许两个异构区块链相互传输Token。那如何创建一个区块链网络呢？

一个想法是网络中的每个区块链用 IBC 和另一个区块链两两相连。这种方法的主要问题是网络中的连接数随区块链的数量呈二次增长。如果网络中有100个区块链, 并且每个区块链都需要保持彼此的 IBC 连接, 那就是 4950 个连接。这很快就失控。

为了解决这个问题, Cosmos 提出了一个模块化架构, 其中包含两类区块链: Hubs 和 Zones。

![Cosmos Hub & Spoke Architecture](https://img.learnblockchain.cn/2019/05/15585167584777.jpg!wl/scale/60%)

> Hubs：中心枢纽链 ， Zones ：区域链

Zones 是常规的异构链, Hubs 是专门为将 Zones 连接在一起而设计的区块链。当一个 Zone 创建与 Hub 的 IBC 连接时, Hub可以自动访问 (即发送和接收) 连接到它的所有 Zone 。因此, 每个 Zone 只需要为有限的 Hub 建立有限的连接。Hubs 还防止 Zone 之间的双花问题。这意味着, 当一个 Zone 从 Hubs 接收 Token 时, 它只需要信任此 Token 的原始 Zone 和 Hub。

在Cosmos网络中推出的第一个 Hub 是Cosmos Hub。 Cosmos Hub 是一个开放的权益证明（POS）的区块链，其原生staking 代币为ATOM，并且交易费用可以用多个Token支付。 Cosmos Hub 的推出也标志着[Cosmos 主网上线](https://cosmos.network/launch)。

## 如何桥接非 Tendermint 链

到目前为止，我们展示的 Cosmos 架构展示了基于Tendermint的链如何进行交互操作。 但Cosmos并不限于Tendermint链。 事实上，任何类型的区块链都可以连接到Cosmos。

如何桥接非 Tendermint 链 以及 Cosmos 如何解决可扩展性问题，我会在[区块链扩容及跨链技术](https://xiaozhuanlan.com/interchain)专栏介绍。

## 总结，Cosmos是什么?

![Cosmos is the internet of blockchains](https://img.learnblockchain.cn/2019/05/15585168934635.jpg!wl/scale/60%)

希望现在你对Cosmos 有了更清晰的了解。简洁回顾下 Cosmos 三个要点:

* Cosmos 通过 Tendermint BFT 和 模块化的 Cosmos SDK 使区块链易于开发。
* Cosmos 使区块链能够通过 IBC 和 Peg-Zones 相互转移价值, 同时让它们保留主权。
* Cosmos 允许区块链应用通过水平和垂直可扩展性解决方案可支持数百万用户。

最后，Cosmos 不是一个产品, 而是建立在一套模块化、适应性强和可交互工具之上的生态系统。


### 进一步

* 阅读 [Cosmos 白皮书](https://cosmos.network/whitepaper)
* 开始 [在 Cosmos 开发](https://cosmos.network/developers)

本文参考官网的[What is Cosmos?](https://cosmos.network/intro)。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。

<!-- 

我们有两种情况来区分：具有快速最终确定性的区块链和概率确定性的区块链。

### 快速最终确定性区块链

任何使用快速确定性共识算法的区块链可以通过适配 [IBC](https://cosmos.network/intro#connecting-blockchains-together-ibc) 与 Cosmos 连接。例如, 如果 Ethereum 要切换到 Casper FFG (Friendly Finality Gadget), 可以通过适配 IBC 连接 Casper 来和 Cosmos 生态系统建立直接的联系。


### 概率确定性区块链

对于没有快速确定性的区块链 (如工作证明链), 更棘手一些。对于这些链, 需要使用一种特殊的称为 [Peg-Zone 的代理链](https://blog.cosmos.network/the-internet-of-blockchains-how-cosmos-does-interoperability-starting-with-the-ethereum-peg-zone-8744d4d2bc3f)。

![Peg zones bridge non-Tendermint blockchains](https://img.learnblockchain.cn/2019/05/15585168084469.jpg!wl/scale/60%)

Peg-Zone 是跟踪另一个区块链状态的区块链。Peg-Zone 本身具有快速的终结性, 因此与 IBC 兼容。它的作用是为它所桥接的区块链建立最终确定性。让我们看下面的例子。

#### 例子: 以太坊 Peg-Zone

> 我们要桥接工作量证明的以太坊, 以便能够在以太坊和 Cosmos 之间相互发送 Token。由于工作量证明的以太坊无法快速达成确认状态, 我们需要创建一个 Peg-Zone 作为两者之间的桥梁。

> 首先, Peg-Zone 需要决定源链的最终确定性阈值。例如, 可以认为在源链给定块之后添加100个块后, 源链的给定块状态是最终确定的。

> 其次, 需要在以太坊上部署一个合约。当用户想要将 Token 从以太坊发送到 Cosmos 时, 他们首先要将 Token 发送到此合约。然后合约冻结资产, 在100个区块后, 这些资产的表示形式在 Peg-Zone 上发布。类似的机制被用来将资产返回以太坊。

有趣的是, Peg-Zone 还允许用户将存在于 Cosmos 上的任何 Token 发送到以太坊 (Cosmos 上的 Token 将表示为以太坊上的 [ERC20](https://learnblockchain.cn/2018/01/12/create_token/#ERC20-Token))。Tendermint 团队目前正在为以太坊实现一个Peg-Zone，名为[Peggy](https://github.com/cosmos/peggy) 。

桥接的特定链需要进行特定的定制。建造一个以太坊 Peg-Zone 相对简单, 因为太坊是基于帐户的, 并且有智能合同。然而, 建立一个比特币 Peg-Zone 更具挑战性（理论上是可能的）。有兴趣的同学可以阅读[Peg-zarl](https://github.com/cosmos/peggy/tree/master/spec)。 


## 解决可扩展性问题

现在我们可以轻松地创建和连接区块链, 还有一个问题需要解决: 可扩展性。 Cosmos 处理了两种形式的可扩展性:

* **垂直可扩展性**: 这包括扩展区块链本身的方法。不使用工作量证明并优化组件, Tendermint BFT 可以每秒处理数千个交易。瓶颈是应用本身。例如, 像Ethereum 虚拟机这样的应用交易吞吐量要比直接嵌入交易和状态转换的应用低得多 (例如,标准 Cosmos  SDK 应用程序)。这也是特定应用的区块链可行的原因之一 (更多原因可阅读[这里](https://medium.com/@gautier_md/why-application-specific-blockchains-make-sense-32f2073bfb37))。

* **水平可扩展性**: 即使共识引擎和应用经过高度优化, 在某个时候, 单个链的交易吞吐量也不可避免地触及天花板。这就是垂直可扩展性的限制。可以通过使用多链架构来解决。方案是让多个并行链运行相同的应用程序, 并由一个通用的验证者集合进行验证, 使区块链理论上具有无限的可扩展性。水平可扩展性的细节很复杂，不做讨论。

![Horizontal scalability with multiple blockchains](https://img.learnblockchain.cn/2019/05/15585168553965.jpg!wl/scale/60%)

 Cosmos 在启动时提供非常好的垂直可扩展性, 这将是对目前区块链解决方案的重大改进。在 IBC 模块完成后, 水平可扩展性解决方案将开始实现。
 -->
