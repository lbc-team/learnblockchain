---
title: 关于形式化验证两大工具(Vass & Mythril) 测试对比
permalink: VaasMythril
un_reward: true
date: 2019-10-15 09:44:33
categories: 区块链安全
tags: 形式化验证
author: Beosin 成都链安
---


随着以**智能合约（Smart Contract）及区块链应用（DApp）**为核心的区块链2.0时代逐渐成为主流，智能合约及区块链应用的安全性也越发成为业界备受关注的焦点。尤其是，在经历过诸如**THE DAO、币安被盗**等事件，智能合约及区块链应用的安全性究竟应该如何得到验证和保障，业已成为当前区块链业界亟待解决的痛点。

<!-- more -->

笔者作过简单统计，自17年9月到18年9月期间，智能合约及区块链应用的相关漏洞**呈频繁爆发的模式增长**，并且所造成的后果都是影响深远的。不仅直接造成了巨额的金额损失；从长远发展角度上来看，更是影响到区块链这项新兴技术在未来的可持续发展。

另外，尽管当前智能合约及区块链应用的潜在漏洞并未得到妥善解决，可现状却是，智能合约及区块链应用的数量每天仍在以万计的平均增长率飞速提升。

**不难看出，智能合约及区块链应用的增长率和安全性，正在以一种不太“健康”的关系并存。**如果我们以供求关系来作类比（增长率为“供”；安全性为“求”），当下智能合约及区块链应用的普遍现状即是 **"供不应求"**的状态。

**基于此，如何保证海量智能合约及区块链应用的安全，已成为区块链行业内具备前瞻性的企业和个人所思考的核心问题。**其实，当前行业内已有特行的方法来攻略这个痛点，诸如**特征代码匹配、基于符号执行和符号抽象的自动审计、基于形式化验证的自动审计**等等都是较为可行的办法。其中，经过业界的广泛探究和实践，**“基于形式化验证的自动审计”**已成为了业内相对成熟和主流的方式。

因此，笔者特地将着眼点聚焦于“形式化验证”，选取当前行业内主流的两大形式化验证工具 **（VaaS & Mythril）**，进行了一个简单的测试对比。**特别指出，用以测试的Mythril工具版本为0.21.12。**

以下为相关的测试报告，希望能够抛砖引玉，为广大读者带来一些直观感受和客观建议。若有不妥之处，欢迎留言指出。（本文仅代表笔者作测试后的个人建议，不对任何产品和工具作相关背书）


# 1.VaaS & Mythril工具简介

## 01.VaaS工具简介：

VaaS工具是由Beosin成都链安采用自有知识产权独立研发的自动形式化验证工具，能够为智能合约和区块链应用提供“军事级”的形式化验证服务，可精确定位到有风险的代码位置并指出风险原因，有效检测出智能合约常规安全漏洞、安全属性和功能正确性，精确度高达95%以上。

## 02.Mythril工具简介：

Mythril工具是由以太坊开源社区所提供的安全分析工具，能够检测出Solidity智能合约中的安全漏洞并实现深入分析，是用以分析以太坊智能合约及区块链应用安全性的安全分析工具及引擎，支持常用IDE集成。

# 2.测试案例组成：

合约测试案例组成包括代币合约260个及业务合约20个。

01. 代币合约包括Top200的代币合约及60个用以审计的典型代币合约，覆盖到了ICO、锁仓、铸币和销毁等功能。

02. 业务合约包括拍卖、商城、溯源等业务类合约共20个。

# 3.测试结果总览：

VaaS工具可检测出代币类和业务类的所有合约测试案例；但Mythril工具仅能检测出代币类合约，却无法对业务类合约进行检测。因此需要注意的是，本次测试结果总览仅是对代币类合约所罗列的对比分析。

VaaS工具总计有28项漏洞检查；但Mythril工具相对于VaaS工具只有9项漏洞检测。因此VaaS工具的检测项是远远多于Mythril工具的检测项。具体检测项对比如下：

