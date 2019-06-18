---
title: DeFi 的流动性模型
permalink: defi-liquidity-models
date: 2019-05-28 22:48:34
categories: DeFi
tags: 
    - DeFi
    - Uniswap
    - Maker
    - Compound
author: Ashton
---

 DeFi （Decentralized Finance 去中心化金融）今年以来受到了越来越多的关注，本文来聊聊主流 DeFi 项目的流动型模型。本文译自[DeFi Liquidity Models](https://www.placeholder.vc/blog/2019/4/9/defi-liquidity-models)

<!-- more -->


## 流动性差异

随着开放金融协议的潜力变得越来越清晰，一些应用得到采用的速度比其他应用更快。 [Maker](https://makerdao.com/en/) 在锁定价值和交易量方面占主导地位。[Compound](https://compound.finance/) 和 [Uniswap](https://uniswap.io/)
紧随其后，但在流动性方面远远领先于 [0x](https://0x.org/)、[Dharma](https://www.dharma.io/)、[Augur](https://www.augur.net/) 和 [dydx](https://dydx.exchange/)。 其余的还没有出现在视野内。 

仔细观察这三个具有主导地位的协议，就会发现它们在流动性方面的一个设计优势: 不需要交易对手就可完成交易。

[Maker](https://makerdao.com/en/) 、 [Compound](https://compound.finance/) 和 [Uniswap](https://uniswap.io/) 的成功似乎与它们所支持的业务范围没有太大关系。 从借贷的角度来看，[Maker](https://makerdao.com/en/) 和 [Compound](https://compound.finance/) 并没有提供交易双方通过类似 [Dharma](https://www.dharma.io/) 通过交易对手达成的贷款交易 。 通过 [标量市场（scalar markets）](https://medium.com/veil-blog/a-guide-to-augur-market-economics-16c66d956b6c)，[Augur](https://www.augur.net/) 可以提供与 [Maker](https://makerdao.com/en/) 类似的看涨 ETH 的杠杆式长期投资，用户还可以有更多选择。 Uniswap 的配对数量远少于许多 0x 中继商，但却获取了更高的交易量。

为什么提供更少选项的协议却获得了更多的使用呢？这可能是因为它们限制了用户可用的交易类型，从而允许“自动供应方”可以持续的提供服务。

在 Augur 上采用二元市场: 要做多 ETH，用户需要从另一个用户或做市商那里购买一个看涨ETH份额 ー 一个定制的 [ERC20](https://learnblockchain.cn/2018/01/12/create_token/) 代币。 或者，他们可以自己发行一套完整的看涨份额和看空份额，然后将看空份额出售给另一个用户，自己留下看涨份额直到市场结算。 这些代币在任何去中心化交易所（DEX）上都没有交易对，更不要说那些中心化交易所了。 这种长尾资产的流动性受到严重限制，使得它们的交易成本更高、更不方便。

在 Maker 中，这个过程更容易完成。 用户通过[锁定 ETH 来发行 DAI](https://learnblockchain.cn/2019/03/19/understand_dai/)。 要杠杆化做多，他们只需要将新发行的代币兑换成 ETH。这很容易做到，在任何交易所都有充足的流动性。 换句话说，Augur 将流动性分散在大量唯一的 ERC20 代币上，而 Maker 将流动性集中在单一资产 DAI 上。 Augur 是一个定制的和多样化的过程，Maker 是自动并持续的过程。 这极大地优化了成本和可用性。

## 三个流动性类别

从流动性的角度来看 DeFi 协议，可以分为三个明显的类别:

* 其中一类协议 (Augur，0x，Dharma) 需要用户找到对手方进行交易；
* 另一类协议 (Compound，Uniswap) 将做市商的资产集中起来形成资产池，并将它们提供给交易者以获得费用；
* 最后一类协议 (Maker) 通过治理设定参数，允许用户直接与[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)进行交易。

像 0x、 Augur 和 Dharma 这样的协议是真正的 P2P： 对于每个想做多的用户来说，必须找到一个交易对手来做空。 由于这些都是需要对等协商的双边交易所，这些 P2P 协议上所支持的交易类型应该是其它类别协议所支持交易类型的超集。 这里不存在全局价格，只有一系列不同价位的双边交易（我们通常可以从中看出一些隐含的全局价格指示）。这些交易对手可以相互协商的交易类型几乎没有理论上的限制。

如果拿游戏做类比，我们可以把 Uniswap 和 Compound 想象成一个大型多人在线角色扮演游戏（MMORPG）: 不是离散的双边交易，而是所有用户都在同一张地图上玩。 用户不需要去寻找交易对手，他们只需要与资产池进行交易。 这些交易的全局价格是通过算法设定的，在 Uniswap 采用恒定的[乘积规则](https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf)，在 [Compound](https://compound.finance/documents/Compound.Whitepaper.v04.pdf) 采用基于利用率的利率模型。 这里的交易和市场都受到了更多的限制。

Maker 提供了一种（准）单一玩家模式，用户根据通过治理确定的参数自行发放贷款(有人可能会争辩说，用户是在与代表系统管理者的资产池进行交易)。 目前，Maker 只提供一种类型的交易，流动性集中在一个资产 DAI 上。


![不同项目的区别](https://img.learnblockchain.cn/2019/05/15591124257652.jpg!wl/scale/80%)



在 Augur 上，任何用户都可以创建对任何事件的看涨，只要他们能够找到持有相反意见的交易对手方即可。 在 Dharma 中，任何人都可以以任何条件借入任何资产，只要他们找到另一方借给他们。 在 Maker 上，人们可以下注的“赌注”数量较少，但一旦确定，就几乎不存在流动性约束——也就是说，单人玩家模式是可行的（玩法取决于在线参数）。 对 Maker 而言，这就意味着核心团队只需专注于为 DAI 创造需求和流动性即可，而不需要为多资产交易去考虑整体的基础设施。

## 未来

在过去几个月我们观察到，迄今为止，将流动性集中到更少数量市场和资产的协议有更顺利的采用路径。研发 P2P DeFi 协议背后的团队也注意到了这一点。Dharma 团队已经通过“升级”创建了一个名为 Lever 的 Dharma 应用，该应用已经超过了协议原来的 P2P 借贷量。值得注意的一点是，Lever 限制了产品组合，允许借款人和放贷人将流动性集中到少数的几个借贷类型。为了解决 P2P 流动性的问题，0x 协议团队已经将其重点从中继商转向做市商。

也就是说，这些 P2P 协议仍然需要更多的基础设施来实现扩展，而这对于限制了用户选择的其他协议来说影响更小。例如，交易对手方相互寻找的机制（请注意，Dharam、Veil/Augur以及 0x 都包含了某种“中继商”的概念），作为做市商需要解决的需求双重巧合，以及可以有效解决大量独立交易的扩展解决方案。

如果 DeFi 社区为长尾资产（例如非同质代币和预测市场份额）制定出流动性解决方案，那么，P2P 协议可能会通过提供资产类型的“无限通道”和定制敞口，超越其灵活性较低的类似物效用。这些交易对手协商的合约从理论上可以允许用户接触任何资产或世界状态。随着市场完整性飞轮的启动，这种可塑性可能允许这些系统逐渐服务那些更深的利基市场。

聚合或自动供应方协议则来自于相反的方向。例如，Maker 试图通过多资产抵押DAI 来扩展它的产品组合，Uniswap 可能会持续扩展其交易对，尽管这两个网络都必须注意在流动性方面进行分散权衡。

虽然目前还不清楚谁将是最终的赢家，但这两个类别的网络似乎都着眼于提供更广泛的市场选择，以便于为用户提供足够的流动性。目前，那些在少数几个重要市场中已经构建了深度流动性的项目似乎已经在采用上获得了领先。


本文作者为深入浅出社区共建者Ashton，喜欢他的文章可关注他的[简书](https://www.jianshu.com/u/922115b98e3f)。

[深入浅出区块链](https://learnblockchain.cn/)-系统学习区块链，学区块链的都在这里，打造最好的区块链技术博客。
