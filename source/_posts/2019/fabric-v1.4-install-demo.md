
---
title: Fabric-V1.4安装配置 及 票据应用示例
permalink: fabric-v1.4-install-demo
un_reward: true
date: 2019-04-21 15:36:54
categories: Fabric
tags: Fabric
author: 投河自尽的鱼
---

Fabric-V1.4安装配置 及 票据应用示例


<!-- more -->

## Fabric 1.4 更新内容

Fabric已经发布到1.4LTS版本，各个版本对比如下：

**Fabric v1.1版本主要的新特性包括：**

* Fabric CA的CRL
* 区块以及交易的事件推送
* 增加了所有组建间的双向TLS通信
* Node.js Chaincode链码的支持
* Chaincode API新增了creator identity
* 性能相对v1.0有了明显的提升

**Fabric v1.2开始有了比较大的feature开始出现：**

* Private Data Collections：这个特性不得不说在隐私保护上解决了不少项目的痛点，也减少了许多项目为了隐私保护在业务层做的复杂设计。
* Service Discovery：服务发现这个特性，使得客户端拥有了更多的灵活性和可操作性，可以动态感知整个Fabric网络的变化。
* Pluggable endorsement and validation：可插拔的背书及校验机制，采用了Go Plugin机制来实现，避免了之前需要重新编译源代码的操作，提升了灵活性。


**Fabric v1.3中，同样增加了十分有用的feature：**

* 基于Identity Mixer的MSP Implementation：基于零知识证明实现的身份的匿名和不可链接，这个特性替代了v0.6版本中的T-cert。
* key-level endorsement policies：更细粒度的背书策略，细化到具体的key-value，更加灵活，不仅限于一个链码程序作背书。
* 新增Java Chaincode：至此，v1.3之后支持了Go、Node.js、Java 三种Chaincode，为开发者提供了更多的选择。
* Peer channel-based event services：Channel级别的事件订阅机制，早在v1.1版本中已经亮相了，在v1.3版本中正式发布，至此，旧的Event Hub正式宣告弃用。


**Fabric v1.4是一个里程碑式的版本，是首个LTS的版本（Long Term Support的版本）：**

* 可操作性和可维护性的提升：
* 开放日志级别设置的接口
* 开放节点健康状态的检查接口
* 开放节点数据指标的收集接口
* 改进了Node SDK的编程模型，简化开发者的代码复杂度，使得SDK更加易用
* Private Data的增强：
* 对于后续添加的允许访问节点能够获取之前的隐私数据
* 添加客户端层面的隐私数据的权限控制，不需要添加链码逻辑。


## 环境搭建准备工作

### 实验环境

这里作一个更新，新建Centos7.4的虚拟机环境。大致搭建过程如下。
云主机：Centos 7.4 、CPU：4C、内存：16G，硬盘:200G。

### 相关前置软件安装

关闭Selinux，关闭防火墙等相关操作，相关操作网络上随处可查。

建议更新后再进行下列操作：

```bash
> yum update
```

####  安装git、curl、pip

```bash
> yum install git
> yum install curl
> yum -y install epel-release
> yum install python-pip
> pip install --upgrade pip
```


#### 安装docker相关

```bash
>  yum install docker-ce
# 或者：yum install docker-ce.18.06.3.ce-3.el7  指定具体版本，可以先设置好yum 源（yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo）
> pip install docker-compose #（可能会失败，那就用以下的命令）
> pip install docker-compose --ignore-installed requests 
```

相关软件环境：
安装完成后查看各个软件版本，如下图：
![屏幕快照 2019-04-01 下午3.37.38.png-435kB][1]

**注：** 可能会碰到docker-compose报错：

```
File "/usr/lib/python2.7/site-packages/paramiko/ssh_gss.py", line 55, in <module>
GSS_EXCEPTIONS = (gssapi.GSSException,)
AttributeError: 'module' object has no attribute 'GSSException'
```

