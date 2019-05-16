
---
title: 技术工坊43期 - 数字钱包的技术实现
permalink: dev_meeting_43
date: 2019-05-16 10:47:23
categories: 技术工坊
tags:  
author: 辉哥
---

区块链技术工坊43期 - 数字钱包的技术实现
<!-- more -->

# 1. 活动基本信息
**1）题目：**
【区块链技术工坊43期】数字钱包的技术实现

**2）议题：**
Qbao Network钱包自2017年10月24日上线，在全球吸引了百万级的用户。Qbao Network钱包以去中心化和中心化相结合的方式，为全球用户提供数字资产存储、管理、支付、交易等多种功能，并支持7种语言，用户遍布全球13个国家和地区。

本次技术分享，QBAO CTO何鹏飞老师为大家深度分析钱包的技术实现。

**议题纲要：**
 1) 虚拟数字钱包与法币钱包的区别
2) 去中心化与中心化的技术难点
3) qbao的解决方案
4) 虚拟数字钱包的未来

**3）嘉宾：**
![](https://upload-images.jianshu.io/upload_images/1190574-07a981dc57b7bbf0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**何鹏飞**是码以科技CTO，长期从事区块链及相关应用的研究，主持开发了qbao network钱包及相关应用、集成、对接，在区块链与中心化应用的领域方面有丰富的经验与独到的理解。《区块链学堂》创办人，“数字经济生活”概念项目创始人。

**4）活动定位**
区块链技术工坊系列活动，由HiBlock，兄弟区块链，下笔有神科技，HPB芯链联合主办，聚焦于深度分享区块链知识，实现小会技术交友。

区块链技术工坊一直以来坚持4F原则：
* Frency - 每周三晚上一次；
* Focus - 聚焦区块链技术分享；
* Fun - 20人以内会前做自我介绍，分享有深度的技术内容，技术交友；
* Feedback - 会后有活动实录文章和合影照片，深度对接业务交流；

通过技术工坊，连接了广大区块链项目和开发者，搭建了技术交友和知识传播的平台。

# 2.会议实录
![](https://upload-images.jianshu.io/upload_images/1190574-7b6e356388e5ad84.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

作为钱包，至少具有3大功能：余额，交易，交易流水。



![](https://upload-images.jianshu.io/upload_images/1190574-81179f54f8e78599.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-5fe24ab1575741ee.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

问题：
（1）私钥不存在服务器里，保存在手机里，如何保证安全呢？
（2）EOS是账户名+私钥，相对而言，更难被攻破。
（3）转账如果地址错误，怎么办？私钥被忘记怎么办？
（4）必须考虑跨国，多语言，多社区情况。IP经常被墙，运维工作很复杂。


![](https://upload-images.jianshu.io/upload_images/1190574-3f2875f025070d05.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-7ef49a827b2a6a26.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-cfc4af880cf2ea1b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

（1）提币地址/私钥存在数据库，文件配置，代码中，如何保证安全呢？
（2）清算的安全一致，例如代币的交易记录；


![](https://upload-images.jianshu.io/upload_images/1190574-c7b8d31ec762d48d.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

（1）空节点钱包
imToken，QBAO APP等都是轻节点钱包；
（2）轻节点钱包，例如Parity等PC端钱包


![](https://upload-images.jianshu.io/upload_images/1190574-ee73b266935adf68.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-0797abf3d5d019bd.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-3fb89ab7ec13dbd7.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-56337c31bdad8c34.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-2584e76bd26d015a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
（1）助记词在不同的钱包有不同的词库，提取12个地址。有可能存在不同的钱包的助记词导不过去。
（2）BIP39是指生产地址的规则，相同的助记词生产相同的地址；
（3）HD钱包用助记词代替私钥，是否存在撞库可能呢？
查询业务量太大了，可以分控分表；


![](https://upload-images.jianshu.io/upload_images/1190574-ed199869117ba5bb.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-89cf6a50d569cc38.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-5bfacffd4bb982f2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-800150cd8100b146.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-f75dbb3fcc990358.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

说明：数据库表做特殊处理，中心化钱包私钥生产的方法跟前端的不一样，助记词也不一样；


![](https://upload-images.jianshu.io/upload_images/1190574-10c7c269ade07716.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-bcd3a5493092e8c3.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-3d12ea6565dabf38.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-68b3066a398b3e58.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-d2d86b06db15f302.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-e824b33e1f8fd017.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1190574-59ca0d62c57d8e1b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*本次实录纪要由辉哥(王登辉，下笔有神区块链 CTO 王登辉，HiBlock上海合伙人)整理记录，转发务必注明出处及本段信息。*

**现场活动合影照片：**

![](https://upload-images.jianshu.io/upload_images/1190574-a7ad7e6e8f89cec2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
其中坐席者为本次活动分享嘉宾QBAO CTO何鹏飞老师。


