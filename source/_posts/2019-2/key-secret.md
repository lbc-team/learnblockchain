---
title: 关于私钥管理及安全
permalink: key-secret
date: 2019-09-06 15:10:54
categories: 基础理论
tags:
    - 私钥
author: Gavin & AA
---

下面是一些有用的技巧，帮助你更好地履行私钥管理这个重大的责任：

<!-- more -->

* 不要随意用自己的方式来保障安全，要使用久经考验的标准方法。
* 账户越重要（例如，受控资产的价值越高，或智能合约越重要），越应采取更高的安全措施。
* 空气隔离设备（不通过任何方式与互联网连接）能够提供最高级别的安全保障，但并非所有账户都需要达到这一级别。
* 切勿以简单形式存储你的私钥，尤其是以数字化方式存储。
* 私钥可以以加密形式存储，作为数字“keystore”文件。加密后，它们需要密码才能解锁。当系统提示你选择密码时，请将其设置为强（即长且随机），备份密码，不要共享密码。如果你没有密码管理器，请将其记下并存放在安全且保密的地方。如果要访问你的账户，你需要同时拥keystore文件和密码。
* 不要把密码保存在数字文档、数字照片、截屏、在线网盘、加密的PDF等。不要临时拼凑一些安全解决方案。使用密码管理器或者纸和笔。
* 当提示你备份以助记词显示的私钥时，使用纸和笔把它们记下来。不要把这个任务置之脑后，因为你一定会忘记。万一你计算机系统中的所有数据都丢失了，或者你把密码弄丢了，这张小纸条就会派上用处。然而，这也可能为攻击者提供可乘之机，进而窃取私钥。所以，千万不要以数字信息的形式存储私钥，建议把这张小纸条锁在抽屉或保险箱里。
* 在进行大笔的数字资产转账之前（特别是转到新地址），首先做一笔小金额的测试转账（例如不到一美元），并且等待收据以确认交易成功。
* 创建新账户时，首先只向新地址发送一笔小额的测试交易。收到测试交易后，尝试从该账户再次发回。创建账户可能会出错的原因有很多，如果出现问题，最好是通过这样的小额交易来发现问题。如果测试正常工作，那说明一切都没问题。
* 公共区块浏览器是一种独立查看交易是否已被网络接受的简单方法。但是，这种便利性会对你的隐私产生负面影响，因为你把地址透露给了区块浏览器，这可能导致你被追踪到。

节选自： 精通以太坊 《Mastering Ethereum 》