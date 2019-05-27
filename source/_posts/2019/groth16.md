---
title: 零知识证明 - Groth16算法介绍
permalink: groth16
un_reward: true
mathjax: true
hide_wechat_subscriber: true
date: 2019-05-27 15:10:54
categories: 基础理论
tags: 
    - 密码学
    - 零知识证明
    - Groth16
author: Star Li
---

看zk-SNARK的文章或者资料的时候，经常会碰到一些算法名称，比如Groth16，GGPR13等等。这些名称是由算法提出的作者名称或者名称首字母以及相应的年份组成。Groth16，是由Jens **Groth**在20**16**年提出的算法。GGPR13，是由Rosario **G**ennaro，Craig **G**entry，Bryan **P**arno，Mariana **R**aykova在20**13**年提出的算法。

零知识证明（[zk-SNARK](https://learnblockchain.cn/2019/04/18/learn-zkSNARK/) )，从[QSP/QAP](https://learnblockchain.cn/2019/05/07/qsp-qap/)到Groth16，期间也有很多学者专家，提出各种优化（优化计算时间，优化证明的大小，优化电路的尺寸等等）。Groth16提出的算法，具有非常少的证明数据（2/3个证明数据）以及一个表达式验证。

Groth16论文（On the Size of Pairing-based Non-interactive Arguments）可在[这里](https://eprint.iacr.org/2016/260.pdf)下载。

本文主要从工程应用理解的角度介绍Groth16算法的证明和验证过程。文章中所用的中文字眼可能和行业中不一样，欢迎批评指出。

<!-- more -->

## **术语介绍**

**Proofs** - 在零知识证明的场景下，Proofs指具有完美的完备性（Completeness）以及完美的可靠性（Soundness）。也就是，具有无限计算资源也无法攻破。

**Arguments** - 在零知识证明的场景下，Arguments是指具有完美的完备性以及多项式计算的可靠性。也就是，在多项式计算能力下，是可靠的。

**Schwartz-Zippel 定理** - 假设$f(x_1, x_2, ..., x_n)$是个n元多项式，多项式总的阶为d。如果$r_1, r_2, ..., r_n$是从有限集合S中随机选取，则$f(r_1, r_2, ..., r_n) = 0$的概率是小于等于$\frac{d}{|s|}$。简单的说，如果多元多项式，在很大的集合中随机选取参数，恰好函数f等于0的概率几乎为0。参见[Schwartz-Zippel 定理 Wiki](https://brilliant.org/wiki/schwartz-zippel-lemma/)

**线性（Linear）函数** - 假设函数f满足两个条件：**1.** $f(x+y) = f(x)+f(y)$ **2.** $f(\alpha x) = \alpha f(x)$，则称函数f为线性函数。

**Affine 函数** - 假设函数g，能找到一个线性函数f，满足$g(x) = f(x) + b$，则称函数g为Affine函数。也就是，Affine函数是由一个线性函数和偏移构成。

**Trapdoor函数** - 假设一个Trapdoor函数f，$x \to f(x)$ 很容易，但是$f(x) \to x$非常难。但是，如果提供一个secret，$f(x) \to x$也非常容易。

## **Jens Groth**是谁？

Groth是英国伦敦UCL大学的计算机系的教授。伦敦大学学院 (*University College London*），简称UCL，建校于1826年，位于英国伦敦，是一所世界著名的顶尖高等学府，为享有顶级声誉的综合研究型大学，伦敦大学联盟创始院校，英国金三角名校，与剑桥大学、牛津大学、帝国理工、伦敦政经学院并称G5超级精英大学。他的[介绍页
](http://www0.cs.ucl.ac.uk/staff/j.groth/)。

Groth从2009年开始，每年发表一篇或者多篇密码学或者零知识证明的文章，所以你经常会听到Groth09，Groth10等等算法。

简言之，牛人～。

## **NILP**

Groth16的论文先引出NILP（non-interactive linear proofs）的定义：

(1).  $(\sigma, \tau) \gets Setup(R)$ ：设置过程，生成$\sigma \in F^m$, $\tau \in F^n$。

(2).  $\pi \gets Prove(R, \sigma, \phi, \omega) $ ：证明过程，证明过程又分成两步：a. 生成线性关系$\Pi \gets ProofMatrix(R, \phi, \omega)$，其中ProofMatrix是个多项式算法。b. 生成证明：$\pi = \Pi\sigma$。

(3).  $0/1 \gets Vfy(R, \sigma, \phi, \pi) $ ：验证过程，验证者使用$(R, \phi)$生成电路t，并验证$t(\sigma, \pi)$是否成立。

在`NILP`定义的基础上，Groth16进一步定义了split NILP，也就是说，CRS分成两部分$(\sigma1, \sigma2)$，证明者提交的证明也分成两部分$(\pi1, \pi2)$。

总的来说，核心在“Linear”上，证明者生成的证明和CRS成线性关系。

## **QAP的NILP**

QAP的定义为"**R**elation"：$$R=(F, aux, \ell, \{u_i(X), v_i(X), w_i(X)\}_{i=0}^m, t(X))$$。也就是说，statements为$$(a_1, ..., a_\ell) \in F^\ell$$， witness为$(a_{l+1}, ..., a_m) \in F^{m-\ell}$，并且$a_0 = 1$的情况下，满足如下的等式：

$$\sum_{i=0}^m a_iu_i(X) \cdot \sum_{i=0}^m a_iv_i(X) = \sum_{i=0}^m {a_iw_i(X)+h(X)t(X)}$$

$t(X)$的阶为n。

(1). 设置过程：随机选取$\alpha, \beta, \gamma, \delta, x \gets F^*$，生成$\sigma, \tau$。

   $$\tau = (\alpha, \beta, \gamma, \delta, x)$$

   $$\sigma = (\alpha, \beta, \gamma, \delta, \{x^i\}_{i=0}^{n-1}, \{\cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma}\}_{i=0}^\ell, \{\cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta}\}_{i=\ell+1}^m, \{\cfrac{x^it(x)}{\delta}\}_{i=0}^{n-2})$$

(2).  证明过程：随机选择两个参数$r和s$，计算$\pi = \Pi\sigma = (A, B, C)$

   $$A = \alpha + \sum_{i=0}^{m} a_i u_i(x) + r\delta$$

  $$B = \beta + \sum_{i=0}^{m} a_i v_i(x) + s\delta$$

   $$C = \cfrac{\sum_{i=\ell+1}^m a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))+h(x)t(x)}{\delta} + As + r B - r s \delta$$

(3). 验证过程：

   验证过程，计算如下的等式是否成立：

   $$A\cdot B = \alpha \cdot \beta + \cfrac{\sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))}{\gamma} \cdot \gamma + C \cdot \delta$$