那么通过修改配置文件:/usr/lib/python2.7/site-packages/paramiko/ssh_gss.py来解决:

```
vi /usr/lib/python2.7/site-packages/paramiko/ssh_gss.py
53.55行修改如下解决：
53：import gssapi.error
55：GSS_EXCEPTIONS = (gssapi.error.GSSException,)
```

![屏幕快照 2019-04-01 下午3.42.12.png-158.8kB][2]

---

#### 安装Golang、Node.js、npm

**安装Golang**

如果单独去下载安装包麻烦的话，那么直接通过wget来下载解压，配置环境变量。

```
wget https://studygolang.com/dl/golang/go1.10.8.linux-amd64.tar.gz
tar -xvf go1.10.8.linux-amd64.tar.gz
```

配置环境变量。修改/etc/profile文件,路径根据下载安装路径来。

```
vim /etc/profile
添加
export GOROOT=/usr/go
export GOPATH=/usr/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

**安装Node.js**

```
wget https://npm.taobao.org/mirrors/node/v11.0.0/node-v11.0.0.tar.gz
tar -xvf node-v11.0.0.tar.gz
解压后进入Node文件夹：
yum install gcc gcc-c++
完成后gcc -v,这时候会发现gcc为4.8.5 建议更新：
wget http://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz
```

更新完成后，解压gcc，并安装：

```
tar -xvf gcc-7.3.0.tar.gz
进入gcc-7.3.0目录执行：
./contrib/download_prerequisites
mkdir 一个新的目录
进入该目录 cd 目录
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib 
make (请耐心等待，我这里大概等待了2个多小时。。。)
make install
建议重启后再进行之后的操作
```

重启后看到gcc版本为7.3.0

![屏幕快照 2019-04-01 下午7.22.57.png-137.4kB][3]

安装Node.js

```
进入Node.js文件夹(这里可能有一个文件夹名的问题，建议修改node7.3.0文件夹名直接为node)
./configure
make （耐心等待）
make install
建议重启后再进行之后的操作
```

**安装npm**

```
npm install npm -g
```

完成上述操作后，查看各软件版本：

![屏幕快照 2019-04-02 上午10.40.50.png-206.8kB][4]


## 安装 Fabric

首先下载Fabric源码，我们在go/src目录下新建文件夹。

```
mkdir -p github.com/hyperledger
进入该文件夹执行：
git clone https://github.com/hyperledger/fabric.git (耐心等待)
```

完成后进入 fabric/scripts文件夹，可以看到bootstrap.sh脚本，cat该脚本可以看到fabric版本为1.4.0：

![屏幕快照 2019-04-02 上午11.21.22.png-259.7kB][5]

执行bootstrap.sh脚本，自动进行fabric相关镜像的下载,耐心等待
```
./bootstrap.sh
```

![屏幕快照 2019-04-02 上午11.26.35.png-781.6kB][6]

镜像下载完成后如图：

![屏幕快照 2019-04-02 上午11.48.58.png-476.3kB][7]

通过Fabric-samples提供的BYFN(build your first network)构建网络。
```
 ./byfn.sh -m generate -c jackychannel（自定义名字）
