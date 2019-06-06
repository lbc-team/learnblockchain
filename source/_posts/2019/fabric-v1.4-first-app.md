---
title: 利用Hyperledger Fabric开发第一个区块链应用
date: 2019-04-22 11:04:46
permalink: fabric-v1.4-first-app
catagories: Fabric
tags:
 - Fabric入门
 - Fabric
author: TopJohn
---

> 本文示例源于`fabric-samples`中的[fabcar](https://github.com/hyperledger/fabric-samples)

在这个例子中，我们通过一个简单的示例程序来了解Fabric应用是如何运行的。在这个例子中使用的应用程序和智能合约（链码）统称为`FabCar`。这个例子很好地提供了一个开始用于理解`Hyperledger Fabric`。在这里，你将学会如何开发一个应用程序和智能合约来查询和更新账本，如何利用`CA`来生成一个应用程序需要的用于和区块链交互的X.509证书。

<!-- more -->

我们使用应用程序SDk来执行智能合约中的查询更新账本的操作，这些操作在智能合约中借助底层接口实现。

我们将通过3个步骤来进行讲解：

1. **搭建开发环境**。我们的应用程序需要和网络交互，因此我们需要一个智能合约和应用程序使用的基础网络。

![应用交互图](https://img.learnblockchain.cn/2019/15561157456697.png!/scale/40%)

2. **学习一个简单的智能合约：FabCar**。我们使用**JavaScript**开发智能合约。我们通过查看智能合约来学习应用程序如何使用智能合约发送交易，如何使用智能合约来查询和更新账本。
   
3. **使用FabCar开发一个简单的应用程序**。我们的应用程序会使用`FabCar`智能合约来查询及更新账本上的汽车资产。我们将进入应用程序的代码中去了解如何创建交易，包括查询一辆汽车的信息，查询一批汽车的信息以及创建一辆汽车。

## 设置区块链网络

> 注意：下面的部分需要进入你克隆到本地的`fabric-samples`仓库的`first-network`子目录。

如果你已经学习了` Building Your First Network`，你应该已经下载了`fabric-samples`而且已经运行起了一个网络。在你进行本教程之前，你需要停止这个网络：

```shell
./byfn.sh down
```

如果你之前运行过这个教程，使用下面的命令关掉所有停止或者运行的容器。注意，这将关掉**所有**的容器，不论是否和Fabric有关。

```shell
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images | grep fabcar | awk '{print $3}')
```

如果你没有这个网络和应用相关的开发环境和构件，请访问[ Prerequisites](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html)页面（或[参考](https://learnblockchain.cn/2019/02/21/fabric-1.4-install-demo/)），确保你的机器安装了必要的依赖。

接下来，如果你还没有这样做的话，请浏览[ Install Samples, Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/latest/install.html)页面，跟着上面的操作进行。当你克隆了`fabric-samples`仓库，下载了最新的稳定版Fabric镜像和相关工具之后回到教程。

如果你使用的是Mac OS和Mojava，你需要安装[Xcode](https://hyperledger-fabric.readthedocs.io/en/latest/tutorial/installxcode.html)。

## 启动网络

> 下面的部分需要进入`fabric-samples`仓库的`fabcar`子目录。

使用`startFabric.sh`来启动你的网络。这个命令将启动一个区块链网络，这个网络由peer节点、排序节点、证书授权服务等组成。同时也将安装和初始化javascript版本的`FabCar`智能合约，我们的应用程序将通过它来操作账本。我们将通过本教程学习更过关于这些组件的内容。

```shell
./startFabric.sh javascript
```

现在，我们已经运行起来了一个示例网络，还安装和初始化了`FabCar`智能合约。为了运行我们的应用程序，我们需要安装一些依赖，同时让我们看一下它们是如何工作的。

## 安装应用程序

> 注意：下边的章节需要进入你克隆到本地的`fabric-samples`仓库的`fabcar/javascript`子目录。
下面的命令来安装应用程序所需的Fabric有关的依赖。大概将话费1分钟左右的时间：

```shell
npm install
```

这个指令用于安装应用程序所需的依赖，这些依赖被定义在`package.json`中。其中最重要的是`fabric-network`类；它使得应用程序可以使用身份、钱包和连接到通道的网关，以及提交交易和等待通知。本教程也将使用`fabric-ca-client`类来注册用户以及他们的授权证书，生成一个`fabric-network`使用的合法的身份。

一旦`npm install`执行成功，运行应用程序所需的一切就准备好了。在这个教程中，你将主要使用`fabcar/javascript`目录下的JavaScript文件来操作应用程序。让我们来了解一下里面有哪些文件：

```shell
ls
```

你将看到下列文件：

```shell
enrollAdmin.js  node_modules       package.json  registerUser.js
invoke.js       package-lock.json  query.js      wallet
```
里面也有一些其他编程语言的文件，比如`fabcar/typescript`目录中。当你使用过JavaScript示例之后-其实都是类似的。

如果你在使用Mac OS而且运行的是Mojava你需要`[安装Xcode](https://hyperledger-fabric.readthedocs.io/en/latest/tutorial/installxcode.html)`。

## 登记管理员用户

> 下面的部分涉及执行和CA服务器通讯的过程。你在执行下面的程序的时候，打开一个终端执行`docker logs -f ca.example.com`来查看CA的日志，会是十分有帮助的。

当我们创建网络的时候，一个叫`admin`的用户已经被授权服务器（CA）创建为**登记员**。我们第一步要做的是使用`enroll.js`程序为`admin`生成私钥，公钥和x.509证书。这个程序使用一个证书签名请求 (CSR)--先在本地生成私钥和公钥，然后把公钥发送到CA，CA会发布一个应用程序使用的证书。这三个凭证会保存在钱包中，以便于我们以管理员的身份使用CA。

接下来我们会注册和登记一个新的应用程序用户，我们将使用这个用户来通过应用程序和区块链进行交互。

让我们登记一个`admin`用户：

```shell
node enrollAdmin.js
```
这个命令将CA管理员证书保存在`wallet`目录。

## 注册和登记`user1`

现在我们在钱包里放了管理员的证书，我们可以登记一个新用户--user1--用这个用户来查询和更新账本：

```shell
node registerUser.js
```

和登记管理员类似，这个程序使用了CSR来登记`user1`并把它的证书保存到`admin`所在的钱包中。现在我们有了2个独立的用户--`admin`和`user1`--它们都将用于我们的应用程序。

接下来是账本交互时间...

## 查询账本

区块链网络中的每个节点都拥有一个账本的副本，应用程序可以通过执行智能合约查询账本上的最新舒徐来实现查询账本操作，将结果返回给应用程序。

这是一个如何查询的简单阐述：

![fabric 查询账本图](https://img.learnblockchain.cn/2019/15561160817806.png!/scale/60%)


应用程序使用查询从ledger读取数据。最常见的就是查询当前账本中的最新值--世界状态。世界状态是一个键值对的集合，应用程序可以根据一个键或者多个键来查询数据。而且，当键值对是以JSON形式存在的时候，世界状态可以通过配置使用数据库（例如CouchDB）来支持富查询。这个特性对于查询匹配特定的键的值是很有帮助的，比如查询一个人的所有汽车。

首先，让我们使用`query.js`程序来查询账本上的所有汽车。这个程序使用我们的第二个身份--`user1`--来操作账本。

```shell
node query.js
```

输出结果如下：

```shell
Wallet path: ...fabric-samples/fabcar/javascript/wallet
Transaction has been evaluated, result is:
[{"Key":"CAR0", "Record":{"colour":"blue","make":"Toyota","model":"Prius","owner":"Tomoko"}},
{"Key":"CAR1", "Record":{"colour":"red","make":"Ford","model":"Mustang","owner":"Brad"}},
{"Key":"CAR2", "Record":{"colour":"green","make":"Hyundai","model":"Tucson","owner":"Jin Soo"}},
{"Key":"CAR3", "Record":{"colour":"yellow","make":"Volkswagen","model":"Passat","owner":"Max"}},
{"Key":"CAR4", "Record":{"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}},
{"Key":"CAR5", "Record":{"colour":"purple","make":"Peugeot","model":"205","owner":"Michel"}},
{"Key":"CAR6", "Record":{"colour":"white","make":"Chery","model":"S22L","owner":"Aarav"}},
{"Key":"CAR7", "Record":{"colour":"violet","make":"Fiat","model":"Punto","owner":"Pari"}},
{"Key":"CAR8", "Record":{"colour":"indigo","make":"Tata","model":"Nano","owner":"Valeria"}},
{"Key":"CAR9", "Record":{"colour":"brown","make":"Holden","model":"Barina","owner":"Shotaro"}}]
```

让我们近距离看一下这个程序。使用文本编辑器（如atom或者visual studio）打开`query.js`。

应用程序开始的时候就从`fabric-network`模块引入了两个关键的类`FileSystemWallet`和`Gateway`。这两个类将用于定位钱包中`user1`的身份，并且使用这个身份连接网络：

```javascript
const { FileSystemWallet, Gateway } = require('fabric-network');
```

应用程序使用网关连接网络：

```javascript
const gateway = new Gateway();
await gateway.connect(ccp, { wallet, identity: 'user1' });
```

这段代码创建了一个新的网关，然后通过它来让应用程序连接网络。`cpp`描述了网关通过`wallet`中的`user1`来连接网络。打开 `../../basic-network/connection.json`来查看`cpp`是如何解析一个JSON文件的：

```javascript
const ccpPath = path.resolve(__dirname, '..', '..', 'basic-network', 'connection.json');
const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
const ccp = JSON.parse(ccpJSON);
```

如果你想了解更多关于连接配置文件的结构以及它是怎么定义网络的，请查阅[ the connection profile topic](https://hyperledger-fabric.readthedocs.io/en/latest/developapps/connectionprofile.html)

一个网络可以被拆分成很多个通道，代码中下一个很重要的地方是将应用程序连接到特定的通道`mychannel`上：

在这个通道中，我们可以通过`fabcar`智能合约来和账本进行交互：

```javascript
const contract = network.getContract('fabcar');
```

在`fabcar`中有许多不同的交易，我们的应用程序先使用`queryAllCars`交易来查询账本的世界状态：

```javascript
const result = await contract.evaluateTransaction('queryAllCars');
```

`evaluateTransaction`方法呈现了一种和区块链网络中的智能合约交互的最简单的方法。它只是根据配置文件中的定义连接一个节点，然后向节点发送请求，在节点内执行该请求。智能合约查询了节点账本上的所有汽车，然后把结果返回给应用程序。这次交互并没有更新账本。

## FabCar 智能合约

让我们看一看`FabCar`智能合约里的交易。进入`fabric-samples`下的子目录`chaincode/fabcar/javascript/lib`，然后用你的编辑器打开`fabcar.js`。

看一下我们的智能合约是如何通过`Contract`类来定义的：

```javascript
class FabCar extends Contract {...
```

在这个类结构中，你将看到定义了以下交易： `initLedger`，`queryCar`，`queryAllCars`，`createCar`和`changeCarOwner`。例如：

```javascript
async queryCar(ctx, carNumber) {...}
async queryAllCars(ctx) {...}
```

让我们更进一步看一下 queryAllCars ，看一下它是怎么和账本交互的。

```javascript
async queryAllCars(ctx) {

  const startKey = 'CAR0';
  const endKey = 'CAR999';

  const iterator = await ctx.stub.getStateByRange(startKey, endKey);
```

这段代码定义了 queryAllCars 将要从账本获取的汽车的范围。从 CAR0 到 CAR999 的每一辆车 -- 一共 1000 辆车，假定每个键都被合适地锚定了 -- 将会作为查询结果被返回。 代码中剩下的部分，通过迭代将查询结果打包成 JSON 并返回给应用。

下边将展示应用程序如何调用智能合约中的不同交易。每一个交易都使用一组 API 比如 getStateByRange 来和账本进行交互。了解更多API请阅读[文档](https://fabric-shim.github.io/master/index.html?redirect=true)。

![账本交互图](https://img.learnblockchain.cn/2019/15561163104691.png!/scale/50%)


你可以看到我们的`queryAllCars`交易，还有另一个叫做`createCar`。我们稍后将在教程中使用他们来更新账本，和添加新的区块。

但是在那之前，返回到`query`程序，更改`evaluateTransaction`的请求来查询为`CAR4`。`query`程序现在如下：

```javascript
const result = await contract.evaluateTransaction('queryCar', 'CAR4');
```

保存程序，然后返回到`fabcar/javascript`目录。现在，再次运行`query`程序：

```javascript
node query.js
```

你应该会看到如下所示：

```shell
Wallet path: ...fabric-samples/fabcar/javascript/wallet
Transaction has been evaluated, result is:
{"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}
```

如果你查看一下之前`queryAllCars`的交易结果，你会看到`CAR4`是`Adriana`的`黑色 Tesla model S`，也就是这里返回的结果，是一样的。

我们可以使用`queryCar`交易来查询任意汽车，使用它的键（比如`CAR0`）得到车辆的制造商、型号、颜色和车主等相关信息。

非常好。现在你应该已经了解了智能合约中基础的查询交易，也手动修改了查询程序中的参数。

是时候进行更新账本了。

## 更新账本

现在我们已经完成一些账本的查询操作，添加了一些代码，我们已经准备好更新账本了。我们进行更新操作了，但是我们从创建一辆新车开始。

从一个应用程序的角度来说，更新一个账本很简单。应用程序向区块链网络提交一个交易， 当交易被验证和提交后，应用程序会收到一个交易成功的提醒。但是在底层，区块链网络中各组件中不同的共识程序协同工作，来保证账本的每一个更新提案都是合法的，而且有一个大家一致认可的顺序。


![账本交互图](https://img.learnblockchain.cn/2019/15561163104691.png!/scale/50%)


上图中，我们可以看到完成这项工作的主要组件。同时，多个节点中每一个节点都拥有一份账本的副本，并可选的拥有一份智能合约的副本，网络中也有一个排序服务。排序服务保证网络中交易的一致性；它也将连接到网络中不同的应用程序的交易以定义好的顺序生成区块。

我们对账本的的第一个更新是创建一辆新车。我们有一个单独的程序叫做`invoke.js`，用来更新账本。和查询一样，使用一个编辑器打开程序定位到我们构建和提交交易到网络的代码段：

```javascript
await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');
```

看一下应用程序如何调用智能合约的交易`createCar`来创建一辆车主为Tom的黑色Honda Accord汽车。我们使用`CAR12`作为这里的键，这也说明了我们不必使用连续的键。

保存并运行程序：

```shell
node invoke.js
```

如果执行成功，你将看到类似输出：

```shell
Wallet path: ...fabric-samples/fabcar/javascript/wallet
2018-12-11T14:11:40.935Z - info: [TransactionEventHandler]: _strategySuccess: strategy success for transaction "9076cd4279a71ecf99665aed0ed3590a25bba040fa6b4dd6d010f42bb26ff5d1"
Transaction has been submitted
```

注意`inovke`程序使用的是`submitTransaction`API和区块链网络交互的，而不是`evaluateTransaction`。

```javascript
await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');
```

`submitTransaction`比`evaluateTransaction`要复杂的多。不只是和单个节点交互，SDK将把`submitTransaction`提案发送到区块链网络中每一个必要的组织的节点。每一个节点都将根据这个提案执行请求的智能合约，并生成一个该节点签名的交易响应并返回给SDK 。SDK将所有经过签名的交易响应收集到一个交易中，这个交易将会被发送到排序节点。排序节点搜集并排序每个应用的交易，并把这些交易放入到一个交易区块。然后排序节点将这些区块分发到网络中的节点，每一笔交易都会在节点中进行验证和提交。最后，SDK会后到提醒，并把控制权返回给应用程序。

> `submitTransaction`也会包括一个监听器用于确保交易已经被校验和提交到账本里了。应用程序需要利用监听器或者使用`submitTransaction`接口，它内部已经实现了监听器。如果没有监听器，你可能无法确定交易是否被排序校验以及提交。

应用程序中的这些工作由`submitTransaction`完成！应用程序、智能合约、节点和排序服务一起工作来保证网络中账本一致性的程序被称为共识。

为了查看这个被写入账本的交易，返回到`query.js`并将参数`CAR4`更改为`CAR12`。

换句话说就是将：

```javascript
const result = await contract.evaluateTransaction('queryCar', 'CAR4');
```

改为：

```javascript
const result = await contract.evaluateTransaction('queryCar', 'CAR12');
```

再次保存，然后查询：
```javascript
node query.js
```

将返回：

```shell
Wallet path: ...fabric-samples/fabcar/javascript/wallet
Transaction has been evaluated, result is:
{"colour":"Black","make":"Honda","model":"Accord","owner":"Tom"}
```

恭喜。你创建了一辆汽车并验证了它记录在账本上！

现在我们已经完成了，我们假设Tom很大方，想把他的Honda Accord送给一个叫Dave的人。

为了完成这个，返回到`invoke.js`然后利用输入的参数，将智能合约的交易从`createCar`改为`changeCarOwner`：
```javascript
await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');
```

第一个参数 ---`CAR12`--- 表示将要易主的车。第二个参数 ---`Dave`--- 表示车的新主人。

再次保存并执行程序：

```shell
node invoke.js
```
现在我们来再次查询账本，以确定Dave和`CAR12`键已经关联起来了：
```shell
node query.js
```

将返回如下结果：

```shell
Wallet path: ...fabric-samples/fabcar/javascript/wallet
Transaction has been evaluated, result is:
{"colour":"Black","make":"Honda","model":"Accord","owner":"Dave"}
```

`CAR12`的主人已经从Tom变成了Dave。

>在实际的应用中，智能合约有权限控制逻辑。举个例子，只有有权限的用户可以创建新车，只有车子的拥有者可以转移车辆所属权。

## 总结

现在我们已经完成了账本的查询和更新，你也应该比较了解如何通过智能合约和区块链进行交互来查询账本和更新账本了。在教程中已经讲解了查询和更新的智能合约，API和SDK，想必你对其他商业场景也有了一定的了解和认识。

通过`FabCar`这个例子，我们可以快速学习如何基于`Node SDK`开发应用程序。


本文经TopJohn授权转自[TopJohn’s Blog](https://www.xuanzhangjiong.top/)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。