注意，设置过程中的x是一个值，不是代表多项式。在理解证明/验证过程的时候，必须要明确，A/B/C的计算是和CRS中的参数成线性关系（NILP的定义）。在明确这一点的基础上，可以看出$\alpha和 \beta$的参数能保证A/B/C的计算采用统一的$$a_0, a_1, ... , a_m$$ 参数。因为$$A\cdot B$$会包含$$\sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x))$$子项，要保证$$A\cdot B$$和C相等，必须采用统一的$$a_0, a_1, ... , a_m$$参数。参数$r和s$增加随机因子，保证零知识（验证者无法从证明中获取有用信息）。参数$\gamma和\delta$保证了验证等式的最后两个乘积独立于$\alpha和 \beta$的参数。

### **完备性证明（Completeness)：**
完备性证明，也就是验证等式成立。

$$A\cdot B = (\alpha + \sum_{i=0}^{m} a_i u_i(x) + r\delta) \cdot (\beta + \sum_{i=0}^{m} a_i v_i(x) + s\delta) $$

$$= \alpha \cdot \beta + \alpha \cdot \sum_{i=0}^{m} a_i v_i(x) + \alpha s \delta$$
$$ + \beta \cdot \sum_{i=0}^{m} a_i u_i(x) + \sum_{i=0}^{m} a_i u_i(x) \cdot \sum_{i=0}^{m} a_i v_i(x) + s\delta \cdot \sum_{i=0}^{m} a_i u_i(x)$$
$$ + r\delta \beta + r\delta \sum_{i=0}^{m} a_i v_i(x) + rs\delta^2$$

