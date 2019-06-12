---
title: 以太坊合约地址是怎么计算出来的？
permalink: address-compute
date: 2019-06-10 11:25:59
categories: 问与答
tags: 
    - Solidity
author: Tiny熊
---


{% cq %}
合约地址是怎么计算出来的？有没有办法提前知道合约的地址？
{% endcq %}

<!-- more -->

## 合约地址生成

以太坊合同的地址是根据创建者（sender）的地址以及创建者发送过的交易数量（nonce）来计算确定的。 `sender`和`nonce` 进行[RLP编码](https://learnblockchain.cn/2019/05/20/geth-rlp-encode/)，然后用`Keccak-256` 进行hash计算。

参考 [pyethereum](https://github.com/ethereum/pyethereum/blob/782842758e219e40739531a5e56fff6e63ca567b/ethereum/utils.py) 代码（Python）：

```python
def mk_contract_address(sender, nonce):
    return sha3(rlp.encode([normalize_address(sender), nonce]))[12:]
```

**使用 Solidity 代码**：

```
//  nonce 为 0 时生成的地址
nonce0 = address(keccak256(0xd6, 0x94, address, 0x80))
nonce1 = address(keccak256(0xd6, 0x94, address, 0x01))
```

这里有一些[讨论](https://swende.se/blog/Ethereum_quirks_and_vulns.html)：

如果 sender 为 0x6ac7ea33f8831ea9dcc53393aaa88b25a785dbf0 ， 创造的合约地址如下，这个过程完全是确定的：

```
nonce0= "0xcd234a471b72ba2f1ccf0a70fcaba648a5eecd8d"  
nonce1= "0x343c43a37d37dff08ae8c4a11544c718abb4fcf8"
nonce2= "0xf778b86fa74e846c4f0a1fbd1335fe81c00a0c91"
nonce3= "0xfffd933a0bc612844eaf0c6fe3e5b8e9b6c1d19c"
```

**使用 Web3j 的 Java 代码**：

```java
private String calculateContractAddress(String address, long nonce){
    byte[] addressAsBytes = Numeric.hexStringToByteArray(address);

    byte[] calculatedAddressAsBytes =
            Hash.sha3(RlpEncoder.encode(
                    new RlpList(
                            RlpString.create(addressAsBytes),
                            RlpString.create((nonce)))));

    calculatedAddressAsBytes = Arrays.copyOfRange(calculatedAddressAsBytes,
            12, calculatedAddressAsBytes.length);
    String calculatedAddressAsHex = Numeric.toHexString(calculatedAddressAsBytes);
    return calculatedAddressAsHex;
}
```

**注**：根据[EIP 161 规范](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md#specification)合约帐户使用 **nonce=1** 初始（在主网络上）。 因此，由一个合同创建的第一个合同地址将使用非零nonce进行计算。

## CREATE2

在[EIP-1014](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1014.md)中添加了一个新的操作码 `CREATE2` （在19年1月的君士坦丁堡硬分叉中引入的操作码），它是可以创建合约的另一种方式。


对于由`CREATE2`创建的合约，其地址将是:

```python
keccak256(0xff ++ senderAddress ++ salt ++ keccak256(init_code))[12:]
```

{% note info %}

CREATE2 在二层扩容尤其是状态通道中很有用, 这里有一个例子来[理解简单的状态通道](https://learnblockchain.cn/docs/solidity/examples/micropayment.html)， 即便状态通道合约还不存在，只要确定创建合约的 salt，init_code, 就可以用状态通道进行支付。
{% endnote %}


更多信息`CREATE2`， 参阅[EIP-1014](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1014.md)。

原问答[链接](https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed)

深入浅出区块链知识星球提供专业的[区块链问答](https://learnblockchain.cn/2019/01/12/about-qa/)服务，如果你需要问题一直没有思路，也许可以考虑咨询下老师。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
