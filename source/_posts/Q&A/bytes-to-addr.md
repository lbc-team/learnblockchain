---
title: Solidity 中 bytes类型如何转换为地址address类型
permalink: bytes-to-address
date: 2019-10-10 11:25:59
categories: 问与答
tags:
    - bytes
    - Solidity
author: Tiny熊
---

Solidity 中 bytes类型如何转换为地址address类型

<!-- more -->

## bytes 类型如何转换为address

转换方法如下：

```js

     function bytesToAddress(bytes memory bys) external pure returns (address addr) {
      assembly {
        addr := mload(add(bys,20))
      }
```



[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里