---
title: Solidity 中如何删除数组中某个位置的元素？
permalink: delete-item
date: 2019-02-22 11:25:59
categories: 问与答
tags: 
    - Solidity
author: Tjaden Hess
---


{% cq %}
Solidity 中如何删除[数组](https://learnblockchain.cn/docs/solidity/types.html#arrays)中某个位置的元素？
{% endcq %}

<!-- more -->

## 使用 `delete` 操作符
 
 `delete` 操作符可以删除元素：

```
delete array[index];
```

## 移动元素（可选）
不过上面会留出一个空位置，如果先移除这个位置，则需要手动移动元素：

```
contract test{
    uint[] array = [1,2,3,4,5];
    function remove(uint index)  returns(uint[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;
    }
}
```

如果不关心元素的位置，可以把最后一个元素拷贝到删除的元素上。



## 参考文档

1. [数组成员](https://learnblockchain.cn/docs/solidity/types/reference-types.html#array-members)
2. [delete 操作符](https://learnblockchain.cn/docs/solidity/types.html#delete)


原问题[链接](https://ethereum.stackexchange.com/questions/1527/how-to-delete-an-element-at-a-certain-index-in-an-array)


深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