**VaaS & Mythril检测项对比**

| 漏洞检测项 | Mythril | VaaS |
| --- | --- | --- |
| ERC20 标准规范 | ×       | √    |
|Fake Recharge Vulnerability（假充值）                        | ×       | √    |
|TransferToZeroAddress（目标零地址检测）                        | ×       | √    |
|Re Entrancy（重入）                                          | √       | √    |
|TXOriginAuthentication（tx.origin使用错误）                   | √       | √    |
|Invoke Low Level Calls（call调用,delegatecall调用,自杀函数调用）| √       | √    |
|BlockMembers Manipulation（区块参数依赖）                     | √       | √    |
|Invoke Extcodesize（调用Extcodesize函数）                     | ×       | √    |
|Invoke Ecrecover（调用Ecrecover函数）                         | ×       | √    |
|Unchecked Call Or Send Return Values（call和send的返回值检测） | √       | √    |
|Denial of service（拒绝服务）                                 | √       | √    |
|Redefine Variable From Base Contracts（合约继承中的变量覆盖）   | ×       | √    |
|Unprotected Ether Withdrawal（无保护的转账）                   | √       | ×    |
|Check This Balance（合约资金受到严格限制）                      | ×       | √    |
|ArbitraryJumpwith Function（具有函数类型变量的任）              | ×       | √    |
|Overload Assert（重写assert函数）                             | ×       | √    |
|CompilerVersionDeclaration（编译器版本声明）                   | ×       | √    |
|Constructor Mistyping（构造函数失配）                          | ×       | √    |
|Complex Code In Fallback Function（fallback函数使用）         | ×       | √    |
|Unary Operation（+= 写成=+ ）                                 | ×       | √    |
|No Return（返回值适配）                                        | ×       | √    |
|Unchecked Api Return Values（没检查API返回值）                 | ×       | √    |
|Emit Event Beforerevert(事件在revert前触发了)                  | ×       | √    |
|Integer Overflow（整数溢出）                                  | √       | √    |
|Exception State(异常检测，包括数组越界、除0、assert失败等)        | √       | √    |
|Call problem                                                | ×       | √    |
|Function problem                                            | ×       | √    |
|Require Fail                                                | ×       | √    |

## 01.之于两者相同检测项的检测结果

对于选择的260个代币测试用例，Mythril工具在15分钟的时限内，可跑出184个合约结果，76个无检测结果；而VaaS工具可跑出全部结果。取Mythril工具和VaaS工具双方均可跑出的184个结果进行对比，结果如下。

**A.命中率&误报率**

通过检测结果对比，之于相同的检测项，VaaS工具的检测能力是远远高于Mythril工具的检测能力。据计算，VaaS工具的检测精度为96.9%；Mythril工具的检测精度为36.6%；而VaaS工具的误报率为15.3%；Mythril工具的误报率为48.5%。具体见下图。

