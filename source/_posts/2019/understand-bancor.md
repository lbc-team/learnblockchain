---
title: 深入浅出Bancor协议
permalink: understand-bancor
un_reward: true
hide_wechat_subscriber: true
date: 2019-04-15 15:36:54
categories: DeFi
tags: 
  - Bancor
  - DeFi
author: Star Li
---


Bancor协议是为了降低币币交易的门槛，形成Token经济中的Token交易的长尾效应。目前大量的市值相对小的Token没能在交易所上交易，Bancor协议在有一定“抵押物”的情况下，实现Token和“抵押物”的自由交易。进一步，所有通过Bancor协议实现交易的Token又能聚集在一起形成Bancor生态。举个例子，一个TokenA，一个TokenB都是以以太进行抵押，通过Bancor都能实现TokenA和ETH，TokenB和ETH的交易，逻辑上也就实现了TokenA和TokenB的交易。Bancor协议，取名Bancor，是为了纪念宏观经济经济学之父 - 约翰·梅纳德·凯恩斯。

<!-- more -->

## Bancor名字历史

英国经济学家约翰·梅纳德 ·凯恩斯于1944年在美国新罕布什尔州的布雷顿森林举行联合国货币金融会议上提出Bancor计划。其目的是为维持和延续英镑的国际地位，削弱美元的影响力，并与美国分享国际金融领导权。由于历经二战的英国经济军事实力严重衰退，而英国最有力的竞争对手美国实力空前膨胀，最终凯恩斯计划在美国提出的怀特计划面前流产。凯恩斯提出的这套世界货币方案中，由国际清算同盟发行统一的世界货币（**Bancor Coin**），货币的分配份额按照二战前三年的进出口贸易平均值计算。

凯恩斯是何许人也？

约翰·梅纳德·凯恩斯（John Maynard Keynes，1883年6月5日—1946年4月21日），英国经济学家，现代经济学最有影响的经济学家之一。他创立的宏观经济学与弗洛伊德所创的精神分析法和爱因斯坦发现的相对论一起并称为二十世纪人类知识界的三大革命。

凯恩斯开创了经济学的“凯恩斯革命”，被后人称为“**宏观经济学之父**”。

## Bancor协议白皮书


