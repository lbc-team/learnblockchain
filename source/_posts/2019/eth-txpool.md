---
title: 以太坊交易流程及交易池 TXpool 分析
permalink: eth-txpool
date: 2019-06-03 20:41:20
categories: 基础理论
tags: 
    - 以太坊
author: 清源
---

这篇文章来看看以太坊的交易流程及交易池TXpool。

<!--more -->

## 以太坊交易流程

用户通过 `Json RPC` 向以太坊网络发送的交易请求最后都会被 `go-ethereum/internal/ethapi/api.go` 的`SendTransaction` 函数所接收。 从接收用户传入的参数，到把交易放入交易池等待广播的流程如下图所示： 

![交易流程](https://img.learnblockchain.cn/2019/06/15596338384835.png!wl/scale/60%)


整个流程从`SendTransaction`接收到`SendTxArgs`开始, `SendTxArgs`的结构如下；

```go
type SendTxArgs struct {
   From     common.Address  `json:"from"`
   To       *common.Address `json:"to"`
   Gas      *hexutil.Uint64 `json:"gas"`
   GasPrice *hexutil.Big    `json:"gasPrice"`
   Value    *hexutil.Big    `json:"value"`
   Nonce    *hexutil.Uint64 `json:"nonce"`
   Data  *hexutil.Bytes     `json:"data"`
   Input *hexutil.Bytes     `json:"input"`
}
```

SendTransaction首先需要根据From字段来找到当前的账户，为签名交易做准备。

接着开始对交易进行预处理，为`SendTxArgs`的一些空字段设置默认值，比如分配`Nonce`，根据`To`字段是否为空，来判断交易是部署合约还是发送交易等。

进行预处理之后，需要对交易进行RLP编码，再根据之前获得的账户私钥进行签名。

最后在把交易提交到TXpool。


## 交易序列化

交易的序列化是通过 `toTransaction` 这个函数来完成的。

序列化的时候根据To字段是否为`nil`来判断是将交易序列化成交易，还是创建合约。

调用`SendTranstion`接口的`Data`和`Input`字段，最终都会被赋值给`Input`，再被序列化成`Payload`放入交易池（TXpool）中，现在保留`Data`字主要是为了向前兼容，目前推荐用`Input`字段。

> 当部署合约的时候`Input`是合约的代码，当发送交易的时候`Input`是交易的内容

```go
func (args *SendTxArgs) toTransaction() *types.Transaction {
   var input []byte
   if args.Data != nil {
      input = *args.Data
   } else if args.Input != nil {
      input = *args.Input
   }
   if args.To == nil {
      return types.NewContractCreation(uint64(*args.Nonce), (*big.Int)(args.Value), uint64(*args.Gas), (*big.Int)(args.GasPrice), input)
   }
   return types.NewTransaction(uint64(*args.Nonce), *args.To, (*big.Int)(args.Value), uint64(*args.Gas), (*big.Int)(args.GasPrice), input)
}
```

最终序列化后的交易包含以下字段，需要注意的是不包含From字段，把交易和发送者解耦以后可以支持域名地址，提供了更多的可能性。

```go
type txdata struct {
   AccountNonce uint64          `json:"nonce"    gencodec:"required"`
   Price        *big.Int        `json:"gasPrice" gencodec:"required"`
   GasLimit     uint64          `json:"gas"      gencodec:"required"`
   Recipient    *common.Address `json:"to"       rlp:"nil"` // nil means contract creation
   Amount       *big.Int        `json:"value"    gencodec:"required"`
   Payload      []byte          `json:"input"    gencodec:"required"`

   // Signature values
   V *big.Int `json:"v" gencodec:"required"`
   R *big.Int `json:"r" gencodec:"required"`
   S *big.Int `json:"s" gencodec:"required"`

   // This is only used when marshaling to JSON.
   Hash *common.Hash `json:"hash" rlp:"-"`
}
```

> r,s,v是交易签名后的值，它们可以被用来生成签名者的公钥；R，S是ECDSA椭圆加密算法的输出值，V是用于恢复结果的ID

用户私钥签名序列化的交易以后就会被放入到交易池中。


## 交易池

无论是本节点创建的交易(local)还是其他节点广播过来的交易(remote)，都会缓存在TXpool中，当需要生成区块时，就从TXpool中选择合适的交易打包成块，经由共识最终确认。

TXpool的核心功能

* 缓存交易
* 在打包区块前，对交易进行验证
* 过滤无效交易 
* 惩罚恶意发送大量交易的账户

TXpool的核心结构如下图； 

![TXpool 结构](https://img.learnblockchain.cn/2019/06/15596350432032.png!wl/scale/60%)


TXpool最为核心的结构是两个Map: `queued`和`pending`，用来存未验证的交易和验证过的交易。


## 添加交易

添加交易到TXpool的过程比较简单，总体流程是这样的；

* 验证交易的有效性 - 判断交易的`price`是否大于缓存中最小的，如果小于就拒收，如果大于就删除最小的交易，把本次交易插入`pending` 
* 如果这个`nonce`已经存在，依然是按照price的大小进行替换 
* 如果交易有效，不能替换`pending`里面的任何交易，则添加到`queued`中

## 清理交易池

`TXpool`存在内存中，不可能无限大，等超过一定阈值就需要对交易池里面的交易进行清理。

> pending的缓冲区容量默认是 4096，queued的缓冲区容量默认是1024

清理交易分为清理`queued`和清理`pending`，清理顺序`queued`->`pending`->`queued`

 当满足以下条件的时候就会清理`queued`

* 当`nonce`小于当前账号发送`noce`的最小值，也就是说之前的交易已经全部上链
* 当前的`nonce`符合条件可以移动到`pending`队列中，先从`queued`清除，然后移动（send）到`pending`中 
* 账户余额不足以支持该交易的花费了 - 交易数量超过了缓冲区

> 清理`queued`会影响`pending`的大小，所以`queued`清理优先级高

清理pending时，首先把超过每个账户可执行交易数量(AccountSlots)的数量，按照从大到小记录下来，接着按照从多到少删除。 举个例子来说明剔除的规则；

>假如AccountSlots为4 有四个超出的账户，它们的数量分别是10， 9， 7，5
>第一次剔除 [10], 剔除结束 [10]
>第二次剔除 [10, 9] 剔除结束 [9，9] 
>第三次剔除 [9, 9, 7] 剔除结束 [7, 7, 7] 
>第四次剔除 [7, 7 , 7 ,5] 剔除结束 [5，5，5，5]
>这个时候如果还是超出限制，则继续剔除
>第五次剔除 [5, 5 , 5 ,5] 剔除结束 [4，4，4，4]
    
接着清理`ququed`，规则也很简单，越先进入`queued`的越后删除，直到清理到满足最大队列长度（`GlobalQueue`）为止。

## 重构交易池(reset)

到这一步还有一个问题没有解决，[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)是分布式系统，当本地节点已经挑选出最优的交易，准备广播给整个网络，这个时候矿工已经打包了一个区块，本地节点的区块头就是旧的了，本地筛选的交易有可能已经被打包，如果已经被打包生成了新区块，再将这个交易广播已经没有任何的意义，甚至我们费尽心思准备好的`pending`缓冲区里的交易都是无效的。

为了避免上面的情况发生，我们就需要监听链是否有新区块产生，也就是`ChainHeadEvent`事件。

当监听到`ChainHeadEvent`事件时候，我们又该如何调整`queued`和`pending`呢？

首先需要将已经分叉的链回退到同一个区块号上(blockNumebr)，有可能是本地节点领先，有可能是网络上其他节点领先，但无论怎样，都回退到同一个区块号。 

![](https://img.learnblockchain.cn/2019/06/15596364439683.png!wl/scale/60%)


 本地节点回退时，撤销的交易保存到`discarded`切片中，网络上其他节点的撤销交易保存在`included`切片中。

当区块号一致的时候，还需要进一步的比较区块的`Hash`来进一步确认区块里面的交易是否一致，如果不一致一致回退到区块Hash为止，回退撤销的交易依旧保存在`discarded`和`included`切片中。

等完全确认本地和网络的链没有分叉的时候，就需要比较discarded和included里面的交易，因为网络上区块的生成优先级高于本地，所以需要剔除`discarded`中`inclueded`的交易，生成`reinject`切片，剔除完以后还需要对`TXpool`按照网络新生成区块的信息设置世界状态等信息，设置完以后，重新将`reinject`加入`TXpool`，加入以后在进行验证清理等流程。

## 思考

* 以太坊在实现TXpool的时候为了保证数据的一致性使用大量的锁，性能一般。
* 当区块生成速度比较快的时候需要频繁的reset，导致TXpool需要占用比较多的资源。
* 是否有比较好的方法既可以保证数据的一致性又可以快速找到相同的根区块？

本文作者是深入浅出区块链共建者清源，欢迎关注清源的[博客](qyuan.top)，不定期分享一些区块链底层技术文章。
备注：编者在原文上略有修改。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


