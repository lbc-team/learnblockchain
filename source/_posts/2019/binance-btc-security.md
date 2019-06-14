---
title: 币安交易所比特币被窃漏洞分析
permalink: binance-btc-security
date: 2019-05-08 15:45:14
categories: 区块链安全
tags: 漏洞分析
author: Beosin 成都链安
---


知名加密货币交易所币安受到黑客攻击，目前已经有7074.18个比特币被窃。 


<!-- more -->

## 发生了什么

根据币安首席执行官赵长鹏对外披露的信息，该交易所在5月7日发现了**大规模的安全漏洞**，该漏洞导致黑客能够访问用户应用程序接口密钥（API keys）、双重身份验证码、以及其他信息。按照安全通知中公布的一笔交易，黑客从币安交易所中取走了价值大约4100万美元的比特币。

![安全披露](https://img.learnblockchain.cn/2019/15573024523548.jpg)



## 被窃交易详情

对此次攻击，Beosin成都链安科技安全团队进行了深度分析：

交易详情如下：

![被窃交易详情](https://img.learnblockchain.cn/2019/15573029017317.jpg)


交易发生在575013块，总损失最高可达7074个BTC


![详细提币地址](https://img.learnblockchain.cn/2019/15573028799579.jpg)



> 详细提币地址


截至目前，币安热钱包（地址：`1NDyJtNTjmwk5xPNhjgAMu4HDHigtobu1s`）被盗约7000枚BTC.
现在币安的热钱包余额`3,612.69114593`个BTC，说明币安热钱包的私钥安全。

经过团队分析，黑客在05月08日 01:17:18 通过API接口在同一时间发起提币操作。

## 币安交易所 API 功能
币安交易所的API申请后会生成`API key`和`Secret key`，如下图：


![API key和Secret key](https://img.learnblockchain.cn/2019/15573028597933.jpg)






API接口有限定用户开放IP限制和开放提现功能。

开放提现就是直接利用`API key`和`Secret key`直接提现，不需要收集验证码、短信、谷歌验证码。
如下图：

![API 功能](https://img.learnblockchain.cn/2019/15573028218321.jpg)

API部分[官方调用代码](https://github.com/binance-exchange/python-binance)demo如下（来自）:

```python
from binance.client import Client
client = Client(api_key, api_secret)

# get market depth
depth = client.get_order_book(symbol='BNBBTC')

# place a test market buy order, to place an actual order use the create_order function
order = client.create_test_order(
    symbol='BNBBTC',
    side=Client.SIDE_BUY,
    type=Client.ORDER_TYPE_MARKET,
    quantity=100)

# get all symbol prices
prices = client.get_all_tickers()

# withdraw 100 ETH
# check docs for assumptions around withdrawals
from binance.exceptions import BinanceAPIException, BinanceWithdrawException
try:
    result = client.withdraw(
        asset='ETH',
        address='<eth_address>',
        amount=100)
except BinanceAPIException as e:
    print(e)
except BinanceWithdrawException as e:
    print(e)
else:
    print("Success")
```


## 安全分析

初步分析认为是用户的API key和Secret key信息泄露导致的此次攻击。

如果用户没有限制`ip`并配置了开放提现功能，任意攻击者在获取了`API key`和`Secret key`信息后便可以实现攻击。

用户的信息泄露途径可能有：

1. 普通用户一般不会使用`api key`，一般是高级用户用于代码中实现自动化交易，可能是用户源码泄露导致`api Secret key`泄露 
2. 用户被钓鱼攻击，输入了`API key`和`Secret key`被黑客截取。
3. 用户的`API key`和`Secret key`保存的电脑被攻击窃取。
4. 币安交易所系统原因导致用户`API key`和`Secret key`泄露，其中只有71个用户开放了提现功能，被盗币。


被黑客盗取的7074枚BTC的主要20个地址如下：
```
bc1qp6k6tux6g3gr3sxw94g9tx4l0cjtu2pt65r6xp           555.997 BTC
bc1qqp8pwq277d30cy7fjpvhcvhgztvs7v0nudgul5          463.9975 BTC
bc1qld27dqu6wrl4tmjdr8tl55qavmghwrr4ldh7qn         473.9975 BTC
bc1q8m9h3atn4cqeqhu3ekswdqxchp3g7d4v3qv3wm          567.997 BTC
bc1q7p6edvd4zvtya8uj366c23dan8pvlp503spucu         468.9975 BTC
bc1ql0wlnu80l8kctjzkzlzd72sdjqwuvruvgepceq            383.998 BTC
bc1q3ldtrr6xtpx8jam5gw68aaexz2wtluj0qullvr             189.999 BTC
bc1qyv4zv0wjn299kx4yz6g7v6g6400wqgzcqgw9vx          383.998 BTC
bc1q6fejm4r866tmt8ptf42juedv5gevlv2qt72agq           371.998 BTC
bc1qvstwzsrfml43jrclsp68220l4lx5lw3kwf7dp0             193.999 BTC
bc1qecs672j9dpvwr56zeldgf3swtlv3dad52wzuta          463.9975 BTC
bc1qshkncv7tkpye7z0z4a3k9yw2e73whha9gjs88z          97.9995 BTC
bc1qhlhx6lrnr0jf4zpvm788j7yeezau6s8q557p2z           279.9985 BTC
bc1qesy52g7ndy652qudr2awuk57mcaxgmn9qsmpzk          469.9975 BTC
bc1q9svj9wp68zftgejjgk6f96ukuyx8c5urkqsv69           193.999 BTC
bc1qanrl8n3flz4jftkscljx2hwuc3h50f9ynp2nyn             89.9995 BTC
bc1qtpdptcf4ngfkwq6dr36kqaeh2n5h00rx5unkgc          670.9965 BTC
bc1qvr2jxlmvckap7cg2l6mdgh5fa8glkhe4s88sax          377.998 BTC
bc1qhqap39mpkldjzvqdf3204p732krtnf56mm9aj3          370.998 BTC
3KBsR6Ld255Tw5hNR4S6KaX5SXxvRF6jv3                    1.29968018 BTC
```


## 安全无小事

各交易所和用户都应该注意信息的保护，用户在使用开放提现等高级功能时，应提高对安全性的重视，避免信息泄露导致的各种危害，不让攻击者有可乘之机。


本文来自 **深入浅出区块链社区合作伙伴**：专注于区块链生态安全的[Beosin 成都链安](https://www.lianantech.com) 

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。






































