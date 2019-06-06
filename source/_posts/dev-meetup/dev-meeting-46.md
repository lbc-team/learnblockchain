---
title: 技术工坊46期 - 椭圆曲线密码学简介
permalink: dev-meeting-46
date: 2019-06-06 10:47:23
categories: 技术工坊
tags: 密码学
author: 辉哥
---

技术工坊46期 - 椭圆曲线密码学简介
<!-- more -->


# 1. 活动基本信息
**1）题目：**
  【区块链技术工坊46期】椭圆曲线密码学简介

**2）议题：**
目前区块链项目如火如荼，几乎所有的区块链都会用到钱包，我们也经常听说椭圆曲线这个密码学术语，那么它们之间有没有什么关系？“加密货币”，到底是不是加了密的货币？为什么***和以太坊等众多区块链项目选用的是椭圆曲线而不是RSA？大名鼎鼎的Sony PS3上的私钥是如何被盗的？请报名者带好笔记本电脑，且看PPIO区块链开发工程师蒋鑫的技术分享。

**议题纲要：**
1）椭圆曲线的重要性
2）RSA算法回顾
3）群论
4）椭圆曲线上加法的定义
5）基于椭圆曲线的签名和验签
6）安全性问题
7）ECC与RSA的比较


**3）嘉宾：**

