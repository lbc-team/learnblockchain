---
title: Solidity 中 bytes类型如何转换为整型 uint
permalink: bytes-to-uint
date: 2019-10-16 11:25:59
categories: 问与答
tags:
    - bytes
    - Solidity
author: Tiny熊
---

Solidity 中 bytes类型如何转换为整型 uint

<!-- more -->

##  bytes类型如何转换为整型 uint

```js
    function bytesToUint(bytes memory b) public view returns (uint256){
        
        uint256 number;
        for(uint i= 0; i<b.length; i++){
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
        return (ad, number);
    }
```


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里