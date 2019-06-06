---
title: 如何开发一款以太坊安卓钱包系列6 - 获取账号交易列表 
permalink: eth-wallet-dev-6
un_reward: false
date: 2019-04-19 22:34:40
categories: 
    - 以太坊
    - 钱包
tags:
    - 钱包
    - 以太坊
    - Web3j
author: Tiny熊
---


这是如何[开发以太坊安卓钱包系列](https://learnblockchain.cn/2019/04/11/wallet-dev-guide/)第6篇，获取账号交易列表: 以太转账、代币 Token（通证）转账及合约调用列表。

<!-- more -->
## 交易列表功能

几乎每一个数字钱包都会把账号的交易列表展示出来，像下面这样一个列表:
![](https://img.learnblockchain.cn/2019/15553370001937.jpg!/scale/50%)

这篇文章来看看如何来实现交易列表，首先得了解一点：**[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)官方的节点服务不提供获取某一个地址的历史交易**。

因此实现交易列表需要把区块的交易记录扫描存储在数据库，并由服务器提供交易查询功能接口，过程如下：


![扫描区块入库-查询列表服务过程图](https://img.learnblockchain.cn/2019/scan-block-service2.jpg!wl)

看上去这个工作量还挺大， 不过已经有人帮我们帮我们造好轮子了：有相应的第三服务和开源框架。


## Etherscan 服务


Etherscan 是以太坊上应用最广泛的区块链浏览器，也同时提供 [API 服务](https://learnblockchain.cn/docs/etherscan/), 实现交易列表功能其中一个选择就是使用Etherscan API 服务。

[Etherscan](https://learnblockchain.cn/docs/etherscan/) API 主要包含模块有：
* 账号地址相关接口
* [智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)相关接口
* 交易相关接口
* 区块相关接口
* 事件日志相关接口
* Tokens代币相关接口
* 状态相关接口
* 一些相关工具相关接口


交易列表API，是在账号地址相关接口提供的，接口如下：

```
/api?module=account&action=txlist&address=&apikey=YourApiKeyToken
```

> 深入浅出区块链对[Etherscan API ](https://learnblockchain.cn/docs/etherscan/)进行了翻译，大家可以点击查看了解更多API使用。

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


## 自建区块服务

Etherscan API 是社区提供的服务，仅支持每秒 5 个GET或POST请求，如果我们要做一个商业级的产品，使用 Etherscan API 显然没法满足需求，这就需要需要自建服务，这也是[登链钱包](https://github.com/xilibi2003/Upchain-wallet) 所采用的方式。

自建服务并不意味着我们需要从头开始写所有的代码，使用Trust Wallet开源的[Trust-ray](https://github.com/xilibi2003/trust-ray) 框架（为了保证版本一直，我fork了一份）是个很好的选择。

Trust-ray 是一个Node项目，服务如何搭建请大家订阅[小专栏](https://xiaozhuanlan.com/blockchaincore)查看，这里简单介绍下 Trust-ray 服务的逻辑，更多细节还需大家阅读 Trust-ray 的代码。


### Trust-ray 解析区块 

Trust-ray 提供的功能有两块：一个是扫描解析区块， 一个是提供API服务。
Trust-ray 扫描解析区块逻辑在 `common` 目录下，入口是[ParseStarter.ts](https://github.com/xilibi2003/trust-ray/blob/master/src/common/ParseStarter.ts) 大家最好对照代码阅读，大致解析逻辑（有删减）如下：

{% mermaid sequenceDiagram %}
Title: Trust-ray 解析区块逻辑序列图
Note left of ParseStarter: 调用 start()
ParseStarter->>BlockchainState: getState
ParseStarter->>BlockchainParser: start
BlockchainParser->>TransactionParser: parseTransactions
BlockchainParser->>TokenParser: parseERC20Contracts
Note right of BlockchainParser:  写入MongoDB
{% endmermaid %}

### Trust-ray 提供接口服务

Trust-ray 比较坑的一点时，代码虽然开源了，可以没有提供一丁点文档，要知道 Trust-ray 提供了哪些 API 只有查看代码，在[ApiRoutes.ts](https://github.com/xilibi2003/trust-ray/blob/master/src/routes/ApiRoutes.ts) 文件中列出了所有接口。

提供接口服务的代码在 [controllers](https://github.com/xilibi2003/trust-ray/tree/master/src/controllers) 下，接受请求对应的 Controller 会根据请求参数查询 **MongoDB** 中的数据。

重点关注的**获取交易列表** API ：

 ```
 /transactions?address=
 ```
 
这个接口返回所有跟此地址有关的**交易列表**， 除了输入参数账号地址 `address` 还有一些可选参数：
 
*  **contract** ： 请求某地址关联在**合约地址**的交易，获取某一个 `Token` 的交易历史记录就需要这个参数。
*  **filterContractInteraction**:  过滤掉合约交易（即不返回合约交易）
*  **page** ： 按页请求，每页返回25条交易数据
*  **limit** ：限制每次请求时返回的数据大小
*  **startBlock** ： 起始区块号
*  **endBlock**：结束区块号
 
 返回结果如下：
 
 ```js
 {
    "docs": [
        {
            "operations": [
                {
                    "transactionId": "0x...",
                    "contract": {
                        "address": "0x7f",
                        "decimals": 18,
                        "name": "ABC Token",
                        "symbol": "ABC",
                        "totalSupply": "14080000000"
                    },
                    "from": "0x...",
                    "to": "0x...",
                    "type": "token_transfer",
                    "value": "880000"
                }
            ],
            "contract": "  ",
            "_id": "0xf2b2c76524a",
            "blockNumber": 7420104,
            "timeStamp": "1553278744",
            "nonce": 14515,
            "from": "0x...",
            "to": "0x...",
            "value": "0",
            "gas": "710000",
            "gasPrice": "420000000",
            "gasUsed": "701227",
            "input": "...",
            "error": "",
            "id": "..."
        }
        ],
    "total": n
  }
 ```

**operations** 知道在执行合约转账时信息，如果是以太转账，这个数据为空。其他的字段应该都可以理解。


## 交易列表的实现

### 获取交易列表逻辑步骤

有了后端的接口，客户端交易列表就容易实现了，步骤如下：
1. 获取到用户的地址，参考[钱包开发第三篇](https://learnblockchain.cn/2019/03/24/eth_wallet_dev_3/)。
2. 获取当前设置的网络， 参考[钱包开发第四篇](https://learnblockchain.cn/2019/03/26/eth-wallet-dev-4/)。
3. 根据用户的网络不同，使用用户的账号地址请求不同的接口地址，如果是获取代币交易列表，请求时传入 Token的合约地址。

{% note info %}
    在[钱包开发第四篇](https://learnblockchain.cn/2019/03/26/eth-wallet-dev-4/)在网络结构`NetworkInfo`中，`backendUrl` 就是用来定义该网络下获取交易列表服务的URL。
{% endnote %}

### 实现逻辑

登链交易钱包的页面在`PropertyDetailActivity`类，其通过`TransactionsViewModel`类来获取数据，几个关键的数据如下：

```java TransactionsViewModel.java
public class TransactionsViewModel extends BaseViewModel {
    private static final long FETCH_TRANSACTIONS_INTERVAL = 1;
    private final MutableLiveData<NetworkInfo> defaultNetwork;
    private final MutableLiveData<ETHWallet> defaultWallet;
    private final MutableLiveData<List<Transaction>> transactions;
}
```

UI 界面  `PropertyDetailActivity` 通过订阅 `LiveData` 数据 `transactions` 来展现UI， `TransactionsViewModel` 获取交易列表数据逻辑（序列图只保持了主干）如下：


{% mermaid sequenceDiagram %}

Title: 获取交易列表数据逻辑序列图
Note left of TransactionsViewModel: UI 调用 fetchTransactions
TransactionsViewModel->>FetchTransactionsInteract: fetch
FetchTransactionsInteract->>TransactionRepository: fetchTransaction
TransactionRepository->>BlockExplorerClient: fetchTransactions
Note left of BlockExplorerClient: 通过 Retrofit2 请求服务器接口
FetchTransactionsInteract-->>TransactionsViewModel: onTransactions
{% endmermaid %}



请求上面 Trust-ray 提供获取交易列表API 是有 BlockExplorerClient 类完成的，其使用了网络请求框架 `Retrofit2` ，服务返回的数据会封装成 `Transaction` 结构对象列表 `transactions` ，这个列表会作为一个订阅数据返回给PropertyDetailActivity。

代码就不列了，大家可对照GitHub阅读。

加我微信：xlbxiong 备注：钱包， 加入钱包开发的微信群。

加入[知识星球](https://learnblockchain.cn/images/zsxq.png)和一群优秀的区块链从业者一起学习，还可以解答技术问题。
[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。






