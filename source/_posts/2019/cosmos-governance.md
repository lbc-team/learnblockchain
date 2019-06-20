---
title: 理解 Cosmos Hub 的治理【译】
permalink: comsmos-governance
date: 2019-06-18 09:25:14
categories: 
    - 跨链
    - Cosmos
tags: 
    - Cosmos
author: Felix Lutsch
---

本文作者Felix Lutsch 是Chorus One（验证人节点运营服务商）的研究员，本文将介绍Cosmos Hub的治理流程以及如何参与治理。

<!-- more -->

Cosmos Hub已经正式上线，其核心功能之一就是让Atom代币持有人拥有共同治理区块链的能力。Atom代币持有人可以通过签署特殊类型的交易来提交提案，并表明他们是否批准（或不批准）提交给区块链网络的提案。以下文章将介绍Cosmos Hub的治理流程，以及治理工具，该工具允许任何Atom代币持有人参与链上治理机制。

## 治理流程

在当前的Cosmos Hub治理实施流程中，任何人都可以向系统提交文本提案。不过，如果想要提交的提案进入到投票阶段，则有最低存款金额要求。在投票阶段，Atom代币持有人可以就提案是否被接受进行投票。以下使用的数字是基于文本撰写时（2019年3月25日）在Cosmos Hub上实施的参数。

![](https://img.learnblockchain.cn/2019/06/15608394248887.jpg)
<p class="image-caption">Cosmos Hub治理流程的一个例证</p>

### 阶段1：存款阶段

对于想要进入到投票阶段的提案，需要在提交该提案之后的两周时间内存入至少512 Atom代币，这也是进入到投票阶段的最低存款金额要求。任何Atom代币持有人都可以支持提案，并且为该提案提供存款，这意味着提案提交方不一定自己存入512 Atom代币，只要有人愿意为其出这笔“钱”即可。同时，存款必须要有垃圾邮件保护，这样当提案被接受的时候或是两周之后未能达到最低存款限额要求，支持该提案的Atom代币持有人就能够收到通知提醒。

### 阶段2：投票阶段

一旦提案满足了最低存款限额要求，那么长达两周（336小时）的投票阶段就将正式启动。在此期间，所有Atom代币持有人可以对该提案进行投票，目前有四个投票选项，分别是“是”、“否”、“行使否决权的否定（No with Veto）”、“弃权”。

Cosmos治理实施有一些重要细节值得关注，包括：

1. 只有质押的（staked/bonded）代币才能参与治理；
2. 投票权基于质押权益(stake)被评估，你拥有的Atom 质押的代币数量决定了对提案决策的影响力大小（代币投票）；
3. 委托人可以继承验证人的投票，除非委托人自己有过投票。如果委托人自己投票的话，将会覆盖验证人的决定。

## 阶段3：清点投票结果

根据Atom代币持有人的投票结果，如果提案被接受，那么至少需要满足以下几个条件：

1. 法定人数(Quorum)：在投票结束的时候，超过40%的权益代币(staked tokens)需要参与投票；
2. 门槛：参与投票代币（剔除“弃权”投票后）需要超过 50% 支持该提案（即选择的投票结果是“是”）；
3. 行使否决权：参与投票的代币（剔除“弃权”投票后）需要低于 33.4% 行使“否决权（No with Veto）”。

如果在投票阶段结束时上述要求中有任何一项没有满足，比如法定人数没有达到，那么该提案就不能被通过。此时，这个被拒绝的提案中的存款不会被退还，而是会被纳入到社区池中。

## 阶段4：实施提案

如果提案被接受，则需要被实现并合并到网络验证人运行的软件中。我们未来还会专门发布一篇文章来详细解释不同类型的提案、以及验证人会如何准确地协调、实施上述提到的那些被接受的提案。

如果你想要看看一个治理投票的典型示例，不妨可以先看看验证人团队[B-Harvest](https://bharvest.io/)的[第一个治理提案](https://hubble.figment.network/cosmos/chains/cosmoshub-1/governance/proposals/1验证人)，该提案是关于调整用于计算网络通胀的块时间比率，以反映网络中的实际情况。（请注意：Chorus One支持该提案，因为它通过实时网络支付权益奖励，符合Cosmos白皮书中的描述。不过我们发现这只是一个临时解决方案，今后也会支持通过引入一个基于网络条件动态调整的其他提案。

## 如何参与治理

在Chorus One，我们的目标是让代币持有人能够对网络治理施加影响。出于这个原因，我们创建了一个工具，允许Atom代币持有人方便的地从他们的Ledger 钱包中投出治理投票，该工具可以在这个[链接](https://chorus.one/networks/cosmos)找到。

## 结论

我们相信通过Cosmos的治理方式，委托人可继承验证者投票，同时委托人也能够覆盖验证者选择并做出自己的决定。这是在其他区块链网络中可以观察到的低治理投票率的一个很好的解决方案。 我们认为这种方法对于不太感兴趣的持有者的代议制民主（“代理投票”）之间取得一个很好平衡，同时仍然允许对想要网络治理的代币持有者直接参与。

Cosmos Hub治理仍处于早期阶段，我们的目标是提供我们对如何改进系统的意见，因为我们相信运行良好的治理机制将增加Cosmos Network成功的可能性。

## 附录
### Cosmo 治理的线上资源：

1. [Chorus One治理工具](https://chorus.one/networks/cosmos)
2. [Cosmos SDK治理文档](https：//cosmos.network/docs/spec/governance/)
3. [Cosmos网络治理论坛](https://forum.cosmos.network/c/governance)
4. 治理提案统计: 
    https://bharvest.io/wallet_en
    https://hubble.figment.network/chains/cosmoshub-1/governance

### Gaiacli指令

查询命令列表（在gaiacli中）：

```
gaiacli query gov -h
```

> 注：Gaia 是 Cosmos Hub 应用名字，包含 gaiad 和 gaiacli 两个部分。