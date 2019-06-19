---
title: 用Loom SDK 搭建的以太坊侧链并部署智能合约
permalink: use-loom
date: 2019-04-29 20:41:20
categories: 
    - 扩容技术
    - Loom
tags: 
    - Loom
    - 智能合约
author: Tiny熊
---

前两天写了一篇 [用Truffle开发一个链上记事本](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain/) ，很多人讲，这样写一条笔记成本该多高呀，这篇我们看看如何把链上记事本智能合约迁移到Loom SDK 搭建的以太坊侧链，在下一篇会介绍如何来[用loom.js重写这个DApp](https://learnblockchain.cn/2019/05/06/use-loom-for-dapp/)。

<!-- more -->

## 关于 Loom 

Loom （或者称 Loom Network） 是一支探索区块链二层扩容方面技术的团队，他们在尝试构建可用于游戏等领域的二层网络（Layer2）平台，目前两个开发的两个重要产品是 **Loom PlasmaChain** 及 **Loom SDK**。

### Loom PlasmaChain

**Loom PlasmaChain** 是一条实现了 **[Plasma Cash 框架模型](https://learnblockchain.cn/2018/11/16/plasma-cash/)**的高性能 DPoS 侧链（提供1–3秒的交易确认时间）。

这条侧链带来的特点是显而易见的，它可以获得由[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)底层网络的安全背书，让我们使用在以太坊上发布的Token（包含 ERC20和 ERC721支持），又可以享受 DPos 共识带来的高性能。

> 以太坊交易确认至少是15秒以上，并且需要消耗一笔 [Gas](https://learnblockchain.cn/2019/06/11/gas-mean/) 费用，当然因此牺牲了一些去中心化。

这张图可以表明 PlasmaChain 与 以太坊的关系，它未来会链接多条侧链，据官方搞 PlasmaChain 集成排名前100的[ERC20](https://learnblockchain.cn/2018/01/12/create_token/)代币，其中包含6种稳定币。

{% fi https://img.learnblockchain.cn/2019/15565495038560.jpg, PlasmaChain 二层网络图, 图片来源于 Loom 官网 SDK 介绍 %}

### Loom SDK（工具集） 

**Loom SDK** 则让开发者快速构建自己的区块链(DApp侧链)，同时也提供了一些工具开发部署应用，它包含内容有：

* 一个可执行的 `loom` 命令行工具， 用于创建一条自己的应用链。

    >   有时狭义的Loom SDK就是单指这个工具
* 一些其他工具，如用来在主链和侧链之间转移资产的工具：plasma-cli  gateway-cli。
* 用来部署合约及开发DApp 的 JavaScript SDK， 包含 `Loom [Truffle](https://learnblockchain.cn/docs/truffle/) Provider` 及 `loom-js`， 这篇文章后面会介绍他的使用。

* 用来部署合约及开发DApp 的 Go SDK。
* 以及开发游戏相关的 SDK： Cosos SDK、Unity SDK。

本篇文章重点就是要介绍如何使用 Loom SDK 创建一条自己的链并部署应用。


## Loom 安装 & 启动区块链  

### `loom` 安装

`loom` 命令行工具安装很简单，直接下载可执行文件，在控制台输入：

```bash
wget https://private.delegatecall.com/loom/osx/stable/loom
chmod +x loom
```

大家可以把 `loom` 加入到环境变量里，方便后面使用。

> 我使用的系统是 Mac OS， 如果你使用 Linux， 则 wget 后面的 url 是 `https://private.delegatecall.com/loom/linux/stable/loom` ，Window 暂时不支持，可以选择虚拟机。

### 初始化链

```bash
mkdir loom-chain  # 为侧链创建一个目录
cd loom-chain
loom init
```

初始化命令会生成`genesis.json` 和 `chaindata`目录，`genesis.json` 是这条侧链的创世纪块配置，`chaindata`目录用户保存区块数据。

## 运行区块链

使用以下的命令可以启动刚刚初始化的DApp侧链：

```bash
loom run
```

输出像下面这样：

```
I[29046-04-29|20:46:50.356] Loading IAVL Store                           module=loom
I[29046-04-29|20:46:50.362] Using simple log event dispatcher
I[29046-04-29|20:46:50.368] Deployed contract                            vm=plugin location=coin:1.0.0 name=coin address=default:0xe288d6eec7150D6a22FDE33F0AA2d81E06591C4d
Init DPOS Params &dpos.DPOSInitRequest{Params:(*dpos.Params)(0xc000e44dc0), Validators:[]*types.Validator{(*types.Validator)(0xc000e46dc0)}, XXX_NoUnkeyedLiteral:struct {}{}, XXX_unrecognized:[]uint8(nil), XXX_sizecache:0}
I[29046-04-29|20:46:50.369] Deployed contract                            vm=plugin location=dpos:1.0.0 name=dpos address=default:0x01D10029c253fA02D76188b84b5846ab3D19510D
E[29046-04-29|20:46:50.374] Couldn't connect to any seeds                module=p2p
I[29046-04-29|20:46:50.374] Starting RPC HTTP server on [::]:46658       module=query-server
I[29046-04-29|20:46:50.374] Starting RPC HTTP server on 127.0.0.1:9999   module=query-server
```

启动的侧链运行在端口`46658`上， 可以通过区块链浏览器 `https://blockexplorer.loomx.io/?rpc=http://127.0.0.1:46658` , 查看这条测试链的出块数据，如图：
![区块浏览器](https://img.learnblockchain.cn/2019/15566148507301.jpg!/scale/45%)


> `https://blockexplorer.loomx.io/` 是`Plasma Chain`的区块链浏览器，在区块浏览器浏览器的下方可以选择链接的RPC 服务器，选择本地的IP及端口。


现在链已经准备好了，接下来就是开发及部署DApp了，我们依然使用 Truffle 进行开发，不熟悉可参考： [Truffle 官方开发文档-中文](https://learnblockchain.cn/docs/truffle/)

## 在侧链上开发和部署智能合约

在[用Truffle开发一个链上记事本](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain/)文章里，以及介绍了如何开发这个DApp 这里不再重复介绍。
 
这个链上记事本的源码在[GitHub](https://github.com/xilibi2003/note_dapp) ， 进行下面的操作之前，需要 git clone 到本地：

```bash
> git clone git@github.com:xilibi2003/note_dapp.git
> npm install  # 安装相应的依赖
```


###  Truffle 配置侧链网络

原来的代码里，Truffle 连接的是以太坊网络，因此需要修改 `truffle.js` 添加刚刚创建的侧链网络，和我们之前介绍的 使用 `truffle-hdwallet-provider` 连接 `Infura` 网络原理类似，连接侧链网络也需要提供一个`Provider`，它是 [Loom Truffle Provider](https://loomx.io/developers/docs/zh-CN/web3js-loom-provider-truffle.html#%E4%B8%8B%E8%BD%BD%E5%B9%B6%E9%85%8D%E7%BD%AE-loom-truffle-provider)， 修改配置之前先安装它：

```bash
npm install loom-truffle-provider --save
```

然后修改配置文件 `truffle.js`，（这有有一份 [Truffle 配置](https://learnblockchain.cn/docs/truffle/reference/configuration.html) 文档），参考配置如下：


```js
const { readFileSync } = require('fs')
const LoomTruffleProvider = require('loom-truffle-provider')

const chainId    = 'default'
const writeUrl   = 'http://127.0.0.1:46658/rpc'
const readUrl    = 'http://127.0.0.1:46658/query'
const privateKey = readFileSync('./priv_key', 'utf-8')

const loomTruffleProvider = new LoomTruffleProvider(chainId, writeUrl, readUrl, privateKey)

module.exports = {
  networks: {
    loom_dapp_chain: {
      provider: loomTruffleProvider,
      network_id: '*'
    }
  }
}
```

在配置里，我们新加入一个网络 `loom_dapp_chain` ，这个网络有 LoomTruffleProvider 提供，`http://127.0.0.1:46658/` 是 使用 `loom run` 启动侧链节点提供的RPC 服务， 细心的同学应该已经发现了 `priv_key`， 它是用来部署合约到侧链上账号的私钥文件，下面就来创建它。

> 配置链接到其他的侧链，可以参考[PlasmaChain 测试网](https://loomx.io/developers/docs/zh-CN/testnet-plasma.html)

### 创建测链账号

`loom` 工具提供了选项来创建账号，在项目`note_dapp`目录下，执行如下命令：

```
$ loom genkey -k priv_key -a pub_key
```

输出结果像下面（当然大家的账号和我的会不一样）：

```
local address: 0x8b7A68cFf3725ca1b682XLb575bC891e381138ef8
local address base64: i3poz/NyXKG2gv5XW8iR44ETjvg=
```

这个命令会在当前文件夹加生成私钥和公钥文件： `priv_key` 和 `pub_key` ， `priv_key` 文件里包含后面用来把合同部署到侧链的私钥。


### 部署到DApp侧链

执行部署时（需要先确定链当前在运行），使用 --network 指定网络，命令如下：

```bash
truffle migrate --network loom_dapp_chain
```

输出的结构像下面：

```
Compiling ./contracts/Migrations.sol...
Compiling ./contracts/NoteContract.sol...
Writing artifacts to ./build/contracts

Starting migrations...
======================
> Network name:    'loom_dapp_chain'
> Network id:      13654820909954
> Block [gas](https://learnblockchain.cn/2019/06/11/gas-mean/) limit: 0

.......

2_deploy_contract.js
====================

   Deploying 'NoteContract'
   ------------------------
   > transaction hash:    0x88a6131cb89fcf...d72d3f92ceb2e
   > Blocks: 0            Seconds: 0
   > contract address:    0x0611Afc2fac9B72f5a75E1BC330Ba4c5da103217
   > account:             0x8b7A68cFf3725ca1b682XLb575bC891e381138ef8
   > balance:             0
   > gas used:            0
   > gas price:           0 gwei
   > value sent:          0 ETH
   > total cost:          0 ETH

   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:                   0 ETH


Summary
=======
> Total deployments:   2
> Final cost:          0 ETH
```

从这个输出会列出部署的网络名、网络id、交易hash、合约地址等信息，用样部署动作也在 `build` 目录下生成对应的文件`contracts/NoteContract.json`。

## 与侧链上的智能合约进行交互

Truffle 提供了一个控制台 [truffle console](https://learnblockchain.cn/docs/truffle/getting-started/using-truffle-develop-and-the-console.html#) 

### 启动控制台

首先通过 `--network` 选项指定连接到DApp侧链`loom_dapp_chain`， 进入控制台，命令如下：

```bash
truffle console --network loom_dapp_chain
```

进入控制台后，控制台提示文字是这样：
```
truffle(loom_dapp_chain)> 
```

然后我们就可以在这个控制台内执行交互命令。

### 获取合约实例


```bash
truffle(loom_dapp_chain)> let instance = await NoteContract.deployed()
truffle(loom_dapp_chain)> instance
```

查看 `instance` ，会输出 instance 实例的详情，使用的Provider, 包含哪些方法，ABI 描述等， 结果像下面：

```js
TruffleContract {
...
web3:
      Web3 {
        class_defaults:
      { from: '0x8b7A68cFf3725ca1b682XLb575bC891e381138ef8',
        gas: 6721975,
        gasPrice: 20000000000 },
currentProvider:
      TruffleLoomProvider {
        _engine: [LoomProvider],
        send: [Function],
        _alreadyWrapped: true },
     network_id: '13654820909954' },
  methods:
   { 'notes(address,uint256)':
      { ... },
     'addNote(string)':
      {... },
     'getNotesLen(address)':
      {...},
     'modifyNote(address,uint256,string)':
      { ... },
  abi:
   [...]
}
```

### 通过合约实例调用合约函数

调用合约添加一条笔记：

```bash
truffle(loom_dapp_chain)> instance.addNote("abc");
```

获取当前账号（后面查看笔记数量函数需要使用账号作为参数，因此先获取下账号）：

```
truffle(loom_dapp_chain)> let accounts = await web3.eth.getAccounts()
truffle(loom_dapp_chain)> accounts[0]
```

这时控制台会打印出账号地址：

```
‘0x8b7A68cFf3725ca1b682XLb575bC891e381138ef8’
```

查看这个下这个账号的笔记条数：

```
truffle(loom_dapp_chain)> let noteNum = await instance.getNotesLen("0x8b7A68cFf3725ca1b682XLb575bC891e381138ef8")
truffle(loom_dapp_chain)> noteNum.toNumber()
# 输出结果
1
```

调用其他的方法类似，不一一讲解，可以参考[Truffle 文档 - 与合约交互](https://learnblockchain.cn/docs/truffle/getting-started/interacting-with-your-contracts.html)

下一篇将继续介绍在DApp 中怎么和合约进行交互。

## 参考文章

1. [loom 官网](https://loomx.io/)
2. [PlasmaChain与排名前100的ERC20代币集成，通过多币种支持实现闪电级的第2层稳定币支付](https://medium.com/loom-network/plasmachain-integrates-with-top-100-erc20-tokens-enabling-lightning-fast-layer-2-stablecoin-fb9c99e879d4)
3. [https://plasma.io/](https://plasma.io/)
4. [Loom SDK 介绍](https://loomx.io/developers/docs/zh-CN/intro-loom-sdk.html)
5. [Truffle 官方文档-中文版](https://learnblockchain.cn/docs/truffle/) 



加入[知识星球](https://learnblockchain.cn/images/zsxq.png)，和一群优秀的区块链从业者一起学习。
[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


