---
title: 零知识证明-Semaphore源代码导读
permalink: zkp-Semaphore
un_reward: true
date: 2019-11-08 15:22:49
categories: 零知识证明
tags:
    - 零知识证明
    - Semaphore
author: Star Li
---

Semaphore是一个用零知识证明（zk-SNARK）技术的开源项目。Semaphore实现的是基于零知识证明的身份和信号。

<!---more-->

https://github.com/barryWhiteHat/semaphore

## 整体框架
Semaphore整个项目，由三部分组成：nodejs模块（客户端/服务器端以及前端页面），snark模块（zk-SNARK Groth16电路相关模块），以及以太坊上的智能合约。主要逻辑都在semaphorejs目录中，其源代码目录结构如下：

![源代码目录结构](https://img.learnblockchain.cn/2019/11/08/001.jpg)

contracts - 智能合约，使用truffle框架部署测试。

snark - snark模块，使用snarkjs(iden3)开发zk-SNARK电路。

src - nodejs模块，实现前后端。

三部分之间的逻辑关系如下：

![逻辑关系](https://img.learnblockchain.cn/2019/11/08/002.jpg)

## Key & Identity

使用Semaphore的每个账户需要创建私钥和公钥。每个账户的公钥和私钥，以及对应的Identity的具体逻辑可以查看semaphorejs/src/client/semaphore.js文件中generate_identity函数：
```js
const private_key = crypto.randomBytes(32).toString('hex');
const prvKey = Buffer.from(private_key, 'hex');
const pubKey = eddsa.prv2pub(prvKey);
const identity_nullifier = '0x' + crypto.randomBytes(31).toString('hex');
const identity_trapdoor = '0x' + crypto.randomBytes(31).toString('hex');
const identity_commitment = pedersenHash([bigInt(circomlib.babyJub.mulPointEscalar(pubKey, 8)[0]), bigInt(identity_nullifier), bigInt(identity_trapdoor)]);
```

私钥是256位的随机数。公钥是私钥的EdDSA的签名。Identity主要由两部分组成：31个字节的nullifier和31个字节的trapdoor。这两部分都是随机生成。这里的nullfier，不要和ZCash中的Nullifier混淆。这里的nullfier就是随机数。每个Identity会对应两个对应的信息：一个是commitment，一个是nullifier_hash。Commitment的计算方式如下图：

![Commitment的计算方式](https://img.learnblockchain.cn/2019/11/08/003.jpg)

Identity中的nullifier以及trapdoor并不记录在以太坊的智能合约中，对应的commitment会记录在合约中。

## Semaphore.sol
semaphorejs/contracts/Semaphore.sol是智能合约部分的逻辑实现。insertIdentity函数实现一个账户Identity的“注册”。
```js
function insertIdentity(uint256 identity_commitment) public style="box-sizing: border-box; padding-right: 0.1px;">   insert(id_tree_index, identity_commitment);
   uint256 root = tree_roots[id_tree_index];
   root_history[root] = true;
}
```
Identity对应的commitment会添加到一个merkle树上，同时新的merkle树根会记录在root_history的mapping中。

## Nullifier Hash
Nullifier Hash是用来证明某个Identity对应commitment存在一个merkle树上，并生成的标示。Nullfier Hash的计算过程可以查看电路的逻辑（semaphorejs/snark/semaphore-base.circom）。
```js
template Semaphore(jubjub_field_size, n_levels, n_rounds) {
...
  component external_nullifier_bits = Num2Bits(232);
     external_nullifier_bits.in <== external_nullifier;
     component nullifiers_hasher = Blake2s(512, 0);
     for (var i = 0; i < 248; i++) {
       nullifiers_hasher.in_bits[i] <== identity_nullifier_bits.out[i];
     }
     for (var i = 0; i < 232; i++) {
       nullifiers_hasher.in_bits[248 + i] <== external_nullifier_bits.out[i];
     }
     for (var i = 0; i < n_levels; i++) {
       nullifiers_hasher.in_bits[248 + 232 + i] <== identity_path_index[i];
     }
     for (var i = (248 + 232 + n_levels); i < 512; i++) {
       nullifiers_hasher.in_bits[i] <== 0;
     }
     component nullifiers_hash_num = Bits2Num(253);
     for (var i = 0; i < 253; i++) {
       nullifiers_hash_num.in[i] <== nullifiers_hasher.out[i];
     }
     nullifiers_hash <== nullifiers_hash_num.out;
...
}
```
Nullifier Hash的计算逻辑如下图：

![Nullifier Hash的计算逻辑](https://img.learnblockchain.cn/2019/11/08/004.jpg)

其实nullfier和path index已经足够表示。额外加入了external nullfier的原因是，同一个Identity，在external nullifier不同的情况下，生成不同的nullifier hash。也就是说，一个账户可以多次“消费”。这样设计的原因是为了Signal的业务需求。

## Signal

通过智能合约创建了Identity，就可以发信号（Signal）了。一个账户发送信号，必须首先提供Identity在merkle树上的证明（能计算出commitment）。智能合约中的broadcastSignal是发送信号的接口：
```js
function broadcastSignal(
   bytes memory signal,
   uint[2] memory a,
   uint[2][2] memory b,
   uint[2] memory c,
   uint[4] memory input // (root, nullifiers_hash, signal_hash, external_nullifier)
) public
   style="box-sizing: border-box; padding-right: 0.1px;">   isValidSignalAndProof(signal, a, b, c, input)
{
   uint nullifiers_hash = input[1];
   signals[current_signal_index++] = signal;
   nullifier_hash_history[nullifiers_hash] = true;
   emit SignalBroadcast(signal, nullifiers_hash, input[3]);
}
```
signal就是需要发送的信号，a/b/c是零知识证明的proof信息，input是零知识证明对应电路的输入，包括merkle树根，nullifier hash，signal hash以及external nullifier。

只有在proof信息验证过后，对应signal才会记录。每次发送signal时对应的nullifier hash会被记录下来。也就是说，在external nullifier不变的情况下，所有Identity只能发送一次Signal。

## 总结

Semaphore项目由js开发，结合零知识证明(zk-SNARK)，在以太坊的智能合约的基础上实现Identity。每个Identity可以发送信号。在external nullifier不变的情况下，每个Identity只能发送一次Signal。


本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
