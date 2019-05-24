---
title: 技术工坊44期 - Filecoin区块链以及存储协议解析
permalink: dev_meeting_44
date: 2019-05-24 10:47:23
categories: 技术工坊
tags: Filecoin
author: 辉哥
---

【区块链技术工坊44期】Filecoin区块链以及存储协议解析
<!-- more -->


![](https://upload-images.jianshu.io/upload_images/1190574-0684df7796f8adf2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 1. 活动基本信息
**1）题目：**
【区块链技术工坊44期】Filecoin区块链以及存储协议解析

**2）议题：**
IPFS(InterPlanetary File System)是一个基于内容寻址的分布式的新型超媒体传输协议。IPFS支持创建完全分布式的应用。它旨在使网络更快，更安全，更开放。 Filecoin 是 IPFS 的激励层。Filecoin 采用复制证明(Proof of Replication)算法，证明矿工在自己的物理存储设备上实际存储了数据。 

**议题纲要：**
1) IPFS层次结构以及IPLD的构想
2) Filecoin区块链框架剖析
3) Filecoin存储证明PoRep/PoSt介绍
4) Filecoin挖矿须知


**3）嘉宾：**
![](https://upload-images.jianshu.io/upload_images/1190574-6707281e3fc4c394.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**李星（Star.Li）**， Dora网络的联合创始人， Dora网络的CTO。香港中文大学访问学者，前猎豹移动技术总监，前Powermo联合创始人。在嵌入式，Android框架，分布式存储系统有十多年的开发经验。

**4）活动定位**
区块链技术工坊系列活动，由HiBlock，下笔有神科技，兄弟区块链，HPB芯链联合主办，聚焦于深度分享区块链知识，实现小会技术交友。

区块链技术工坊一直以来坚持4F原则：
* Frency - 每周三晚上一次；
* Focus - 聚焦区块链技术分享；
* Fun - 20人以内会前做自我介绍，分享有深度的技术内容，技术交友；
* Feedback - 会后有活动实录文章和合影照片，深度对接业务交流；

通过技术工坊，连接了广大区块链项目和开发者，搭建了技术交友和知识传播的平台。

# 2.会议实录

![](https://img.learnblockchain.cn/2019/05/15586626275083.gif!/scale/40%)

![](https://img.learnblockchain.cn/2019/05/15586627220587.gif!/scale/40%)

![Filecoin 整体框架](https://img.learnblockchain.cn/2019/05/15586627541153.gif!/scale/40%)

<p class="image-caption">Filecoin 整体框架</p>

![IPFS/IPLD](https://img.learnblockchain.cn/2019/05/15586627840390.gif!/scale/40%)

<p class="image-caption">IPFS/IPLD</p>

![IPFS/IPLD](https://img.learnblockchain.cn/2019/05/15586628055383.gif!/scale/40%)

<p class="image-caption">IPFS/IPLD</p>

![IPFS/IPLD-Cidv1](https://img.learnblockchain.cn/2019/05/15586628428828.gif!/scale/40%)

<p class="image-caption">IPFS/IPLD-Cidv1</p>

![FileCoin BlockChain- 基本术语](https://img.learnblockchain.cn/2019/05/15586628734423.gif!/scale/40%)


<p class="image-caption">FileCoin BlockChain- 基本术语</p>

![FileCoin BlockChain - 地址生成逻辑](https://img.learnblockchain.cn/2019/05/15586629168534.gif!/scale/40%)
<p class="image-caption">地址生成逻辑</p>


![FileCoin 共识 - Ticket](https://img.learnblockchain.cn/2019/05/15586629389311.gif!/scale/40%)
<p class="image-caption">FileCoin 共识 - Ticket</p>

![FileCoin 共识机制 - Leader 选举](https://img.learnblockchain.cn/2019/05/15586629841708.gif!/scale/40%)

<p class="image-caption">FileCoin 共识机制 - Leader 选举</p>

![FileCoin 共识机制 - 确认主链](https://img.learnblockchain.cn/2019/05/15586630358919.gif!/scale/40%)

<p class="image-caption">FileCoin 共识机制 - 确认主链</p>

![FileCoin 整体框架](https://img.learnblockchain.cn/2019/05/15586630505654.gif!/scale/40%)

<p class="image-caption">FileCoin 整体框架</p>

![FileCoin 虚拟机](https://img.learnblockchain.cn/2019/05/15586630635573.gif!/scale/40%)
<p class="image-caption">FileCoin 虚拟机</p>

![FileCoin 存储撮合协议 1](https://img.learnblockchain.cn/2019/05/15586630818863.gif!/scale/40%)

<p class="image-caption">FileCoin协议- 存储撮合协议</p>

![FileCoin 存储撮合协议 2](https://img.learnblockchain.cn/2019/05/15586630896798.gif!/scale/40%)


<p class="image-caption">FileCoin协议 - 存储撮合协议</p>

![FileCoin协议 - 支付通道](https://img.learnblockchain.cn/2019/05/15586630956213.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - 支付通道 </p>

![FileCoin协议 - 免费读取](https://img.learnblockchain.cn/2019/05/15586631041630.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - 免费读取 </p>

![FileCoin协议 - FPS](https://img.learnblockchain.cn/2019/05/15586631122108.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - FPS </p>

![FileCoin协议 - PoRep 1](https://img.learnblockchain.cn/2019/05/15586631190003.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - PoRep </p>

![FileCoin协议 - PoRep 2](https://img.learnblockchain.cn/2019/05/15586631294105.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - PoRep </p>

![FileCoin协议 - PoSt](https://img.learnblockchain.cn/2019/05/15586631370424.gif!/scale/40%)
<p class="image-caption">FileCoin协议 - PoSt </p>

![FileCoin 区块奖励](https://img.learnblockchain.cn/2019/05/15586631534717.gif!/scale/40%)
<p class="image-caption">FileCoin 区块奖励</p>

![FileCoin 区块奖励 核心要素](https://img.learnblockchain.cn/2019/05/15586631721664.gif!/scale/40%)
<p class="image-caption">FileCoin 区块奖励 核心要素</p>

![FileCoin 存储矿工性能分析](https://img.learnblockchain.cn/2019/05/15586631797826.gif!/scale/40%)
<p class="image-caption"> FileCoin 存储矿工性能分析</p>

![FileCoin 未完善 - TODO](https://img.learnblockchain.cn/2019/05/15586631895879.gif!/scale/40%)
<p class="image-caption"> FileCoin 完善度 </p>

![公众号 - 新想法](https://img.learnblockchain.cn/2019/05/15586631997593.gif!/scale/40%)

<p class="image-caption"> 公众号 - 新想法</p>


*本次实录纪要由辉哥(王登辉，下笔有神区块链 CTO 王登辉，HiBlock上海合伙人)整理记录，转发务必注明出处及本段信息。*

**现场活动合影照片：**
![活动合影照片](https://upload-images.jianshu.io/upload_images/1190574-128f58029063023a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*图中左起第8位为本期分享嘉宾李星老师。*


