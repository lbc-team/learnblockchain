---
title: 门罗币恶意钱包文件分析
permalink: Monroe-malicious-file-analysis
un_reward: true
date: 2019-11-24 19:02:06
categories:
    - 区块链安全
tags:
    - 门罗币
    - 安全情报
author: NoneAge
---

门罗币恶意钱包文件分析。

<!-----more----->

## 事件背景

11月19日零时科技安全情报中心监控到消息称，门罗币官方发布安全警告，一些用户反映称下载的二进制文件的哈希值与预期的二进制文件不匹配。经检查，官方称在过去24小时内，getmonero.org上可用CLI二进制文件遭到攻击 ，二进制文件hash和正常 hash不一致，疑似被非法替换，建议用户从安全的备用来源来下载文件。 

>  任何不同内容[哈希](https://learnblockchain.cn/2017/10/25/whatbc/#哈希函数) 之后，得到的结果总是不一样。 


![](https://img.learnblockchain.cn/2019/11/15746641883693.jpg)


## 详情分析

零时科技安全团队及时进行事件分析，通过从GitHub下载安装文件，以及从门罗币官网下载的安装文件，两个压缩包文件hash不一致，且从GitHub下载的安装文件压缩包hash值与官网给出的hash值一致，官网下载的安装文件压缩包hash与官方给出的hash不一致。

![](https://img.learnblockchain.cn/2019/11/15746641983021.jpg)


- 53d9da55137f83b1e7571aef090b0784d9f04a980115b5c391455374729393f3 monero-linux-x64-v0.15.0.0-github.tar.bz2
- b99009d2e47989262c23f7277808f7bb0115075e7467061d54fd80c51a22e63d monero-linux-x64-v0.15.0.0-site.tar.bz2



对文件解压后进行对比分析发现：

- 门罗币官网恶意hash值文件monero-wallet-cli具体hash值： 7ab9afbc5f9a1df687558d570192fbfe9e085712657d2cfa5524f2c8caccca31

  [下载链接](https://drive.google.com/file/d/1A3Uu3fN27OYDHR6evJ-4poP4hPLV89OW/view)

- Github上正确hash值文件monero-wallet-cli具体hash值： 5decc690a63aab004bae261630980e631b9d37a0271bbe0c5b477feffcd3f8c2/monero-wallet-cli

  [下载链接](https://drive.google.com/file/d/14Wrw7WTRsrd6KoqunqVCvNooWUiU-LcX/view)



通过对恶意二进制文件的对比分析，攻击者添加了两个恶意函数：

```
cryptonote::simple_wallet::send_to_cc at address 0x0000000000689AE0

cryptonote::simple::wallet::send_seed at address 0x000000000068B590
```

上述两个函数`send_to_cc`和`send_seed`在函数`cryptonote::simple_wallet::print_seed`中调用，而函数`print_seed`又在`cryptonote::simple_wallet::open_wallet ` 和 `cryptonote::simple_wallet::new_wallet` 中调用。



攻击者在恶意代码中的seed_send函数中把私钥信息发送到node. hashmonero .com 服务器，如下图：

![](https://img.learnblockchain.cn/2019/11/15746642148106.jpg)




接着，攻击者在恶意代码中的seed_to_cc函数中把账户资金相关信息通过HTTP POST请求发送到45.9.148.65 服务器的18081端口，如下图：

![](https://img.learnblockchain.cn/2019/11/15746642230792.jpg)


通过上述代码分析整理恶意代码的整个调用过程及攻击流程如下：

```
new_wallet(新建钱包) -> print_seed -> send_seed（发送私钥信息到CC服务器） -> send_to_cc（发送资金信息到CC服务器）

open_wallet(打开钱包) -> print_seed -> send_seed（发送私钥信息到CC服务器） -> send_to_cc（发送资金信息到CC服务器）
```



从上述分析可以明显看出当用户打开钱包或者创新新钱包时，用户的私钥信息将被盗走。



CC服务器 45.9.148.65 域名为 node.xmrsupport.co，详细信息如下：

- Domain Name: xmrsupport.co
- Registry Domain ID: D9E3AC179ACA44FE4B81F274517F8F47E-NSR
- Registrar WHOIS Server: whois.opensrs.net
- Registrar URL: www.opensrs.com
- Updated Date: 2019-11-14T16:02:52Z
- Creation Date: 2019-11-14T16:02:51Z



域名hashmonero.com的历史解析记录：

- 45.9.148.65 from 2019-11-15 to 2019-11-17
- 91.210.104.245 from 2019-11-19 to 2019-11-19



## 安全建议

* 所有人应该注意自身账户安全，使用强密码，并且尽可能开启两步验证MFA（或2FA），时刻保持安全意识提高警惕。

* 在更新程序版本时注意验证 hash 值。 

* 安装杀毒软件，并尽可能使用防火墙。

* 监视你的帐户/钱包，确认没有恶意交易。

* 下载使用最新版本，[地址](https://web.getmonero.org/downloads/)。 

* 目前正确的官方[hash列表文件](https://web.getmonero.org/downloads/hashes.txt)

---

本文由深入浅出区块链社区合作伙伴 - [零时科技安全团队](https://noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学习区块链技术](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。