
---
title: 以太坊RLP(递归长度前缀)编码
permalink: geth-rlp-encode
date: 2019-05-20 20:41:20
categories: 基础理论
tags: 
    - RLP编码
author: 清源
---

RLP（Recursive Length Prefix）即**递归长度前缀编码**，RLP主要用于以太坊数据的网络传输和持久化存储。
说明：十六进制表示数字前面会加‘0x’， 十进制直接用数字表示，如`0x80`和`128`是一个数字的不同表示，只占用一个字节。

<!-- more -->

## 为什么需要RLP编码

比较常见的序列化方法有`JSON`，`ProtoBuf`，但是这些序列化方法在[以太坊](https://learnblockchain.cn/2017/11/20/whatiseth/)这样的场景下都有一些问题。 比如像`Json`编码，编码后的体积比较大。

```
type Persion struct {
    Name string
    Age uint 
}

p := &Persion{Name: "Tom", Age: 22}
data, _ := json.Marshal(p)

fmt.Println(string(data))
//  {"Name":"Tom","Age":22}
```

从编码后的结果可以看到`{"Name":"Tom","Age":22}`，其实我们需要的数据是`Name`, `Tom`, `Age`, `22`，其余的括号和引号都是描述这种格式的，也就是冗余数据。
当然，会有人说可以用`protoBuf`这样的二进制格式，但是例如`JavaScript`这样的弱类型语言，是没有`int`类型的，所有数字都是用`Number`类型，底层用浮点数来实现，这样就会导致因为语言的不同编码后的数据有一定差异，最后得到的`hash`值也不同。 针对这些问题，以太坊设计了`RLP`编码，同时也大幅简化了编码规则。

## `RLP`编码定义

RLP（Recursive Length Prefix）即**递归长度前缀编码**， 不定义任何指定的数据类型， 仅以嵌套数组的形式存储结构。

`RLP`简化了编码的类型，只定义了两种类型编码：

 - 字符串（byte数组）
 - 字符串（byte数组）的数组，也就是`列表`.

## `RLP`编码基于上面两种数据类型提出了5条编码规则;

**规则一:**

对于值在[0, 127]（十六进制[0x00, 0x7f]）之间的单个字节，其编码是其本身；无需前缀。

```
a的编码是97
```

**规则二:**

如果字符串的长度为0-55个字节之间，编码的结果是数组本身，再加上`0x80 + 字符串长度`作为前缀， 前缀范围是：[0x80, 0xb7] 即十进制[128, 183]。

```
空字符串的编码是128，即 128=128+0
abc的编码是131 97 98 99，其实131=128+len("abc"), 97 98 99依次是`a b c`
```

**规则三:**

如果字符串（数组）长度大于55字节，编码结果第一个值是183（128+55）+ `数组长度的编码的字节长度`，然后是数组长度本身的编码，最后是byte数组的编码（共三个部分）。前缀范围是：[0xb8, 0xbf] 即十进制[184, 191]。

```
编码一个重复1024次"a"的字符串，其结果是`185 4 0 97 97 97 ...
```

1024（2的10次方）按照大端编码是`0000 0000 001`转换为十六进制是`0 0 4 0`，省略前面的`0`,长度为`2`， 因此`185 = 183 + 2`

> 大端编码(BigEndian): 低字节在高内存地址 ;  小端编码(LittleEndian): 低字节在低内存地址

**规则四**

如果列表总内容RLP编码后字节长度小于55，编码结果第一位是`192` + `列表内容编码的长度`，然后依次连接各个子列表的编码，前缀范围是：[0xc0, 0xf7] 即十进制[192,247]。

```
空列表[]编码结果为：192
["abc", "def"]的编码结果是 200 131 97 98 99 131 100 101 102
```

其中`abc`的编码是`131 97 98 99`, `131 = 128 + len("abc")` ， abc的编码长度是4，同样`def`的编码是`131 100 101 102`，编码长度是4，两个子字符串的编码后总长度为8，编码结果的第一位 `200 = 192 + 8`

**规则五**

如果总内容RLP编码后字节长度超过55，编码结果第一位是`0xf7` + `列表长度的编码长度`，然后是列表长度本身的编码，最后依次连接子列表的编码，前缀范围是：[0x80, 0xb7] 即十进制[247,256]。

```
["The length of this sentence is more than 55 bytes, ", "I know it because I pre-designed it"]
```

其中前两个字节的计算方式如下： 
```
1. "The length of this sentence is more than 55 bytes, "的长度为51(0x33)，根据规则二得出前缀179 （0xb3 = 0x80 + 0x33 ）
2. "I know it because I pre-designed it"的长度为35(0x23)，根据规则2得出前缀163 （0xa3 = 0x80 + 0x33)
3. 列表长度本身的编码为：51 + 35 + 2(个子串的前缀占用) = 88 （0x58）
4. 最后根据规则5，0x58只占用一个字节，即 247(0xf7) + 1 = 248 ， 前缀为 248。
```

的编码结果表示是:

```
248 88 179 84 104 101 32 108 101 110 103 116 104 32 111 102 32 116 104 105 115 32 115 101 110 116 101 110 99 101 32 105 115 32 109 111 114 101 32 116 104 97 110 32 53 53 32 98 121 116 101 115 44 32 163 73 32 107 110 111 119 32 105 116 32 98 101 99 97 117 115 101 32 73 32 112 114 101 45 100 101 115 105 103 110 101 100 32 105 116
```

其中规则三，规则四，规则5是递归定义的（允许嵌套）。

## 编码实现

```python

