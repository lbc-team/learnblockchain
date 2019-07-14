---
title: LIBRA 中的可验证随机数 VRF
permalink: libra-VRF
date: 2019-07-14 08:23:48
categories: Libra
mathjax: true
tags:
    - Libra
    - 随机数
    - VRF
author: 白振轩
---


`Libra`中采用的椭圆曲线是`ED25519`,而不是像以太坊比特币使用的是`secp256k1`. 虽然有不同,但是从本质上来说他们都是椭圆曲线,基本性质都是完全相同的.因此适用于`S256`曲线的VRF算法在`Libra`中也是相通的.

<!-- more -->

## ED25519数字签名算法

[ED25519](http://ed25519.cr.yp.to/Ed25519) 是一个数字签名算法，签名和验证的性能都极高， 一个4核2.4GHz 的 Westmere cpu，每秒可以验证 71000 个签名，安全性极高，等价于RSA约3000-bit。签名过程不依赖随机数生成器，不依赖hash函数的防碰撞性，没有时间通道攻击的问题，并且签名很小，只有64字节，公钥也很小，只有32字节。 ED25519使用情况可[参考](http://ianix.com/pub/ed25519-deployment.html)

同时在zcash中签名使用了ED25519,也就是在隐私交易方面, ED25519 也有其独特应用之处,这应该也是主打隐私牌的Libra采用它的原因.

## 什么是 VRF

内容主要来自我的另一篇文章[一篇文章搞懂VRF](http://stevenbai.top/区块链技术/一篇文章搞懂vrf/)

VRF全称是`verifiable random function` ,也就是可验证随机数. 他有两个特性: 第一他产生的是**随机数**,第二还是**可验证**的。

我直接引用维基百科上的[VRF定义](https://en.wikipedia.org/wiki/Verifiable_random_function),就是说针对一个输入x,一个私钥SK的拥有者可以计算 $y=FSK(x)$ 和证明$PSK(x)$. 依据证明(proof)和SK对应的公钥PK( $PK=g^{SK}$),任何人都可以验证y是被正确计算的,但是不知道SK是什么.

原文中提到了使用双线性映射来做这个事情,当然VRF可以有很多种不同的实现,只要满足上面提出的条件即可.一个是随机数,另一个是可验证.

简单解释一下:

1. 验证人只知道x,在私钥SK持有人没有广播之前不知道随机数是什么?

2. 私钥SK持有人无法伪造随机数,一旦x确定,随机数也确定了.
   这就是所谓的随机数(除了SK持有人之外,其他任何人事先不知道)
   可验证(知道公钥PK的任何人都知道SK生成的随机数是否合规)

## Libra 中 VRF 的实现

   Libra中对于VRF的实现依据来自于[Verifiable Random Functions (VRFs) draft-irtf-cfrg-vrf-04](https://tools.ietf.org/html/draft-irtf-cfrg-vrf-04)
   感兴趣的可以读读这篇标准草案

### 推导中用到的符号的含义

   B: ED25519曲线中的基点
   SK: 私钥
   x: 可以认为是私钥,或者有私钥推导出来.
   Y: 公钥,其中 $Y=B^x$
   大小的字母都表示曲线上的点,小写字母表示大整数

   另外需要知道在ECDSA中:

   1. 如果一个整数乘以一个点,实际上表示出来就是指数,比如 $x*B=B^x$
   2. 两个点相减则表示除法,比如 H-B = $H \over B$

### 随机数生成过程及证明

   也就是证明方按照生成一个随机数,并给出证明,这个随机数就是按照我们确定的规则生成的.

#### H1:把任意信息映射到曲线上的点

   思路也很简单,将Hash(m)(**注意是256位hash**)作为曲线上的X,然后带入上述椭圆曲线公式,求出相应的Y即可.
   具体对应代码中就是`hash_to_curve`

   ```rust
   //self是私钥,alpha就是VRF的输入源
   pub(super) fn hash_to_curve(&self, alpha: &[u8]) -> EdwardsPoint {
       let mut result = [0u8; 32];
       let mut counter = 0;
       let mut wrapped_point: Option<EdwardsPoint> = None;

       while wrapped_point.is_none() {
           result.copy_from_slice(
               &Sha512::new()
                   .chain(&[SUITE, ONE])
                   .chain(self.as_bytes())
                   .chain(&alpha)
                   .chain(&[counter])
                   .result()[..32], //这里用的是sha512,但是只取了前半部分,因此是256位
           );
           wrapped_point = CompressedEdwardsY::from_slice(&result).decompress();
           counter += 1;
       }

       wrapped_point.unwrap().mul_by_cofactor()
   }
   ```


#### H2: 将一系列点 Hash为一个大整数

   这个就更简单了,将这些点序列化,然后Hash,就得到一个大整数. 只是需要注意的是这个大整数需要模上曲线的阶.

   ```rust
   pub(super) fn hash_points(points: &[EdwardsPoint]) -> ed25519_Scalar {
   let mut result = [0u8; 32];
   let mut hash = Sha512::new().chain(&[SUITE, TWO]);
   for point in points.iter() {
       hash = hash.chain(point.compress().to_bytes());
   }
   result[..16].copy_from_slice(&hash.result()[..16]);
   ed25519_Scalar::from_bits(result) //这里实际上对基点就是取模
   }
   ```



#### ECVRF_nonce_generation

   根据私钥和待签名信息导出一个确定的大整数.
   这里的nonce是从私钥推导出来的,h_point 则是下文中用到的H.

   ```rust
   pub(super) fn nonce_generation_bytes(nonce: [u8; 32], h_point: EdwardsPoint) -> [u8; 64] {
   let mut k_buf = [0u8; 64];
   k_buf.copy_from_slice(
       &Sha512::new()
           .chain(nonce)
           .chain(h_point.compress().as_bytes())
           .result()[..],
   ); //生成思路也很简单,就是Hash一下,就可以得到一个大整数
   k_buf
   }
   ```



#### 生成随机数以及证明

   $H=H1(α)$
   $k=ECVRF\_nonce\_generation(SK,H)$
   $Γ=H^x$
   $c=H2(H,Γ,B^k,H^k)$
   $s=k+cx$

   然后将 $Proof={Γ,c,s}$ 发给验证方.
   证明其实就是想证明我这里的 $Γ=H^x$ ,而不是通过什么其他方式得到的.

```rust
/// A longer private key which is slightly optimized for proof generation.
///
/// This is similar in structure to ed25519_dalek::ExpandedSecretKey. It can be produced from
/// a VRFPrivateKey.
pub struct VRFExpandedPrivateKey {
    pub(super) key: ed25519_Scalar,
    pub(super) nonce: [u8; 32],
}
/// Produces a proof for an input (using the expanded private key)
    pub fn prove(&self, pk: &VRFPublicKey, alpha: &[u8]) -> Proof {
        let h_point = pk.hash_to_curve(alpha);
        //k实际上是一个随机数,这里采用RFC6979中的规则是为了让每次生成的proof都完全一样,
        // 比特币以太坊签名中也是这么使用的. 但是如果你非要用一个随机数,别人也没办法,
        // 并且完全行得通
        let k_scalar =
            ed25519_Scalar::from_bytes_mod_order_wide(&nonce_generation_bytes(self.nonce, h_point));
        //nonce由私钥hash后生成,可以认为私钥确定了,nonce就确定了,而h_point和签名中的用法是一样的,
        // 就是待签名信息        因此原文中共识是这样的:k = ECVRF_nonce_generation(SK,
        // h_string)

        //Gamma = x*H
        let gamma = h_point * self.key;
        //        c = ECVRF_hash_points(H, Gamma, k*B, k*H)
        let c_scalar = hash_points(&[
            h_point,
            gamma,
            ED25519_BASEPOINT_POINT * k_scalar,
            h_point * k_scalar,
        ]);
        //s = (k + c*x) mod q
        //proof={gama,c,s}
        Proof {
            gamma, //这也是VRF生成的随机数
            c: c_scalar,
            s: k_scalar + c_scalar * self.key,
        }
    }
```

需要补充说明的是验证方不可能知道:

1). 私钥也就是x

2). k,这是证明方用ECVRF_nonce_generation生成的
   虽然随机数用 $Γ$ 也就是曲线上的一个点来表示,但是很容易通过Hash计算转换成一个大整数.


### 验证的过程

已知信息:

1). Y : 公钥

2). $α$ : VRF输入源

