---
title: 零知识证明-R1CS导入导出
permalink: zkp-R1CS
un_reward: true
date: 2019-12-06 09:41:41
categories: 零知识证明
tags:
    - 零知识证明
    - R1CS
author: Star Li
---
玩过zkSNARK的小伙伴都知道，R1CS是目前描述电路的一种语言。目前实现zkSNARK电路的框架有libsnark（C++），bellman (Rust)，ZoKrates（DSL），Circom（js）等等。有的时候，需要将一个框架中生成的电路，导入其他框架。网络上研究了一下，发现两个有意思的项目。

<!----more--->

## 01 J-R1CS

J-R1CS提出了一个[导出RICS的格式标准](https://www.sikoba.com/docs/SKOR_GD_R1CS_Format.pdf)。用一个json文件表述一个电路需要的所有信息。

一个电路的R1CS主要由三部分组成：

### 1）电路的属性描述

```js
{
"r1cs":{
      "version":"1.0",
      "field_characteristic":"133581199851807797997178235848527563401",
      "extension_degree":1,
      "instances":3,
      "witnesses":5,
      "constraints":2000,
      "optimized":true
} }
```

描述了J-R1CS的版本，椭圆曲线的属性，电路的公开/隐私输入的个数以及R1CS的约束个数。

### 2）输入描述

```js
{
  "inputs":["0","1","0","1","3","8", ...],
  "witnesses": ["1","1",,"243202698575991946913848952725080
  8343172040488935114927077578242952867610624", ...]
}
```

输入分成两种，一种是公开(public input)输入，一种是隐私(private input)输入。inputs代表公开输入，witnesses代表隐私输入。

### 3）约束描述

```js
{
 {
  "A": [[0,"2"],[-1,"6"],[5,"4"],....],
  "B": [[0,"5"],[-6,"3"],[3,"4"],....],
  "C": [[0,"3"],[-1,"2"],[-2,"7"],[3,"4"],[4,"1"]...]
  }
}
```

一个约束由A/B/C三个数组组成。每个数组中的元素是一个二元组：输入的index以及输入的系数。输入的index是负数的话，代表的是公开输入；输入的index是整数的话，代表的是隐私输入。

## 02 zkInterface

![zkInterface](https://img.learnblockchain.cn/2019/12/06/001.jpg)

zkInterface更进一步，提供了多种框架下的电路的转换。zkInterface作为“中间”接口，可以将"Frontend"的电路格式，[导出到"Backend"的证明框架中](https://github.com/QED-it/zkinterface)。

目前，zkInterface已经实现了如下的导入导出能力：

![导入导出能力](https://img.learnblockchain.cn/2019/12/06/002.jpg)

## 总结：

目前有一些零知识证明证明的框架，框架中的电路都由R1CS描述电路。J-R1CS提出了一种R1CS电路导出的格式。zkInterface更进一步，提供了多种框架下的电路的转换。


本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