$$ = \alpha \cdot \beta + \sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x)) + \sum_{i=\ell + 1}^m a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x)) + h(t)\cdot t(x) $$

$$+  \alpha s \delta + s\delta \cdot \sum_{i=0}^{m} a_i u_i(x) + r s \delta^2$$

$$ + r\delta \beta + r\delta \sum_{i=0}^{m} a_i v_i(x) +  r s \delta^2$$

$$  - r s \delta^2 $$

$$ = \alpha \cdot \beta + \sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x)) + \sum_{i=\ell + 1}^m a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x)) + h(t)\cdot t(x) $$

$$+ A s \delta + r B \delta - r s \delta^2$$

$$ = \alpha \cdot \beta + \cfrac{\sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))}{\gamma} \cdot \gamma + C \cdot \delta $$

### **可靠性证明 (Soundness):**

Groth16算法证明的是**statistical knowledge soundness**，假设证明者提供的证明和CRS成**线性**关系。也就是说，证明A可以用如下的表达式表达(A和CRS的各个参数成线性关系）：

$$A = A_\alpha \alpha + A_\beta \beta + A_\gamma \gamma + A_\delta \delta + A(x) + \sum_{i=0}^{\ell} A_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} + \sum_{i=\ell + 1}^{m} A_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + A_h(x)\cfrac{t(x)}{\delta}$$

同理，B/C都可以写成类似的表达：

$$B = B_\alpha \alpha + B_\beta \beta + B_\gamma \gamma + B_\delta \delta + B(x) + \sum_{i=0}^{\ell} B_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} + \sum_{i=\ell + 1}^{m} B_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + B_h(x)\cfrac{t(x)}{\delta}$$

$$C = C_\alpha \alpha + C_\beta \beta + C_\gamma \gamma + C_\delta \delta + C(x) + \sum_{i=0}^{\ell} C_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} + \sum_{i=\ell + 1}^{m} C_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + C_h(x)\cfrac{t(x)}{\delta}$$

从Schwartz-Zippel 定理，我们可以把A/B/C看作是$\alpha, \beta, \gamma, \delta, x$的多项式。观察$A\cdot B = \alpha \cdot \beta + \cfrac{\sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))}{\gamma} \cdot \gamma + C \cdot \delta$ 这个验证等式，发现一些变量的限制条件：

1） $$A_\alpha B_\alpha \alpha^2 = 0$$ (等式的右边没有$$\alpha^2因子$$)

不失一般性，可以假设$B_\alpha = 0$。

2） $$A_\alpha B_\beta + A_\beta B_\alpha = A_\alpha B_\beta = 1$$ （等式右边$$\alpha \beta = 1$$）

不失一般性，可以假设$$A_\alpha = B_\beta = 1$$。

3） $$A_\beta B_\beta = A_\beta = 0 $$(等式的右边没有$\beta^2$因子)

也就是$A_\beta = 0$。

在上述三个约束下，A/B的表达式变成：

$$A = \alpha + A_\gamma \gamma + A_\delta \delta + A(x) + \sum_{i=0}^{\ell} A_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} + \sum_{i=\ell + 1}^{m} A_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + A_h(x)\cfrac{t(x)}{\delta}$$

$$B = \beta + B_\gamma \gamma + B_\delta \delta + B(x) + \sum_{i=0}^{\ell} B_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} + \sum_{i=\ell + 1}^{m} B_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + B_h(x)\cfrac{t(x)}{\delta}$$

4）等式的右边没有$\cfrac{1}{\delta^2}$

