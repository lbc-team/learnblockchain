
---
title: Solidity 最新 0.5.8 中文文档发布
permalink: solidity-doc-announce
date: 2019-05-08 17:25:14
categories: 
    - 以太坊
    - Solidity
tags: 
    - Solidity
    - 文档
author: Tiny熊
---

热烈祝贺 [Solidity 最新 0.5.8 中文文档](https://learnblockchain.cn/docs/solidity/)发布， 这不单是一份 Solidity 速查手册，更是一份深入以太坊智能合约开发宝典。

<!-- more -->

## 翻译说明

[Solidity 最新 0.5.8 中文文档](https://learnblockchain.cn/docs/solidity/) 根据当前 [最新官方版本v0.5.8](https://solidity.readthedocs.io/) 进行翻译，本翻译最初 [HiBlock](http://hiblock.one/) 社区发起，后经过 [深入浅出区块链社区](https://learnblockchain.cn/) 社区成员根据最新版本补充翻译。

大部分的译者，都是国内顶尖的[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)开发和研究人员，部分译者如下：

* [杨镇](https://github.com/riversyang) 《深入以太坊智能合约开发》作者，《精通以太坊》译者
* [姜信宝](https://github.com/bobjiang) HiBlock 区块链社区发起人 ，
* [Tiny熊](https://github.com/xilibi2003) 《精通以太坊智能合约开发》作者，[深入浅出区块链技术博客](https://learnblockchain.cn)发起人
* [盖方宇](https://github.com/gitferry) 哥伦比亚大学电子工程系博士，专注扩容研究
* [虞是乎](https://github.com/ysqi) 磨链发起人
* [左洪斌](https://github.com/hongbinzuo)《Scrum精髓(敏捷转型指南)》译者

感谢所有的译者贡献，献花~ 献花~

这份文档无疑是最新质量最好的[中文文档](https://learnblockchain.cn/docs/solidity/)，本文仅仅是部分摘要和目录， 完整文档请前往 https://learnblockchain.cn/docs/solidity/ 。

翻译工作是一个持续的过程（这份文档目前也还有部分未完成），我们热情邀请热爱区块链技术的小伙伴一起参与，欢迎加入我们Group： https://github.com/lbc-team 。

本中文文档大部分情况下，英中直译，但有时为了更好的理解也会使用意译，如需转载请联系Tiny熊（微信：xlbxiong）.

## Solidity 语言简介 及 文档目录

Solidity 是一门面向合约的、为实现智能合约而创建的高级编程语言。这门语言受到了 C++，Python 和 Javascript 语言的影响，设计的目的是能在[以太坊虚拟机](https://learnblockchain.cn/2019/04/09/easy-evm/)（EVM）]上运行。

要理解智能合约及虚拟机是怎么运行，推荐这两篇非常好的文章 [完全理解以太坊智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/) 及 [深入浅出以太坊虚拟机](https://learnblockchain.cn/2019/04/09/easy-evm/) 

[Solidity](https://learnblockchain.cn/docs/solidity/) 是静态类型语言，支持继承、库和复杂的用户定义类型等特性， 以下是完整目录。

### 文档目录


* [入门智能合约](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html)
    * [简单的智能合约](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#simple-smart-contract)
        * [存储合约（把一个数据保存到链上）](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#id3)
        * [子货币合约（Subcurrency）示例](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#subcurrency)
    * [区块链基础](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#blockchain-basics)
        * [交易/事务](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-4)
        * [区块](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-5)
    * [以太坊虚拟机](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-6)
        * [概述](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#id11)
        * [账户](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-7)
        * [交易](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-8)
        * [Gas](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#gas)
        * [存储，内存和栈](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-10)
        * [指令集](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-11)
        * [消息调用](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-12)
        * [委托调用/代码调用和库](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-13)
        * [日志](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-14)
        * [合约创建](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-15)
        * [失效和自毁](https://learnblockchain.cn/docs/solidity/introduction-to-smart-contracts.html#index-16)
* [安装Solidity编译器](https://learnblockchain.cn/docs/solidity/installing-solidity.html)
    * [版本](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id1)
    * [Remix](https://learnblockchain.cn/docs/solidity/installing-solidity.html#remix)
    * [npm / Node.js](https://learnblockchain.cn/docs/solidity/installing-solidity.html#npm-node-js)
    * [Docker](https://learnblockchain.cn/docs/solidity/installing-solidity.html#docker)
    * [二进制包](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id4)
    * [从源代码编译](https://learnblockchain.cn/docs/solidity/installing-solidity.html#building-from-source)
        * [克隆代码库](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id6)
        * [先决条件 - macOS](https://learnblockchain.cn/docs/solidity/installing-solidity.html#macos)
        * [先决条件 - Windows](https://learnblockchain.cn/docs/solidity/installing-solidity.html#windows)
        * [外部依赖](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id8)
        * [命令行构建](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id9)
    * [CMake参数](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id10)
        * [SMT Solvers](https://learnblockchain.cn/docs/solidity/installing-solidity.html#smt-solvers)
    * [版本号字符串详解](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id11)
    * [版本信息详情](https://learnblockchain.cn/docs/solidity/installing-solidity.html#id12)
* [根据例子学习Solidity](https://learnblockchain.cn/docs/solidity/solidity-by-example.html)
    * [投票合约](https://learnblockchain.cn/docs/solidity/examples/voting.html)
        * [可能的优化](https://learnblockchain.cn/docs/solidity/examples/voting.html#id2)
    * [秘密竞价（盲拍）合约](https://learnblockchain.cn/docs/solidity/examples/blind-auction.html)
        * [简单的公开拍卖](https://learnblockchain.cn/docs/solidity/examples/blind-auction.html#simple-auction)
        * [秘密竞拍（盲拍）](https://learnblockchain.cn/docs/solidity/examples/blind-auction.html#id3)
    * [安全的远程购买合约](https://learnblockchain.cn/docs/solidity/examples/safe-remote.html)
    * [微支付通道合约](https://learnblockchain.cn/docs/solidity/examples/micropayment.html)
        * [创建及验证签名](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id3)
            * [创建签名](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id4)
            * [哪些内容需要签名](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id5)
            * [打包参数](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id6)
            * [在Solidity中还原消息签名者](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#solidity)
            * [提取签名参数](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id7)
            * [计算信息的Hash](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#hash)
            * [ReceiverPays 完整合约代码](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#receiverpays)
        * [编写一个简单的支付通道](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id9)
            * [什么是支付通道？](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id10)
            * [打开支付通道](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id11)
            * [进行支付](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id12)
            * [关闭状态通道](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id13)
            * [通道有效期](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id14)
            * [完整合约代码](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id15)
            * [验证支付](https://learnblockchain.cn/docs/solidity/examples/micropayment.html#id16)
    * [库合约使用](https://learnblockchain.cn/docs/solidity/examples/modular.html)
* [深入理解Solidity](https://learnblockchain.cn/docs/solidity/solidity-in-depth.html)
    * [Solidity 源文件结构](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html)
        * [Pragmas](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#pragmas)
        * [版本标识](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#version-pragma)
            * [标注实验性功能](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#experimental-pragma)
        * [导入其他源文件](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#import)
            * [语法与语义](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#id5)
            * [路径](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#id6)
            * [在实际的编译器中使用](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#import-compiler)
        * [注释](https://learnblockchain.cn/docs/solidity/layout-of-source-files.html#index-4)
    * [合约结构](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html)
        * [状态变量](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#structure-state-variables)
        * [函数](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#structure-functions)
        * [函数 修饰器modifier](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#modifier)
        * [事件 Event](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#event)
        * [结构体](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#structure-struct-types)
        * [枚举类型](https://learnblockchain.cn/docs/solidity/structure-of-a-contract.html#structure-enum-types)
    * [类型](https://learnblockchain.cn/docs/solidity/types.html)
        * [值类型](https://learnblockchain.cn/docs/solidity/types.html#value-types)
            * [布尔类型](https://learnblockchain.cn/docs/solidity/types.html#index-2)
            * [整型](https://learnblockchain.cn/docs/solidity/types.html#index-3)
            * [定长浮点型](https://learnblockchain.cn/docs/solidity/types.html#index-4)
            * [地址类型 Address](https://learnblockchain.cn/docs/solidity/types.html#address)
            * [合约类型](https://learnblockchain.cn/docs/solidity/types.html#contract-types)
            * [定长字节数组](https://learnblockchain.cn/docs/solidity/types.html#index-7)
            * [变长字节数组](https://learnblockchain.cn/docs/solidity/types.html#id17)
            * [地址字面常量](https://learnblockchain.cn/docs/solidity/types.html#address-literals)
            * [有理数和整数字面常量](https://learnblockchain.cn/docs/solidity/types.html#rational-literals)
            * [字符串字面常量及类型](https://learnblockchain.cn/docs/solidity/types.html#string-literals)
            * [十六进制字面常量](https://learnblockchain.cn/docs/solidity/types.html#index-11)
            * [枚举类型](https://learnblockchain.cn/docs/solidity/types.html#enums)
            * [函数类型](https://learnblockchain.cn/docs/solidity/types.html#function-types)
        * [引用类型](https://learnblockchain.cn/docs/solidity/types.html#reference-types)
            * [数据位置](https://learnblockchain.cn/docs/solidity/types.html#data-location)
            * [数组](https://learnblockchain.cn/docs/solidity/types.html#arrays)
            * [结构体](https://learnblockchain.cn/docs/solidity/types.html#structs)
        * [映射](https://learnblockchain.cn/docs/solidity/types.html#mapping-types)
        * [涉及 LValues 的运算符](https://learnblockchain.cn/docs/solidity/types.html#lvalues)
            * [delete](https://learnblockchain.cn/docs/solidity/types.html#delete)
        * [基本类型之间的转换](https://learnblockchain.cn/docs/solidity/types.html#types-conversion-elementary-types)
            * [隐式转换](https://learnblockchain.cn/docs/solidity/types.html#id38)
            * [显式转换](https://learnblockchain.cn/docs/solidity/types.html#id39)
        * [字面常量与基本类型的转换](https://learnblockchain.cn/docs/solidity/types.html#types-conversion-literals)
            * [整型](https://learnblockchain.cn/docs/solidity/types.html#id41)
            * [定长字节数组](https://learnblockchain.cn/docs/solidity/types.html#id42)
            * [地址类型](https://learnblockchain.cn/docs/solidity/types.html#id43)
        * [类型推断(已弃用)](https://learnblockchain.cn/docs/solidity/types.html#type-deduction)
    * [单位和全局变量](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html)
        * [以太币Ether 单位](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#ether)
        * [时间单位](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-1)
        * [特殊变量和函数](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#id3)
            * [区块和交易属性](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-2)
            * [ABI 编码函数](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#abi)
            * [错误处理](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-4)
            * [数学和密码学函数](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-5)
            * [地址相关](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#address-related)
            * [合约相关](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-7)
            * [类型信息](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#meta-type)
    * [表达式和控制结构](https://learnblockchain.cn/docs/solidity/control-structures.html)
        * [输入参数和输出参数](https://learnblockchain.cn/docs/solidity/control-structures.html#index-0)
            * [输入参数](https://learnblockchain.cn/docs/solidity/control-structures.html#id3)
            * [输出参数](https://learnblockchain.cn/docs/solidity/control-structures.html#id4)
        * [控制结构](https://learnblockchain.cn/docs/solidity/control-structures.html#index-1)
        * [函数调用](https://learnblockchain.cn/docs/solidity/control-structures.html#function-calls)
            * [内部函数调用](https://learnblockchain.cn/docs/solidity/control-structures.html#internal-function-calls)
            * [外部函数调用](https://learnblockchain.cn/docs/solidity/control-structures.html#external-function-calls)
            * [具名调用和匿名函数参数](https://learnblockchain.cn/docs/solidity/control-structures.html#id9)
            * [省略函数参数名称](https://learnblockchain.cn/docs/solidity/control-structures.html#id10)
        * [通过 new  创建合约](https://learnblockchain.cn/docs/solidity/control-structures.html#new)
        * [赋值](https://learnblockchain.cn/docs/solidity/control-structures.html#index-4)
            * [解构赋值和返回多值](https://learnblockchain.cn/docs/solidity/control-structures.html#index-5)
            * [数组和结构体的复杂性](https://learnblockchain.cn/docs/solidity/control-structures.html#id13)
        * [作用域和声明](https://learnblockchain.cn/docs/solidity/control-structures.html#default-value)
        * [错误处理：Assert, Require, Revert and Exceptions](https://learnblockchain.cn/docs/solidity/control-structures.html#assert-require-revert-and-exceptions)
    * [合约](https://learnblockchain.cn/docs/solidity/contracts.html)
        * [创建合约](https://learnblockchain.cn/docs/solidity/contracts.html#index-1)
        * [可见性和 getter 函数](https://learnblockchain.cn/docs/solidity/contracts.html#getter)
            * [Getter 函数](https://learnblockchain.cn/docs/solidity/contracts.html#getter-functions)
        * [函数 修饰器modifier](https://learnblockchain.cn/docs/solidity/contracts.html#modifier)
        * [Constant 状态变量](https://learnblockchain.cn/docs/solidity/contracts.html#constant)
        * [函数](https://learnblockchain.cn/docs/solidity/contracts.html#functions)
            * [函数参数及返回值](https://learnblockchain.cn/docs/solidity/contracts.html#function-parameters-return-variables)
            * [View 函数](https://learnblockchain.cn/docs/solidity/contracts.html#view)
            * [Pure 函数](https://learnblockchain.cn/docs/solidity/contracts.html#pure)
            * [Fallback 回退函数](https://learnblockchain.cn/docs/solidity/contracts.html#fallback)
            * [函数重载](https://learnblockchain.cn/docs/solidity/contracts.html#overload-function)
        * [事件](https://learnblockchain.cn/docs/solidity/contracts.html#events)
            * [日志的底层接口](https://learnblockchain.cn/docs/solidity/contracts.html#index-14)
            * [其它学习事件机制的资源](https://learnblockchain.cn/docs/solidity/contracts.html#id13)
        * [继承](https://learnblockchain.cn/docs/solidity/contracts.html#index-15)
            * [构造器](https://learnblockchain.cn/docs/solidity/contracts.html#constructor)
            * [基类构造函数的参数](https://learnblockchain.cn/docs/solidity/contracts.html#index-17)
            * [多重继承与线性化](https://learnblockchain.cn/docs/solidity/contracts.html#multi-inheritance)
            * [继承有相同名字的不同类型成员](https://learnblockchain.cn/docs/solidity/contracts.html#id20)
        * [抽象合约](https://learnblockchain.cn/docs/solidity/contracts.html#abstract-contract)
        * [接口](https://learnblockchain.cn/docs/solidity/contracts.html#interfaces)
        * [库](https://learnblockchain.cn/docs/solidity/contracts.html#libraries)
            * [库的调用保护](https://learnblockchain.cn/docs/solidity/contracts.html#id24)
        * [Using For](https://learnblockchain.cn/docs/solidity/contracts.html#using-for)
    * [Solidity汇编](https://learnblockchain.cn/docs/solidity/assembly.html)
        * [内联汇编](https://learnblockchain.cn/docs/solidity/assembly.html#inline-assembly)
            * [例子](https://learnblockchain.cn/docs/solidity/assembly.html#id2)
            * [语法](https://learnblockchain.cn/docs/solidity/assembly.html#id3)
            * [操作码](https://learnblockchain.cn/docs/solidity/assembly.html#id4)
            * [字面常量](https://learnblockchain.cn/docs/solidity/assembly.html#id5)
            * [函数风格](https://learnblockchain.cn/docs/solidity/assembly.html#id6)
            * [访问外部变量和函数](https://learnblockchain.cn/docs/solidity/assembly.html#id7)
            * [标签](https://learnblockchain.cn/docs/solidity/assembly.html#id8)
            * [汇编局部变量声明](https://learnblockchain.cn/docs/solidity/assembly.html#id9)
            * [赋值](https://learnblockchain.cn/docs/solidity/assembly.html#id10)
            * [If](https://learnblockchain.cn/docs/solidity/assembly.html#if)
            * [Switch](https://learnblockchain.cn/docs/solidity/assembly.html#switch)
            * [循环](https://learnblockchain.cn/docs/solidity/assembly.html#id11)
            * [函数](https://learnblockchain.cn/docs/solidity/assembly.html#id12)
            * [注意事项](https://learnblockchain.cn/docs/solidity/assembly.html#id13)
            * [Solidity 惯例](https://learnblockchain.cn/docs/solidity/assembly.html#id14)
        * [独立汇编](https://learnblockchain.cn/docs/solidity/assembly.html#id15)
            * [汇编语法](https://learnblockchain.cn/docs/solidity/assembly.html#id16)
    * [杂项](https://learnblockchain.cn/docs/solidity/miscellaneous.html)
        * [存储storage 中的状态变量储存结构](https://learnblockchain.cn/docs/solidity/miscellaneous.html#storage)
        * [内存memory 中的存储结构](https://learnblockchain.cn/docs/solidity/miscellaneous.html#memory)
        * [调用数据存储结构](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-2)
        * [内部机制 - 清理变量](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-3)
        * [内部机制 - 优化器](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-4)
        * [源代码映射](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-5)
        * [技巧和窍门](https://learnblockchain.cn/docs/solidity/miscellaneous.html#id6)
        * [速查表](https://learnblockchain.cn/docs/solidity/miscellaneous.html#id7)
            * [操作符优先级](https://learnblockchain.cn/docs/solidity/miscellaneous.html#order)
            * [全局变量](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-7)
            * [函数可见性说明符](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-8)
            * [修改器](https://learnblockchain.cn/docs/solidity/miscellaneous.html#index-9)
            * [保留字](https://learnblockchain.cn/docs/solidity/miscellaneous.html#id12)
            * [语法表](https://learnblockchain.cn/docs/solidity/miscellaneous.html#id13)
    * [Solidity v0.5.0 重大更新](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html)
        * [语义变化](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id2)
        * [语义及语法更改](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id3)
        * [准确性要求](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id4)
        * [弃用元素](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id5)
            * [弃用命令行及 JSON 接口](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#json)
            * [构造函数变更](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id6)
            * [弃用函数](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id7)
            * [弃用类型转换](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id8)
            * [弃用字面量及后缀](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id9)
            * [弃用变量](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id10)
            * [弃用语法](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id11)
        * [和老合约进行交互](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#interoperability)
        * [举例](https://learnblockchain.cn/docs/solidity/050-breaking-changes.html#id13)
* [注释描述规范](https://learnblockchain.cn/docs/solidity/natspec-format.html)
    * [文档举例](https://learnblockchain.cn/docs/solidity/natspec-format.html#header-doc-example)
    * [标签](https://learnblockchain.cn/docs/solidity/natspec-format.html#header-tags)
        * [Dynamic expressions](https://learnblockchain.cn/docs/solidity/natspec-format.html#dynamic-expressions)
        * [Inheritance Notes](https://learnblockchain.cn/docs/solidity/natspec-format.html#inheritance-notes)
    * [文档输出](https://learnblockchain.cn/docs/solidity/natspec-format.html#header-output)
        * [用户文档](https://learnblockchain.cn/docs/solidity/natspec-format.html#header-user-doc)
        * [开发者文档](https://learnblockchain.cn/docs/solidity/natspec-format.html#header-developer-doc)
* [安全考量](https://learnblockchain.cn/docs/solidity/security-considerations.html)
    * [陷阱](https://learnblockchain.cn/docs/solidity/security-considerations.html#id2)
        * [私有信息和随机性](https://learnblockchain.cn/docs/solidity/security-considerations.html#id3)
        * [重入](https://learnblockchain.cn/docs/solidity/security-considerations.html#re-entance)
        * [gas 限制和循环](https://learnblockchain.cn/docs/solidity/security-considerations.html#gas)
        * [发送和接收 以太币Ether](https://learnblockchain.cn/docs/solidity/security-considerations.html#ether)
        * [调用栈深度](https://learnblockchain.cn/docs/solidity/security-considerations.html#id5)
        * [tx.origin问题](https://learnblockchain.cn/docs/solidity/security-considerations.html#tx-origin)
        * [整型溢出问题](https://learnblockchain.cn/docs/solidity/security-considerations.html#underflow-overflow)
        * [细枝末节](https://learnblockchain.cn/docs/solidity/security-considerations.html#id7)
    * [推荐做法](https://learnblockchain.cn/docs/solidity/security-considerations.html#id8)
        * [认真对待警告](https://learnblockchain.cn/docs/solidity/security-considerations.html#id9)
        * [限定 以太币Ether 的数量](https://learnblockchain.cn/docs/solidity/security-considerations.html#id10)
        * [保持合约简练且模块化](https://learnblockchain.cn/docs/solidity/security-considerations.html#id11)
        * [使用“检查-生效-交互”（Checks-Effects-Interactions）模式](https://learnblockchain.cn/docs/solidity/security-considerations.html#checks-effects-interactions)
        * [包含故障-安全（Fail-Safe）模式](https://learnblockchain.cn/docs/solidity/security-considerations.html#fail-safe)
    * [形式化验证](https://learnblockchain.cn/docs/solidity/security-considerations.html#id12)
* [资源](https://learnblockchain.cn/docs/solidity/resources.html)
    * [常用资源](https://learnblockchain.cn/docs/solidity/resources.html#id2)
    * [Solidity IDE及编辑器](https://learnblockchain.cn/docs/solidity/resources.html#solidity-ide)
    * [Solidity 工具](https://learnblockchain.cn/docs/solidity/resources.html#id6)
    * [第三方 Solidity 解析器](https://learnblockchain.cn/docs/solidity/resources.html#id7)
* [使用编译器](https://learnblockchain.cn/docs/solidity/using-the-compiler.html)
    * [使用命令行编译器](https://learnblockchain.cn/docs/solidity/using-the-compiler.html#commandline-compiler)
    * [编译器输入输出JSON描述](https://learnblockchain.cn/docs/solidity/using-the-compiler.html#json)
        * [输入说明](https://learnblockchain.cn/docs/solidity/using-the-compiler.html#id3)
        * [输出说明](https://learnblockchain.cn/docs/solidity/using-the-compiler.html#id4)
            * [错误类型](https://learnblockchain.cn/docs/solidity/using-the-compiler.html#id5)
* [合约的元数据](https://learnblockchain.cn/docs/solidity/metadata.html)
    * [元数据哈希字节码的编码](https://learnblockchain.cn/docs/solidity/metadata.html#id2)
    * [自动化接口生成和 以太坊标准说明格式natspec 的使用方法](https://learnblockchain.cn/docs/solidity/metadata.html#natspec)
    * [源代码验证的使用方法](https://learnblockchain.cn/docs/solidity/metadata.html#id4)
* [应用二进制接口Application Binary Interface(ABI) 说明](https://learnblockchain.cn/docs/solidity/abi-spec.html)
    * [基本设计](https://learnblockchain.cn/docs/solidity/abi-spec.html#id2)
    * [函数选择器Function Selector](https://learnblockchain.cn/docs/solidity/abi-spec.html#function-selector)
    * [参数编码](https://learnblockchain.cn/docs/solidity/abi-spec.html#id3)
    * [类型](https://learnblockchain.cn/docs/solidity/abi-spec.html#id4)
    * [编码的形式化说明](https://learnblockchain.cn/docs/solidity/abi-spec.html#id5)
    * [函数选择器Function Selector 和参数编码](https://learnblockchain.cn/docs/solidity/abi-spec.html#id6)
    * [例子](https://learnblockchain.cn/docs/solidity/abi-spec.html#id7)
    * [动态类型的使用](https://learnblockchain.cn/docs/solidity/abi-spec.html#id8)
    * [事件](https://learnblockchain.cn/docs/solidity/abi-spec.html#id9)
    * [JSON](https://learnblockchain.cn/docs/solidity/abi-spec.html#json)
        * [处理 元组tuple 类型](https://learnblockchain.cn/docs/solidity/abi-spec.html#tuple)
    * [非标准打包模式](https://learnblockchain.cn/docs/solidity/abi-spec.html#abi-packed-mode)
* [Yul](https://learnblockchain.cn/docs/solidity/yul.html)
    * [Yul 语言说明](https://learnblockchain.cn/docs/solidity/yul.html#id2)
        * [语法层面的限制](https://learnblockchain.cn/docs/solidity/yul.html#id3)
        * [作用域规则](https://learnblockchain.cn/docs/solidity/yul.html#id4)
        * [形式规范](https://learnblockchain.cn/docs/solidity/yul.html#id5)
        * [类型转换函数](https://learnblockchain.cn/docs/solidity/yul.html#id6)
        * [低级函数](https://learnblockchain.cn/docs/solidity/yul.html#id7)
        * [后端](https://learnblockchain.cn/docs/solidity/yul.html#id8)
        * [后端: EVM](https://learnblockchain.cn/docs/solidity/yul.html#evm)
        * [后端: “EVM 1.5”](https://learnblockchain.cn/docs/solidity/yul.html#evm-1-5)
        * [后端: eWASM](https://learnblockchain.cn/docs/solidity/yul.html#ewasm)
    * [Yul 对象说明](https://learnblockchain.cn/docs/solidity/yul.html#id9)
* [编程风格指南](https://learnblockchain.cn/docs/solidity/style-guide.html)
    * [概述](https://learnblockchain.cn/docs/solidity/style-guide.html#id2)
    * [代码结构](https://learnblockchain.cn/docs/solidity/style-guide.html#id3)
        * [缩进](https://learnblockchain.cn/docs/solidity/style-guide.html#id4)
        * [制表符或空格](https://learnblockchain.cn/docs/solidity/style-guide.html#id5)
        * [空行](https://learnblockchain.cn/docs/solidity/style-guide.html#id6)
        * [代码行的最大长度](https://learnblockchain.cn/docs/solidity/style-guide.html#maximum-line-length)
        * [源文件编码格式](https://learnblockchain.cn/docs/solidity/style-guide.html#id8)
        * [Imports 规范](https://learnblockchain.cn/docs/solidity/style-guide.html#imports)
        * [函数顺序](https://learnblockchain.cn/docs/solidity/style-guide.html#id9)
        * [表达式中的空格](https://learnblockchain.cn/docs/solidity/style-guide.html#id10)
        * [控制结构](https://learnblockchain.cn/docs/solidity/style-guide.html#id11)
        * [函数声明](https://learnblockchain.cn/docs/solidity/style-guide.html#id12)
        * [映射](https://learnblockchain.cn/docs/solidity/style-guide.html#id13)
        * [变量声明](https://learnblockchain.cn/docs/solidity/style-guide.html#id14)
        * [其他建议](https://learnblockchain.cn/docs/solidity/style-guide.html#id15)
    * [命名规范](https://learnblockchain.cn/docs/solidity/style-guide.html#id16)
        * [命名方式](https://learnblockchain.cn/docs/solidity/style-guide.html#id17)
        * [应避免的名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id18)
        * [合约和库名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id19)
        * [结构体名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id20)
        * [事件名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id21)
        * [函数名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id22)
        * [函数参数命名](https://learnblockchain.cn/docs/solidity/style-guide.html#id23)
        * [局部变量和状态变量名称](https://learnblockchain.cn/docs/solidity/style-guide.html#id24)
        * [常量命名](https://learnblockchain.cn/docs/solidity/style-guide.html#id25)
        * [修饰符命名](https://learnblockchain.cn/docs/solidity/style-guide.html#id26)
        * [枚举变量命名](https://learnblockchain.cn/docs/solidity/style-guide.html#id27)
        * [避免命名冲突](https://learnblockchain.cn/docs/solidity/style-guide.html#id28)
    * [描述注释 NatSpec](https://learnblockchain.cn/docs/solidity/style-guide.html#natspec)
* [通用模式](https://learnblockchain.cn/docs/solidity/common-patterns.html)
    * [从合约中提款](https://learnblockchain.cn/docs/solidity/common-patterns.html#withdrawal-pattern)
    * [限制访问](https://learnblockchain.cn/docs/solidity/common-patterns.html#index-1)
    * [状态机](https://learnblockchain.cn/docs/solidity/common-patterns.html#index-3)
        * [示例](https://learnblockchain.cn/docs/solidity/common-patterns.html#id5)
* [已知bug列表](https://learnblockchain.cn/docs/solidity/bugs.html)
* [贡献方式](https://learnblockchain.cn/docs/solidity/contributing.html)
    * [怎样报告问题](https://learnblockchain.cn/docs/solidity/contributing.html#id2)
    * [Pull Request 的工作流](https://learnblockchain.cn/docs/solidity/contributing.html#pull-request)
    * [运行编译器测试](https://learnblockchain.cn/docs/solidity/contributing.html#id4)
        * [编写和运行语法测试](https://learnblockchain.cn/docs/solidity/contributing.html#id5)
    * [通过 AFL 运行 Fuzzer](https://learnblockchain.cn/docs/solidity/contributing.html#afl-fuzzer)
    * [Whiskers 模板系统](https://learnblockchain.cn/docs/solidity/contributing.html#whiskers)
* [LLL](https://learnblockchain.cn/docs/solidity/lll.html)
* [常见问题](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html)
    * [基本问题](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#id2)
    * [高级问题](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#id12)
        * [怎样才能在合约中获取一个随机数？（实施一份自动回款的博彩合约）](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#id13)
        * [从另一份合约中的 non-constant 函数获取返回值](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#non-constant)
        * [让合约在首次被挖出时就开始做些事情](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#id16)
        * [怎样才能创建二维数组？](https://learnblockchain.cn/docs/solidity/frequently-asked-questions.html#id17)
        


[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。