![命中率误报率](https://img.learnblockchain.cn/2019/10/15/001.png)

需要注意的是，命中率和误报率的计算公式为：

**· 命中率 = 命中个数/总问题个数**

**· 误报率 = 误报个数/(误报个数+命中个数)**

笔者统计，VaaS工具和Mythril工具两者都进行的检测项共计655个问题：

·　VaaS工具总计检测出635个问题，命中率为96.9%；误报共115个，误报率为15.3%

·　Mythril工具总计检测出240个问题，命中率为36.6%；误报共计226个，误报率为48.5%。其中，Mythril工具重入攻击和拒绝服务误报率较高，占总数的93.3%。

检测总数值具体对比如下表：

|           | VaaS  | Mythril |
|-----------| ----- | ------- |
|检测用例个数 | 184   | 184     |
|问题总数    | 655   | 655     |
|命中个数    | 635   | 240     |
|误报个数    | 115   | 226     |
|命中率      | 96.9% | 36.6%   |
|误报率      | 15.3% | 48.5%   |

针对每项详细结果对比如下表：

  <table width="655" border="0" cellpadding="0" cellspacing="0" style='width:491.25pt;border-collapse:collapse;table-layout:fixed;'>
   <col width="249" style='mso-width-source:userset;mso-width-alt:7968;'/>
   <col width="69" class="xl65" style='mso-width-source:userset;mso-width-alt:2208;'/>
   <col width="86" class="xl65" style='mso-width-source:userset;mso-width-alt:2752;'/>
   <col width="78" class="xl65" style='mso-width-source:userset;mso-width-alt:2496;'/>
   <col width="82" class="xl65" style='mso-width-source:userset;mso-width-alt:2624;'/>
   <col width="91" class="xl65" style='mso-width-source:userset;mso-width-alt:2912;'/>
   <tr height="24" style='height:18.00pt;mso-height-source:userset;mso-height-alt:360;'>
    <td class="xl66" height="47" width="249" rowspan="2" style='height:35.25pt;width:186.75pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>漏洞检测项</td>
    <td class="xl67" width="69" rowspan="2" style='width:51.75pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>总数</td>
    <td class="xl67" width="164" colspan="2" style='width:123.00pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Mythril</td>
    <td class="xl67" width="173" colspan="2" style='width:129.75pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>VaaS</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl68" x:str>命中</td>
    <td class="xl68" x:str>误报</td>
    <td class="xl74" x:str>命中</td>
    <td class="xl74" x:str>误报</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Re Entrancy（重入）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>14</td>
    <td class="xl68" x:num>7</td>
    <td class="xl68" x:num>115</td>
    <td class="xl68" x:num>14</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl70" x:num="0.5">50%</td>
    <td class="xl71" x:num="0.94200000000000006">94.20%</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>TXOriginAuthentication（<font class="font22">tx.origin</font><font class="font2">使用错误）</font></td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>4</td>
    <td class="xl68" x:num>4</td>
    <td class="xl68" x:num>0</td>
    <td class="xl68" x:num>4</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>BlockMembers Manipulation（区块参数依赖）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>116</td>
    <td class="xl68" x:num>21</td>
    <td class="xl68" x:num>0</td>
    <td class="xl68" x:num>116</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl71" x:num="0.18100000000000002">18.10%</td>
    <td class="xl68" x:num>0</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Denial of service（拒绝服务）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>14</td>
    <td class="xl68" x:num>7</td>
    <td class="xl68" x:num>83</td>
    <td class="xl68" x:num>14</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl70" x:num="0.5">50%</td>
    <td class="xl71" x:num="0.92200000000000004">92.20%</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Invoke Low Level Calls（call调用,delegatecall调用,自杀函数调用）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>54</td>
    <td class="xl68" x:num>7</td>
    <td class="xl68" x:num>0</td>
    <td class="xl68" x:num>54</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl71" x:num="0.129">12.90%</td>
    <td class="xl68" x:num>0</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Unchecked Call Or Send Return Values（call和send的返回值检测）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>25</td>
    <td class="xl68" x:num>4</td>
    <td class="xl68" x:num>0</td>
    <td class="xl68" x:num>25</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl70" x:num="0.16">16%</td>
    <td class="xl68" x:num>0</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl68" x:num>0</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Integer Overflow（整数溢出）</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>356</td>
    <td class="xl68" x:num>126</td>
    <td class="xl68" x:num>28</td>
    <td class="xl68" x:num>336</td>
    <td class="xl68" x:num>90</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl71" x:num="0.35299999999999998">35.30%</td>
    <td class="xl71" x:num="0.18100000000000002">18.10%</td>
    <td class="xl71" x:num="0.94299999999999995">94.30%</td>
    <td class="xl71" x:num="0.20100000000000001">20.10%</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl72" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>Exception State(assert失败)</td>
    <td class="xl68" rowspan="2" style='border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:num>72</td>
    <td class="xl68" x:num>64</td>
    <td class="xl68" x:num>0</td>
    <td class="xl68" x:num>72</td>
    <td class="xl68" x:num>25</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl71" x:num="0.88800000000000001">88.80%</td>
    <td class="xl68" x:num>0</td>
    <td class="xl70" x:num="1">100%</td>
    <td class="xl71" x:num="0.25700000000000001">25.70%</td>
   </tr>
   <![if supportMisalignedColumns]>
    <tr width="0" style='display:none;'>
     <td width="249" style='width:187;'></td>
     <td width="69" style='width:52;'></td>
     <td width="86" style='width:65;'></td>
     <td width="78" style='width:59;'></td>
     <td width="82" style='width:62;'></td>
     <td width="91" style='width:68;'></td>
    </tr>
   <![endif]>
  </table>

**B.测试时限**

Mythril工具的平均测试时间为226.2s；而VaaS工具的平均测试时间为164.4s。说明VaaS工具的运行效率优于Mythril工具。

##02.之于VaaS工具特有检测项的检测结果

具体见下表：

**VaaS工具特有检测项用例结果展示说明**

<table width="546" border="0" cellpadding="0" cellspacing="0" style='width:409.50pt;border-collapse:collapse;table-layout:fixed;'>
   <col width="168" class="xl65" style='mso-width-source:userset;mso-width-alt:5376;'/>
   <col width="198" class="xl65" style='mso-width-source:userset;mso-width-alt:6336;'/>
   <col width="180" class="xl65" style='mso-width-source:userset;mso-width-alt:5760;'/>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl66" height="23" width="168" style='height:17.25pt;width:126.00pt;' x:str>分类</td>
    <td class="xl67" width="198" style='width:148.50pt;' x:str>VaaS log <font class="font24">关键字</font></td>
    <td class="xl67" width="180" style='width:135.00pt;' x:str>说明</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl68" height="115" rowspan="5" style='height:86.25pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>ERC20 <font class="font3">标准规范</font><font class="font2">(ERC20 Standard)</font></td>
    <td class="xl69" x:str>Erc20 Variable</td>
    <td class="xl69" x:str>ERC20 <font class="font4">变量命名规范</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Erc20 Function</td>
    <td class="xl69" x:str>Erc20<font class="font4">函数命名规范</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Erc20 Event</td>
    <td class="xl69" x:str>Erc20 event<font class="font4">使用规范</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Fake Recharge Vulnerability</td>
    <td class="xl69" x:str>假充值</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Transfer To Zero Address</td>
    <td class="xl69" x:str>目标地址非零检查</td>
   </tr>
   <tr height="36" style='height:27.00pt;mso-height-source:userset;mso-height-alt:540;'>
    <td class="xl71" height="84" rowspan="2" style='height:63.00pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>敏感函数调用<font class="font25">(Sensitive</font><font class="font3"> </font><font class="font25">Function</font><font class="font3"> </font><font class="font25">Call)</font></td>
    <td class="xl69" x:str>Invoke Extcodesize</td>
    <td class="xl69" x:str>调用Extcodesize<font class="font4">函数</font></td>
   </tr>
   <tr height="48" style='height:36.00pt;mso-height-source:userset;mso-height-alt:720;'>
    <td class="xl69" x:str>Invoke Ecrecover</td>
    <td class="xl69" x:str>调用Ecrecover<font class="font4">函数</font></td>
   </tr>
   <tr height="39" style='height:29.25pt;'>
    <td class="xl73" height="153" rowspan="5" style='height:114.75pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>不推荐使用<font class="font25">(Deprecated</font><font class="font3"> </font><font class="font25">Usage)</font></td>
    <td class="xl69" x:str>Redefine Variable From Base <span style='display:none;'>Contracts</span></td>
    <td class="xl69" x:str>合约继承中的变量覆盖</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>check_this_balance</td>
    <td class="xl74" x:str>合约资金受到严格限制</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>unused_variables</td>
    <td class="xl69" x:str>未使用的变量</td>
   </tr>
   <tr height="45" style='height:33.75pt;'>
    <td class="xl69" x:str>Arbitrary Jump with Function T<span style='display:none;'>ype Variable</span></td>
    <td class="xl69" x:str>具有函数类型变量的任意跳<span style='display:none;'>转</span></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Overload Assert</td>
    <td class="xl69" x:str>重写assert<font class="font4">函数</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl68" height="200" rowspan="8" style='height:150.00pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>solidity<font class="font3">编码规范</font><font class="font2">(Solidity Coding Conventions)</font></td>
    <td class="xl69" x:str>Compiler Version Declaration</td>
    <td class="xl69" x:str>编译器版本声明</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Constructor Mistyping</td>
    <td class="xl69" x:str>构造函数失配</td>
   </tr>
   <tr height="39" style='height:29.25pt;'>
    <td class="xl69" x:str>Complex Code In Fallback Fun<span style='display:none;'>ction</span></td>
    <td class="xl69" x:str>fallback<font class="font4">函数使用</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Unary Operation</td>
    <td class="xl69" x:str>+= <font class="font4">写成</font><font class="font2">=+</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Constructor Warning</td>
    <td class="xl69" x:str>缺少主构造函数</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>No Return</td>
    <td class="xl69" x:str>返回值适配</td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Unchecked Api Return Values</td>
    <td class="xl69" x:str>没检查API<font class="font4">返回值</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Emit Event Beforerevert</td>
    <td class="xl69" x:str>事件在revert<font class="font4">前触发了</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl76" height="46" rowspan="2" style='height:34.50pt;border-right:1.0pt solid windowtext;border-bottom:1.0pt solid windowtext;' x:str>逻辑验证</td>
    <td class="xl69" x:str>Call problem</td>
    <td class="xl69" x:str>call<font class="font4">调用执行总是</font><font class="font2">revert</font></td>
   </tr>
   <tr height="23" style='height:17.25pt;'>
    <td class="xl69" x:str>Function problem</td>
    <td class="xl69" x:str>Function<font class="font4">执行总是失败</font></td>
   </tr>
   <![if supportMisalignedColumns]>
    <tr width="0" style='display:none;'>
     <td width="168" style='width:126;'></td>
     <td width="198" style='width:149;'></td>
     <td width="180" style='width:135;'></td>
    </tr>
   <![endif]>
  </table>

# 4.案例演示

## 01.两者相同检测项案例

### **A. Re Entrancy（重入）**

案例：

```js
interface TEST {
    function test123() external view returns (uint256);
    function getBlocknumber() external view returns (uint256);
}

contract test2 {

    function testCalling(address _testAdddress) public {
        TEST t = TEST(_testAdddress);
t.test123();//mythril 误报

    }

    function testFormal(address _testAdddress) public view returns(uint256 time){
        TEST t = TEST(_testAdddress);
        t.getBlocknumber();//mythril 误报
        return time;
    }
}
contract Reentrancy {
    mapping(address => uint256) public balances;

    event WithdrawFunds(address _to,uint256 _value);

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function showbalance() public view returns (uint256 ){
        return address(this).balance;
    }

    function withdrawFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(msg.sender.call.value(_weiToWithdraw)());
balances[msg.sender] -= _weiToWithdraw;//mythril 明显的误报
        emit WithdrawFunds(msg.sender,_weiToWithdraw);
    }
}
```

**VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/002.png)

