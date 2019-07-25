---
title: 智能合约构造函数中可以使用this吗？ 
permalink: contract-this
date: 2019-07-25 11:25:59
categories: 问与答
tags:
    - Solidity
author: Tiny熊
---

智能合约的地址什么时候有效? 在构造函数中可以使用this吗？

<!-- more -->

通常的直觉是智能合约应该在构造完之后（即构造函数constructor执行完之后)，其实并不是，在constructor中是可以使用this来表示当前合约的地址，因为在发起交易的时候，就已经可以确定合约的地址，参考[合约地址的计算](https://learnblockchain.cn/2019/06/10/address-compute/)。

可以使用下面的代码测试一下：

```

pragma solidity ^0.5.0;

contract Test {
  address public thisAddress;
  event LogAddr(address);

  constructor()  {
    thisAddress = address(this);
    emit LogAddr(address(this));
  }
}
```


深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。

