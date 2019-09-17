---
title: 如何区分合约地址还是普通账号地址？ 
permalink: is-contract
date: 2019-09-17 11:25:59
categories: 问与答
tags:
    - Solidity
author: Tiny熊
---


如何区分合约地址还是普通账号地址？

<!-- more -->

我们经常有需要区分一个地址是合约地址还是外部账号地址，区分的关键是看这个地址有没有与之相关联的代码。
EVM提供了一个操作码EXTCODESIZE，用来获取地址相关联的代码大小（长度），如果是外部账号地址，则没有代码返回。因此我们可以使用以下方法判断合约地址及外部账号地址：

```
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
```

如果是在合约外部判断，则可以使用web3.eth.getCode()，或者是对应的JSON-RPC方法eth_getcode。
getCode()用来获取参数地址所对应合约的代码，如果参数是一个外部账号地址，则返回"0x"；如果参数是合约，则返回对应的字节码，如下所示：

> web3.eth.getCode("0xa5Acc472597C1e1651270da9081Cc5a0b38258E3")
"0x"

web3.eth.getCode("0xd5677cf67b5aa051bb40496e68ad359eb97cfbf8")
> "0x600160008035811a818181146012578301005b601b6001356025565b8060005260206000f25b600060078202905091905056"

这样我们就可以通过getCode()的内容判断是哪一种地址了。
