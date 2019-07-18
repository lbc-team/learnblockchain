---
title: Fabric 链码Chaincode　的安装、初始化、调用、升级　
permalink: chaincode-run
un_reward: true
date: 2019-07-03 08:18:08
categories:
    - 联盟链
    - Fabric
tags:
    - Fabric
    - chaincode
author: kunpeng
---

上一篇文章，我们[启动了一个Fabric网络](https://learnblockchain.cn/2019/06/28/fabric-first-network/)，这篇文章来看看在Fabric网络进行应用的开发。

<!-- more -->

## 什么是chaincode

chaincode是fabric的智能合约，又叫做链码。Chaincode是生成交易transacton的唯一方式，是外界与区块链系统交互的唯一渠道，开发Fabric区块链应用就是要编写Chaincode, Chaincode就是业务逻辑实现。

## chaincode生命周期

* Install 安装

  chaincode 要在 Fabric 网络上运行，必须要先安装在网络中的节点 peer 上（可以理解为部署代码），安装同时注明版本号保证应用的版本控制。

* Instantiate实例化

  在 peer 上安装 chaincode 后，还需要实例化才能真正激活该 chaincode 。在实例化的过程中，chaincode 就会被编译并打包成docker容器镜像，然后启动运行。每个应用只能被实例化一次，实例化可在任意一个已安装该 chaincode 的 peer 上进行。

* Invoke调用，Query查询

  chaincode 在实例化后，用户就能与它进行交互，其中 query 查询与应用相关的状态（即只读），而 invoke 则可能会改变其状态。

* Upgrade升级

  在 chaincode更新代码后，需要把新的代码通过install交易安装到正在运行该 chaincode的 peer 上，安装时需注明比先前版本更高的版本号，接下来向任意一个安装了新代码的 peer 发送 upgrade 交易就能更新 chaincode，chaincode 在更新前的状态也会得到保留。

## first network示例

现在，我们在first network的环境中，重新部署一个新的应用，应用逻辑是插入一个学生的成绩（学生姓名，语文成绩，数学成绩），然后计算总成绩记录到链上，通过学生姓名查询学生的总成绩，链码路径放到`fabric-samples/chaincode/win_test/src/fabric-chaincode`目录下，链码下载地址是：https://gitee.com/zh5715615/fabric-chaincode.git。

### 先关掉TLS
为了减少参数输入，在这里不引入TLS（安全传输层协议）功能，后面再进行讲解，我们关掉tls开关：

1. 修改`first-network/docker-compose-cli.yaml`

找到`CORE_PEER_TLS_ENABLED=true`，修改为`CORE_PEER_TLS_ENABLED=false`，如下：

``` yml
cli:
    container_name: cli
    image: hyperledger/fabric-tools:$IMAGE_TAG
    tty: true
    stdin_open: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      #- FABRIC_LOGGING_SPEC=DEBUG
      - FABRIC_LOGGING_SPEC=INFO
      - CORE_PEER_ID=cli
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_TLS_ENABLED=false
```



2. 修改`first-network/base/peer-base.yaml`

找到`CORE_PEER_TLS_ENABLED=true`改为`CORE_PEER_TLS_ENABLED=false`

找到`ORDERER_GENERAL_TLS_ENABLED=true`改为`ORDERER_GENERAL_TLS_ENABLED=false`

如下：

```yml
peer-base:
    image: hyperledger/fabric-peer:$IMAGE_TAG
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      # the following setting starts chaincode containers on the same
      # bridge network as the peers
      # https://docs.docker.com/compose/networking/
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_byfn
      - FABRIC_LOGGING_SPEC=INFO
      #- FABRIC_LOGGING_SPEC=DEBUG
      - CORE_PEER_TLS_ENABLED=false
      - CORE_PEER_GOSSIP_USELEADERELECTION=true
      - CORE_PEER_GOSSIP_ORGLEADER=false
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start

  orderer-base:
    image: hyperledger/fabric-orderer:$IMAGE_TAG
    environment:
      - FABRIC_LOGGING_SPEC=INFO
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_GENESISMETHOD=file
      - ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      # enabled TLS
      - ORDERER_GENERAL_TLS_ENABLED=false
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
      - ORDERER_KAFKA_VERBOSE=true
      - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
```

### 进入容器
 first network的操作都是再cli容器中进行的，进入cli容器：

  ```bash
  docker exec -it cli bash
  ```

###  链码安装

  cli容器中，默认的peer成员时`peer0.org0`，所以安装链码只是安装在`peer0.org0`的节点上，如果要在其他节点安装需要切换环境变量，链码安装操作如下：

  1. 在peer0.org1上安装chaincode

     ``` bash
     peer chaincode install -n kpcc -v 1.0 -l golang -p github.com/chaincode/win_test/src/fabric-chaincode/kunpeng_example01/
     ```

  2. 在`peer1.org1`上安装chaincode

     ```bash
     CORE_PEER_ADDRESS=peer1.org1.example.com:8051 #切换节点
     peer chaincode install -n kpcc -v 1.0 -l golang -p github.com/chaincode/win_test/src/fabric-chaincode/kunpeng_example01/
     ```

  3. 在`peer0.org2`上安装chaincode

     ```bash
     CORE_PEER_LOCALMSPID="Org2MSP" #切换组织
     CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp #切换组织msp
     CORE_PEER_ADDRESS=peer0.org2.example.com:9051 #切换节点
     peer chaincode install -n kpcc -v 1.0 -l golang -p github.com/chaincode/win_test/src/fabric-chaincode/kunpeng_example01/
     ```

  4. 在`peer1.org2`上安装chaincode

     ```bash
     CORE_PEER_ADDRESS=peer1.org2.example.com:10051 #切换节点
     peer chaincode install -n kpcc -v 1.0 -l golang -p github.com/chaincode/win_test/src/fabric-chaincode/kunpeng_example01/
     ```

     *注意，如果要切回组织1时，环境变量为：*

     ```bash
     CORE_PEER_LOCALMSPID="Org1MSP"
     CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
     ```



  从上面的例子可以看到，如果不同的节点之间有不同的环境变量，而不同的组织环境变量和需要导入的MSP(成员管理)不同，在使用时注意切换。如果是在非docker的真机环境下，不需要cli时，则记得在`peer node start`启动前，配置好相应的环境变量值。

  参数解析：

  + **-n**：指定链码名称
  + **-v**：指定链码版本号
  + **-l**：指定链码使用的语言，可以是golang, java, nodejs
  + **-p**：指定链码源码目录

  链码安装成功则显示如下：

  ```bash
  response:<status:200 payload:"OK" >
  ```



### 链码初始化

  链码的初始化只需要执行一次，在任意节点上执行都可以：

  ```bash
peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n kpcc -l golang -v 1.0 -c '{"Args":[]}' -P 'AND ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
  ```

  参数解析：

  - **-n**：指定链码名称
  - **-v**：指定链码版本号
  - **-l**：指定链码使用的语言，可以是golang, java, nodejs
  - **-o**：指定排序节点
  - **-C**：指定通道名
- **-c**：指定初始化参数
  - **-P**：指定背书策略，上例中的背书策略是，两个组织必须都参与链码invoke或query，chaincode执行才能生效。这个参数可为空，则任意安装了链码的节点无约束地调用链码。

  链码初始化成功则不会有error信息显示。

### 链码执行

  执行链码Invoke，链码的执行在任意节点完成后，会将结果同步到其他节点：

  ```bash
  peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n kpcc -c '{"Args":["invoke","Alice","98","92"]}'
  ```

  参数解析：

  - **-n**：指定链码名称
  - **-o**：指定排序节点
  - **-C**：指定通道名
  - **-c**：指定链码执行地参数，如上例中有四个参数，invoke是方法，表示写入，Alice是学生名称，98，92是分数

  以上的示例指令执行会失败，并不会记录在链上，因为有背书规则，所以需要两个组织一起参与背书，正确指令如下：

  ```bash
  peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n kpcc --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["invoke","Alice","98","92"]}'
  ```

  链码执行成功显示如下：

  ```bash
  Chaincode invoke successful. result: status:200
  ```



### 链码查询

  ```bash
  peer chaincode query -C mychannel -n kpcc -c '{"Args":["query","Alice"]}'
  ```

  参数解析：

  - **-n**：指定链码名称
  - **-C**：指定通道名
  - **-c**：指定链码执行地参数，如上例中有四个参数，invoke是方法，表示写入，Alice是学生名称，98，92是分数

  链码的查询是不会记录在链上的，只会从账本中读取记录返回给用户，此示例返回值是190

  链码查询其实也可以用invoke来执行，这样就需要背书，且记录上链。

###  链码更新

  链码更新，首先要安装链码，更新一下版本号：

  ```bash
  peer chaincode install -n kpcc -v 1.1 -l golang -p github.com/chaincode/win_test/src/fabric-chaincode/kunpeng_example01/
  ```

  然后再更新链码，参与同初始化一样

  ```bash
  peer chaincode upgrade -o orderer.example.com:7050 -C mychannel -n kpcc -l golang -v 1.1 -c '{"Args":[]}' -P 'AND ('\''Org1MSP.peer'\'','\''Org2MSP.peer'\'')'
  ```

  链码更新只能在安装了新版本链码的节点上有效，老的节点仍然只能用旧的链码，同样，参与背书的节点，也需要将链码升级，才能让提交Invoke的操作背书通过。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