$$(\sum_{i=\ell+1}^m A_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) + A_h(x)t(x))(\sum_{i=\ell+1}^m B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) + A_h(x)t(x)) = 0$$

不失一般性，$\sum_{i=\ell+1}^m A_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) + A_h(x)t(x) = 0$

5）等式的右边没有$\cfrac{1}{\gamma^2}$

$$(\sum_{i=0}^\ell A_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)))(\sum_{i=0}^\ell B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x))) = 0$$

不失一般性，$\sum_{i=0}^\ell A_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) = 0$。

6）等式的右边没有$\cfrac{\alpha}{\gamma}$， $\cfrac{\alpha}{\delta}$

$$\alpha \cfrac{\sum_{i=0}^\ell B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x))}{\gamma} = 0$$

$$\alpha \cfrac{\sum_{i=\ell+1}^m B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) + B_h(x)t(x)}{\delta} = 0$$

所以，$$\sum_{i=0}^\ell B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) = 0，\sum_{i=\ell+1}^m B_i(\beta u_i(x) + \alpha v_i(x) + w_i(x)) + B_h(x)t(x)$$ 。 

7）等式的右边没有$\beta \gamma$和$\alpha\gamma$

$$A_\gamma \beta \gamma = 0, B_\gamma \alpha \gamma = 0$$

所以，$$A_\gamma =0, B_\gamma = 0$$。

在上述七个约束下，A/B的表达式变成：

$A = \alpha + A_\delta \delta + A(x) $

$B = \beta + B_\delta \delta + B(x)$

再看验证的等式：

$A\cdot B = \alpha \cdot \beta + \cfrac{\sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))}{\gamma} \cdot \gamma + C \cdot \delta$

$= \alpha \cdot \beta + \sum_{i=0}^\ell a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x)) + C \cdot \delta$

观察$C \cdot \delta$，因为不存在 $\cfrac{\delta}{\gamma}$，所以，$\sum_{i=0}^{\ell} C_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma} = 0$。

也就是说，$$C = C_\alpha \alpha + C_\beta \beta + C_\gamma \gamma + C_\delta \delta + C(x) + \sum_{i=\ell + 1}^{m} C_i \cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\delta} + C_h(x)\cfrac{t(x)}{\delta}$$。

代入验证等式，所以可以推导出：

$$\alpha B(x) = \sum_{i=0}^\ell a_i \alpha v_i(x)  + \sum_{i=\ell+1}^m C_i \alpha v_i(x) $$，

$$\beta A(x) = \sum_{i=0}^\ell a_i \beta u_i(x)  + \sum_{i=\ell+1}^m C_i \beta u_i(x) $$

如果，假设，对于$i=\ell+1, ... , m，a_i = C_i$，则

$A(x) = \sum_{i=0}^m a_i u_i(x)$

$B(x) = \sum_{i=0}^m a_i v_i(x)$

代入A/B，可以获取以下等式：

$$\sum_{i=0}^ma_i u_i(x) \cdot \sum_{i=0}^ma_i v_i(x) = \sum_{i=0}^ma_i w_i(x) + C_h(x)t(x)$$

在证明和CRS线性关系下，所有能使验证等式成立的情况下，$(a_{\ell+1}, ... , a_m) = (C_{\ell+1}, ... , C_m)$等式必须成立。也就说，能提供正确证明的，肯定知道witness。

## **QAP的NIZK Arguments**

从QAP的NILP可以演化为QAP的NIZK Arguments。也就是说Groth16算法并不是完美的可靠，而是多项式计算情况下可靠。QAP的定义为"**R**elation"：$$R=(p, G_1, G_2, G_T, e, g, h, \ell, \{u_i(X), v_i(X), w_i(X)\}_{i=0}^m, t(X))$$。也就是说，在一个域$$Z_p$$中，statements为$$(a_1, ..., a_\ell) \in Z_p^\ell$$， witness为$$(a_{l+1}, ..., a_m) \in Z_p^{m-\ell}$$，并且$a_0 = 1$的情况下，满足如下的等式（$t(X)$的阶为n）：

