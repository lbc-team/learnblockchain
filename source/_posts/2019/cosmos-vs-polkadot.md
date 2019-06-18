---
title: Cosmos 与 波卡 Polkadot 的五大区别
permalink: comsmos-vs-polkadot
date: 2019-06-18 10:45:14
categories: 跨链
tags: 
    - Cosmos
    - Polkadot
author: Julian Koh
---

Cosmos 和 Polkadot 都是关注区块链互操作性的项目，关于二者之间的差别已经有过很多讨论。如果你还不熟悉这两个项目，Linda Xie 发过一串[推特](https://twitter.com/ljxie/status/1118221870745047040?ref_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1118221870745047040&ref_url=https%3A%2F%2Fmedium.com%2Fmedia%2F4c261ee43d7ae6db10bd7c53dcca9114%3FpostId%3D67f09535594b)介绍过这两个项目，可以作为很好的入门材料。

虽然已经有很多文章分析过这两个项目的区别了，但是我认为其中大部分都存在一定的偏向性或者不够详细。通过这篇文章，我会从架构权衡到设计哲学等方面更深入地探讨这两个项目。

<!-- more -->

## 为什么要构建一条新的区块链？

为什么一些项目要选择从头开始构建一条专门承载应用程序的区块链，而不是以[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)的形式在现有的区块链上编写应用程序呢？主要有以下两点原因。

首先，现有的智能合约平台不一定能满足应用程序所需的灵活性和可定制性。举例来说，如果你想搭建的应用程序需要自定义的哈希函数，那么把它编写到以太坊上会消耗很多 gas ，因为这个函数每调用一次都需要在以太坊虚拟机内执行一次。一种解决方案是提议将这个函数作为[预编译合约](https://ethereum.stackexchange.com/questions/15479/list-of-pre-compiled-contracts)添加至以太坊协议内。但是，除非这个函数也广泛应用于其它应用程序，否则这项提议大概率是不会通过的。从头开始编写一条新的区块链，你就可以自由灵活地设计区块链的核心逻辑，以此满足你的应用程序的需求。

其次是自治问题。在[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)平台上构建的应用程序必须接受平台的治理并遵守其规则，从区块时间和 gas 定价之类影响用户体验的规则，到回滚之类改变状态的决策等等。

但相应的，具有自治能力的链失去了与其它应用程序进行无缝通信的能力，因为应用程序都是搭建在使用不同状态机的区块链上。Cosmos 和 Polkadot 都致力于解决这个问题——Cosmos 采用的是 [Hub-and-Zone](https://medium.com/@juliankoh/a-deep-look-into-cosmos-the-internet-of-blockchains-af3aa1a97a5b)（中心枢纽-分区） 模型，Polkadot 则采用的是[Relay Chain/Parachain](https://medium.com/polkadot-network/polkadot-the-foundation-of-a-new-internet-e8800ec81c7)（中继链/平行链）模型。

读者需要对这两个项目有一定的了解，本文侧重于梳理二者的不同点。

## 局部安全 vs 全局安全

[Cosmos](https://learnblockchain.cn/2019/05/21/what-is-cosmos/) 和 Polkadot 采用的安全模型差别极大。

### Polkadot 共享全局安全

简单来说，Polkadot 的工作流程如下：

![Polkadot的安全模型](https://img.learnblockchain.cn/2019/06/15608239090500.png)
<p class="image-caption">Polkadot 的网络架构</p>


平行链（Parachain）是 Polkadot 网络中的区块链。这些链有自己的状态机、自己的规则和自己的区块生产者，即核验人（collators）。**每条平行链本质上都是一个独立的状态机**，而且可以使用任何类型的特殊功能、共识算法、交易手续费结构等等。在 Polkadot 网络中，所有平行链都有同一条母链，叫做中继链，里面包含了由所有平行链组成的 “全局状态”。中继链拥有自己的共识算法，叫做 GRANDPA 共识（祖父共识），可以迅速将平行链上的区块确定下来。通过这个模型，Polkadot 的平行链实现了 “共享安全性”—— 如果中继链上有 1000 名验证者，具有极高的安全性，凡是连接到这条中继链的平行链都会受益。这样一来，平行链即能拥有自己的状态机并自定义规则，又能与成百上千条平行链一起共享母链的安全性。

这种模型的**缺点**需要在于由中继链上的验证者来验证平行链上的状态改变。例如，验证者可能会出于某种原因一直拒绝某条链上的核验人提议的区块，而且这条中继链上的区块永远无法被添加进全局状态。为了尽量避免这种情况，Polkadot 对验证者进行混洗，让他们随机验证平行链，降低同一位验证者始终验证同一条平行链的概率。Polkadot 还另设有一类被称为 Fishermen （渔夫）的验证者，他们会不断查验验证者是否存在恶意行为。

### Cosmos 独立的局部安全

[Cosmos](https://learnblockchain.cn/2019/05/21/what-is-cosmos/) 采用了完全不同的网络架构。

![Cosmos的网络架构](https://img.learnblockchain.cn/2019/05/15585168934635.jpg!wl/scale/60%)
<p class="image-caption">Cosmos的网络架构</p>

**在 Cosmos 网络中，每条链都是独立运行的**，并设有各自的安全机制，而非像 Polkadot 那样采用全局的安全性模型。每条链都有自己的共识机制，而且由单独的验证者来负责保护这条链的安全性。Cosmos 网络使用中心枢纽-分区模型来实现互操作性，每个分区（独立的链）都可以通过中心枢纽（同样是一条独立的链）向其它分区 “发送代币”。这个协议被称为 IBC （跨链通信），是链与链之间通过发送消息实现代币转账的协议。IBC 协议尚在[开发](https://github.com/cosmos/ics/issues)之中，最开始先支持代币转账，最终会支持各类消息的跨链传递。

相比于 Polkadot 的架构而言，Cosmos 的架构最大的不同之处在于，每个分区链的状态仅由各自的验证者保护。一个分区想要获得很强的安全性，就需要建立自己的验证者集，这对于小型应用程序来说会比较困难。不过，对于那些想要获得更多控制权的应用程序来说，这是个很大的亮点。例如，币安最开始就是用自己的节点来充当币安链的验证者，来促进去中心化交易所的持续运行。这样一来，币安在测试币安链并增加新功能的时候就有了充分的控制权。我觉得币安不太可能放弃决定哪些交易可以上链的权力，但若要在[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)或 Polkadot 平台上开发，就不能不放弃这样的权力。正因如此，我认为 Telegram、Facebook 和 Kakao 这类公司会选择构建自己的区块链并掌握其控制权，未来也不太可能与别的链通信。

## 治理和参与

Polkadot 和 Cosmos 之间的第二个主要差别在于治理和参与。

### 参与规则差异

在 Polkadot 网络中，只有一条中继链和一些与这条中继链共享验证者的平行链。根据[目前的估算](https://medium.com/polkadot-network/a-brief-summary-of-everything-substrate-and-polkadot-f1f21071499d)，平行链的数量上限为 100 条，不过未来有可能减少或增加。Polkadot 网络通过拍卖机制来竞拍平行链的使用权——出价最高的人需要在 PoS 系统中锁定一定数量的 DOT （Polkadot 上的原生货币），才可以在一定时间段内拥有所拍得平行链的使用权。这意味着要想使用 Polkadot 上的平行链，需要购买并锁定大量 DOT ，直到不想再使用这条平行链为止。

Cosmos 网络没有设置固定的参与规则——任何人都可以创建中心枢纽或分区。中心枢纽就是具有自治能力的区块链，它专门用来连接其它区块链。这里有两个例子，一个是 [Cosmos Hub](https://cosmos.bigdipper.live/)，最近已由 Tendermint 团队上线；另一个是 [Iris Hub](https://www.irisnet.org/)，旨在连接主要运行于中国或其它亚洲国家的区块链 。这种中心枢纽-分区模型提高了跨链通信的效率，因为分区链只需要连接到中心枢纽，无需连接到其他每条链上。

![中心枢纽-分区模型](https://img.learnblockchain.cn/2019/06/15608254444315.png)
<p class="image-caption">中心枢纽-分区模型可以更高效地连接多条链</p>

### 治理流程差异

由于参与规则不同，这两个网络在治理流程上也存在差异。
在 Polkadot 网络中，治理决策取决于投票者所质押的 DOT 数量。关于链上投票会有一套正式机制，不过尚未最终确定下来，点击[此处](https://github.com/paritytech/polkadot/wiki/Governance)可了解最新进展。除了采取以质押量决定投票权重的机制之外，Polkadot 还组建了一个委员会来代表不活跃的权益持有者。委员会最开始由 6 人组成，每两周增加 1 人，直到满 24 人为止。每位委员会成员均通过[赞成投票](https://en.wikipedia.org/wiki/Approval_voting)的方式选出。治理流程的具体细节尚未敲定，也就是说有很多方法可以改变中继链的参数，如出块时间、区块奖励等，以及平行链的参与规则。例如，Polkadot 的治理流程可以改变平行链使用权的竞拍机制或所需的 DOT 数量。有一种常见的误解是 DOT 持有者可以通过投票随意弃用某条平行链。实际上，DOT 持有者只能改变参与流程。也就是说一旦竞拍下了某条平行链，在整个[租期](https://twitter.com/PAMauric/status/1118545428809568267)之内都享有这条链的使用权。

另一方面，Cosmos 网络不存在单一的 “治理”流程。每个中心枢纽和分区都有自己的治理流程，因此没有一套应用于整个系统内所有链的核心规则。我们所说的“Cosmos 治理”指的都是 Cosmos Hub 的治理，即由 Tendermint 团队上线的那条链。Cosmos Hub 的规则是，任何人都可以发送一个文本提议，由 ATOM 持有者进行投票表决，ATOM 的质押量决定了投票权重。想知道提议长什么样子，[这里](https://www.mintscan.io/proposals/5)有个例子。如果你想深入了解治理流程的话，可以阅读一下 Chorus One 发布的[ Cosmos Hub 治理机制](https://learnblockchain.cn/2019/06/18/comsmos-governance/)，是不错的了解 Cosmos Hub 治理的入门资料。

##  跨链通信

Polkadot 和 Cosmos 之间的另一个差别是跨链通信协议及其设计目标。
**Polkadot 旨在实现平行链之间任意的消息传递**。也就是说，平行链 A 可以调用平行链 B 中的智能合约，实现与平行链 B 之间的代币转账或是其他类型的通信。**Cosmos 则聚焦于跨链资产转移**，其协议较为简单。目前，这两种通信协议仍待完善细则，而且尚未构建完成。可以查看 [IBC](https://github.com/cosmos/ics)（跨链通信）和 [ICMP](http://research.web3.foundation/en/latest/polkadot/ICMP/)（平行链之间的跨链通信）这两种协议的细则。

跨链通信所面临的最大挑战不是如何将一条链上的数据在另一条链上表示出来，而是如何处理链分叉和链重组这样的情况。这是 Cosmos 和 Polkadot 在构架设计上最大的差异。

为了确保跨链通信的安全性，Polkadot 采用了两种不同的机制。首先是安全性共享机制，降低了信息交换的难度。 共享安全性的另一个好处是所有平行链都位于同一个安全层级，因此每条链可以彼此信任。为便于理解，我们以以太坊（安全性较高）和 Verge（安全性较低）的交互操作为例。若想在 Verge 链上表示以太坊，我们可以锁定一些以太坊，然后在 Verge 链上生成 ETH-XVG 代币。然而，由于 Verge 链的安全性较低，攻击者可能会向 Verge 链发动 51% 攻击，并向以太坊区块链发送双花交易，就可以取回比实际拥有数量更多的以太币。因此，在互相发送消息的时候，安全性较高的链很难信任安全性较低的链。如果是在安全层级各不相同的链之间互传消息，情况就会变得更加复杂。

从理论上来说，共享安全性是一种保障跨链通信的良好方式。前提是，这种协议要确保能够经常对验证者进行混洗，再随机分配到各条平行链上。这就会造成经典的 “数据可用性问题”，即每次验证者被分配到新的平行链上，就需要下载新链的状态。这是目前区块链领域最大的难题之一，Polkadot 能否解决尚未可知。

其次，Polkadot 引入了 Fisherman（渔夫）的概念，也就是 Polkadot 网络上的 “赏金猎人”，专门监视平行链上的恶意行为。从某种意义上来说，这是抵御恶意行为的“第二道防线”。如果某条平行链的验证者将一个无效块上链，Fisherman 发现后可以向中继链提交证明，将包括所有平行链在内的整个 Polkadot 网络的状态进行回滚。在跨链通信期间，最令我们担心的莫过于一条链在重组，另一条链却运行如常。Polkadot 就避免了这个问题，一旦发现无效块上链，整个网络都会回滚。

Cosmos 采用了完全不同的跨链通信方式。因为每条链上都有自己的验证者，所以很有可能会出现分区中的验证者串谋的情况。也就是说，如果有两个分区需要通信，A 分区需要必须信任 Cosmos Hub（通信枢纽）以及 B 分区中的验证者。从理论上来说，A 分区的人在决定向 B 分区发送信息之前，需要调查一下 B 分区的验证者。不过我觉得实际情况没那么糟糕。 [Polychain Labs](https://hubble.figment.network/cosmos/chains/cosmoshub-2/validators/B1167D0437DB9DF0D533EE2ACDE48107139BDD2E) 或 Zaki Manian 的 [iqlusion](https://hubble.figment.network/cosmos/chains/cosmoshub-2/validators/95E060D07713070FE9822F6C50BD76BCCBF9F17A) 等知名验证者节点可能会验证多条链，逐渐建立起良好的声誉。也就是说，当 A 分区的人看到 B 分区是由 Polychain Labs 和 iqlusion 验证的，可能会因此决定信任 B 分区。

然而，即使一条链得到了人们的信任，也有可能被怀有恶意的攻击者控制，出现各种问题。有一段[对话](https://youtu.be/_qUnCUZHc5g)中提到了一个很好的例子：
![](https://img.learnblockchain.cn/2019/06/15608262563931.png)
<p class="image-caption">代币分散于不同分区的 Cosmos 网络</p>

假设上图中的小红点代表一种名为 ETM 的代币，即 Ethermint 分区的原生代币。A、B、C 三个分区的用户想要使用 ETM 来运行各自分区内的一些应用程序，而且他们都信任 Ethermint 分区，因此通过跨链通信在各自的分区内接受了一些 ETM 。现在假设 Ethermint 分区的验证者串谋发动双花攻击，任意转移 ETM 代币。这也会对剩余网络造成影响，因为 ETM 代币也存在于其他分区中。不过受波及的只有 Ethermint 或其他分区中的 ETM 代币持有者。Ethermint 分区中的恶意验证者只能毁掉自己的分区，破坏不了其他分区。这就是 Cosmos 架构的目标——确保恶意行为无法影响整个网络。

Polkadot 则不同。如果中继链（全局状态）上发生了无效状态更新，又没被 Fisherman 发现的话，Polkadot 网络中的每条平行链都会受到影响。平行链不能被看作是完全不同的东西，毕竟它们都共享同一个全局状态。

## 共识算法

Polkadot 中继链采用的是 [GRANDPA](https://medium.com/polkadot-network/grandpa-block-finality-in-polkadot-an-introduction-part-1-d08a24a021b5) 共识算法。这个算法能让中继链迅速确定来自所有平行链的区块，并且容纳大量验证者（1000 名以上）。简单来说，这是因为并非所有验证者都需要对每一个区块进行投票——他们可以只需为自己认为有效的某个区块投票，相当于这个区块之前的所有区块也都得到了认可。通过这种方式，GRANDPA 算法可以找出一组得票数最多的区块，并将这组区块确定了下来。该算法仍处于开发之中，尚不知实际会如何执行。

平行链可以采用不同的共识算法达成局部共识。Polkadot 提供一个软件开发工具包（[Substrate](https://github.com/paritytech/substrate)），其中包括 GRANDPA、Rhododendron 和 Aurand 三种开箱即用的共识算法。今后可能会有更多算法被加入 Substrate ，皆可应用于 Polkadot 网络。

在 Cosmos 网络中，每条链可以选用的共识算法有很多，只要是符合 [ABCI](https://tendermint.com/docs/spec/abci/) 规范的共识算法即可。 [ABCI](https://tendermint.com/docs/spec/abci/) 规范旨在实现跨链通信的标准化。目前只有 Tendermint 算法符合这个规范，还有[另一些团队](https://twitter.com/sunnya97/status/1113454367548379136)也在努力开发符合该规范的其他共识算法。从更抽象的层面上来看，Tendermint 算法的原理是让每位验证者都能互相通信，共同决定一个区块能否上链，这样就能实现单一区块层面上的确定性。该算法的速度很快，而且通过了 200 名验证者的压力测试，在 [Game of Stakes](https://github.com/cosmos/game-of-stakes)（权益争夺赛）中的出块时间为 6 秒。Cosmos 团队也提供了一个软件开发工具包，里面包含了开箱即用的 Tendermint 算法。[这篇文章](https://medium.com/tendermint/a-to-z-of-blockchain-consensus-81e2406af5a3)很好地介绍了共识算法，以及 Tendermint 算法的功能。

Tendermint 算法最大的缺点是验证者之间的通信成本高很高。也就是说，虽然验证者人数在 200 左右的时候，算法的运行速度很快，一旦人数涨到了 2000 ，速度就会慢得多。另一方面需要权衡的是异步环境中的安全性。也就是说，在出现网络分区之时，不会出现两个不同的交易历史最终合并成一个（而另一个交易历史被抛弃）的情况，而是整个网络都将停止运行。这点非常重要，一旦一笔交易得到了“最终确认”，即使是在最差的网络环境下也不会被撤销。

我的个人观点是，基于共识算法来比较这两个项目没什么长远意义。这两个项目的构架未来都将接受不同的共识算法。如今的绝大多数应用不管使用的是 Tendermint 算法还是 Polkadot 的某个共识算法都可以良好运行。

## Substrate vs Cosmos SDK

Polkadot 和 Cosmos 都提供软件开发工具包，分别叫作 [Substrate](https://www.parity.io/substrate/) 和 [Cosmos SDK](https://cosmos.network/sdk) 。二者的目的都是为了便于开发者搭建自己的区块链，其中包括各种开箱即用的模块，例如治理模块（投票系统）、质押模块和认证模块等。这两个工具包最主要的区别在于，[Cosmos SDK](https://learnblockchain.cn/docs/cosmos/) 仅支持 Go 语言，而 Substrate 支持任何可编译为 WASM (Web Assembly) 的语言，给予了开发者更多灵活性。

这两个工具包都是构建区块链的全新框架，未来几年还将新增更多功能。关于这两个工具包的深度剖析以及使用这两个工具包开发应用程序的详细体验需要另外写一篇文章了。如果你感兴趣的话，请在推特上给我[*@*juliankoh](https://twitter.com/juliankoh) 留言。

## 结论

虽然这篇文章篇幅很长，写的也很详细，但是依然有所疏漏。Cosmos 和 Polkadot 之间的不同点很难把握，可能还有很多细节我没有捕捉到。要全方位了解这两个项目绝非易事，毕竟项目文件随时都可能改动。这两个项目尚在起步阶段，未来一年将得到极大的发展——我在上文中提到的几个点可能很快就不成立了。总而言之，我认为 Polkadot 相比 Cosmos 主要有以下几个优势：

1. 应用程序开发者不需要自己维护安全性
2. 共享安全性模型下的跨链通信更容易解决数据可用性问题
3. Substrate（在 WASM、更多共识算法和开箱即用模块方面）表现出很大的野心
4. 相比跨平行链的合约调用更侧重于不限类型的信息传递（这一用例目前尚不明确）
5. 1.0 版本的[开发者](https://twitter.com/web3jp/status/1113440496116846592)似乎多一些

反过来，Cosmos 相比 Polkadot 主要有以下几个优势：

1. Cosmos 已经上线了，Polkadot 还没上线
2. Polkadot 的平行链参与流程限制性更强，而且成本更高
3. 更能满足特定项目（如币安）对自定义的需求
4. 平行链上验证者的恶意行为会波及整个网络。在 Cosmos 网络中，恶意行为只能破坏个别分区和资产
5. 已经有[很多项目](https://cosmos.network/ecosystem)在使用 Cosmos SDK 了
6. 重点关注如何降低资产转移的难度。目前已经有经过验证的用例。

感谢每一位不厌其烦为我答疑解惑的朋友，尤其是来自 Cosmos 团队的 [Zaki Manian](https://twitter.com/zmanian) 和 [Gautier Marin](https://twitter.com/gautier_md) ，以及来自 Polkadot 团队的 Alistair Stewart 。NEAR Protocol ([Alex Skidanov](https://twitter.com/AlexSkidanov)) 发布的 [Whiteboard Series](https://youtu.be/5bLwPQZw9Jk) 系列视频很棒，对我理解这两个项目给予了很大帮助。[Linda Xie](https://twitter.com/ljxie/) 整理出来的关于 Polkadot 和 Cosmos 的链接帮助我缩小了文章的范围，让这篇文章更具有可读性。特别感谢[Cheryl Yeoh](https://twitter.com/cherylyeoh) 在我撰写本文的过程中为我提供的灵感和思路，并且对本文进行了审校。

* * *

原文链接在[这里](https://medium.com/@juliankoh/5-differences-between-cosmos-polkadot-67f09535594b) ， 在[ETHFANS](https://ethfans.org) 的闵敏 & 阿剑的翻译基础上有说所修改。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
