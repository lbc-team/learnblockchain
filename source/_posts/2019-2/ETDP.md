---
title: 安全建议 | 资金盘项目ETDP转移5000ETH跑路事件详情分析
permalink: ETDP
un_reward: true
date: 2019-12-17 10:41:41
categories:
    - 区块链安全
tags:
    - 交易所安全
author: NoneAge
---
ETDP 项目涉嫌诈骗，转移了 5000 多个以太坊，同时无法联系到项目方，怀疑已经跑路
<!---more--->
## 一、 背景

近日，零时科技区块链安全情报中心监控到相关预警信息，称「ETDP 项目涉嫌诈骗，转移了 5000 多个以太坊，同时无法联系到项目方，怀疑已经跑路」。收到消息后，零时科技安全团队及时根据情报搜索更多相关信息，根据社区用户提供的线索，找到ETDP项目相关钱包地址并进行了标记，及时加入监控平台实时监控项目方资金的转移动态，截止发稿时间已有4700多个以太坊被转移到 Bitstamp交易所。

ETDP项目相关信息如下，通过收集项目相关信息证明，此项目打着跟imtoken合作的旗号，号称模式相同，智能合约，无人工干预，全自动分配，利用大家对imtoken的信任欺骗用户以太坊。

![欺骗](https://img.learnblockchain.cn/2019/12/15765508583817.jpg)

早在12月8日IMtoken社区就有用户举报ETDP项目存在问题，并且有大量用户跟帖，声称自己被骗。

12月8日当日，项目方从钱包地址0xe291bb52301c99d50e63ca558869853eb5b6f4f6转移单笔为5160个ETH的转账，到钱包0xe1d9c35f0863b82ec1fedcd1f5ca0c17c19dc1c3中，之后再未发生资金转移。

（下图来自imtoken社区）
![转移](https://img.learnblockchain.cn/2019/12/15765509216981.jpg)

随后，IMtoken社区官方也发布了相关预警。

![预警](https://img.learnblockchain.cn/2019/12/15765509592329.jpg)

## 二、 资金转移溯源分析

首先，12月8日，项目方从钱包地址0xe291bb52301c99d50e63ca558869853eb5b6f4f6发起一笔5160个ETH的转账到钱包0xe1d9c35f0863b82ec1fedcd1f5ca0c17c19dc1c3中，之后再未发生资金转移。

![](https://img.learnblockchain.cn/2019/12/15765509883031.jpg)

之后，在2019年12月15日下午18:22:47开始，钱包0xe1d9c35f0863b82ec1fedcd1f5ca0c17c19dc1c3中转移资产到了四个主要钱包，如图所示。转移的钱包地址为：

0x447919febef973c7c77df3ad9995ef0747f46d0c

0x406804e9e8bbdc3ce01f33b675418e9c2e096932

0x434f682f93cde13221cc9cd430f0ad6370f1f623

0x8afc7d7ad4b52ba4bbe9baefad8e91d33f46ff57

![转移](https://img.learnblockchain.cn/2019/12/15765510094613.jpg)

继续跟进，项目方将其中3个地址中的ETH汇聚到了一个地址0x447919febef973c7c77df3ad9995ef0747f46d0c中。

（示意如下）

0x406804e9e8bbdc3ce01f33b675418e9c2e096932
0x434f682f93cde13221cc9cd430f0ad6370f1f623
0x8afc7d7ad4b52ba4bbe9baefad8e91d33f46ff57

->  0x447919febef973c7c77df3ad9995ef0747f46d0c

![转移](https://img.learnblockchain.cn/2019/12/15765510670935.jpg)

最后，也就是现在，钱包0x447919febef973c7c77df3ad9995ef0747f46d0c中的ETH已经全部转移到Bitstamp交易所中，如下图所示。

![转移](https://img.learnblockchain.cn/2019/12/15765510840122.jpg)

最后总结一下，ETDP项目跑路资金溯源全过程如下图：

![溯源](https://img.learnblockchain.cn/2019/12/15765511037423.jpg)

## 三、 如何识别资金盘
通过零时科技区块链安全情报中心的数据收集及分析，我们发现了一些传销资金盘的惯用套路，整理如下：

        1.以高收益高回报为诱饵
        2.项目信息均为假信息
        3.服务器、域名无备案，且为较新注册
        4.打着去中心化、安全透明的幌子，实际为中心化项目
        5.虚假宣传，碰瓷各种行业内知名项目
        6.分级推广拉人头模式
        7.社区化营销，互相洗脑
        8.线上线下无脑喊单

最后，零时科技安全团队也提醒广大用户请务必擦亮双眼，天下无免费午餐，也不会掉馅儿饼，希望广大用户提高风险意识，加强网络安全意识，不要因为贪图利益参与资金盘项目。如果你发现了资金盘项目，可以发送邮件到support@noneage.com向我们举报，共同创建安全、健康的区块链生态发展环境。

本文由深入浅出区块链社区合作伙伴 - [零时科技安全团队](https://noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学习区块链技术](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。