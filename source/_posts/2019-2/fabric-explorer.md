---
title: 基于fabric1.4.2的区块链浏览器搭建
permalink: fabric-explorer
un_reward: true
date: 2019-09-29 14:18:21
categories:
    - 联盟链
    - Fabric
tags:
    - Fabric
    - 区块链浏览器
author: Duanraudon
---

基于fabric1.4.2的blockchain-explorer搭建

<!-- more --->


## 环境准备

- fabric 1.4.2
- fabric-sample 1.4.2
- blockchain-explorer 0.3.9.5

- **go 1.12.8** 环境安装

> 下载安装包
>
> 在网址 https://studygolang.com/dl 下载压缩包之后解压提取到Ubuntu中
>
> 设置环境配置
>
> vim /etc/profile
>
> export GOROOT=/go
>
> export GOPATH=/Go_WorkSpace
>
> export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
>
> source /etc/profile
> 使此修改的文件立即生效
>
> go env -w GOPROXY=https://goproxy.cn,direct

- **nodejs 8.11.4** 环境安装

> 安装nvm
>
> curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
>
> 安装后重启该会话或重新开一个会话即可生效
>
> 查看当前支持的版本
>
> nvm ls-remote
>
> 安装（同时安装npm）
>
> nvm install 8.11.4
>
> 检查node.js安装版本
>
> node -v
>
> 检查npm的安装版本
>
> npm -v
>
> 切换源
>
> npm install -g nrm
>
> nrm ls
>
> nrm use taobao

- PostgreSQL 10.10 环境安装

> apt install postgresql

- Jq jq-1.5-1-a5b5cbe

> apt install jq

- **docker 19.03.2** 环境安装

> 官方安装脚本
>
> curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
>
> 配置Docker镜像站
>
> curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
>
> sudo systemctl restart docker.service


- **docker-compose 1.24.1** 环境安装

> docker-compose安装
>
> sudo apt-get install python-pip
>
> sudo pip install docker-compose
>
> 查看版本
>
> docker-compose -version

## first-network搭建

### 编译工具


```
go get github.com/hyperledger/fabric

go get -u github.com/golang/protobuf/protoc-gen-go

cd $GOPATH/src/github.com/hyperledger/fabric

git checkout v1.4.2

sudo apt install libtool libltdl-dev

make release

cd release/linux-amd64 （bin文件下生成了一些必要的工具）

sudo cp -r bin /usr/local （移动到/usr/local下，全局使用）

cd ../..

mkdir -p .build/docker/gotools/

cp -r $GOPATH/bin .build/docker/gotools/

cp -r $GOPATH/src/github.com/hyperledger/fabric/release/linux-amd64/bin/ .build/docker/gotools/
```

### 启动网络

```
go get -u github.com/hyperledger/fabric-samples

cd $GOPATH/src/github.com/hyperledger/fabric-samples/

git checkout v1.4.2

cd first-network

./byfn.sh -m generate

./byfn.sh -m up

./byfn.sh -m down(TODO:清除所有容器和镜像，最后使用)
```


## 区块链浏览器运行实现

### 导入数据库


```
cd $GOPATH/src/github.com/hyperledger/blockchain-explorer

git checkout v0.3.9.5

cd app/persistence/fabric/postgreSQL

chmod +R 775 db/

cd db

./createdb.sh

cd  $GOPATH/src/github.com/hyperledger/blockchain-explorer/app/platform/fabric/

vim config.json
```


将$GOPATH换成自己的路径，将organizations组织的sk证书文件名称换成自己的文件名称，保存退出

可参考以下配置信息


```json
{
	"name": "first-network",
	"version": "1.0.0",
	"license": "Apache-2.0",
	"client": {
		"tlsEnable": true,
		"adminUser": "admin",
		"adminPassword": "adminpw",
		"enableAuthentication": false,
		"organization": "Org1",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "300"
				},
				"orderer": "300"
			}
		}
	},
	"channels": {
		"mychannel": {
			"peers": {
				"peer0.org1.example.com": {},
				"peer1.org1.example.com": {},
				"peer0.org2.example.com": {},
				"peer1.org2.example.com": {}
				},

			"connection": {
				"timeout": {
					"peer": {
						"endorser": "6000",
						"eventHub": "6000",
						"eventReg": "6000"
					}
				}
			}
		}
	},
	"organizations": {
		"Org1": {
			"mspid": "Org1MSP",
			"fullpath": true,
			"adminPrivateKey": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/095dd549c6724c0280f1e22adf5216e09da2914c7491ec155b649cef85d960f8_sk"
			},
			"signedCert": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem"
			}
		}
	},
	"peers": {
		"peer0.org1.example.com": {
			"tlsCACerts": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
			},
			"url": "grpcs://localhost:7051",
			"eventUrl": "grpcs://localhost:7053",
			"grpcOptions": {
				"ssl-target-name-override": "peer0.org1.example.com"
			}
		},
		"peer1.org1.example.com": {
			"tlsCACerts": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt"
			},
			"url": "grpcs://localhost:8051",
			"eventUrl": "grpcs://localhost:8053",
			"grpcOptions": {
				"ssl-target-name-override": "peer1.org1.example.com"
			}
		},
		"peer0.org2.example.com": {
			"tlsCACerts": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
			},
			"url": "grpcs://localhost:9051",
			"eventUrl": "grpcs://localhost:9053",
			"grpcOptions": {
				"ssl-target-name-override": "peer0.org2.example.com"
			}
		},
		"peer1.org2.example.com": {
			"tlsCACerts": {
				"path": "$GOPATH/src/github.com/hyperledger/fabric-samples/first-network/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt"
			},
			"url": "grpcs://localhost:10051",
			"eventUrl": "grpcs://localhost:10053",
			"grpcOptions": {
				"ssl-target-name-override": "peer1.org2.example.com"
			}
		}
	}
}
```


### 编译启动


```
cd $GOPATH/src/github.com/hyperledger/blockchain-explorer

npm install

cd app/test

npm install

npm run test

cd ../../client/

rm package-lock.json

npm install

npm run test:ci -- -u --coverage

npm run build
```

### 连接终端


```
cd $GOPATH/src/github.com/hyperledger/blockchain-explorer

./start.sh
```

打开浏览器输入以下网址

http://localhost:8080/#/login

账号密码见config.json配置

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。