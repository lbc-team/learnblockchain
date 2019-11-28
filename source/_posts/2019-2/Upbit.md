---
title: Upbit交易所大额ETH被盗事件详细分析
permalink: Upbit
un_reward: true
date: 2019-11-28 10:18:10
categories: 区块链安全
tags: 漏洞分析
author: Beosin 成都链安
---

今日(2019-11-27) 12:06分，成都链安态势感知系统Beosin-Eagle eye检测到以太坊Upbit交易所热钱包地址向未知地址通过一笔交易转移超过34万ETH。

<!------more----->

![报警](https://img.learnblockchain.cn/2019/11/28/100.png)

![详情](https://img.learnblockchain.cn/2019/11/28/101.png)

黑客转移342000ETH之后，该地址当时仅剩下111.3ETH,几近掏空。

![转移](https://img.learnblockchain.cn/2019/11/28/102.png)

随后，官方发布公告对外称：

![公告](https://img.learnblockchain.cn/2019/11/28/103.png)

紧接着，成都链安安全团队对整个代币转移的交易时间线进行了完整复盘：
北京时间11月27日13时18分，Upbit波场地址TDU1uJ向TA9FnQrL开头的地址分批次转移TRON币，共计转移超过11.6亿枚TRON币，2100万枚BTT。

![复盘](https://img.learnblockchain.cn/2019/11/28/104.png)

北京时间11月27日13时02分，8628959枚EOS从Upbit EOS钱包地址转至Bittrex交易所；

![zhuanyi](https://img.learnblockchain.cn/2019/11/28/105.png)

北京时间11月27日1点55分左右，超过1.52亿枚XLM从Upbit交易所转移至Bittrex交易所。

![](https://img.learnblockchain.cn/2019/11/28/106.png)

通过我们的进一步分析认为：EOS，XLM，TRON代币的转移很有可能是交易所触发风控机制而进行的避险操作，并且有资料显示Upbit和bittrex为合作关系，因此，大额EOS 和XLM转入Bittrex交易所的操作可能是Bittrex协助规避风险。

![通告](https://img.learnblockchain.cn/2019/11/28/107.png)

随后，北京时间下午4点56分，Upbit官方Doo-myeon首席执行官 Lee Sek-woo发通告表明，官方已经暂停加密货币充提服务，并紧急排查原因，并表明Upbit将会全额承担损失。

至此，Upbit整个代币转移过程已经清晰，针对此次ETH被盗事件，成都链安安全团队进行了如下分析判断：

UpBit交易所被盗有可能是存储热钱包私钥的服务器受到攻击导致私钥被盗，或者是交易签名服务器受到攻击，而不是控制热钱包API转账的服务器被黑。

从转账的交易（hash为0xa09871A******43c029)来看，该黑客或团伙是一次性转走当时账户里所有的钱，并没有做多余的操作，后续又有用户充值大约4700左右的eth进UpBit交易所，现交易所已将该笔资产转移至交易所控制的地址0x267F7*******0a8E319c72CEff5。

从目前已知的情况看，UpBit交易所可能遭到鱼叉钓鱼邮件、水坑等攻击手法，获取到交易所内部员工甚至高管的PC权限后实施的进一步攻击。并且有消息报道曾有朝鲜黑客于5月28日使用网络钓鱼手法通过电子邮件向Upbit交易所用户发送钓鱼邮件进行网络攻击。

在此成都链安提醒广大项目方：

* 应做好私钥的储存，来源不明、目的不明的邮件尽可能不要点击；
* 员工个人PC安装主流的杀毒软件，加强内部员工的安全意识培训，建议找可靠的第三方安全公司进行内网防护加固。
* 对于私钥储存服务器建议分派专人运维。

可以采取有效的防护措施：

* 重写服务器的命令，比如黑客常用的history、cat等命令，并开发脚本进行持续监控，如果有运行敏感的命令推送提醒，运维人员只需要维护重写命令后的新命令即可。

* 完善本身的资金风控系统，及时进行报警，和交易阻断，防止大额损失。


本文来自 **深入浅出区块链社区合作伙伴**：专注于区块链生态安全的[Beosin 成都链安](https://www.lianantech.com)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。