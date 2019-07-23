---
title: 在以太坊侧链POA网络与xDai稳定币链进行DApp开发
permalink: poa-network
date: 2019-07-19 20:41:20
categories:
    - 扩容技术
    - POA
tags:
    - Layer2
    - POA
    - xDai
author: Tiny熊
---

由于以太坊又慢又贵的POW共识（尽管如此，以太坊依旧是最受欢迎的DApp平台），催生了各种以太坊测链的方案用来减少以太主网的拥塞，前面我们介绍了Loom SDK， 这篇博客介绍下POA Network以及xDai。
如果大家想稳定的数字货币做一些智能合约应用，在[Libra](https://learnblockchain.cn/docs/libra/)还没有上线之前，也许你可以尝试一下xDai。


<!-- more -->


## 什么是POA 网络

POA 网络定位于以太坊的侧链（兼容以太坊协议），它使用一个全新的POA的共识机制。

> 备注：POA项目官方现在更愿意把POA作为自治证明共识（Proof of Autonomy）的缩写，而不是使用权威证明（Proof of Authority）

POA共识是一种更直接有效的POS共识形式，它的验证者必须经过身份验证（貌似还会签署法律文件），在POS上通常是需要获得足够的选票（代币）来提高作恶成本，而POA则是靠验证者的信誉来做担保，作为一个二层网络，通常只有较小额的交易，追求性能而牺牲一些网络安全性可以理解，这也是二层网络通常的做法。

POA网络启动时有12个验证者（现在有20多个）,这些验证者通过智能合约来管理，智能合约也加入了治理模式，验证者可以投票添加或删除验证者甚至是更新治理合约。验证者验证者出块的几率均等，每产生一个块可以过得一个POA币（侧链的原生代币）以及所有的手续费。

PoA网络平均每5秒出一个块， 区块大小是800万Gas，Gas price 固定为1GWei（1POA＝1,000,000,000Gwei）， 因此可以推算PoA网络大概比以太坊快３倍，而运行DApp的gas费用则大大降低，当前一个POA的价格不到0.2元，历史最高时也只有６元，不像一个以太几千上万的价格。

PoA网络出块信息可以在[blockscout浏览器](https://blockscout.com/poa/core) 查看详情， 值得提一下，BlockScout 是POA Network的另一个贡献，这是一个功能强大的开源的区块浏览器，支持所有以太坊协议的网络。[Github库](https://github.com/poanetwork/blockscout)

POA 网络的主网称为**POA Core**，他还有一个测试网络为**POA Sokol**。其实以太坊主网也有一个POA共识的测试网叫 Kovan 。



## POA的桥接技术(TokenBridge)

**POA最大的价值在于其桥接技术**，TokenBridge是一个互操作性协议，它使得以太坊网络和POA网络之间可以相互通信（交互）。

> 备注：TokenBridge 之前为 POA Bridge， 因此很多文档里没有及时跟随更改， TokenBridge[代码库](https://github.com/poanetwork/tokenbridge)。

目前桥接技术已经完成的功能有：

1. 允许用户把自己在POA网络的原生代币 POA 转移到以太坊网络，在以太坊网络生成对应的POA20代币，POA20是以太坊网络的ERC 20代币。

2. 允许把以太坊网络的ERC 20代币转移到POA 网络（或其他链），这些转移并不会重复产生新的币，它会在接收链创建对应的币而在发起链销毁对应的币。
3. 不同网络之间的ERC20代币相互转移，有了这个技术我们就可以把昂贵的链上交易转移价格低廉的侧链，让区块链落地有了更多的可能。

其实，POA桥接技术不仅仅可以用于以太坊网络和POA网络相互通信，也有其他的项目使用TokenBridge来进行token的转移，如：Sentinel Chain 和 Virtue Poker。


## 稳定币链 xDai Chain

最近Libra关注度太高，很多朋友知道它是Facebook发行的一个稳定币链，稳定币链要排个辈分的话，Libra应该叫xDai一声大哥。

DAI是以太坊上通过抵押数字资产发行的稳定币，一个Dai=1美元，  不熟悉的同学可以看我一篇文章理解[去中心化稳定币 DAI](https://learnblockchain.cn/2019/03/19/understand_dai/), xDai Chain是DAI背后的团队MakerDAO和POA Network合作推出的一条基于稳定币的POA共识链，xDai Chain 也是POA 共识机制及TokenBridge相结合的最好的一个例子。

xDai链和POA Core一样是以太坊网络上的侧链，XDAI是侧链上原生代币（用来支付链上交易的Gas），DAI是对应在以太坊的ERC20代币，注意，xDai链是不支持挖矿的，而是必须通过把Dai通过TokenBridge转移到xDai链产生XDAI币。其他的特性和POA Core一样， 如5秒的块生成时间，每笔交易的gas成本为1Gwei，这样在xDai链上的交易成本就非常低。

xDai解决了阻碍数字货币用于日常交易的两个主要因素：价格波动大及手续费高，把一些应用部署到xDai链上来会是个不错的选择。　后面我们会有文章介绍。

xDai网络出块信息可以在[blockscout浏览器](https://blockscout.com/poa/dai/) 查看详情。


## 在POA 网络上部署应用


我之前有一个教程在[以太坊网络上开发了一个记事本应用](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain/), 这个应用每添加一条记录会消耗不少的gas费用，现在我们把这个记事本应用部署到 POA 网络上。


### 利用水管获取POA币

把应用部署到 POA 网络上，需要要消耗一点POA币，我们得先想方法获得一些POA，这里我们我使用POA测试网络POA Sokol提供的水管 https://faucet-sokol.herokuapp.com 获取(如果要使用POA主网则需要去交易所购买POA)，进入页面之后，可以看到如下界面：

![获取Sokol网络代币](https://img.learnblockchain.cn/2019/07/22_20190722100816.png!wl)


注意一下：Sokol水管为了防止被程序撸羊毛，加入了Google人机身份验证，所以这个页面需要大家**翻墙**访问，输入自己的以太坊账号，点击“REQUEST 0.5 SPOA”，就可以获取到POA Sokol测试的代币 0.5 SPOA。


###　Metamask 连接到POA网络

接下来在　Metamask 查看下账号的 SPOA 余额，看看是否到账，由于Metamask默认网络里面没有POA网络，所有我们通过“CUSTOM RPC”添加一个网络，在“New RPC URL”里输入`https://sokol.poa.network`　，如下图:

![Metamask添加RPC](https://img.learnblockchain.cn/2019/07/23_add-rpc.png!wl)

查了使用Metamask钱包插件之外，还可以使用POA基于MetaMask定制的[Nifty 钱包](https://chrome.google.com/webstore/detail/nifty-wallet/jbdaocneiiinmjbjlgalhcelgbejmnid?hl=en)，Nifty默认就支持POA的各个网络，Nifty 钱包如下图：

![Nifty](https://img.learnblockchain.cn/2019/07/23_Nifty.png!wl)


> 备注： 查看下账号也可以在[sokol的blockscout浏览器 ](https://blockscout.com/poa/sokol/)查看，Metamask 连接POA网络也是为后面使用DApp做准备。　　


### 使用 Truffle 部署合约到POA网络

Truffle 的基本使用，以及开发这个记事本DApp，本文就不再重复介绍，参考前面的文章：[Truffle教程](https://learnblockchain.cn/2018/01/12/first-dapp/), [用 Truffle 开发一个链上记事本](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain/)，这里主要介绍如果Truffle如何了连接到POA网络。

先把DApp代码克隆到本地，大家可订阅[跨链技术小专栏](https://xiaozhuanlan.com/interchain)获取源代码。

#### truffle配置加入POA网络

然后打开`truffle-config.js` 文件，加入一个`sokol`网络， 方法如下：

```js
module.exports = {

  networks: {
    ...
    sokol: {
          provider: function() {
                return new HDWalletProvider(mnemonic, "https://sokol.poa.network")
          },
          network_id: 77,
          gasPrice: 1000000000
    },
    ...

```


上面 `mnemonic` 处大家用自己的助记词代替。

#### 部署合约

然后使用命令`truffle migrate --network sokol` 进行部署:

```bash
> truffle migrate --network sokol

...

2_deploy_contract.js
====================

   Deploying 'NoteContract'
   ------------------------
   > transaction hash:    0x48dbba680f3f227b0e6aba42ecf467bf4xlb1324e0d765dcd
   > Blocks: 2            Seconds: 9
   > contract address:    0xb89ccfF5c3D4A15F69xLB9D0a9C3ce4a87047a6a
   > block number:        9867109
   > block timestamp:     1563892140
   > account:             0x1a197940bd151xlb53aF8eD04996A880a251D454
   > balance:             0.999159377
   > gas used:            537207
   > gas price:           1 gwei
   > value sent:          0 ETH
   > total cost:          0.000537207 ETH


   > Saving migration to chain.
   > Saving artifacts
   -------------------------------------
   > Total cost:         0.000537207 ETH


Summary
=======
> Total deployments:   2
> Final cost:          0.0007986 ETH

```

####　启动DAPP应用

`npm run dev` 启动DAPP服务， 在浏览起输入地址：`http://localhost:3000` 运行DApp，因为刚刚MetaMask已经连接好了POA 的测试网络Sokoa， 现在可以直接和DApp进行交付。

![](https://img.learnblockchain.cn/2019/07/23_note-on-poa.png!wl)



## 在稳定币链xDai网络上部署应用


在xDai网络上部署和前面的POA测试网络步骤完全一起，只需要把上面 RPC URL更改为 `https://dai.poa.network`
下面是一个各个网络对应RPC URL 及网络ID的表格：



| 网络名称              | RPC URL |   网络ID   |  代币  |  浏览器URL |
| ----------------- | ---- | ------- | ------ |------ |
| sokol 测试网         |https://sokol.poa.network | 77 | SPOA |https://blockscout.com/poa/sokol/ |
| POA 主网         | https://core.poa.network | 99 | POA | https://blockscout.com/poa/core |
| xDai         | https://dai.poa.network | 100 | xDai | https://blockscout.com/poa/dai |


下一遍我们继续介绍在以太坊网络和POA网络之间如何使用桥接技术转移代币。最后安利一下我的[跨链技术小专栏](https://xiaozhuanlan.com/interchain)，现在订阅只要19元，订阅要趁早。


## 参考文章

1. [What is POA and How is it Unique?](https://dgaming.com/media/what-is-poa-and-how-is-it-unique/)
2. [POA - Part 1 - Develop and deploy a smart contract](https://kauri.io/article/549b50d2318741dbba209110bb9e350e/v13/poa-part-1-develop-and-deploy-a-smart-contract)
3. [POA - Getting Started](https://forum.poa.network/t/getting-started-with-poa-products/2595)
4. [POA-Network-Whitepaper](https://github.com/poanetwork/wiki/wiki/POA-Network-Whitepaper)
5. [POA bridge](https://poabridge.com)
6. [xDai Chain](https://medium.com/poa-network/poa-network-partners-with-makerdao-on-xdai-chain-the-first-ever-usd-stable-blockchain-65a078c41e6a)



加入[知识星球](https://learnblockchain.cn/images/zsxq.png)，和一群优秀的区块链从业者一起学习。
[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


