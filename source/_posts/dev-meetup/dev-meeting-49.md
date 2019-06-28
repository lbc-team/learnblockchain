---
title: 跨链技术沙龙 - 构建价值流通的桥梁
permalink: dev-meeting-49
date: 2019-06-28 10:47:23
categories: 技术工坊
tags: 跨链
author: 辉哥
---

本次会议首先有3个独立的主题分享：《ChainX平行链的跨链技术的实践与探索》，《支持Cosmos公有链的钱包技术原理实现》，《跨链生态之Defi去中心化金融的未来》，然后组织了跨链生态的圆桌会议。从跨链开发生态，钱包到Defi生态，围绕跨链这个主题，分享嘉宾从多个维度对跨链技术做了深度的交流，更新了大家对2019年跨链发展的一些认知。

<!-- more -->

## Chainx CTO 郭光华：跨链技术的实践与探索
![](https://img.learnblockchain.cn/2019/06/28_280282513.jpg)

郭光华给大家普及了目前市面上已有的跨链项目是什么样的状态。目前存在3种类型的跨链形态：

1. 侧链的扩展 - 同质链的轻节点跨链
2. 见证人似的跨链 - 需要人为的参与，中心化跨链，中心化交易所是典型
3. 轻节点跨链 - 全自动化跨链， 去信任化跨链。

跨链的最终形态是能够搭建轻节点跨链，完全信代码，不需要任何中间人参与，就能够自动化执行的逻辑。所以把轻节点跨链叫做 自动化跨链 / 去中心化跨链 /去中介化跨链。

郭光华接下来介绍了跨链场景中对链的基本要求包含确定性，性价比，合约丰富性等3方面的要求。

![](https://img.learnblockchain.cn/2019/06/28_107486615.png)

跨链需要的最大突破点是实现以下2点：
1. 路由转发协议：链与链层级的底层协议 -如何像传统路由器转发消息一样转发各个链的价值信息。
2. 用户索引协议：A链用户 Call 调用 B链合约的接口 -各个链之间如何像 WWW协议一样 可以互相Call。

作为明星项目的Polkadot 项目带给技术圈带来了4个方面的思维突破。

![](https://img.learnblockchain.cn/2019/06/28_691093812.png)

Polkadot虽然还没有主网上线，但目前情况已经取得了一些重要的突破。

![](https://img.learnblockchain.cn/2019/06/28_411977171.png)

ChainX作为Polkadot的平行链项目，已经在2019年5月25日完成了主网上线。ChainX目前已经在多个方面取得了重大进展。

![](https://img.learnblockchain.cn/2019/06/28_300561688.png)

而ChainX与Polkadot的生态关系如下图所示：

![](https://img.learnblockchain.cn/2019/06/28_947840661.png)

最后，作为一个资深的区块链技术人员，郭光华给出了区块链技术人员在跨链开发时的技能提升晋级路径：

![](https://img.learnblockchain.cn/2019/06/28_599390197.png)

欢迎大家关注ChainX公众号，了解更多信息。
![](https://img.learnblockchain.cn/2019/06/28_279510326.png)

![](https://img.learnblockchain.cn/2019/06/28_690839062.png)

## QBAO CEO 陈琳：支持Cosmos公有链的钱包技术原理实现

![](https://img.learnblockchain.cn/2019/06/28_384376265.jpg)

作为一个虔诚的技术布道者，陈琳在身体有小恙咳嗽的情况下坚持来布道，同时也为了照顾现场可能存在的区块链小白，陈琳还是简单普及了下比特币的基础知识后，普及了区块链的6层结构图。

![](https://img.learnblockchain.cn/2019/06/28_700827337.png)

接下来，陈琳给出了去中心化钱包的开发框架。针对这个框架，他解释了去中心化[钱包开发](https://learnblockchain.cn/2019/04/11/wallet-dev-guide/)的每一个步骤，让大家了解了数字钱包的完整功能。

![](https://img.learnblockchain.cn/2019/06/28_440072259.png)

接下来，陈琳介介绍了去中心化[钱包](https://learnblockchain.cn/2019/04/11/wallet-dev-guide/)支持cosmos公链的开发步骤。主要有3个步骤：
**Step 1: Generate [Cosmos](https://learnblockchain.cn/2019/05/21/what-is-cosmos/) Private Key & Public Key （移动端实现）**
访问cosmos的核心仓库之一 gaia
https://github.com/cosmos/gaia
根据他的核心代码在APP端进行Private Key & Public Key的生成

**Step 2: 移动端实现**
1. Generate Un-signed TXs
2. Signed TXs
3. Send Signed TXs

**Step 3:**
1. 连接全节点 （Qbao 拥有自己的阿里云和AWS双套的全节点）
2. 打开区块链浏览器 （Qbao拥有自己开发的cosmos浏览器）

最后陈琳分享了QBAO钱包的组成框架和生态应用。

![](https://img.learnblockchain.cn/2019/06/28_337713932.png)

![](https://img.learnblockchain.cn/2019/06/28_85267462.png)

QBAO钱包的资料信息如下，欢迎大家下载体验。

![](https://img.learnblockchain.cn/2019/06/28_897345546.png)

![](https://img.learnblockchain.cn/2019/06/28_126306357.png)

## Wanchain&DFP 联合创始人 杨涛：跨链及在Defi上的应用场景
![](https://img.learnblockchain.cn/2019/06/28_16517641.jpg)
Wanchain的杨涛首先分享了自己的认知给与会的朋友。

跨链的本质是什么？

![](https://img.learnblockchain.cn/2019/06/28_83186853.png)

跨链存在的2大难题是什么？

![](https://img.learnblockchain.cn/2019/06/28_837695298.png)

Wanchain 采用Storeman机制来解决跨链问题，使用原子互换完成跨链的过程。

![](https://img.learnblockchain.cn/2019/06/28_826661850.png)

原子互换的基本原则是不需要第三方公证人，而是让交易的参与双方自行判定对方的交易是否完成，通过哈希时间锁（hash time lock）和密数（Secret）控制，实现交易双方“一手交钱一手交货”，也就是两种不同token 的互换。这种方式能够有效的规避第三方公证人不完美的问题。在Wanchain 的跨链过程中，两种互换的token 分别是指原链token 与Wanchain 上的映射token. 当原链上的某个用户需要发送一笔跨链交易使
原链token 能够转移到Wanchain 上时，用户的钱包会构造一笔原链交易，这笔原链交易被哈希时间锁锁定，Wanchain 上负责处理跨链交易的Storeman 在检测到这笔跨链交易后，会在Wanchain 上发起一笔跨链的合约交易，该笔交易负责产生映射token 并转移到用户指定的跨链接收账户，此时该笔交易被跨链合约锁定。当用户的钱包检测到被跨链合约锁定的交易后，主动释放密数到跨链合约中，Storeman 通过该密数获得锁定账户中对应的原链token 的控制权，用户获得Wanchain 上映射token 的控制权。如果这个过程中，用户在哈希时间锁的时间范围内没有释放密数，则哈希时间锁到期后，用户重新获得原链token 的控制权，跨链合约中的交易自动失效。
以上跨链过程看似复杂，但多数功能都由钱包和合约完成，用户只需要在发起交易、释放密数、撤销交易的环节进行操作。对于参与跨链的Storeman，Wanchain 会提供专门的客户端，客户端根据协议进行无需值守的自动化运行。

杨涛给出了Defi的应用层协议结构图：

![](https://img.learnblockchain.cn/2019/06/28_189364092.png)

接下来，杨涛分享了区块链金融发展阶段。目前就处于第3阶段。

![](https://img.learnblockchain.cn/2019/06/28_98114796.png)


Defi走向必经之路，要解决“补助资道投什么”，“不知道怎么投”，“不知道为什么投”这个不可能三角问题。

![](https://img.learnblockchain.cn/2019/06/28_573700626.png)

然后，杨涛给大家举例说明了目前一些DeFi的跨链场景举例。

一种是借贷结合POS投资：

![](https://img.learnblockchain.cn/2019/06/28_758701540.png)

一种是多币种期权：

![](https://img.learnblockchain.cn/2019/06/28_666288532.png)

还有一种是MakerDAO为代表的多币种MakerDAO和分布式交易所模式。

![](https://img.learnblockchain.cn/2019/06/28_107991604.png)

![](https://img.learnblockchain.cn/2019/06/28_69509496.png)

![](https://img.learnblockchain.cn/2019/06/28_771258994.png)

# 5. 圆桌会议
![](https://img.learnblockchain.cn/2019/06/28_227200708.png)

圆桌会议由以下7位嘉宾组成，由王超担任圆桌主持人。
王  超     下笔有神科技区块链 CEO
郭光华    Chainx联合创始人兼CTO
陈  琳      Qbao Network 联合创始人兼CEO
杨  涛      Wanchain联合创始人
兰锦生    NULS(纳世)上海技术负责人
胡继臣    HPB芯链DAPP研发总监
FrankYing  UDAP联合创始人

限于时间关系，会议分享了2个必答问题：
1，跨链跟协议标准的关系？
2，如何看待Libra对区块链行业，互联网行业的影响？
各位嘉宾都给出了自己的看法。

会议也给现场听众提供了2个问题的机会，大家咨询了NULS一键发链的相关疑问。

![](https://img.learnblockchain.cn/2019/06/28_606746038.png)

将近6点，会议进入尾声，大家依依不舍的离开了neutrino孵化器，回味着当天的分享内容。

敬请继续关注HiBlock组织的好活动。
![](https://img.learnblockchain.cn/2019/06/28_438861815.png)


## 主办方介绍
![](https://img.learnblockchain.cn/2019/06/28_998310022.png)

本次活动主办方之一，HiBlock技术社区上海合伙人，下笔有神科技区块链 CTO王登辉介绍了本次跨链主题分享活动的来源。介绍了HiBlock是一个全国跨城市的技术社区联盟，无公司实体，目前在上海，北京，深圳，杭州，珠海，西安等地建立了合伙人制度和活动组织。HiBlock在全国各地的兼职城市合伙人一起赋能给HiBlock这个区块链社群品牌，连接了广大区块链项目和开发者，搭建了技术交友和知识传播的平台。目前HiBlock上海已经组织了48场技术工坊，坚持4F活动组织原则-Frency，Focus，Fun，Feedback，建立较大的社区影响力和技术布道能力。

![](https://img.learnblockchain.cn/2019/06/28_759449302.png)
另一个活动主办方Netrino社区负责人刘怡上台讲解了全球知名区块链孵化器Neutrino的情况。Netrino孵化器不止是区块链共享空间，更是全球开发者们的分布式家园，为项目提供了线上线下、社区交流和技术支持的平台。


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里。