3). Proof : {$Γ$,$c$,$s$}



$$H=H1(α)$$

$$U=  \frac {B^s}{Y^c} $$
$$V= \frac {H^s}{Γ^c} $$
$$c′=H2(H,Γ,U,V)$$





**如果 $c'$ 和 $c$ 相等,则认可 $Γ$ 就是证明方按照规则生产的随机数.**

这里在计算 $c'$ 和证明方计算 $c$ 的过程不一样的对方只有两处:

1). 用 $U$ 来代替了 $Bk$

2). 用 $V$ 代替了 $Hk$


接下来我们要证明,两者都是相等的.

#### 证明 $U=B^k$



$$U=\frac {B^s}{Y^c}\\
=\frac {B^{k+cx}}{Y^c}\\
=\frac {B^{k+cx}}{B^{x^c}}\\
=\frac {B^{k+cx}}{B^{cx}}\\
=B^k$$




#### 证明 $V=H^k$



$$V=\frac {H^s}{Γ^c}
\\=\frac {H^{k+cx}}{Γ^c}
\\=\frac {H^{k+cx}}{H^{x^c}}
\\=\frac {H^{k+cx}}{H^{cx}}
\\=H^k$$




#### 实现过程

```rust
/// An ECVRF public key
#[derive(Serialize, Deserialize, Deref, Debug, PartialEq, Eq)]
pub struct VRFPublicKey(ed25519_PublicKey);
 /// Given a [`Proof`] and an input, returns whether or not the proof is valid for the input
    /// and public key
    pub fn verify(&self, proof: &Proof, alpha: &[u8]) -> Result<()> {
        //同样将已知的确定信息alpha映射到H点
        let h_point = self.hash_to_curve(alpha);
        //PK:是公钥
        let pk_point = CompressedEdwardsY::from_slice(self.as_bytes())
            .decompress()
            .unwrap();
        //c' = ECVRF_hash_points(H, Gamma, U, V)
        let cprime = hash_points(&[
            h_point,
            proof.gamma,
            ED25519_BASEPOINT_POINT * proof.s - pk_point * proof.c, //U=s*B - c*Y
            h_point * proof.s - proof.gamma * proof.c,              //V= s*H - c*Gamma
        ]);
        //相等则有效,不等则无效
        if proof.c == cprime {
            Ok(())
        } else {
            bail!("The proof failed to verify for this public key")
        }
    }
```


## 结束语

VRF是一个好东西,给区块链带来了可预测的伪随机性.
不过在Libra中号称自己使用了VRF,并且也在代码中看到了实现.就是没有找到使用的地方,可能是我的找法不对?
我看的代码版本是[commit-hash](https://github.com/libra/libra/tree/d324ce75cc9bcc6777a2b45c756f4df2f47c4ef3/crypto)

本文作者为深入浅出共建者：白振轩，[libra中的vrf](https://stevenbai.top/libra系列/9.libra中的vrf/)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。