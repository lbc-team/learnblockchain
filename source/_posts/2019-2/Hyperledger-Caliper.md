---
title: Hyperledger Caliper 原理及使用指南
permalink: Hyperledger-Caliper
un_reward: true
date: 2019-09-23 14:32:27
categories:
  - 联盟链
  - Fabric
tags:
    - Caliper
    - 测试
author: TopJohn
---

前段时间花了一段时间来研究Hyperledger Caliper的原理以及使用方式，研究的时候正处于Caliper改动较大的时候，因此也踩了不少的坑，也发现了一些问题，同时也加深了对这个项目的认识，在这里进行一下整理和归纳，以便大家能够更好地使用Caliper。

<!-- more -->

## Caliper 架构

先附上一张官方文档的架构图：
![架构图](https://img.learnblockchain.cn/2019/10/14/001.jpg)

Hyperledger Caliper这个项目其主要的核心思想是实现一套通用的区块链性能测试框架，能够支持Hyperledger旗下的所有framework，但是也不限于下面的项目，也可以支持其他的区块链项目，不过需要自己实现adaptation Layer。目前，Caliper已经正式发布了v0.1.0版本，支持Hyperledger Fabric v1.0-v1.4.3、Sawtooth、Iroha、composer和burrow。

Adaptation Layper（适配层）

适配层类似编程语言中接口与实现中的实现部分，即各种区块链操作最后都会调用到你所指定的Adaptation Layper的具体实现去操作对应的区块链平台。

Interface&Core Layper（接口及核心层）

下述内容摘自官方文档，该层核心思想是定义整个框架的相关流程，从初始化到测试到最后的统计及生成报告和相关的速率控制等实现，主体思想是定义整个核心流程代码。

接口和核心层提供 Blockchain NBI、资源监控、性能监控、报告生成模块，并为上层应用提供四种相应的北向接口：

Blockchain operating interfaces: 包含诸如在后端区块链上部署智能合约、调用合约、从账本查询状态等操作。
Resource Monitor: 包含启动/停止监视器和获取后端区块链系统资源消耗状态的操作，包括CPU、内存、网络IO等。现在提供两种监视器，一种是监视本地/远程docker容器，另一种则是监控本地进程。未来将实现更多功能。
Performance Analyzer: 包含读取预定义性能统计信息（包括TPS、延迟、成功交易数等）和打印基准测试结果的操作。在调用区块链北向接口时，每个交易的关键指标（如创建交易的时间、交易提交时间、交易返回结果等）都会被记录下来，并用于生成最终的预定义性能指标统计信息。
Report Generator: 生成HTML格式测试报告。

Application Layer(应用层)

应用层用于定义区块链网络的配置，测试的相关配置，指benchmark和network两个文件夹的配置。相关配置信息在此不进行展开。
![配置](https://img.learnblockchain.cn/2019/10/14/002.jpg)

整个测试流程，主要包括3个阶段：

１、准备阶段：用于初始化整个区块链网络，读取配置文件，部署智能合约，启动监控组建等。

２、测试阶段：根据定义好的benchmark配置文件，启动客户端子进程，执行相应的测试，返回统计结果。

３、报告阶段：分析统计结果，生成html报告。

测试客户端有2种，一种是local client，一种是zookeeper client，local client模式用于进行单机模式下的测试，zookeeper client模式用于解决单机性能不足，进行分布式的客户端测试。但是目前因为架构调整，zookeeper client这种模式将被废弃，作者尝试过此种模式的测试，但是存在一些问题https://github.com/hyperledger/caliper/issues/572，在这里贴出来，有兴趣的朋友可以研究下，但是maintainer已经不做维护了。后续将会设计新的分布式测试方案，可以关注后期的设计。

用户自己的定义的test case可以在benchmark文件夹中实现自己定义的相应JavaScript代码来实现相应的智能合约方法调用以及初始化和结束时要做的事情。

## 项目结构
caliper项目中所有的代码都位于`caliper/packages`目录下：
```
├── caliper-burrow
├── caliper-cli
├── caliper-composer
├── caliper-core
├── caliper-fabric
├── caliper-iroha
├── caliper-samples
├── caliper-sawtooth
└── caliper-tests-integration
```

其中包括各个adaptation Layper层：caliper-burrow、caliper-composer、caliper-fabric、caliper-iroha、caliper-sawtooth。

caliper-cli：用于命令行参数解析。

caliper-core：用于整个项目的核心流程接口的实现。

caliper-samples；用于存放各种区块链网络的配置文件示例、测试文件的示例，以及各种智能合约。

caliper-tests-integration：用于进行caliper的本地打包发布和安装。

**在学习使用的时候可以重点关注fabric-samples文件夹下的相关配置，网络配置在network目录中，测试配置在benchmark文件夹中，智能合约文件在src/contract文件夹中。**

##Caliper安装及使用

目前caliper有了较为丰富的安装方法，大家可以根据自己的喜好以及实际情况择优选择。

Caliper目前已经将v0.1.0版本发布到了官方的npm server上了包名为`@hyperledger/caliper-cli`，将制作好的docker镜像发布到了docker hub，`hyperledger/caliper`，镜像包括了caliper的二进制文件。

安装和使用caliper主要有3个步骤：

1、安装可执行程序
２、执行bind命令绑定对应的底层平台的sdk的版本
３、开始测试

##Caliper命令的使用
>*在这里介绍下npx命令，npx命令在下面主要是搜索node_modules中下载的caliper命令的作用，起到类似将caliper放到全局搜索路径的效果。*

#version命令
使用如下命令确认下载的caliper的版本：

```
user@ubuntu:~/caliper-benchmarks$ npx caliper --version
v0.1.0
```

#help命令
Cli提供了很多的辅助信息，可以使用–help进行查看。

```
user@ubuntu:~/caliper-benchmarks$ npx caliper --help
caliper <command>

Commands:
  caliper benchmark <subcommand>   Caliper benchmark command
  caliper bind [options]           Bind Caliper to a specific SUT and its SDK version

Options:
  --help         Show help  [boolean]
  -v, --version  Show version number  [boolean]

Examples:
  caliper bind
  caliper benchmark run

For more information on Hyperledger Caliper: https://hyperledger.github.io/caliper/
```


#Bind命令
bind命令用于指定caliper命令行操作的区块链平台的sdk类型及版本：

```
user@ubuntu:~/caliper-benchmarks$ npx caliper bind --help
Usage:
  caliper bind --caliper-bind-sut fabric --caliper-bind-sdk 1.4.1 --caliper-bind-cwd ./ --caliper-bind-args="-g"

Options:
  --help               Show help  [boolean]
  -v, --version        Show version number  [boolean]
  --caliper-bind-sut   The name of the platform to bind to  [string]
  --caliper-bind-sdk   Version of the platform SDK to bind to  [string]
  --caliper-bind-cwd   The working directory for performing the SDK install  [string]
  --caliper-bind-args  Additional arguments to pass to "npm install". Use the "=" notation when setting this parameter  [string]

```

#benchmark命令
benchmark命令也是整个命令的核心，用于执行相应的测试，需要指定工作目录，网络配置及测试配置。

```
user@ubuntu:~/caliper-benchmarks$ npx caliper benchmark run --help
caliper benchmark run --caliper-workspace ~/myCaliperProject --caliper-benchconfig my-app-test-config.yaml --caliper-networkconfig my-sut-config.yaml

Options:
  --help                   Show help  [boolean]
  -v, --version            Show version number  [boolean]
  --caliper-benchconfig    Path to the benchmark workload file that describes the test client(s), test rounds and monitor.  [string]
  --caliper-networkconfig  Path to the blockchain configuration file that contains information required to interact with the SUT  [string]
  --caliper-workspace      Workspace directory that contains all configuration information  [string]
```

##安装方式

#从官方的NPM Server下载安装

目前这种方式已经非常方便了，可以直接用npm install安装，分为局部安装和全局安装2种方式。

1、局部安装

这种方式的好处是可以在同一台服务器上设置多个不同的测试客户端而且不会相互干扰。

```
user@ubuntu:~/caliper-benchmarks$ npm init -y
user@ubuntu:~/caliper-benchmarks$ npm install --only=prod @hyperledger/caliper-cli
user@ubuntu:~/caliper-benchmarks$ npx caliper bind --caliper-bind-sut fabric --caliper-bind-sdk 1.4.0
user@ubuntu:~/caliper-benchmarks$ npx caliper benchmark run --caliper-workspace . --caliper-benchconfig benchmarks/scenario/simple/config.yaml --caliper-networkconfig networks/fabric/fabric-v1.4/2org1peergoleveldb/fabric-go.yaml
```

1、初始化npm项目
２、安装Caliper命令行
３、绑定所需要的平台SDK
４、调用命令行进行测试
５、全局安装

全局安装不需要初始化。

```
user@ubuntu:~$ npm install -g --only=prod @hyperledger/caliper-cli
user@ubuntu:~$ caliper bind --caliper-bind-sut fabric --caliper-bind-sdk 1.4.0 --caliper-bind-args=-g
user@ubuntu:~$ caliper benchmark run --caliper-workspace ~/caliper-benchmarks --caliper-benchconfig benchmarks/scenario/simple/config.yaml --caliper-networkconfig networks/fabric/fabric-v1.4/2org1peergoleveldb/fabric-go.yaml
```

1、直接执行install进行全局安装
２、指定所需要的平台SDK
３、调用命令行进行测试

##使用Docker镜像

使用Docker镜像可以通过直接使用docker命令或者docker-compose的方式进行启动，只需要配置相应的环境变量以及将相关配置文件映射进容器即可。

下面是docker命令的方式：

```
user@ubuntu:~/caliper-benchmarks$ docker run \
    -v .:/hyperledger/caliper/workspace \
    -e CALIPER_BIND_SUT=fabric \
    -e CALIPER_BIND_SDK=1.4.0 \
    -e CALIPER_BENCHCONFIG=benchmarks/scenario/simple/config.yaml \
    -e CALIPER_NETWORKCONFIG=networks/fabric/fabric-v1.4/2org1peergoleveldb/fabric-go.yaml \
    --name caliper hyperledger/caliper
```

下面是docker-compose的方式：

```
version: '2'

services:
    caliper:
        container_name: caliper
        image: hyperledger/caliper
        environment:
        - CALIPER_BIND_SUT=fabric
        - CALIPER_BIND_SDK=1.4.0
        - CALIPER_BENCHCONFIG=benchmarks/scenario/simple/config.yaml
        - CALIPER_NETWORKCONFIG=networks/fabric/fabric-v1.4/2org1peergoleveldb/fabric-go.yaml
        volumes:
        - ~/caliper-benchmarks:/home/node/hyperledger/caliper/workspace
```

如果docker-compose的配置文件名为docker-compose.yaml，直接执行：

```
docker-compose up
```

##从源代码安装

1、首先需要在项目根目录进行全局的初始化操作。

```
user@ubuntu:~/caliper$ npm i && npm run repoclean -- --yes && npm run bootstrap
```

2、将npm包发布到本地npm仓库

```
user@ubuntu:~/caliper$ cd ./packages/caliper-tests-integration
user@ubuntu:~/caliper/packages/caliper-tests-integration$ npm run start_verdaccio
...
[PM2] Spawning PM2 daemon with pm2_home=.pm2
[PM2] PM2 Successfully daemonized
[PM2] Starting /home/user/projects/caliper/packages/caliper-tests-integration/node_modules/.bin/verdaccio in fork_mode (1 instance)
[PM2] Done.
┌───────────┬────┬──────┬────────┬────────┬─────────┬────────┬─────┬───────────┬────────┬──────────┐
│ App name  │ id │ mode │ pid    │ status │ restart │ uptime │ cpu │ mem       │ user   │ watching │
├───────────┼────┼──────┼────────┼────────┼─────────┼────────┼─────┼───────────┼────────┼──────────┤
│ verdaccio │ 0  │ fork │ 115203 │ online │ 0       │ 0s     │ 3%  │ 25.8 MB   │ user   │ disabled │
└───────────┴────┴──────┴────────┴────────┴─────────┴────────┴─────┴───────────┴────────┴──────────┘
 Use `pm2 show <id|name>` to get more details about an app
 user@ubuntu:~/caliper/packages/caliper-tests-integration$ npm run npm_publish_local
...
+ @hyperledger/caliper-core@0.1.0
[PUBLISH] Published package @hyperledger/caliper-core@0.1.0
...
+ @hyperledger/caliper-fabric@0.1.0
[PUBLISH] Published package @hyperledger/caliper-fabric@0.1.0
...
+ @hyperledger/caliper-cli@0.1.0
[PUBLISH] Published package @hyperledger/caliper-cli@0.1.0
```

3、下载caliper命令行并执行bind命令后即可进行测试

```
user@ubuntu:~/caliper/packages/caliper-tests-integration$ npm install --registry=http://localhost:4873 --only=prod @hyperledger/caliper-cli
user@ubuntu:~/caliper/packages/caliper-tests-integration$ npx caliper bind --caliper-bind-sut fabric --caliper-bind-sdk 1.4.0
user@ubuntu:~/caliper/packages/caliper-tests-integration$ npx caliper benchmark run --caliper-workspace ../caliper-samples --caliper-benchconfig benchmark/simple/config.yaml --caliper-networkconfig network/fabric-v1.4/2org1peergoleveldb/fabric-node.yaml
```

##构建Docker镜像

如果需要自己构建Docker镜像的话，请执行下述命令：

```
user@ubuntu:~/caliper/packages/caliper-tests-integration$ npm run docker_build_local
...
Successfully tagged hyperledger/caliper:0.1.0
[BUILD] Built Docker image "hyperledger/caliper:0.1.0"
```
>*如果执行完了发布命令的话，请清理一下环境*
>*`user@ubuntu:~/caliper/packages/caliper-tests-integration$ npm run cleanup`*

##总结

上述是我结合官方文档以及自己在前两周使用Caliper的过程中的心得体会，但是受限于目前Caliper目前客户端的性能问题，我并未采用Caliper进行测试，而是采用了别的方式，会在后续博客中提到。目前Caliper测试Fabric v1.4以上版本使用的SDK采用的是SDK的高级API，封装效果好，但是测试结果发现，在8核16G的服务器上，测试的sendRate在800TPS左右的时候，服务器CPU就已经满负荷运行了，无法提升单机的发送速率，和社区开发者交流后证实，在此版本之前，Caliper单机发送速率通过多进程的方式是可以达到4000TPS的，所以目前作者仅仅采用Caliper进行测试网络的初始化、销毁以及部署智能合约等辅助操作。真正的测试需要社区排查解决CPU占用率过高的问题之后才能使用，我也会持续关注这个问题，个人认为是由于发送的时候建立了过多的event hub的连接导致的资源消耗过高的原因。


本文经TopJohn授权转自[TopJohn’s Blog](https://www.xuanzhangjiong.top/)


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
