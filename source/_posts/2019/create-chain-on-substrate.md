---
title: 使用Substrate搭建一条能跨链的区块链
date: 2019-05-30 22:48:34
permalink: create-chain-on-substrate
category:
    - 跨链
    - Polkadot
tags: 
    - Substrate
    - Polkadot
author: 孙凯超
---

Substrate 是Polkadot项目推出的**区块链构建框架**。通过使用Substrate，使普通的软件开发人员可以在短时间内建立一条**属于自己的完整区块链**，开发者只需要关注自己的业务逻辑，从底层复杂的技术中解放出来。

<!-- more -->


## 为什么使用区块链

比特币网络作为最早的区块链网络，已经存在了十年时间。在今天，区块链技术还没有像互联网那样深刻地改变着我们每个人的生活，但是它的优势已经在一些行业和领域展现出来，比如国际支付、金融衍生品交易、预测市场、去中心化自治组织等。

区块链或者更准确的说是去中心账本，相对于传统互联网行业有其天生的优势，比如：

* **永不离线** - 安全的公有链又全球数以万计的计算机节点共同维护，理论上讲只要还有一个节点可供访问，数据就不会丢失。
* **开源审查** - 绝大部分区块链应用的代码都是开源的，供全世界的开发人员审查，除了能够提升代码质量，开源运动更为深远的意义在于通过分享促进着人类社会的进步。
* **数据加密** - 密码学技术是去中心账本的基石，保证数据不被篡改，让数据更加安全。
* **保护隐私** - 每一个用户都是链上的一个账户，而账户的所有信息完全由掌握账户所对应私钥的用户控制着，除非用户自己公开或者交易数据，否则数据不会泄露。
* **分享权益** - 用户可以通过参与到区块链的安全运转机制中，获取到原本只有中心化的企业才能拿到的权益。

随着区块链技术的不断演进，交易成本、确认时间、能源消耗、安全性、互通性都得到了极大地提升，传统互联网企业在相同的产业领域将面临着具有以上所说优势的区块链企业的挑战。

现在处在优势地位的传统互联网"独角兽"，如果依靠区块链技术成功转型，能够确保在未来不会被轻易淘汰；

处于劣势地位的小企业或者小团队，通过在链上实现业务，可以达到"四两拨千斤"的竞争优势。

然而区块链的开发依赖多学科的知识技能，比如密码学、高效点对点网络、软件工程、经济学模型等等，小团队甚至是大企业都很难具备这样的人才资源，对于"上链"大多数人都是心有余而力不足。`Substrate`的出现就是为了解决这个问题。

## 什么是Substrate