```
过程很快，完成后如图：
![屏幕快照 2019-04-02 下午12.34.40.png-432.6kB][8]

启动网络：
```
./byfn.sh -m up -c jackychannel
```
启动后如图：
![屏幕快照 2019-04-02 下午12.36.24.png-610.7kB][9]
完成后如图：
![屏幕快照 2019-04-02 下午12.37.48.png-86.5kB][10]

这个时候出现4个peer节点，通过top命令可以清楚看到：
![屏幕快照 2019-04-02 下午12.39.07.png-308.2kB][11]

**注：** 关闭命令：`./byfn.sh -m down`

启动网络服务后会启动排序服务节点、4个Peer节点，以及1个命令行容器cli。


## 搭建完成后功能测试

上述步骤完成后，可是去看下一些基本的操作和命令。

```
/usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/first-network/channel-artifacts目录中,可称为创世区块目录（目录根据每个人的配置）
```
可以看到下列文件：

![屏幕快照 2019-04-02 下午12.57.54.png-155.5kB][12]

Org1MSPanchors.tx、Org2MSPanchors.tx,两个锚节点配置。
channel.tx，生成通道配置文件。
genesis.block，创世区块文件。

```
/usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/first-network/crypto-config目录中，可称为证书目录（目录根据每个人的配置）
```
该目录存放生成排序服务节点和Peer节点的MSP证书文件，如图：
![1112019-04-02 下午1.11.57.png-560.3kB][13]

使用docker命令查看运行中的镜像：

```
docker ps
```

结果如图：
![12222019-04-02 下午1.14.47.png-614.9kB][14]

进入cli来进行一些简单的操作：

```
docker exec -it cli bash
```

切换到容器内做一个简单的查询：

```
peer chaincode query -C jackychannel(刚设置启动的名称) -n mycc -c '{"Args":["query","a"]}'
```

结果会看到90余额。



## 票据应用测试

在Fabric官网文档中有一个商业票据的例子，这里简单进行了测试。(停止Fabric网络服务后再进行以下操作。)

两个组织：MagnetoCorp、DigiBank，
票据网络：PaperNet。

进入该目录启动基本网络：

```
/usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/basic-network
./start.sh
```
启动完成后查看：docker ps 会出现4个运行中容器。

使用：docker network inspect net_basic命令查看docker网络：
![屏幕快照 2019-04-02 下午4.20.01.png-780.9kB][15]

进入以下目录，启动：

```
cd commercial-paper/organization/magnetocorp/configuration/cli/
./monitordocker.sh net_basic
```

出现下图：

![屏幕快照 2019-04-02 下午4.32.23.png-79.5kB][16]

另外开一个终端连接到服务器，在之前目录下，创建MagnetoCorp公司特定的docker容器。

```
cd commercial-paper/organization/magnetocorp/configuration/cli/
docker-compose -f docker-compose.yml up -d cliMagnetoCorp
```

再输入：docker ps 可以看到fabric-tools：3f078207c01a已加入网络中：
![屏幕快照 2019-04-02 下午4.34.27.png-304.3kB][17]

MagnetoCorp 管理员通过fabric-tools：3f078207c01a来进行操作。

接下来看下智能合约：
进入以下目录：

```
cd /usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/commercial-paper/organization/magnetocorp/contract/lib
```

该目录下三个文件，其中papercontract.js为商业票据的智能合约。可以cat看下具体内容，这里暂不展开。

执行如下部署合约代码：

```
docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0 -p /opt/gopath/src/github.com/contract -l node
```

![屏幕快照 2019-04-02 下午4.56.54.png-179.5kB][18]

实例化智能合约：

```
docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0 -l node -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"
```
输入如下：
![屏幕快照 2019-04-02 下午4.58.28.png-209.7kB][19]

之前打开的终端中会有输出，也就是logsout容器的中的日志输出内容，具体如下：
![屏幕快照 2019-04-02 下午4.59.47.png-1484.7kB][20]

再次docker ps就可以看到：dev-peer0.org1.example.com-papercontract-0，说明此容器是peer0.org1.example.com节点启动的，且正在运行的papercontract链码版本为0。
![屏幕快照 2019-04-02 下午5.01.25.png-403.6kB][21]

MagnetoCorp Application进行票据发行:

过程图：
![屏幕快照 2019-04-03 下午12.03.35.png-153kB][22]

MagnetoCorp的Isabella发起整个交易过程。

进入以下目录：
```
cd /usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/commercial-paper/organization/magnetocorp/application
```
可以看到下列文件:
eslintrc.js、issue.js、package.json、addToWallet.js、node_modules 

```
node addToWallet.js
```

**在执行上述命令的时候，强烈建议先进行如下操作：这几个坑一般都存在~~**

```
修改package.json文件
vi package.json
把里面1.0.0版本改成1.4.0
npm install（如报错执行下列命令）
npm install --unsafe-perm fabric-network
如有：Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found 报错那么执行下列命令：
find / -name "libstdc++.so.6*
找到文件的指定目录，笔者这里是6.0.24，复制到/lib64目录、删除之前的libstdc++.so.6文件，执行如下命令链接：
ln -s libstdc++.so.6.0.24 libstdc++.so.6
```
再删除之前的node_modules文件夹，再次执行：
```
npm install（如报错执行下列命令）
npm install --unsafe-perm fabric-network
node addToWallet.js
```
这个时候正常的话会出现done，如图：
![屏幕快照 2019-04-03 上午11.25.58.png-26.2kB][23]

查看钱包的结构：
```
ll ../identity/user/isabella/wallet/
ll ../identity/user/isabella/wallet/User1\@org1.example.com
```

结果如下图：
![屏幕快照 2019-04-03 上午11.59.10.png-199.3kB][24]

Isabella钱包信息:
用户私钥：c75bd6911aca808941c3557ee7c97e90f3952e379497dc55eb903f31b50abc83-priv
用户公钥：c75bd6911aca808941c3557ee7c97e90f3952e379497dc55eb903f31b50abc83-pub
用户证书文件：User1@org1.example.com

发起交易：
Isabella现在可以使用issue.js来提交一个交易（发行MagnetoCorp 公司的商业票据00001）
```
node issue.js
```
结果如图：
![屏幕快照 2019-04-03 下午12.11.41.png-239.8kB][25]

---

以上操作都是在MagnetoCorp的Isabella，接下来是，DigiBank-Balaji ，他将购买刚刚发行的商业票据。

购买流程图：
![购买流程图][26]

进入下列目录：

```
/usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/commercial-paper/organization/digibank/configuration/cli
执行：docker-compose -f docker-compose.yml up -d cliDigiBank
```

结果如图：

![屏幕快照 2019-04-03 下午12.22.48.png-104.5kB][27]

```
cd /usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/commercial-paper/organization/digibank/application
vi buy.js
```

buy.js文件可查看合约内容.

和之前npm的操作一样、修改相关文件内容：

```
修改package.json文件
vi package.json  # 把里面1.0.0版本改成1.4.0
npm install（如报错执行下列命令）
npm install --unsafe-perm fabric-network
```


创建账户及购买，商业票据00001生命周期的最后一个交易是redeem交易，Balaji 通过运行redeem.js程序来实现这一过程。

```
node addToWallet.js 
node buy.js
node redeem.js
```
在执行过程中可能会出现：
![屏幕快照 2019-04-03 下午1.17.42.png-343.7kB][28]

那么执行：

```
npm install -g js-yaml
```

结果如图：
![11111.png-261.8kB][29]
![2222.png-231.8kB][30]

整个实验大致完成。


参考文章：

1. https://www.jianshu.com/p/cb032c42c909
2. https://blog.csdn.net/ASN_forever/article/details/87859346
3. https://hyperledger-fabric.readthedocs.io/en/latest/


  [1]: http://static.zybuluo.com/JackyJin/j4oj3qpfpe9gyneamd9sg515/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-01%20%E4%B8%8B%E5%8D%883.37.38.png
  [2]: http://static.zybuluo.com/JackyJin/qcmrry22eydcy7olg3e560e4/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-01%20%E4%B8%8B%E5%8D%883.42.12.png
  [3]: http://static.zybuluo.com/JackyJin/t15h1oltz7rc9sux22w8la2l/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-01%20%E4%B8%8B%E5%8D%887.22.57.png
  [4]: http://static.zybuluo.com/JackyJin/0c1bstxapb2abbov2y9cimih/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8A%E5%8D%8810.40.50.png
  [5]: http://static.zybuluo.com/JackyJin/b9qq5yrn7jy3o6by1zgw2cta/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8A%E5%8D%8811.21.22.png
  [6]: http://static.zybuluo.com/JackyJin/zhcpi5o7h9enn0e25gap6wzb/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8A%E5%8D%8811.26.35.png
  [7]: http://static.zybuluo.com/JackyJin/gqmfotupxempqafc8iredlkt/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8A%E5%8D%8811.48.58.png
  [8]: http://static.zybuluo.com/JackyJin/lln962u9tfeikopbsp9hjmxb/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%8812.34.40.png
  [9]: http://static.zybuluo.com/JackyJin/doa3adonfpnfbii7lfsb7v4s/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%8812.36.24.png
  [10]: http://static.zybuluo.com/JackyJin/o0peadgti0g4vkqe5xydvt3r/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%8812.37.48.png
  [11]: http://static.zybuluo.com/JackyJin/9a3azzmat2ys656yk93eba3u/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%8812.39.07.png
  [12]: http://static.zybuluo.com/JackyJin/cxalxjgjm1ss6rh89jp0w9zo/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%8812.57.54.png
  [13]: http://static.zybuluo.com/JackyJin/b3wmxbbfqbiaifqtcpx3y6dk/1112019-04-02%20%E4%B8%8B%E5%8D%881.11.57.png
  [14]: http://static.zybuluo.com/JackyJin/vsucu8979qqo9lo5kztqa2vg/12222019-04-02%20%E4%B8%8B%E5%8D%881.14.47.png
  [15]: http://static.zybuluo.com/JackyJin/9n888ptxe1vz0jdi14btmh64/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.20.01.png
  [16]: http://static.zybuluo.com/JackyJin/s4suayq6vax8aakckn01ho1v/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.32.23.png
  [17]: http://static.zybuluo.com/JackyJin/v6wwfv4qf1rzctss5c40hvie/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.34.27.png
  [18]: http://static.zybuluo.com/JackyJin/yuypzlkg6wltfis1kpn8twpp/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.56.54.png
  [19]: http://static.zybuluo.com/JackyJin/ce9uwcgxv74nwvi9a9dr9vdv/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.58.28.png
  [20]: http://static.zybuluo.com/JackyJin/dqsjc6ya5qgymuwy1bss2xfo/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%884.59.47.png
  [21]: http://static.zybuluo.com/JackyJin/5t06ol21nlqtj8atlfk2zai8/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-02%20%E4%B8%8B%E5%8D%885.01.25.png
  [22]: http://static.zybuluo.com/JackyJin/7huyzsd9xmxoxd1m1bwibyez/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%8812.03.35.png
  [23]: http://static.zybuluo.com/JackyJin/3hm4pzr3cdv9mtxsish4yfe8/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8A%E5%8D%8811.25.58.png
  [24]: http://static.zybuluo.com/JackyJin/snahsk20u8gxmtzwyt82hvhb/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8A%E5%8D%8811.59.10.png
  [25]: http://static.zybuluo.com/JackyJin/1azpthmfxjaq40bycx7yq25z/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%8812.11.41.png
  [26]: http://static.zybuluo.com/JackyJin/6fm92c8g4xyww6ahiozd7dck/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%8812.13.56.png
  [27]: http://static.zybuluo.com/JackyJin/0nu04j79yiz9ld5gnss47x02/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%8812.22.48.png
  [28]: http://static.zybuluo.com/JackyJin/wzn2xsgbnwh3vukiiqtaewr6/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%881.17.42.png
  [29]: http://static.zybuluo.com/JackyJin/eil998xtoev9ue94jkmqf5o9/11111.png
  [30]: http://static.zybuluo.com/JackyJin/ak150f86umc6j675izas6h52/2222.png

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，打造最好的[区块链技术博客](https://learnblockchain.cn/) 。