Bancor协议白皮书[可点击下载](https://storage.googleapis.com/website-bancor/2018/04/01ba8253-bancor_protocol_whitepaper_en.pdf)。

Bancor协议在以太坊上的智能合约代码：[GitHub](https://github.com/bancorprotocol/)。

Bancor协议是想在智能合约的基础上实现具有去中心化流通性的Token交易网络。Bancor协议要求每个Token都需要提供“储备金”，储备金的比例每个Token自行定义（0～100%）。因为“储备金”的存在，每个Token天生通过Bancor协议可以交易，也就天生具备了去中心化流通性。使用Bancor协议进行交易的Token，Bancor协议称为“Smart Token”（智能Token）。

看懂Bancor协议，只要看懂三个公式。

###  Bancor术语

* **流通性**（Liquidity）- Token之间流通能力，称为流通性。
* **长尾效应**（Long Tail Phenomenon）- 目前所有代币中的前10%的代币占了数字货币市值的95%，也占了交易总量的99%。而在传统的互联网行业中，存在长尾效应，也就是说，“小交易量“总共会占总交易量的30～40%。以亚马逊买的书为例，销售量很小的各种书籍加起来会占总销售量的30～40%。长尾效应的形成是因为进入的门槛变低了。比如说，Youtube上能很方便的上传视频。Bancor协议就是想降低交易Token的门槛，产生长尾效应。
* **智能Token**（Smart Token）- 使用Bancor协议创建的能直接交易的Token称为智能Token。
* **储备金**（Connector）-  每个Smart Token可以指定一种或者多种储备金。
* **储备金比例** （Connector Weight）- 储备金比例在创建Smart Token设定并固定。储备金比例，简称CW。

### 公式1 - 储备金比例计算

Bancor协议要求在创建Smart Token的时候必须提供储备金，储备金比例的计算公式如下：

![](https://img.learnblockchain.cn/2019/15553147507540.jpg)

也就是说，储备金比例（CW）等于储备金的价值除以Smart Token的预期价值。比如说，创建一个Smart Token，名叫STAR，初始总量1000万，提供储备金为[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)10000个。预期一个STAR币的初始价格是0.002个以太，

                    CW = 10000/（0.002*1000*10000） = 0.5

### 公式2 - 价格计算

在知道储备金比例的前提下，用户可以通过Bancor协议买卖Smart Token。每次买卖时，价格的计算公式如下：
![价格的计算公式](https://img.learnblockchain.cn/2019/15553147727085.jpg)


当前的价格等于当前的储备金数量除以储备金比例，再除以当前的Smart Token的流通量。还以2.2中讲的STAR币为例，初始时STAR币的总流通量是1000万。如果这时需要买入STAR币，价格是：

                    price = 10000/（0.5*1000*10000） = 0.002

也就是说，买入100万个STAR币，需要支付20000个以太（近似，后面会讲滑价）。买入后的价格变化为：

	price = （10000+20000）/（0.5*（1000+100）*10000） = 0.0054

也就是说，买入100万个STAR币后，价格从0.002涨到了0.0054。

### 公式3 - 价格滑价处理

用户在每次买卖Smart Token后，价格都会变化。如果只是用2.3中介绍的价格计算公式，用户一次买卖和分几笔小交易买卖的价格不同。Bancor协议进一步定义公式处理滑价问题。买入时，Smart Token的发行计算公式如下：

![](https://img.learnblockchain.cn/2019/15553148085508.jpg)

卖出时，储备金的数量计算公式如下：

![](https://img.learnblockchain.cn/2019/15553148418166.jpg)

那一次交易过程中的真实的价格是：

![](https://img.learnblockchain.cn/2019/15553148557229.jpg)

也就是，真实的价格等于上面两个公式计算的真实的储备金数量变化除以真实的Smart Token的数量变化。

再举个例子：假设当前一个Smart Token的流通量为1000，储备金的数量为250，储备金比例为50%。也就是说当前的价格是：

        price = 250/（1000*0.5） = 0.5

一个用户买入10个储备金，该用户收到的Smart Token的数量为：

也就是，真实的价格等于上面两个公式计算的真实的储备金数量变化除以真实的Smart Token的数量变化。

再举个例子：假设当前一个Smart Token的流通量为1000，储备金的数量为250，储备金比例为50%。也就是说当前的价格是：

        price = 250/（1000*0.5） = 0.5

一个用户买入10个储备金，该用户收到的Smart Token的数量为：

![](https://img.learnblockchain.cn/2019/15553148829701.jpg)

也就是说，真实的交易价格为：

	price = 10/19.8 = 0.5051


## 深入理解Bancor协议

储备金比例是Bancor协议中比较重要的参数，体现了Smart Token的储备水平。储备金比例高，价格的波动就低；储备金比例低，价格的波动就高。白皮书中的四张图给出了四个比较典型的储备金比例情况下的，价格波动曲线（Smart Token初始流通量为1000，价格为1）。

CW=100%的情况，储备金和Smart Token的价值相当，Smart Token的价格恒定为1。也就是，在储备金和Smart Token的价值相当的情况下，不论Smart Token的流通量如何变化，Smart Token的价格不变。有多少Smart Token，就有多少储备金。

![](https://img.learnblockchain.cn/2019/15553149064731.jpg!/scale/60%
)

CW=50%的情况下，储备金的价值是Smart Token价值的一半，买卖的价格和流通量成线性增长。

![](https://img.learnblockchain.cn/2019/15553149186334.jpg!/scale/60%)

CW=10%的情况下，储备金只有Smart Token价值的10%，买卖的价格指数级增长。买卖后，储备金的数量相对来说急剧上升，导致下一次价格进一步扩大。

![](https://img.learnblockchain.cn/2019/15553149306805.jpg!/scale/60%)

CW=90%的情况下，储备金是Smart Token价值的90%，买卖的价格缓慢的增长。

![](https://img.learnblockchain.cn/2019/15553149483999.jpg!/scale/60%)

现实中，往往是很容易先画出价格曲线，然后再利用Bancor协议，求解出储备金比例CW。在已知价格曲线的情况下，求解CW的方法如下图所示（以CW=10%的价格曲线为例）：

![求解CW的方法图](https://img.learnblockchain.cn/2019/15553149606674.jpg!/scale/70%)


也就是说，CW = 价格曲线下面的面积/价格曲线所在的矩形。

**总结**：Bancor协议是为了降低币币交易的门槛，形成Token经济中的Token交易的长尾效应。Bancor协议，取名Bancor，是为了纪念宏观经济经济学之父 - 约翰·梅纳德·凯恩斯。Bancor协议在一定储备金的前提下，实现Smart Token的交易。储备金比例不同，Smart Token交易的价格曲线也不同。储备金比例越高，价格曲线越平坦，储备金比例越低，价格曲线越陡峭。在已知某一价格曲线的情况下，用曲线下方的面积除以整个矩形面积即可求出储备金比例CW。


本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)


[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。


