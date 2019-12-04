---
title: ENS-为你的钱包添加多币种支持
permalink: ENS-wallet
un_reward: true
date: 2019-12-04 12:04:54
categories: ENS
tags:  ENS
author: makoto_inoue
---

在 Devcon5 上宣布了[多币种支持特性](https://medium.com/the-ethereum-name-service/ens-launches-multi-coin-support-15-wallets-to-integrate-92518ab20599)后，我们很快就在 [ENS 管理器](https://app.ens.domains/)上实现了这一功能。

[许多钱包](https://medium.com/the-ethereum-name-service/ens-launches-multi-coin-support-15-wallets-to-integrate-92518ab20599)也紧接着开始支持这一特性。

开发者们可以通过阅读 [EIP](https://eips.ethereum.org/EIPS/eip-2304) 、[ENS文档](https://learnblockchain.cn/docs/ens/)以及我们的 JavaScript [地址编码库](https://github.com/ensdomains/address-encoder)来了解最新的实现细节。

在这篇文章中，我将介绍我们把多币种支持特性接入到自己 app 中的经验，为其他钱包开发者抛砖引玉，提供大致思路。

## 解析器

由于这个特性是全新的，许多以太坊库都尚未支持（目前 ethers.js 、go-ens 以及 ethreal 支持）。

为了直接和解析器合约交互，你通过 npm 下载我们的合约，并导入以下 abi 。

```js
import { abi } from
 '@ensdomains/resolver/build/contracts/Resolver.json'
```

首先我们来看看设置/获取以太坊地址和其它数字货币地址的区别。

```js
## 获取并设置以太坊地址
function addr(bytes32 node);
function setAddr(bytes32 node, address addr);
## 获取并设多币种地址
function addr(bytes32 node, uint coinType);
function setAddr(bytes32 node, uint coinType, bytes calldata a);
```

最大的区别在于 getter 和 setter 函数现在都要附加上 coinType 参数。请留意现在 setAddr 函数的参数是 bytes 类型而不是 address 类型。

## 地址编码器

`address-encoder` 是一个 js 编解码库，对存储在 ENS 解析器中的记录进行处理。它有两个函数，包括 `formatsByName` 以及 `formatsByCoinType` 。

```js
import { formatsByName, formatsByCoinType } from '@ensdomains/address-encoder';
formatsByName['BTC']
{ coinType: 0, decoder: [Function],encoder: [Function],name: 'BTC' }
formatsByCoinType['0']
{ coinType: 0, decoder: [Function],encoder: [Function],name: 'BTC' }
From now on, we only use formatsByName.
```

下面我们只使用 `formatsByName` 函数。

## 获取支持的币种列表

或许你想接入自己的支持的币种列表。如果你想直接接入我们已经实现了编解码的代币，你应该通过以下代码构造这个币种列表。

```js
export const COIN_LIST = Object.keys(formatsByName)
```

## 获取地址

下面是我们在自己的 `React` 组件中实现 `getAddr` 函数的超级简化版本。

![简化版本](https://img.learnblockchain.cn/2019/12/04/001.png)

通过第一行代码，我们获取到了 `coinType` 以及 `encoder` 函数。接下来会用到 `coinType` 和 `namehash` 参数从 `Resolver` 合约中获取到某种代币的具体地址。

第四行代码是把地址传给译码器之前先检查是否是空地址，如果是的话就直接返回。因为如果把一个空字符串直接传给编码器，就有可能抛出某些代币类型的错误。

第五行代码把地址的二进制表达形式传给编码函数，将地址以文本形式显示。

## 设置地址

以下是我们 `setAddr` 函数的简化版本。

![简化版本](https://img.learnblockchain.cn/2019/12/04/002.png)

和我们在 `getAddr` 函数中的处理一样，当地址为空时，我们提前返回这个结果，而不传给解码器。第五行直接用空字符串的二进制表示就行。

## 验证

验证地址是否符合对应币种的格式十分关键。

![验证](https://img.learnblockchain.cn/2019/12/04/003.png)

如果向 `address-encoder` 库随便传一个无效的文本，就会抛出错误。

本例中，我们捕获了这个错误并展示了出来。

![错误](https://img.learnblockchain.cn/2019/12/04/004.png)

## BCH 贴士

通常情况下，对同一条文本先解码再编码，依然会得到一样的文本。但比特币现金表现的不太一样（想要探究具体的技术原因，可以参考这条 EIP 中的 “CashAddr”），比特币现金在编码之后返回文本会加一个 “bitcoincash” 前缀。下面这个例子显示了原始文本、16进制表示以及查询时 BCH 编码后的规范表示形式（你可以在[测试用例](https://github.com/ensdomains/address-encoder/blob/master/src/__tests__/index.test.ts#L97)中找到它）。

![规范表示形式](https://img.learnblockchain.cn/2019/12/04/005.png)

## 总结

在本文中，我们梳理了实现多币种支持的流程，介绍了需要留意的某些细节。事实上这和原来设置/获取地址的操作十分接近，只不过要多传一个 `coinType` 参数。此外，在涉及到验证和空字符串的问题上，要额外小心。

随着越来越多库支持多币种特性，以后钱包开发者将很轻松地添加这一功能。


*原文链接：https://medium.com/the-ethereum-name-service/how-to-integrate-ens-multi-coin-support-into-your-wallet-for-developers-8d3a8a37d1eb*

*本文转自[ETHFANS](https://ethfans.org/posts/how-to-integrate-ens-multi-coin-support-into-your-wallet-for-developers)*


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。