---
title: 智能合约安全审计 -- 环境搭建
permalink: Smart-contract-security-environment
un_reward: true
date: 2020-01-16 11:46:38
categories:
    - 区块链安全
tags:
    - 智能合约安全
    - 环境搭建
author: NoneAge
---

工欲善其事必先利其器，只有知道怎么搭建智能合约安全漏洞实战练习的环境，才能更好的进行合约漏洞的复盘。

<!-----more----->



本文主要介绍在进行以太坊智能合约安全漏洞实验演练时需要的工具和环境，方便后续漏洞实战操作。

阅读本文前，你应该对区块链、以太坊、智能合约有所了解。本文在第一部分简单快速介绍一下相关内容。

#### 基础知识复习

##### 快速了解区块链

区块链技术是利用块链式数据结构来验证与存储数据、利用分布式节点共识算法来生成和更新数据、利用密码学的方式保证数据传输和访问的安全、利用由自动化脚本代码组成的智能合约来编程和操作数据的一种全新的分布式基础架构与计算范式。

简单地说，区块链就是一种去中心化的分布式账本数据库。

区块链网络传递的是价值信息，解决的是信任问题。

![区块链](./1.png)

##### **什么是以太坊**

以太坊（Ethereum）是一个建立在区块链技术之上的去中心化应用平台。它允许任何人在平台中建立和使用通过区块链技术运行的去中心化应用。

以太坊平台对底层区块链技术进行了封装，让区块链应用开发者可以直接基于以太坊平台进行开发，只要专注于开发应用本身逻辑的智能合约，这样就可以大大降低开发难度。

以太坊与比特币很大的不同是以太坊拥有智能合约的概念。比特币是数字货币 - 价值存储，而以太坊不单单是数字货币，还支持智能合约。