def rlp_decode(input):
    if len(input) == 0:
        return
    output = ''
    (offset, dataLen, type) = decode_length(input)
    if type is str:
        output = instantiate_str(substr(input, offset, dataLen))
    elif type is list:
        output = instantiate_list(substr(input, offset, dataLen))
    output = output + rlp_decode(substr(input, offset + dataLen))
    return output

def decode_length(input):
    length = len(input)
    if length == 0:
        raise Exception("input is null")
    prefix = ord(input[0])
    if prefix <= 0x7f:
        return (0, 1, str)
    elif prefix <= 0xb7 and length > prefix - 0x80:
        strLen = prefix - 0x80
        return (1, strLen, str)
    elif prefix <= 0xbf and length > prefix - 0xb7 and length > prefix - 0xb7 + to_integer(substr(input, 1, prefix - 0xb7)):
        lenOfStrLen = prefix - 0xb7
        strLen = to_integer(substr(input, 1, lenOfStrLen))
        return (1 + lenOfStrLen, strLen, str)
    elif prefix <= 0xf7 and length > prefix - 0xc0:
        listLen = prefix - 0xc0;
        return (1, listLen, list)
    elif prefix <= 0xff and length > prefix - 0xf7 and length > prefix - 0xf7 + to_integer(substr(input, 1, prefix - 0xf7)):
        lenOfListLen = prefix - 0xf7
        listLen = to_integer(substr(input, 1, lenOfListLen))
        return (1 + lenOfListLen, listLen, list)
    else:
        raise Exception("input don't conform RLP encoding form")

def to_integer(b):
    length = len(b)
    if length == 0:
        raise Exception("input is null")
    elif length == 1:
        return ord(b[0])
    else:
        return ord(substr(b, -1)) + to_integer(substr(b, 0, -1)) * 256
```

## 参考文章

https://github.com/ethereum/wiki/wiki/RLP
http://hidskes.com/blog/2014/04/02/ethereum-building-blocks-part-1-rlp/

本文作者是深入浅出区块链共建者清源，欢迎关注清源的[博客](qyuan.top)，不定期分享一些区块链底层技术文章。
备注：编者在原文上略有修改。


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。