$$\sum_{i=0}^m a_iu_i(X) \cdot \sum_{i=0}^m a_iv_i(X) = \sum_{i=0}^m {a_iw_i(X)+h(X)t(X)}$$

也就是说，三个有限群$G_1, G_2, G_T$, 对应的生成元分别是$g, h, e(g,h)$。为了方便起见，也为了和论文的表达方式一致，$G_1有限群$的计算用$[y]_1 = g^y$表示，$G_2有限群$的计算用$[y]_2 = h^y$表示。

1). 设置过程：随机选取$\alpha, \beta, \gamma, \delta, x \gets Z_p^*$，生成$\sigma, \tau$。

   $$\tau = (\alpha, \beta, \gamma, \delta, x)$$

   $$\sigma = ([\sigma_1]_1, [\sigma_2]_2)$$

   $$\sigma_1 = (\alpha, \beta, \delta, \{ x^i \}_{i=0}^{n-1}, \{\cfrac{\beta u_i(x)+\alpha v_i(x) + w_i(x)}{\gamma}\}_{i=0}^{\ell}, \{\cfrac{\beta u_i(x) + \alpha v_i(x) +  w_i(x)}{\delta}\}_{i=\ell+1}^{m}, \{\cfrac{x^it(x)}{\delta}\}_{i=0}^{n-2})$$

  $$\sigma_2 = (\beta, \gamma, \delta, \{x^i\}_{i=0}^{n-1})$$

2). 证明过程：随机选择两个参数$r和s$，计算$\pi = \Pi\sigma = ([A]_1, [C]_1, [B]_2)$

   $A = \alpha + \sum_{i=0}^{m} a_i u_i(x) + r\delta$

   $B = \beta + \sum_{i=0}^{m} a_i v_i(x) + s\delta$

   $C = \cfrac{\sum_{i=\ell+1}^m a_i (\beta u_i(x)+\alpha v_i(x)+w_i(x))+h(x)t(x)}{\delta} + As + r B - r s \delta$

3). 验证过程：验证如下的等式是否成立。

   $$[A]_1\cdot [B]_2 = [\alpha]_1 \cdot [\beta]_2 + \sum_{i=0}^\ell a_i [\cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma}]_1 \cdot [\gamma]_2 + [C]_1 \cdot [\delta]_2$$

很容易发现，验证过程的等式也可以用4个配对函数表示:

​	$$e([A]_1,  [B]_2) = e([\alpha]_1, [\beta]_2) \cdot e(\sum_{i=0}^\ell a_i [\cfrac{\beta u_i(x)+\alpha v_i(x)+w_i(x)}{\gamma}]_1, [\gamma]_2) \cdot e([C]_1, [\delta]_2)$$

证明过程和QAP的NILP的证明过程类似，不再详细展开。

## **证明元素的最小个数**

论文指出zk-SNARK的最少的证明元素是**2个**。上述的证明方式是需要提供3个证明元素（A/B/C）。论文进一步说明，如果将电路进行一定方式的改造，使用同样的理论，可以降低证明元素为2个，但是，电路的大小会变的很大。

## **总结**：
Groth16算法是Jens Groth在2016年发表的算法。该算法的优点是提供的证明元素个数少（只需要3个），验证等式简单，保证完整性和多项式计算能力下的可靠性。Groth16算法论文同时指出，zk-SNARK算法需要的最少的证明元素为2个。目前Groth16算法已经被ZCash，Filecoin等项目使用。

**题外：**

最近好多朋友表示对零知识证明的基础知识感兴趣，但是，zk-SNARK相关的技术涉及到比较多的数学公式的推导，比较难理解。我打算有空录个QSP/QAP/Groth16的介绍视频，方便工程开发人员快速的入门和理解。觉得有需要的小伙伴，大家可扫描以下二维码关注我的公众号-星想法留言“零知识证明”。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

本文作者 Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。

