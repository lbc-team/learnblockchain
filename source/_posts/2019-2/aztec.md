---
title: 利用 AZTEC 协议进行匿名隐私转账
permalink: aztec
date: 2019-10-18 09:44:33
categories: 零知识证明
tags:
    - AZTEC
    - 零知识证明
author: Yuren Ju
---


这次去 Devcon5 有机会跟 AZTEC 的开发者聊天，后续讨论中也厘清了我自己使用 AZTEC 的一些疑问，搞清楚后也分享本篇文章来介绍此协议。

Ethereum 区块链是一个透明的平台，虽然不知道特定地址的拥有人是谁，但是发生在区块链上的交易都可以看得一清二楚。而在日常使用时交易的保密性还是非常重要的。

<!-- more -->

先定义一下**保密 (confidentiality)**：我们这边说的保密是隐藏着双方交易的金额不显示于区块链上，但又可以透过其他机制来验证此笔交易无误。但是交易的双方资讯还是公开的。

Ethereum 上面有许多基于[零知识证明的解决方案](https://learnblockchain.cn/categories/zkp/)都在试着建立可以提供保密支付的功能，今天要介绍的 Aztec 就是其中之一。

![](https://img.learnblockchain.cn/2019/10/15713703862556.jpg)


本文不会介绍 AZTEC 密码学上是如何达到的原理，而主要会聚焦在概观介绍以及如何使用如何发送保密交易。

## 简介

AZTEC 提供了一种名为ZKAsset 的资产，在系统里面我们称它为单据(note)，你可以用任意数量的[ERC20](https://learnblockchain.cn/docs/eips/eip-20.html) 转换任一数量的单据，举个例子，我们可以把10,000 [DAI](https://learnblockchain.cn/2019/03/19/understand_dai/) 转换成一张单据，而这张单据就是等值的10,000 DAI，此时这张单据的价值是有被记录在区块链上的。

但是这个ZKAsset 的单据是可以切割成任意数量的，而切割时每张单据的价值此时就不是可见于区块链上了，所以当我把这个单据传给另外一个帐号时，只有单据的拥有者可以利用AZTEC 的工具得知这张单据的价值是多少。

而这张单据也可以将任意数量的 ERC20 转换出来使用，直到这张单据里面的 ERC20 用完为止。而单据跟单据也可以合并，这样的话里面到底包含多少数量的 ERC20 就会更无法预测。

这边我们假设一个使用情境来解释：一间公司想要保密的支付每个员工的薪水。这样的情境下，要如何使用 AZTEC 来达成呢？

首先公司先把 100,000 DAI 转成一张单据 A，此时这张单据价值 100,000 DAI 是公开的。

![](https://img.learnblockchain.cn/2019/10/15713805483137.jpg)

发薪水时，公司把单据 A 切成两份，分别价值 90,000 DAI 跟 10,000 DAI 的两张单据 A1, A2。

![](https://img.learnblockchain.cn/2019/10/15713805988245.jpg)


接着把 A2 传送给员工，此时这两张单据的价值并不会公开的记录在区块链上，但是拥有者依然可以透过 AZTEC 的工具来验证其价值。


![](https://img.learnblockchain.cn/2019/10/15713806384338.jpg)


员工收到代表10,000 DAI 的单据后，当需要用钱时可以将此单据中一部分的DAI 如1,000 DAI 从隐藏价值的note 切分出来，一部分变成公开的DAI，另外一部分仍是隐藏价值的note，此时区块链上可以知道此员工换出了1,000 DAI，但是不知道他还剩下多少DAI，此员工也可以一直重复这个步骤把钱领出。

![](https://img.learnblockchain.cn/2019/10/15713809394718.jpg)

如果下份薪水进来后，此员工还可以把他原本的两张单据合并或切分，让实际还有多少钱更难被推敲出来。

![](https://img.learnblockchain.cn/2019/10/15713809684243.jpg)

## DEMO 案例

以上述这样的情境时，AZTEC 就可以利用其保密交易功能实现薪资保密转帐。而 AZTEC 的原理则是基于[零知识证明](https://learnblockchain.cn/categories/zkp/)的技术完成，使用时则是透过他们提供的工具 aztec.js 来产生零知识证明中所需要的证明，再透过 Aztec 提供的智能合约来完成这些保密交易。

在看源码前，一些名词先解释一下：

* **ZkAsset**：价值保密的资产，将会绑定特定的 ERC20，比如说 DAI，会透过此智能合约的接口 `confidentialTransfer()` 进行保密转帐。保密转帐时会需要一些对应的资料将会由 aztec.js 工具产生。
* **ACE (AZTEC Cryptography Engine)**：Aztec 的主合约，一些验证相关的合约都注册其中。在我们的案例中仅直接使用到 `publicApprove()` 功能用于同意 ERC20 转帐。其他的则会透过 ZkAsset 间接的调用到。
* **Aztec.js**：AZTEC 提供的工具集合，用来建立票据、产生证明、透过私钥产生签名等等
* **JoinSplitProof**：Aztec.js 之中多用途的证明，进行保密转帐时，会需要透过 JoinSplitProof 产生证明。

以下案例将利用Aztec 的工具在Rinkeby 网路上进行保密转帐，在看案例之前你可以先到etherscan 上面看从 [0xa2b19…3a589](https://rinkeby.etherscan.io/address/0x79fb585ffc18acd5b7002dfd8764e3b9f1188651) (block 5265001 ) 开始的6 个transactions，除了：

* [Bob 公开转入 100 个 ERC20 token](https://rinkeby.etherscan.io/tx/0x36eb10e163878654b05dd72e74d2fb08abefd8c3f381ce1c26639656aa991693)
* [Alice 公开转出 10 个 ERC20 token](https://rinkeby.etherscan.io/tx/0x40c0dd9a523a1c3a351b9c2df932140dab6f74ee024e478a1c2b76f4c5297090)

你有办法得知 Bob 实际上转了多少钱给 Alice 吗？

整个案例的流程如下：

1. Bob 先无中生有价值 200 元（单纯测试用）
2. Bob 把 100 元的 ERC20 token 转成一张价值 100 元的单据（公开）
3. Bob 把单据切成两张，分别是 20 元的单据跟 80 元的单据（保密），并且把 80 元的单据给 Alice（保密）
4. Alice 把 80 元的单据领出其中 10 元（公开），保留剩下 70 元的单据（保密）

### Mint

这个步骤跟 Aztec 无关，单纯是测试用的 ERC20 加了一个 mint function 可以帮自己加值任意数量的 ERC20 token。
```js
async function mint() {
  const mintValue = 200;
  console.log(chalk.green(`Minting ${mintValue} to Bob`));
  const tx = await bob.signers.erc20.mint(bob.address, mintValue);
  await tx.wait();
}
```

### Deposit

这个步骤把 Bob 的 200 元中的 100 元转换成 aztec note，请注意这部分的金额会公开在区块链上。

```js 1_deposit.js
async function deposit() {
  const depositValue = 100;
  console.log(chalk.green(`Deposit ${depositValue} from Bob's public erc20 to a aztec note`));

  console.log(`- executing bob.signers.erc20.approve()`);
  await (await bob.signers.erc20.approve(contractAddresses.ace, depositValue)).wait();

  const depositNote = await note.create(bob.publicKey, depositValue);
  depositNotes = [depositNote];
  const proof = new JoinSplitProof([], depositNotes, bob.address, depositValue * -1, bob.address);
  const data = proof.encodeABI(contractAddresses.zkAsset);
  const signatures = proof.constructSignatures(contractAddresses.zkAsset, []);

  const prevBalance = await erc20.balanceOf(bob.address);
  console.log(`- prevBalance: ${prevBalance.toString()}`);

  console.log(`- executing ace.publicApprove(ZK_ASSET_ADDRESS, ${proof.hash}, ${depositValue})`);
  await (await bob.signers.ace.publicApprove(
    contractAddresses.zkAsset,
    proof.hash,
    depositValue
  )).wait();

  console.log(`- executing zkAssetSigner.confidentialTransfer()`);
  await (await bob.signers.zkAsset.confidentialTransfer(data, signatures, ethOptions)).wait();

  const currBalance = await erc20.balanceOf(bob.address);
  console.log(`- currBalance: ${currBalance.toString()}`);
}
```

首先利用 `erc20.approve(contractAddresses.ace, depositValue)`允许 ACE 合约转换资产。接着利用 note.create() 来产生单据，其中第一个参数是帐号的公钥，第二参数是此张单据的价值。

```js
bob.signers.erc20.approve(contractAddresses.ace, depositValue);
const depositNote = await note.create(bob.publicKey, depositValue);
```

接下来透过 aztec.js 提供的 `JoinSplitProof` 来建立一个 proof，之后会作为 `confidentialTransfer()` 的参数传入。 JoinSplitProof 有几个功能：

1. 合并单据
2. 切分单据
3. 把 ERC20 从一般的公开金额转换成保密金额
4. 把单据中保密金额的 ERC20 转移部分金额变成公开金额

因为要达成以上功能，所以 JoinSplitProof 五个参数如下：

* **inputNotes**: 你想要合并的 note，如果要从公开的 ERC20 转换进来时，就给一个空列表。
* **outputNotes**: 想要输出的 note，这边可以是任意数量
* **sender**: 送出这笔交易的帐号地址
* **publicValue**: 要转出的公开金额，如果是负数是公开转成保密金额，反之则是保密金额转成公开金额
* **publicOwner**: 公开金额 ERC20 的拥有者

在我们的例子第一次使用时是将 100 元转换成一张单据，用法如下：

```js
const proof = new JoinSplitProof([], depositNotes, bob.address, depositValue * -1, bob.address);

const data = proof.encodeABI(contractAddresses.zkAsset);
const signatures = proof.constructSignatures(contractAddresses.zkAsset, []);
```

产生之后，我们会需要利用 encodeABI 以及 constructSignatures 分别产生给 `confidentialTransfer()` 用的参数，signatures 是要产生 inputNotes 的签名，因为我们这边没有任何 inputNotes，所以就会是一个空的列表。

接着除了 ERC20 要同意 ACE 合约可以动用资产外，因为 ACE 里面也会记录哪些资产是什么人可以动用，所以只要需要动用到公开的 ERC20 时，都会需要在这边同意资产动用。

```js
ace.publicApprove(
    contractAddresses.zkAsset,
    proof.hash,
    depositValue
)
```

以上都做完了后，将 proof 产生的资料传入 `confidentialTransfer()` 即可。后面的 ethOptions 则适用于提高 gasLimit 来覆盖过 [ethers.js](https://learnblockchain.cn/docs/ethers.js/) 提供的预设数值。

```js
const ethOptions = {
  gasLimit: 1000000
};

zkAsset.confidentialTransfer(data, signatures, ethOptions)
```

### 切分单据与传送给 Alice

这边会将原本 Bob 拥有的 100 元单据切成一张 20 元给 Bob，另外一张 80 元给 Alice。
```js 2_split_and_transfer.js
async function transferFromBobToAlice() {
  const msg =
    `Split note to note A with ${splitValues[0]} value for bob & ` +
    `note B with ${splitValues[1]} value for alice`;
  console.log(chalk.green(msg));

  const noteA = await note.create(bob.publicKey, splitValues[0]);
  const noteB = await note.create(alice.publicKey, splitValues[1]);
  transferNotes = [noteA, noteB];
  const transferProof = new JoinSplitProof(
    depositNotes,
    transferNotes,
    bob.address,
    0,
    bob.address
  );

  const transferData = transferProof.encodeABI(contractAddresses.zkAsset);
  const transferSignatures = transferProof.constructSignatures(contractAddresses.zkAsset, [
    bob.aztecAccount
  ]);

  console.log("- executing transfer: zkAssetSigner.confidentialTransfer()");

  await (await bob.signers.zkAsset.confidentialTransfer(
    transferData,
    transferSignatures,
    ethOptions
  )).wait();
}
```

这边跟前面的原理类似，先利用 `note.create()` 造出两张单据分别为 Bob 与 Alice 拥有。因为前一张的 inputNotes 是由 Bob 拥有，所以这边我们利用 `constructSignatures()` 产生 bob 的签名。

```js
const transferSignatures = transferProof.constructSignatures(contractAddresses.zkAsset, [
    bob.aztecAccount
  ]);
```

最后一样利用 `confidentialTransfer()` 传送，但不一样的是这边的所有金额都是保密的了，虽然有一张价值为 80 元的票据已经传送给 Alice，但是金额也是保密的。

### Alice 提款

Alice 将提款出 10 元，保留剩下的 70 元单据往后继续使用。

```js 3_withdraw.js
async function withdraw() {
  console.log(chalk.green("Executing withdraw"));
  const withdrawValue = 10;
  const [, noteB] = transferNotes;
  const noteC = await note.create(alice.publicKey, splitValues[1] - withdrawValue);
  const withdrawProof = new JoinSplitProof(
    [noteB],
    [noteC],
    alice.address,
    withdrawValue,
    alice.address
  );
  const withdrawData = withdrawProof.encodeABI(contractAddresses.zkAsset);
  const withdrawSignatures = withdrawProof.constructSignatures(contractAddresses.zkAsset, [
    alice.aztecAccount
  ]);

  console.log("- executing withdraw: zkAssetSigner.confidentialTransfer()");
  await (await alice.signers.zkAsset.confidentialTransfer(
    withdrawData,
    withdrawSignatures,
    ethOptions
  )).wait();
}
```

重复之前的过程，但是透过给 JoinSplitProof 不一样的参数就可以达到这个功能。之前有提到 JoinSplitProof 的第四个参数 publicValue 如果负值是转换公开金额变成保密金额的单据，反之则是把保密金额的单据转换部份成公开金额。

所以这边只要给他正数的数值就可以把钱提出来。


```js
const withdrawValue = 10;
const [, noteB] = transferNotes;
const noteC = await note.create(alice.publicKey, 70);
const withdrawProof = new JoinSplitProof(
  [noteB],
  [noteC],
  alice.address,
  withdrawValue,
  alice.address
);
```

此时到 etherscan 上面可以看到有 [10 元的 ERC20 transfer](https://rinkeby.etherscan.io/tx/0x40c0dd9a523a1c3a351b9c2df932140dab6f74ee024e478a1c2b76f4c5297090)，到这边就完成了整个案例场景了。

完整的源码可以到 [yurenju/aztec-demo](https://github.com/yurenju/aztec-demo) 里面找到。


## 结论

AZTEC 除了保密转帐外，其实还有提供许多功能可以建构更复杂的 Dapp，本文提及的功能仅是其中一小部分。

如果你对AZTEC 有兴趣，可以接着参考官方的medium 所撰写的介绍文章知道更多细节，更棒的是还有[官方中文版](https://medium.com/@leila.w/aztec- %E5%8D%94%E5%AE%9A%E7%B0%A1%E4%BB%8B-ef38d0b9627)呦:-)

也感谢 AZTEC 的开发者回答了我们许多疑问，特别是 [Joe Andrews](https://github.com/joeandrews) 协助我们解答了开发上的许多疑问！

本文转载（翻译）自[Yuren Ju 的medium](https://medium.com/@yurenju/aztec-%E4%BF%9D%E5%AF%86%E5%82%B3%E8%BC%B8%E5%8D%94%E8%AD%B0-devcon5-%E8%A6%8B%E8%81%9E-9d6cba69dfa8)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