[Substrate](https://github.com/paritytech/substrate)是由德国[Parity](https://github.com/paritytech/substrate)公司推出的一个**区块链构建框架**。它实现了区块链开发领域中所遇到的大部分通用功能，比如点对点网络连接，可配置的共识算法，常用加密算法，数据库存储，交易管理等。通过使用Substrate，使普通的软件开发人员可以在短时间内建立一条**属于自己的完整区块链**，开发者只需要关注自己的业务逻辑，从底层复杂的技术中解放出来。

使用Substrate构建的区块链，有一个额外的好处，就是可以轻易地连接到Parity的Polkadot公链网络，这一网络具有很多优势，比如**跨链交易**、**共享安全**等。

Substrate是由Rust语言开发，而Rust最为一门高级静态编程语言，具有诸多优势，如内存安全、类型检查、支持编译为WASM、函数式友好、社区资料完善等优点。通过借助Rust的优良特性，也使得Substrate的性能优良、可读性高。

你也可以参考Substrate官方[参考文档](https://docs.substrate.dev/docs)来了解更多。

下面，进入今天我们的主要任务，使用Substrate来构建一条本地的测试区块链网络。

## 搭建区块链

通过这一节，你会学到：

* 如何创建和编译节点程序
* 如何启动节点程序及各项参数配置
* 不同的节点网络有什么区别
* 如何修改chainspec文件

### 准备环境

* Mac OS 或者Linux计算机
* Git

### 创建和编译节点程序

#### 方式一

1. 安装依赖工具，如Rust环境、openssl、cmake、 llvm库：

```shell
curl https://getsubstrate.io -sSf | bash
```

如果感兴趣上面脚本的具体执行内容，可以参考[这里](https://getsubstrate.io)。由于国内网络原因，以上脚本可能会下载失败或者过慢，参考下面的方法配置国内的Rust仓库镜像进行下载。

```shell
git clone https://github.com/kaichaosun/getsubstrate-cn

cd substrate-cn

cp config ~/.cargo/config

./getsubstrate
```

2. 新建节点程序，使用命令行导航至你想要放置节点程序的目录，执行：

```shell
substrate-node-new substrate-demo-node someone
```

 你也可以替换`substrate-demo-node`为你想要的节点程序名，替换`someone`为你自己的名字。等待命令执行完后，一个属于自己的节点程序就完成了。

注：`substrate-node-new`命令会帮你拷贝substrate[模板节点程序](https://github.com/paritytech/substrate/tree/master/node-template)、初始化WASM的构建环境、编译Rust代码为WASM等，具体内容参考[链接](https://github.com/paritytech/substrate-up/blob/master/substrate-node-new)。

如果发生了代码改动，就需要重新编译。

首先，编译Rust代码为WASM：

```shell
./build.sh
```

之后，编译生成可执行程序：

```shell
cargo build --release
```

可执行程序被放为`target/release/template-node`。

#### 方式二

另外一种创建节点的方式是通过拷贝substrate的Git源码，编译node-template：

```shell
git clone https://github.com/paritytech/substrate

git checkout -b v1.0

cd substrate

cd node-template

# 初始化WASM的构建环境
./scripts/init.sh

# 编译Rust代码为WASM
./scripts/build.sh

# 生成可执行程序
cargo build --release
```

这种方式适合对substrate源码有一定了解的人，**如果是初学者，建议用上面第一种方式**。

### 本地开发网络

首先清空节点数据库：

```shell
./target/release/template-node purge-chain --dev
```

然后启动节点程序：

```shell
./target/release/template-node --dev
```

`--dev`表示我们准备启动一个本地开发链，会自动初始化开发环境所需的数据和配置。

如果出现了类似下图所示地内容，那恭喜你成功创建了一条本地开发链。

![dev_node](https://img.learnblockchain.cn/2019/06/15598051515020.jpg)


现在你可以访问[https://substrate-ui.parity.io](https://substrate-ui.parity.io)，选择Settings，将remote node设置为Local Node (127.0.0.1:9944)，如下图所示：

![ui_local_node](https://img.learnblockchain.cn/2019/06/15598051743127.jpg)


选择Explorer，就能够看到最新的区块在不断产生。

下面，我们来发送一笔交易，选择Extrinsics，`submit the following extrinsic`选择为`balances` `transfer(dest, value)`，`dest: Address`选择为`BOB`，`value: Compact<Balance>`设置为你想转账的金额，之后点击Submit Transaction，几秒钟之后会弹出交易成功的提示，这个时候你可以看到Alice的金额减少了，当切换`using the selected account`为Bob之后，可以看到他的金额增加。

接下来请你要独立地尝试这个页面上的不同功能，不用担心把辛苦搭建的链玩坏，这也是Substrate的一个好处，可以快速清理垃圾数据。

### 本地多节点测试网络

这里我们使用本地测试网络内置的账户，首先启动Alice节点：

```shell
./target/release/template-node \
  --base-path /tmp/alice \
  --chain=local \
  --key //Alice \
  --port 30333 \
  --telemetry-url ws://telemetry.polkadot.io:1024 \
  --validator \
  --name AlicesNode
```

命令行参数的涵义如下：

* `--base-path /tmp/alice`：节点数据所存储的位置
* `--chain=local`：指定了节点所处的网络类型，这里`local`表示本地测试网络，`dev`表示本地开发，`staging`表示公开测试网络
* `--key //Alice`：模块节点程序启动时需要私钥，这里我们用了预置的Alice用户私钥
* `--port 30333`：指定p2p协议的TCP端口
* `--telemetry-url ws://telemetry.polkadot.io:1024`：将节点的监控数据发送到指定的监控服务器
* `--validator`：启用validator模式，参与区块生产
* `--name AlicesNode`：指定节点名

命令执行之后，应该能看到以下启动信息：

![alice_node](https://img.learnblockchain.cn/2019/06/15598051951500.jpg)


打开一个新的命令行窗口，启动Bob节点：

```shell
./target/release/template-node \
  --base-path /tmp/bob \
  --chain=local \
  --key //Bob \
  --port 30334 \
  --telemetry-url ws://telemetry.polkadot.io:1024 \
  --validator \
  --name BobsNode \
  --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/QmRhEhiX8QHVW87wKCTp3qKyY1X21ycKXKdDBrqSR74NWx
```

这里，我们为Bob节点指定了不同的数据存储路径、p2p端口等，`--bootnodes`指明了依赖的启动节点信息，这里使用了Alice节点作为启动节点，`30333`为Alice节点的端口，`QmRhEhiX8QHVW87wKCTp3qKyY1X21ycKXKdDBrqSR74NWx`为Alice的节点ID。

如果一切正常，你应该能够看到：

```
Idle (1 peers), best: #2 (0x5155…5b72), finalized #0 (0x146f…317f), ⬇ 24 B/s ⬆ 0.1kiB/s
```

表示Bob节点连接到Alice节点上了(1 peers)，并且新产生的区块没有最终确定`finalized #0 (0x146f…317f)`，这是因为模块节点程序没有最终确定性这一功能，想要了解更多，请查看官方文档或者留意我的后续文章。

然后，和之前的方式相同，在浏览器访问区块的信息。

### 使用新账户启动本地测试网络

**生成新账户**

如果我们不想用预置的Alice和Bob账户启动网络，就需要执行`subkey -e generate`命令生成新账户，生成的内容包含私钥seed，公钥public key和交易地址Address：

账户1：

```shell
Phrase `gas ride shoe victory oil young music trend kingdom rookie south harbor` is account:
  Seed: 0x9aaae371d50d1109fee8595398e54a86f6c79b116ba1894e8207f503708f7d0f
  Public key (hex): 0xcc706bd768a54054ac70b3f5568d0103e0f70a2f878e37949e125dd7456ee180
  Address (SS58): 5Ggm2DMCG1LRcXUjGE6toVmyHKVSNutzSbUrvQv5gbr5BC6S
```

账户2：

```shell
Phrase `real during evidence worry mountain plastic depth desert actress infant age pill` is account:
  Seed: 0x16208851b59f7c6a383a70342fa0893169c7c3190c543d44bd42833f61e54a56
  Public key (hex): 0xd6147f4bbb0eeb925e61b31fbed45ab1e3c45fed8d36ce4161c99956dfdf8f9b
  Address (SS58): 5GuQCAzXM5xcJfEinUgWnB7PFn2ZGhQfAKAdGRhacRHsXWE9
```

将生成的内容安全地保存起来，通过分享地址给其它节点，实现p2p的连接。

注：如果没有subkey命令，需要到substrate源码目录下重新编译生成`cargo install --force --path subkey subkey`。

**构造chainspec文件**

Substrate区块链的初始启动信息在`chainspec`的json文件中维护着，首先生成一个local测试网络的chainspec:

```shell
./target/release/template-node build-spec --chain=local > localspec.json
```

编辑`localspec.json`，修改`authorities`为新生成用户的地址，其它不用修改：

```json
"consensus": {
 "authorities": [
  "5Ggm2DMCG1LRcXUjGE6toVmyHKVSNutzSbUrvQv5gbr5BC6S",
  "5GuQCAzXM5xcJfEinUgWnB7PFn2ZGhQfAKAdGRhacRHsXWE9"
 ],
 "code": "0x0061736d01000000018b011660027..."
}
```

修改完后，转换chainspec为原始格式，区别是原始格式的chainspec中所有的字段名都用十六进制进行了编码：

```shell
./target/release/template-node build-spec --chain localspec.json --raw > customspec.json
```

**启动节点**

启动账户1的节点：

```shell
./target/release/template-node \
  --base-path /tmp/account1 \
  --chain ./customspec.json \
  --key 0x9aaae371d50d1109fee8595398e54a86f6c79b116ba1894e8207f503708f7d0f \
  --port 30333 \
  --telemetry-url ws://telemetry.polkadot.io:1024 \
  --validator \
  --name Account1Node
```

这里，`--chain ./customspec.json`是启动区块链所需的chainspec文件。

启动账户2的几点：

```shell
./target/release/template-node \
  --base-path /tmp/account2 \
  --chain ./customspec.json \
  --key 0x16208851b59f7c6a383a70342fa0893169c7c3190c543d44bd42833f61e54a56 \
  --port 30334 \
  --telemetry-url ws://telemetry.polkadot.io:1024 \
  --validator \
  --name Account2Node \
  --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/5Ggm2DMCG1LRcXUjGE6toVmyHKVSNutzSbUrvQv5gbr5BC6S
```

这时候你已经拥有了属于自己的第一条区块链！

## 总结

恭喜你，完成了substrate搭建区块链的第一堂课，我们回顾一下学到的内容，包括安装substrate的依赖环境，创建和编译节点程序，启动测试网络，修改chainspec等等。社区提供了很多的资料供参考，也可以关注知乎专栏[《Substrate区块链开发》](https://zhuanlan.zhihu.com/substrate)。

## 参考资料

- [Start a Private Network with Substrate](https://docs.substrate.dev/docs/deploying-a-substrate-node-chain)

本文作者孙凯超, [原文链接](https://zhuanlan.zhihu.com/p/67580341)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。