**Mythril工具测试结果：**

![Mythril工具测试结果1](https://img.learnblockchain.cn/2019/10/15/003.png)

![Mythril工具测试结果2](https://img.learnblockchain.cn/2019/10/15/004.png)

笔者分析，VaaS工具报出存在重入攻击的位置；而Mythril工具针对外部的call调用作了告警，总共有4处告警，其中2处是正常的外部调用，另1处是明显的误报，误报率较高。

### **B. TXOriginAuthentication（tx.origin使用错误）**

案例：

```
contract TxUserWallet {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function transferTo(address  dest, uint amount) public {
        require(tx.origin == owner);
        dest.transfer(amount);
    }
}
```

**VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/005.png)

**Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/006.png)

笔者分析，VaaS工具和Mythril工具均能对tx.origin关键字进行检测报警。

### **C. Invoke Low Level Calls（call调用,delegatecall调用,自杀函数调用）**

案例：

```js
contract Delegatecall{
    uint public q;
    bool public b;
    address addr = 0xde6a66562c299052b1cfd24abc1dc639d429e1d6;
    function Delegatecall() public payable {

    }

    function call1() public returns(bool) {
b = addr.delegatecall
(bytes4(keccak256("fun(uint256,uint256)")),2,3);
        return b;
    }

    function call2(address add) public returns(bool){
b=add.delegatecall
(bytes4(keccak256("fun(uint256,uint256)")),2,3);
        return b;
    }
}
```

** VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/007.png)

** Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/008.png)

笔者分析，案例有两处delegetacall调用，而Mythril工具仅报了一次，存在漏报风险。

###  **D. BlockMembers Manipulation（区块参数依赖）**

案例：
```js
function createTokens() payable external {
      if (isFinalized) throw;
if (block.number < fundingStartBlock) throw;
if (block.number > fundingEndBlock) throw;
      if (msg.value == 0) throw;

      uint256 tokens = safeMult(msg.value, tokenExchangeRate);
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      if (tokenCreationCap < checkedSupply) throw;

      totalSupply = checkedSupply;
      balances[msg.sender] += tokens;
      CreateBAT(msg.sender, tokens);
    }

function finalize() external {
      if (isFinalized) throw;
      if (msg.sender != ethFundDeposit) throw;
      if(totalSupply < tokenCreationMin) throw;
      if(block.number <= fundingEndBlock && totalSupply != tokenCreationCap) throw;
      // move to operational
      isFinalized = true;
      if(!ethFundDeposit.send(this.balance)) throw;
    }


function refund() external {
      if(isFinalized) throw;
if (block.number <= fundingEndBlock) throw;
      if(totalSupply >= tokenCreationMin) throw;
      if(msg.sender == batFundDeposit) throw;
      uint256 batVal = balances[msg.sender];
      if (batVal == 0) throw;
      balances[msg.sender] = 0;
      totalSupply = safeSubtract(totalSupply, batVal);
      uint256 ethVal = batVal / tokenExchangeRate;
      LogRefund(msg.sender, ethVal);
      if (!msg.sender.send(ethVal)) throw;
    }
}
```

