---
title: Solidity 中 uint 转 bytes
permalink: solidity-uint-to-bytes
date: 2019-07-10 11:25:59
categories: 问与答
tags:
    - Solidity
author: Tiny熊
---

Solidity 中很多[Hash函数,　如：keccak256　](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html#index-5)　等需要bytes作为一个参数，这个时候有时需要把uint转化为bytes　。

<!-- more -->

## uint 如何转为 bytes　类型

Solidity 中 uint 转 bytes 的几种方法，gas 消耗从少到多：
1. toBytes0(): 用inline assembly 实现, Gas 消耗最少，最高效的方法。
    
    > 备注： 这个实现在某情况下会出现out-of-gas,  原因未知。
    
2. toBytes1() : 用inline assembly 实现 **推荐**；
3. toBytes2() : 先转化为bytes32，再按一个个直接复制；
4. toBytes3() :　按一个个直接转换，效率最低。



```js

pragma solidity >=0.4.22 <0.7.0;

contract uintTobytes {

  // 比　toBytes1　少 15% de gas
    function toBytes0(uint _num) public returns (bytes memory _ret) {
      assembly {
        _ret := mload(0x10)
        mstore(_ret, 0x20)
        mstore(add(_ret, 0x20), _num)
        }
    }


    function toBytes1(uint256 x) public  returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }



    function toBytes2(uint256 x) public  returns (bytes memory c) {
        bytes32 b = bytes32(x);
        c = new bytes(32);
        for (uint i=0; i < 32; i++) {
            c[i] = b[i];
        }
    }


    function toBytes3(uint256 x) public  returns (bytes memory b) {
        b = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            b[i] = byte(uint8(x / (2**(8*(31 - i)))));
        }
    }

}
```

关于gas的消耗，大家也可以自己对比。


原问答链接：
https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity


深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
