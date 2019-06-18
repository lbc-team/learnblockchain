---
title: 理解 EIP712 - 类型结构化数据 Hash与签名
permalink: token-EIP712
date: 2019-04-24 10:48:34
categories: 以太坊
tags: EIP712
author: Ashton
---


区块链能够实现去中心化无信任情形下的资产安全，很关键的一点儿就是充分的把公私钥体系引入并使用起来了。通过对每笔交易进行私钥签名的方式保证每个人都只能花费他自己账号里的钱，别人也可以很容易的去验证某笔交易确实是账号所有人所发出的。其实私钥不只是可以签名交易，还可以签名其它数据。

<!-- more -->

## 排名第一的去中心化交易所 IDEX

下面是从 [etherscan](https://etherscan.io/stat/dextracker) 上截取的以太坊去中心化交易所在过去七天的交易量分布图，我们可以清楚的看到，IDEX 的交易量是远远超过其它交易所的。

![交易所交易量](https://img.learnblockchain.cn/2019/15561117218102.jpg!/scale/45%)


IDEX 有啥特别的呢？与其它去中心化交易所不同，IDEX 采取的是中心化交易戳合，去中心化结算的方式，资产的保存和结算都是在[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)里，交易所无法动用任何用户资产，但同时用户又能享受中心化交易撮合的快速方便。

![IDEX](https://img.learnblockchain.cn/2019/15561118926543.jpg!/scale/55%)


## 关键的签名

IDEX 需要在中心化服务器上进行订单的撮合，如何保证订单不会被交易所更改呢？核心就在于我们的每笔交易，在发送到中心化服务器前都会用用户自己的私钥进行签名，然后智能合约在进行结算时会对用户签名进行验证。如果中心化服务器对订单数据有任何改动，都无法通过智能合约的校验。


![交易签名](https://img.learnblockchain.cn/2019/15561120349739.jpg!/scale/55%)



## EIP712 的改进

但是，上一步提到的签名有个很大的缺陷，我们能看到的签名信息只能是像下面这样的一串哈希值，至于生成这个哈希值的原始数据，我们是无从得知的，进而也就不易验证。

![Hash哈希图](https://img.learnblockchain.cn/2019/15561121071312.jpg!/scale/55%)


使用 EIP712 之后，我们看到的签名窗口就是下面这样的了。在这里，我们不只是看到一串哈希数据了，而是能看到完整的签名数据，进而可以验证所签名的数据是不是正确的数据，有没有被攥改。

![EIP712 签名数据图](https://img.learnblockchain.cn/2019/15561121415080.jpg)



## 如何把 EIP712 用起来

下面我们以一个拍卖场景为例，看看如何在产品中把 EIP712 用起来。

### 定义数据结构

首先，用 JSON 格式列出用户所要签名的数据。 比如作为一个拍卖应用，需要签名的就是下面的投标数据：
    
```js
{
    amount: 100, 
    token: “0x….”,
    id: 15,
    bidder: {
        userId: 323,
        wallet: “0x….”
    }
}
```
    
然后，我们可以从上面的代码片段中提炼出两个数据结构: 竞标 Bid，它包括以 [ERC20](https://learnblockchain.cn/2018/01/12/create_token/) 代币资产和拍卖 id 确定的出价金额，以及身份 Identity，它指定了用户 id 和 用户钱包地址。
下一步，将 Bid 和 Identity 定义为结构体，就可以写出下面的 solidity 合约代码了。 可以通过 EIP712 协议草案查看 EIP712 所支持的完整数据类型列表，比如地址、 bytes32、 uint256等。
    
```js
Bid: {
    amount: uint256, 
    bidder: Identity
}
    
Identity: {
    userId: uint256,
    wallet: address
}
```

### 设计域分隔符（domain separator）

主要防止一个 DApp 的签名还能在另一个 DApp 中工作，从而导致签名冲突。拿拍卖为例子的话，一个拍卖应用里的投标请求竟然在另外一个拍卖应用里也能执行成功，可能会就导致不必要的损失。

具体来说，域分隔符就是下面这样的结构和数据：

```js
{
    name: "Auction dApp", // DApp 的名字
    version: "2", // DApp 的版本
    chainId: "1", // [EIP-155] 定义的 chainId
    verifyingContract: "0x1c56346...", // 验签合约地址
    salt: "0x43efba6b4..." // 硬编码到合约和 DApp 中的一个随机数值
}
```

### 为 DApp 编写签名代码
DApp 的前端 Javascript 代码需要能够请求 MetaMask 对相应的数据签名。

> 备注：需要安装最新版的 MetaMask 浏览器插件钱包

首先，定义数据类型:

```js
const domain = [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "chainId", type: "uint256" },
    { name: "verifyingContract", type: "address" },
    { name: "salt", type: "bytes32" },
];
const bid = [
    { name: "amount", type: "uint256" },
    { name: "bidder", type: "Identity" },
];
const identity = [
    { name: "userId", type: "uint256" },
    { name: "wallet", type: "address" },
];
```

接下来，定义域分隔符和需要签名的应用数据

```js
const domainData = {
    name: "Auction dApp",
    version: "2",
    chainId: parseInt(web3.version.network, 10),
    verifyingContract: "0x1C56346CD2A2Bf3202F771f50d3D14a367B48070",
    salt: "0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558"
};
var message = {
    amount: 100,
    bidder: {
        userId: 323,
        wallet: "0x3333333333333333333333333333333333333333"
    }
};
```

像下面这样组合这些变量：

```js
const data = JSON.stringify({
    types: {
        EIP712Domain: domain,
        Bid: bid,
        Identity: identity,
    },
    domain: domainData,
    primaryType: "Bid",
    message: message
});
```

接下来，通过调用 eth_signTypedData_v3 来进行签名：

```js
web3.currentProvider.sendAsync(
{
    method: "eth_signTypedData_v3",
    params: [signer, data],
    from: signer
},
function(err, result) {
    if (err) {
        return console.error(err);
    }
    const signature = result.result.substring(2);
    const r = "0x" + signature.substring(0, 64);
    const s = "0x" + signature.substring(64, 128);
    const v = parseInt(signature.substring(128, 130), 16);
    // The signature is now comprised of r, s, and v.
    }
);
```

### 在智能合约中添加验证签名代码

按 EIP712 的要求，数据在签名前首先要进行格式化和相应的哈希计算。为了能够通过 [ecrecover](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#ecrecover) 来确定是哪个账户进行的数据签名，我们在合约里也要按同样的规则对数据进行格式化。

首先，需要在 solidity 代码里定义所需要的结构体类型。

```js
struct Identity {
    uint256 userId;
    address wallet;
}
struct Bid {
    uint256 amount;
    Identity bidder;
}
```

然后，定义相应的类型格式串。

```js
string private constant IDENTITY_TYPE = "Identity(uint256 userId,address wallet)";
string private constant BID_TYPE = "Bid(uint256 amount,Identity bidder)Identity(uint256 userId,address wallet)";
```

再者，定义域分隔符的哈希值。

```js
uint256 constant chainId = 1;
address constant verifyingContract = 0x1C56346CD2A2Bf3202F771f50d3D14a367B48070;
bytes32 constant salt = 0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558;
string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";

bytes32 private constant DOMAIN_SEPARATOR = keccak256(abi.encode(
    EIP712_DOMAIN_TYPEHASH,
    keccak256("Auction dApp"),
    keccak256("2"),
    chainId,
    verifyingContract,
    salt
));
```

还需要为每种数据类型定义一个计算哈希值的函数。

```js
function hashIdentity(Identity identity) private pure returns (bytes32) {
    return keccak256(abi.encode(
        IDENTITY_TYPEHASH,
        identity.userId,
        identity.wallet
    ));
}
function hashBid(Bid memory bid) private pure returns (bytes32){
    return keccak256(abi.encodePacked(
        "\\x19\\x01",
       DOMAIN_SEPARATOR,
       keccak256(abi.encode(
            BID_TYPEHASH,
            bid.amount,
            hashIdentity(bid.bidder)
        ))
    ));
```

最后，别忘了最关键的签名验证函数：

```js
function verify(address signer, Bid memory bid, sigR, sigS, sigV) public pure returns (bool) {
    return signer == ecrecover(hashBid(bid), sigV, sigR, sigS);
}
```


本文作者为深入浅出社区共建者 Ashton ，喜欢他的文章可关注[他的简书](https://www.jianshu.com/u/922115b98e3f)。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


