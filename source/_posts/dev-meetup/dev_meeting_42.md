---
title: 技术工坊42期 - 区块链子链技术及墨客链的实现方案
permalink: dev_meeting_42
date: 2019-05-09 10:47:23
categories: 技术工坊
tags:  
author: 辉哥
---

【区块链技术工坊42期】区块链子链技术及墨客链的实现方案

<!-- more -->

# 1. 活动基本信息
**1）题目：**
【区块链技术工坊42期】区块链子链技术及墨客链的实现方案

**2）议题：**
经过近一年的研发，MOAC(墨客) 最新的版本可以大规模支撑dapp的阶段。
MOAC(墨客) 子链是基于MOAC(墨客) 母链的区块链系统，其目的是将区块链上不同行业不同业务隔离在相对独立的区块链中。
MOAC(墨客) 母子链相较于其他区块链有些什么优势，如何搭建一个MOAC(墨客) 子链环境。
请报名者带好笔记本电脑，且看MOAC公链技术负责人徐卿先生的分享。

**议题纲要：**
1） 侧链、分片、DAG 、子链定义和实现；
2)  MOAC(墨客) 母子链的总体介绍；
3)  MOAC(墨客) 生态和子链之间的关系；
4） 选择MOAC(墨客) 子链落地应用的优劣；
5） MOAC(墨客) 子链环境的搭建实操

**3）嘉宾：**

![image](https://upload-images.jianshu.io/upload_images/1190574-ee67c398bc6933bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/399/format/webp)

**徐卿**是MOAC中国区技术负责人。在硅谷及中国高科技公司10多年的软件开发经验，原游戏行业架构师，独立承担过多个软件项目；现从事区块链行业，拥有多个区块链专利及区块链软件著作权。

**4）活动定位**
区块链技术工坊系列活动，由HiBlock，兄弟区块链，下笔有神科技联合主办，HPB芯链战略支持的，聚焦于深度分享区块链知识，实现小会技术交友。

区块链技术工坊一直以来坚持4F原则：

Frency - 每周三晚上一次；
Focus - 聚焦区块链技术分享；
Fun - 20人以内会前做自我介绍，分享有深度的技术内容，技术交友；
Feedback - 会后有活动实录文章和合影照片，深度对接业务交流；
通过技术工坊，连接了广大区块链项目和开发者，搭建了技术交友和知识传播的平台。

# 2.会议实录
![幻灯片1.PNG](https://upload-images.jianshu.io/upload_images/1190574-39579ce8a95d4096.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片2.PNG](https://upload-images.jianshu.io/upload_images/1190574-804af741fdcb951c.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片3.PNG](https://upload-images.jianshu.io/upload_images/1190574-59c276e537777889.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片4.PNG](https://upload-images.jianshu.io/upload_images/1190574-f47f5096f1f640f2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片5.PNG](https://upload-images.jianshu.io/upload_images/1190574-ad9feb4dc53d788c.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片6.PNG](https://upload-images.jianshu.io/upload_images/1190574-d541711fe3b41074.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片7.PNG](https://upload-images.jianshu.io/upload_images/1190574-f1277743d6fa3f55.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片8.PNG](https://upload-images.jianshu.io/upload_images/1190574-bb2043fa1198aa68.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片9.PNG](https://upload-images.jianshu.io/upload_images/1190574-c67a5ea9d7f734bb.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片10.PNG](https://upload-images.jianshu.io/upload_images/1190574-4b3ba992efbc6b63.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片11.PNG](https://upload-images.jianshu.io/upload_images/1190574-0334c463a1b9d01f.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片12.PNG](https://upload-images.jianshu.io/upload_images/1190574-a7af4059a7bd47da.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片13.PNG](https://upload-images.jianshu.io/upload_images/1190574-9c0122cd9a655ccc.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片14.PNG](https://upload-images.jianshu.io/upload_images/1190574-19a0a12114ed579b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片15.PNG](https://upload-images.jianshu.io/upload_images/1190574-fb386fd0e9274162.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片16.PNG](https://upload-images.jianshu.io/upload_images/1190574-dae07d6165247e74.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片17.PNG](https://upload-images.jianshu.io/upload_images/1190574-434948c9b91f0bea.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片18.PNG](https://upload-images.jianshu.io/upload_images/1190574-6af251e4b1075469.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片19.PNG](https://upload-images.jianshu.io/upload_images/1190574-252201590044c8ec.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片20.PNG](https://upload-images.jianshu.io/upload_images/1190574-655f82241e814ff7.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片21.PNG](https://upload-images.jianshu.io/upload_images/1190574-0bb7d4882250f175.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片22.PNG](https://upload-images.jianshu.io/upload_images/1190574-93d5ec129673665a.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片23.PNG](https://upload-images.jianshu.io/upload_images/1190574-5e8fb67b8db712b9.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片24.PNG](https://upload-images.jianshu.io/upload_images/1190574-b1815258b769f91f.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片25.PNG](https://upload-images.jianshu.io/upload_images/1190574-4f351d0f118a1439.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![幻灯片26.PNG](https://upload-images.jianshu.io/upload_images/1190574-c9d5d398967e9322.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**参考资料：**
版本：https://github.com/MOACChain/moac-core/releases
子链： https://moacdocs-chn.readthedocs.io/zh_CN/latest/subchain/index.html


本次实录纪要由辉哥(王登辉，下笔有神区块链 CTO 王登辉，HiBlock上海合伙人)整理记录，转发务必注明出处及本段信息。

现场活动合影照片：

![](https://upload-images.jianshu.io/upload_images/1190574-905934ef65bc1b07.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
左起第一排第4位就是本次分享嘉宾MOAC中国区技术负责人徐卿老师。

