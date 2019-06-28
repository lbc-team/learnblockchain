---
title: fabric-first-network
permalink: fabric-first-network
un_reward: true
date: 2019-06-28 06:55:59
categories:
tags:
author: kunpeng
---

## 超级账本介绍

​		超级账本(hyperledger)项目是首个面向企业应用场景的开源分布式账本平台，于2015年12月份由Linux基金会牵头，成立项目组，推动区块链的相关协议，规范，标准的发展。

​		参与超级账本的规范制定，开发的企业和组织有IBM，Intel，Cisco等国际知名机构，国内参与机构有小蚁，布比，万达等企业。

​		超级账本项目，致力于构建透明，公开，去中心化的企业级分布式应用，主要应用在银行，证券，数字资产等金融领域，减少企业间的信任成本，增加机构之间互助合作的可能性。



## 超级账本项目

**fabric：**由IBM发起，包括fabric,fabric-ca,fabric-sdk等子项目，是区块链的基础核心平台。github地址：https://github.com/hyperledger/fabric；

**swatooth：**由Intel公司发起的项目，共识机制基于硬件芯片时间消逝证明(PoET)。github地址：https://github.com/hyperledger/sawtooth-core；

**Iroha：**由Soramitsu发起，用c++语言实现，支持web端和移动端的一些分布式需求。github地址：https://github.com/hyperledger/iroha；

**Cello**：由IBM发起，提供区块链平台的部署和运行时管理功能。使用Cello部署区块链，应用开发者不需要关心如何搭建和维护区块链。github地址：https://github.com/hyperledger/cello；

除以上主流项目之外，还有**Blockchain Explorer**, **Indy**， **Composer**, **Burrow**等小型项目。



## Fabric结构介绍

架构图如下：![framework](https://img.learnblockchain.cn/2019/06/28_framework.png!wl)

* 应用程序角度

  1. **身份管理**

     用户注册和登陆系统后，获取到用户注册证书，其他所有的操作都需要与用户证书关联的私钥进行签名，消息接收方首先会进行签名验证，才进行后续的消息处理。

  2. **账本管理**

     授权的用户是可以查询账本数据的，这可以通过多种方式查询，包括根据区块号查询区块，根据区块哈希查询区块，根据交易号查询区块，根据交易号查询交易，还可以根据通道名称获取查询到的区块信息。

  3. **交易管理**

     账本数据只能通过交易执行才能更新，应用程序通过交易管理提交交易天并获取到交易背书以后，再给排序服务节点提交交易，然后打包生成区块。

  4. **智能合约**

     实现“可编程的账本”，通过链码执行提交的交易，实现基于区块链的只能合约业务逻辑。

* 底层角度

  1. **成员管理(MSP)**

     MSP对成员管理进行了抽象，每个MSP都会建立一套根信任证书体系，利用PKI对成员身份进行认证，验证成员用户提交请求的签名。结合Fabric-CA或者第三方的CA系统，提供成员注册功能，并对成员身份证书进行管理。

  2. **共识服务**

     在分布式节点环境下，要实现同一个链上不同节点区块的一致性，同事要确保区块里的交易有效和有序。共识机制由3个阶段完成：(1)客户端向背书节点提交提案进行背书签名；(2)客户端将背书后的交易提交给排序服务节点进行排序，生成区块和排序服务；(3)广播给记账节点验证交易后写入本地账本。

  3. **链码服务**

     智能合约的实现依赖于安全的执行环境，确保安全的执行过程和用户数据的隔离。Fabric采用Docker管理普通的链码，提供安全的沙箱环境和镜像文件仓库。

  4. **安全和密码服务**

     Fabric定义了一个BCCSP(BlockChain Cryptographic Service Provider)的概念，使其实现密钥生成，哈希运算，签名验签，加密解密等基础功能。

## First Network

### 环境准备

**linux(ubuntu)**：fabric运行的系统平台；

**docker, docker-compose**：部署虚拟化镜像容器，学习时减少机器开销；链码运行环境为docker容器的沙箱环境；

**golang**：fabric运行的基础环境，编译fabric项目。



### 源码下载和编译

* 下载

在$GOPATH/src/github.com/hyperledger目录下执行：

```bash
git clone https://github.com/hyperledger/fabric
```

* 编译

``` bash
cd fabric
make all
```

* 编译中可能出现的问题

1. 服务器访问问题

   **错误信息**：package golang.org/x/tools/imports: unrecognized import path "golang.org/x/tools/imports"

   ![net_error](https://img.learnblockchain.cn/2019/06/28_neterror.png!wl)

   **原因**：golang.org/x/tools包在国内是访问不到它的服务器的

   **解决方法**：

   (1)用VPN翻墙编译;

   (2)从https://github.com/golang/tools上克隆再拷贝到GOPATH的golang.org/x/tools目录;

   (3)从https://gopm.io/download下载解压使用

2. 缺少protobuf工具问题

   **错误信息**：cp: 无法获取‘.build/docker/gotools/bin/protoc-gen-go’ 的文件状态(stat): 没有那个文件和目录

   !(proto-error)[https://img.learnblockchain.cn/2019/06/28_protoerror.png!wl]

   **原因**：系统环境下没有protoc-gen-go工具，无法拷贝到docker镜像

   **解决方法**：

   + 在系统终端执行go get -u github.com/golang/protobuf/protoc-gen-go，会在$GOROOT/bin生成protoc-gen-go文件；
   + 将$GOROOT/bin下的protoc-gen-go拷贝到.build/docker/gotools/bin目录

3. 检查dep错误

   **错误信息**：./scripts/check-deps.sh: line 7: dep: command not found

   ![dep-error](https://img.learnblockchain.cn/2019/06/28_deperror.png!wl)

   **原因**：docker buildenv镜像中没有将dep包管理工具打包进去，造成找不到dep命令

   **解决方法**：

   (1). 自己编写buildenv的Dockerfile，将dep拷贝进去；
   
   (2). 注释掉./scripts/check-deps.sh文件中的dep version和dep check两行，因为这两行命令只做了查看版本和检测的功能，在正常情况下是不需要用到的，注释掉不影响fabric的使用,如下：
   
   ![dep-modify](https://img.learnblockchain.cn/2019/06/28_depmodify.png!wl)

* 编译结果

  1. 在./build/bin目录下生成了一下执行文件

     chaintool  configtxgen  configtxlator  cryptogen  discover  idemixgen  orderer  peer
     
     *注意：要能正常使用fabric，则需要将./build/bin中的执行文件放到环境变量$PATH中*
  2. 生成了hyperledger fabric的一批镜像，包括
     
     ```bash
     hyperledger/fabric-tools    
     hyperledger/fabric-buildenv 
     hyperledger/fabric-ccenv    
     hyperledger/fabric-orderer  
     hyperledger/fabric-peer     
     hyperledger/fabric-ca       
     hyperledger/fabric-zookeeper
     hyperledger/fabric-kafka    
     hyperledger/fabric-couchdb  
     hyperledger/fabric-baseimage
     hyperledger/fabric-baseos   
     hyperledger/fabric-ccenv    
     ```

### 运行first network

1. 从github下载示例程序

   ```bash
   git clone https://github.com/hyperledger/fabric-samples
   ```
2. 进入fabric-samples/first-network目录执行运行脚本

   ``` bash
   cd fabric-samples/first-network
   ./byfn.sh up
   ```

3. 执行成功结果

   出现以下标志则认为成功：

   ![end](https://img.learnblockchain.cn/2019/06/28_end.png!wl)