![](https://img.learnblockchain.cn/2019/06/15598033481082.png)


**蒋鑫**，PPIO区块链高级开发工程师，7年安卓系统开发经验，2年安全开发经验，1年区块链开发经验，南京大学硕士毕业。曾组织“安卓安全小分队(ASS)”发现第二个Android Master Key漏洞。

**4）活动定位**
区块链技术工坊系列活动，由HiBlock，下笔有神科技，兄弟区块链，HPB芯链，墨客联合主办，聚焦于深度分享区块链知识，实现小会技术交友。

区块链技术工坊一直以来坚持4F原则：
* Frency - 每周三晚上一次；
* Focus - 聚焦区块链技术分享；
* Fun - 20人以内会前做自我介绍，分享有深度的技术内容，技术交友；
* Feedback - 会后有活动实录文章和合影照片，深度对接业务交流；

通过技术工坊，连接了广大区块链项目和开发者，搭建了技术交友和知识传播的平台。

# 2.会议实录

![](https://img.learnblockchain.cn/2019/06/15598033682444.png)
![](https://img.learnblockchain.cn/2019/06/15598033931692.png)
![](https://img.learnblockchain.cn/2019/06/15598034006336.png)

## RSA加密算法
**RSA加密算法**是一种非对称加密算法。在公开密钥加密和电子商业中RSA被广泛使用。[RSA](https://learnblockchain.cn/2017/11/15/asy-encryption/)是1977年由罗纳德·李维斯特（Ron Rivest）、阿迪·萨莫尔（Adi Shamir）和伦纳德·阿德曼（Leonard Adleman）一起提出的。当时他们三人都在麻省理工学院工作。RSA就是他们三人姓氏开头字母拼在一起组成的。

RSA公开密钥密码体制。所谓的公开密钥密码体制就是使用不同的加密密钥与解密密钥，是一种“由已知加密密钥推导出解密密钥在计算上是不可行的”密码体制。

在公开密钥密码体制中，加密密钥（即公开密钥）PK是公开信息，而解密密钥（即秘密密钥）SK是需要保密的。加密算法E和解密算法D也都是公开的。虽然解密密钥SK是由公开密钥PK决定的，由于无法计算出大数n的欧拉函数phi(N)，所以不能根据PK计算出SK。

正是基于这种理论，1978年出现了著名的RSA算法，它通常是先生成一对RSA 密钥，其中之一是保密密钥，由用户保存；另一个为公开密钥，可对外公开，甚至可在网络服务器中注册。为提高保密强度，RSA密钥至少为500位长，一般推荐使用1024位。这就使加密的计算量很大。为减少计算量，在传送信息时，常采用传统加密方法与公开密钥加密方法相结合的方式，即信息采用改进的DES或IDEA密钥加密，然后使用RSA密钥加密对话密钥和信息摘要。对方收到信息后，用不同的密钥解密并可核对信息摘要。

RSA算法是第一个能同时用于加密和数字签名的算法，也易于理解和操作。RSA是被研究得最广泛的公钥算法，从提出到现今的三十多年里，经历了各种攻击的考验，逐渐为人们接受，截止2017年被普遍认为是最优秀的公钥方案之一。
SET(Secure Electronic Transaction)协议中要求CA采用2048bits长的密钥，其他实体使用1024比特的密钥。RSA密钥长度随着保密级别提高，增加很快。下表列出了对同一安全级别所对应的密钥长度。

![](https://img.learnblockchain.cn/2019/06/15598035829259.png)

![](https://img.learnblockchain.cn/2019/06/15598035994862.png)


**一、ECDSA概述**

椭圆曲线数字签名算法（ECDSA）是使用椭圆曲线密码（ECC）对数字签名算法（DSA）的模拟。ECDSA于1999年成为ANSI标准，并于2000年成为IEEE和NIST标准。

它在1998年既已为ISO所接受，并且包含它的其他一些标准亦在ISO的考虑之中。与普通的离散对数问题（discrete logarithm problem DLP）和大数分解问题（integer factorization problem IFP）不同，椭圆曲线离散对数问题（elliptic curve discrete logarithm problem ECDLP）没有亚指数时间的解决方法。因此椭圆曲线密码的单位比特强度要高于其他公钥体制。

[数字签名算法](http://www.shsxt.com/it/html5/653.html)（DSA）在联邦信息处理标准FIPS中有详细论述，称为数字签名标准。它的安全性基于素域上的离散对数问题。椭圆曲线密码（ECC）由Neal Koblitz和Victor Miller于1985年发明。它可以看作是椭圆曲线对先前基于离散对数问题（DLP）的密码系统的模拟，只是群元素由素域中的元素数换为有限域上的椭圆曲线上的点。

椭圆曲线密码体制的安全性基于椭圆曲线离散对数问题（ECDLP）的难解性。椭圆曲线离散对数问题远难于离散对数问题，椭圆曲线密码系统的单位比特强度要远高于传统的离散对数系统。因此在使用较短的密钥的情况下，ECC可以达到于DL系统相同的安全级别。这带来的好处就是计算参数更小，密钥更短，运算速度更快，签名也更加短小。因此椭圆曲线密码尤其适用于处理能力、存储空间、带宽及功耗受限的场合。

**二、ECDSA原理**
ECDSA是ECC与DSA的结合，整个签名过程与DSA类似，所不一样的是签名中采取的算法为ECC，最后签名出来的值也是分为r,s。

签名过程如下：
1、选择一条椭圆曲线Ep(a,b)，和基点G；
2、选择私有密钥k（k<n，n为G的阶），利用基点G计算公开密钥K=kG；
3、产生一个随机整数r（r<n），计算点R=rG；
4、将原数据和点R的坐标值x,y作为参数，计算SHA1做为hash，即Hash=SHA1(原数据,x,y)；
5、计算s≡r - Hash * k (mod n)
6、r和s做为签名值，如果r和s其中一个为0，重新从第3步开始执行

验证过程如下：
1、接受方在收到消息(m)和签名值(r,s)后，进行以下运算
2、计算：sG+H(m)P=(x1,y1), r1≡ x1 mod p。
3、验证等式：r1 ≡ r mod p。
4、如果等式成立，接受签名，否则签名无效。

![](https://img.learnblockchain.cn/2019/06/06_tmp/98498081.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/19727887.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/27131847.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/39984059.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/11902081.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/74941318.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/40954425.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/36122540.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/8240456.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/46203300.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/6410694.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/47278511.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/60128162.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/17455089.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/83024728.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/6933274.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/7811211.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/29431445.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/58323237.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/69339106.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/36340495.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/74965466.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/25511528.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/52186258.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/29458047.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/37979947.png)

**1. 密码强度比较**
Symmetric | ECC | RSA | 
:- | :-: | :-:
80	 | 163 | 	1024
112	 | 233 | 	2240
128 | 	283	 | 3072
192 | 	409	 | 7680

这是学术界普遍认可的密码强度对照表。比如，3072-bit的RSA密码强度，大约相当于283-bit的ECC密码强度，大约相当于128-bit的对称密码算法的强度。换句话说，攻击分组加密算法AES-128的难度，与攻击数字签名RSA-3072的难度相当。此外，我们应注意到，从RSA-1024到RSA-3072，模数长度增长了200%，但密码强度仅增强了50%左右；拿密码哈希函数来比较，这个安全强度的增长只是相当于从SHA1增强到SHA-256。

**2. 性能比较**

笔者基于开源的tommathlib实现了ECDSA（符合ANSI X9.62标准）和RSA签名算法（符合PKCS#1 v2.1, e=65537）。

  _  |Verify | Sign| 
:- | :-: | :-:
RSA-1024	 | 12 us | 	511 us
RSA-2048	 | 30 us | 	3270 us
ECDSA-192 | 	590 us	 | 490 us

表中数据是笔者基于自己的开发机器（Intel Xeon CPU E5520  @ 2.27GHz）上单线程运行得出的实验结果。对于ECDSA来说，生成签名与验证签名的开销相差不大，而对于RSA来说，验证签名比生成签名要高效得多，这是因为RSA可以选用小公钥指数，比如{3, 5, 17, 257 or 65537}，而安全强度不变。如果只看单次操作，那么ECDSA的Sign操作比RSA的性能更好，而RSA的Verify要比ECDSA更好。

**3. 结论**
(1) RSA签名算法适合于：Verify操作频度高，而Sign操作频度低的应用场景。比如，分布式系统中基于capability的访问控制就是这样的一种场景。
(2) ECDSA签名算法适合于：Sign和Verify操作频度相当的应用场景。比如，点对点的安全信道建立。


![](https://img.learnblockchain.cn/2019/06/06_tmp/16138287.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/43632888.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/58292790.png)

![](https://img.learnblockchain.cn/2019/06/06_tmp/96193015.png)


![](https://img.learnblockchain.cn/2019/06/15598039378158.png)

![](https://img.learnblockchain.cn/2019/06/15598039309780.png)


蒋鑫老师发布了一个ecc加密算法的样例，其中部分内容标识为//TODO的是需要联系者补充，以验证你对ECC的理解。如果需要答案或者与蒋鑫老师交流，请扫描二维码加群沟通。
[源码地址](https://github.com/PPIO/ppio-blockchain-code-talks) 


![](https://img.learnblockchain.cn/2019/06/15598039225841.png)

*本次实录纪要由辉哥(王登辉，下笔有神区块链 CTO 王登辉，HiBlock上海合伙人)整理记录，转发务必注明出处及本段信息。*

**现场活动合影照片：**

![](https://img.learnblockchain.cn/2019/06/15598039079586.png)



*坐席左一女生为neutrino社区主管刘怡女士，坐席左二为本次分享嘉宾蒋鑫老师。*

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。