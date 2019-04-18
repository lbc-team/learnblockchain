---
title: 如何开发一款以太坊安卓钱包系列6 - 获取账号交易列表 
permalink: eth-wallet-dev-6
un_reward: true
date: 2019-03-27 22:34:40
categories:
tags:
author: Tiny熊
---


这是如何[开发以太坊安卓钱包系列](https://learnblockchain.cn/2019/04/11/wallet-dev-guide/)第6篇，获取账号交易列表。

## 交易列表功能

几乎每一个数字钱包都会把账号的交易列表展示出来，像下面这样一个列表:
![](https://img.learnblockchain.cn/2019/15553370001937.jpg!wl)

这篇文章来看看如何来实现交易列表，首先得了解一点：**以太坊官方的节点服务不提供获取某一个地址的历史交易**。

因此实现交易列表需要把区块的交易记录扫描存储在数据库，并由服务器提供交易查询功能接口，过程如下：


![扫描区块入库-查询列表服务过程图](https://img.learnblockchain.cn/2019/scan-block-service2.jpg!wl)

看上去这个工作量还挺大， 不过已经有人帮我们帮我们造好轮子了：有相应的第三服务和开源框架。


## Etherscan 服务


Etherscan 是以太坊上应用最广泛的区块链浏览器，也同时提供 [API 服务](https://etherscan.io/apis), 实现交易列表功能其中一个选择就是使用Etherscan API 服务。

Etherscan API 主要包含模块有：
* 账号地址相关接口
* 智能合约相关接口
* 交易相关接口
* 区块相关接口
* 事件日志相关接口
* Tokens代币相关接口
* 状态相关接口
* 一些相关工具相关接口



交易列表API，是在账号地址相关接口提供的，接口如下：

```
api?module=account&action=txlist&address=&apikey=YourApiKeyToken
```

参数说明：

* module: 指明接口所属模块；
* action: txlist - 表示列出交易记录；
* address: 所查询交易的账号地址；
* apikey: 根据key来统计请求限额； 
* startblock: 起始查询块 id，可选，默认值为 0；
* endblock: 结束查询块 id，可选，默认值为最后一个区块；
* page: 页码，可选；
* offset: 每页查询记录数，可选，默认是查询 10000 条记录；
* sort: 排序规则，支持正序asc和倒序desc。


这个接口来获取某个账号地址的交易记录，如请求[这个地址](http://api.etherscan.io/api?module=account&action=txlist&address=0xddbd2b932c763ba5b1b7ae3b362eac3e8d40121a&offset=1&page=2)返回的结果如下：

```json
{
	"status": "1",
	"message": "OK",
	"result": [{
		"blockNumber": "47884",
		"timeStamp": "1438947953",
		"hash": "0xad1c27dd8d0329dbc400021d7477b34ac41e84365bd54b45a4019a15deb10c0d",
		"nonce": "0",
		"blockHash": "0xf2988b9870e092f2898662ccdbc06e0e320a08139e9c6be98d0ce372f8611f22",
		"transactionIndex": "0",
		"from": "0xddbd2b932c763ba5b1b7ae3b362eac3e8d40121a",
		"to": "0x2910543af39aba0cd09dbb2d50200b3e800a63d2",
		"value": "5000000000000000000",
		"gas": "23000",
		"gasPrice": "400000000000",
		"isError": "0",
		"txreceipt_status": "",
		"input": "0x454e34354139455138",
		"contractAddress": "",
		"cumulativeGasUsed": "21612",
		"gasUsed": "21612",
		"confirmations": "7525550"
	}]
}
```


请求 token 的交易记录，则使用 API 的 action 参数是 `tokentx` ， 大家可以在浏览器请求[这个接口](http://api.etherscan.io/api?module=account&action=tokentx&address=0x4e83362442b8d1bec281594cea3050c8eb01311c&startblock=0&endblock=999999999&sort=asc&apikey=YourApiKeyToken)试试，返回的数据格式和上面的接口是一样。

此接口在测试网络下也使用，只是所使用的域名不同，目前支持的三个网络的域名为：

https://api-ropsten.etherscan.io/
https://api-kovan.etherscan.io/
https://api-rinkeby.etherscan.io/


有时候，为了控制访问限额的问题，我们可能需要使用的自己的服务器做请求中转和缓存，这个时候，我们也可以使用API Wrapper，如：

* [node.js 接口](https://github.com/sebs/etherscan-api)
* [Go 接口](https://github.com/nanmu42/etherscan-api)
* [Php 接口](https://github.com/dzarezenko/etherscan-api)


## 区块解析逻辑




## 搭建区块解析服务器



## 