**　VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/009.png)

** Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/010.png)

笔者分析，VaaS工具和Mythril工具均能对区块参数依赖作出检测；但Mythril工具存在漏报风险。

###  **E. Denial of service（拒绝服务）**

案例：

```js
contract Auction {
    address public highestBidder = 0x0;
    uint256 public highestBid;
    function Auction(uint256 _highestBid) {
        require(_highestBid > 0);
        highestBid = _highestBid;
        highestBidder = msg.sender;
    }

    function bid() payable {
        require(msg.value > highestBid);
        highestBidder.transfer(highestBid);
highestBidder = msg.sender;
highestBid = msg.value;
    }

    function auction_end() {
    }
}
```

**VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/011.png)

**Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/012.png)

笔者分析，VaaS工具和Mythril工具均能针对拒绝服务作出风险检测。但在此案例中，highestBidder可能是恶意攻击合约，而导致transfer恒不成功，从而导致合约拒接服务，此案例VaaS工具能够检测出拒绝服务风险，Mythril工具未检出。

###  **F. Unchecked Call Or Send Return Values（call和send的返回值检测）**

案例：

```js
if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
msg.sender.send(amount);
    creditorAddresses[creditorAddresses.length - 1].send(profitFromCrash);
    corruptElite.send(this.balance);

    ...

    return true;
}
else {
msg.sender.send(amount);
return false;
}
```

**VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/013.png)

**Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/014.png)

笔者分析，VaaS工具和Mythril工具均能对未检查call调用的返回值检测；但Mythril工具存在漏报风险。

###  **G. Integer Overflow（整数溢出）**

案例1：

```js
function distributeBTR(address[] addresses) onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        balances[owner] -= 2000 * 10**8;
        alances[addresses[i]] += 2000 * 10**8;
        Transfer(owner, addresses[i], 2000 * 10**8);
		}
    }
```

笔者分析，以上案例没有对balances[owner]的值作检测，可能会产生下溢，但Mythrill工具不会报错，说明Mythrill工具对常数的运算不会作检测。

案例2：

```js
contract A {
    uint c;
    function add(uint8 a,uint8 b){
uint8 sum = a+b;
        c=sum;
    }
}
```

**VaaS工具测试结果：**

![VaaS工具测试结果](https://img.learnblockchain.cn/2019/10/15/015.png)

**Mythril工具测试结果：**

![Mythril工具测试结果](https://img.learnblockchain.cn/2019/10/15/016.png).

笔者分析，Mythrill工具对非uint256数据类型的溢出检测不准确。

案例3：

**· Mythril工具的一些检测结果：**

![Mythril工具的一些检测结果1](https://img.learnblockchain.cn/2019/10/15/017.png)

![Mythril工具的一些检测结果2](https://img.learnblockchain.cn/2019/10/15/018.png)

笔者分析，Mythrill工具对一些特定变量未作处理，导致误报。比如数组，msg.value，now等。

## 02. VaaS工具特有检测项案例

案例1：

```js
...
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
...
 function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }
```

测试结果：

![测试结果1](https://img.learnblockchain.cn/2019/10/15/019.png)

![测试结果2](https://img.learnblockchain.cn/2019/10/15/020.png)

案例2：

```js
contract A {
    B b;
    uint c;
    function test(uint a){
        b = new B(a);
        c = b.get(200);
    }
}

contract B {
    uint b;
    function B(uint e){
        b=100;
    }
    function get(uint a)returns(uint){
        require(a<100);
        return a;
  }
}
```

测试结果：

![测试结果](https://img.learnblockchain.cn/2019/10/15/021.png)

笔者分析，在案例2中关于合约间的调用问题，在拥有源码的情况下，VaaS工具是可以调用成功并进行测试的；而Mythril工具不行。这也是Mythril工具无法进行业务合约验证的原因之一。

通过以上对VaaS工具和Mythril工具逻辑、维度、数据进行简单的对比分析，笔者认为，读者在阅后将能够根据自身业务取向和侧重作出相应的判断和评估。且毋论智能合约和区块链应用，甚至整个区块链行业的安全性，未来都将需要以一种供（增长率）求（安全性）关系平衡的模式向前发展，我们就更需要清楚地知道，当前现状的痛点所在，以及如何针对该痛点进行改进和革新。

无论是作为前沿科技拥戴者，还是区块链技术极客，但凡具备去中心化思维以及认可智能合约及区块链应用在未来具备深远影响力的有识之士，都能明白笔者针对“形式化验证”作此篇测试报告的用意。诚然，尽管当下更多的目光放是放在如何推进智能合约和区块链应用的落地以及区块链全生态的统筹建设上，但倘若底层技术架构方面本身都还存在各种漏洞风险尚未解决，就未免太过于好高骛远了。

因此，笔者建议，为保障海量智能合约及区块链应用的安全，以及维护区块链生态的良好运维，“形式化验证”业已成为了当下自动化审计的重要途径。通过漏报率、误报率、命中率、测试时限等评估维度，来整体判别某种验证和审计工具的可行性，是当前智能合约及区块链应用发展的必经阶段，也是作为区块链从业者需要认真践行的使命。

本文来自 深入浅出区块链社区合作伙伴：专注于区块链生态安全的[Beosin 成都链安](https://www.lianantech.com/?utm_source=learnblockchain.cn)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。