如果想更深入地了解什么是以太坊，还可以参考另一篇文章：[以太坊是什么 - 以太坊开发入门指南](https://learnblockchain.cn/2017/11/20/whatiseth/)

##### 什么是智能合约

那么什么是智能合约呢？以太坊网络上运行程序就称之为智能合约， 它和其他的程序一样，也是代码和数据(状态)的集合。

![智能合约账户结构](./2.png)

智能合约是由事件驱动的、具有状态的、运行在一个可复制的、共享的账本之上的计算机程序，当满足特定条件时，智能合约会自动执行。合约一旦部署不可修改、合约执行后不可逆、所有执行事务可追踪。

智能合约非常适合对信任、安全和持久性要求较高的应用场景，比如：数字货币、数字资产、投票、保险、金融应用、预测市场、产权所有权管理、物联网、点对点交易等等。

区块链是去中心化的系统，存在于所有允许的各方之间，智能合约消除了传统的系统中对导致各方冲突的中间商的需要。

![什么是智能合约](./3.png)



如果想更深入地了解智能合约原理，还可以参考另一篇文章：[智能合约运行原理](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)

#### 智能合约安全漏洞实战环境搭建

目前开发智能合约的IDE，首推还是Remix，Remix是以太坊智能合约编程语言Solidity的一个基于浏览器的IDE，强烈建议新手使用[Remix -Solidity IDE](http://remix.ethereum.org/)来进行开发，不用本地安装Solidity。

如果想自己本地搭建开发环境，可以看另一篇文章: [搭建智能合约开发环境Remix IDE及使用](https://learnblockchain.cn/2018/06/07/remix-ide/)。

我们在进行智能合约的安全漏洞实战过程中，需要开发测试，如果通过[Remix在线IDE](http://remix.ethereum.org/)来进行的话，根据 Remix IDE 的 Environment 选项不同，有不同的方法，如下图所示：

![environment](./5.png)

Remix IDE 的 Environment 选项有三种：

- Javascript VM，这个Remix内置的虚拟机，提供了合约部署、运行的功能，跟以太坊虚拟机功能一样的，这个相当于在内存中模拟了一条区块链，如果选择Javascript VM模式，可对合约进行debug调试；
- Injected Web3，主要是通过插件使用，配合metamask可方便部署智能合约到以太坊测试网或者主网；
- Web3 Provider，将Remix连接指定的以太坊节点，比如通过本地通过安装以太坊客户端geth搭建的私有链节点。

下面分别从上述三种模式对智能合约的安全漏洞实战环境搭建进行讲解，以方便后续对智能合约漏洞进行实战练习。

本文所使用的Solidity开发也将基于在线Remix IDE来进行。

##### Javascript VM

Javascript VM模式，也是最简单的方式，可以直接使用在线[Remix -Solidity IDE](http://remix.ethereum.org/)来进行智能合约的开发、编译、部署、调用、测试、调试等，很适合入门选手进行练习，如下图所示：

![remix ide](./4.png)

具体的Remix IDE使用这里不在赘述，可移步Remix官方文档：[Remix, Ethereum-IDE 官方使用手册](https://remix-ide.readthedocs.io/en/latest/#) 。



##### Injected Web3

Injected Web3，主要是通过插件使用，配合metamask可方便部署智能合约到以太坊测试网或者主网。

在这种模式下，可以使用remix + metamask + myetherwallet的模式开发部署智能合约，这种方法最简单也最常用；还可以使用Truffle + Infura这种工程化的高级开发部署方法。

> **[Remix](http://remix.ethereum.org)**不用介绍了；
>
> **[MetaMask](https://www.metamask.io)**是一款在谷歌浏览器Chrome上使用的插件类型的以太坊钱包，该钱包不需要下载，只需要在谷歌浏览器添加对应的扩展程序即可，非常轻量级，使用起来也非常方便，[Metamask详细图文教程](https://www.jianshu.com/p/7ea707978dc5)：
>
> **[MyEtherWallet](https://www.myetherwallet.com)**或简称MEW钱包，是最有名的以太钱包之一，MEW钱包是一个基于网络的服务，允许您控制您的资金。它用于安全地存储、发送和接收以太和ERC-20代币，以及用于与智能合同进行交互。该服务为其用户提供了一个地址（公共地址），用户可以在此接收任何人的硬币和代币。它还为用户提供了一种通过私钥（秘密密码）发送硬币的快捷方式。
>
> **[Infura](https://infura.io/)**就是一个可以让你的dApp快速接入以太坊的平台，不需要本地运行以太坊节点，背后是负载均衡的API节点集群。使用它的好处就是，你永远不必担心连接的节点失效的问题，Infura会管理好这一切。
>
> **[Truffle](https://www.trufflesuite.com)**是针对基于以太坊的Solidity语言的一套开发框架。本身基于Javascript。对以太坊客户端做了深度集成，开发，测试，部署一行命令都可以搞定。[Truffle - 以太坊Solidity编程语言开发框架使用指南](https://truffle.tryblockchain.org/index.html)

下面介绍如何通过remix + metamask + myetherwallet这种简单的方法开发、部署、调用合约，开始之前请自行安装好Metamask钱包插件到浏览器。

这里使用简单的测试用Solidity智能合约：

```javascript
pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData;
    function set(uint x) public {
        storedData = x;
    }
    
    function get() public constant returns (uint) {
        return storedData;
    }
}
```

将合约写入Remix IDE编辑器中，并完成编译。

![remix ide](./6.png)

然后在Metamask中选择测试网络，并申请测试ETH，因为在我们部署合约到以太网测试网时也需要测试ETH手续费，部署到以太坊主网就得真正的花真金白银ETH了。

![remix ide](./7.png)

在测试网中申请测试ETH

![remix ide](./8.png)

然后同过Remix IDE点击部署，此时弹出Metamask交易确认，看到了是需要话费测试ETH的。

![remix ide](./10.png)

部署成功后，可以再Remix IDE的console窗口看到我们在测试网的交易hash，以及我们的合约。

![remix ide](./11.png)

此时可以通过Remix IDE直接调用已经部署的合约，也可以通过myetherwallet来调用任意合约，进入myetherwallet网站之后，需要选择跟myetherwallet进行交互的方式，这里我们选择Metamask，然后myetherwallet就会和Metamask建立连接。

![remix ide](./9.png)

我们输入部署之后的合约地址，再输入合约的ABI，然后就可以直接调用我们部署的合约。

![remix ide](./12.png)

调用合约，如图所示，我们设置一个x值为2，然后获取x的值，返回结果为2。

![remix ide](./13.png)

![remix ide](./14.png)



##### Web3 Provider

Web3 Provider，将Remix连接指定的以太坊节点，比如通过本地安装以太坊客户端geth搭建的私有链节点。

> **Geth**是典型的开发以太坊时使用的客户端，基于Go语言开发。 `Geth`提供了一个交互式命令控制台，通过命令控制台中包含了以太坊的各种功能（API）。

安装完以后，把geth控制台启动，通过如下命令进入：

```
geth --datadir testNet --dev console 2>> test.log
```

执行命名后，会进入geth控制台：

![](./open_geth_eth.jpg)

然后创建账户，解锁账户，编写合约，编译合约，从编译详情中拷贝WEB3DEPLOY中的内容，通过修改相关信息后进入geth客户端执行，进行合约部署。

![](./15.png)

部署成功即可直接在geth控制台进行合约调用，整个部署和调用过程确保账户中有余额。更多详细过程请见另一篇文章：[使用remix+geth开发部署智能合约](https://learnblockchain.cn/2017/11/24/init-env/)  。



磨刀不误砍柴工，先了解清楚基础知识，才能更好的了解智能合约，以及智能合约的安全问题。

工欲善其事必先利其器，只有知道怎么搭建智能合约安全漏洞实战练习的环境，才能更好的进行合约漏洞的复盘。

本篇文章为以太坊智能合约安全漏洞实战的前奏文章，敬请期待后续的智能合约安全漏洞实战详情文章。



本文由深入浅出区块链社区合作伙伴 - [零时科技安全团队](https://noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学习区块链技术](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。