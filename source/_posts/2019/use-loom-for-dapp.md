---
title: 用 Loom SDK 搭建的以太坊侧链上运行 DApp
permalink: use-loom-for-dapp
date: 2019-05-06 10:41:20
categories: 
    - 扩容技术
    - Loom
tags: 
    - Loom
    - DApp
author: Tiny熊
---

上一篇，我们在[Loom 构建的DApp侧链上部署了智能合约](https://learnblockchain.cn/2019/04/29/use-loom/)，这篇文章就来基于侧链网络部署一个DApp（去中心化应用）。

<!-- more -->


## 应用如何连接 Loom 侧链

之前我们在开发DApp时，我们会引入 web3.js 或 [ethers.js](https://learnblockchain.cn/docs/ethers.js/) 作为链和应用前端的桥梁，通过一个设置一个Provider 来和指定的节点进行通信，以[web3.js 0.20](https://learnblockchain.cn/docs/web3js-0.2x/web3.eth.html#contract) 为例，代码大概是这样的：

```js 
var web3Provider = window.ethereum;  // ❶
    
var web3 = new Web3(web3Provider);
var MyContract = web3.eth.contract(abiArray);
// 使用合约地址实例化合约
var contractInstance = MyContract.at(address);

contractInstance.callMethod(function());
```

❶ 行就是用来设置 provider, 如果我们的的浏览器安装了MetaMask 插件， 它会注入一个ethereum对象，也是通常推荐的方式。

不过目前（2019-05） MetaMask 还不支持连接 Loom 侧链，Loom 为此提供了一个 LoomProvider。



## 安装 LoomProvider

LoomProvider 在 `loom-js` 包里，可以 npm 来安装，安装命令如下：

```
npm install loom-js --save
```

除了 LoomProvider外 `loom-js` 中还有几个模块我们需要使用到，使用 ES6的 `import { } from 'loom-js'` 的方式引入模块会比较方便，由于这个语法目前大多数浏览器依然不支持，不过我们可以使用 [webpack](https://github.com/webpack/webpack) 转化为 浏览器支持的 ES5 代码。


## Webpack 安装与使用

## Webpack  安装
同样使用 npm 来安装，命令如下：

```bash
npm install webpack --save

```

同时建议把 `webpack-dev-server` 安装上，这样在开发过程中，我们修改的代码可以实时反映的浏览器中（俗称“热更新”），安装方式如下：

```bash
npm install webpack-dev-server --save
```

## Webpack 配置

为了方便把与合约交互的代码放在`src/index.js`（index.js 的代码编写见下节）中，把webpack生成的代码放在`dist/bundle.js`文件（这也是通常的作法），编写配置文件 `webpack.config.js` 如下： 

```js webpack.config.js
const webpack = require('webpack')
var path = require('path')

module.exports = {
    entry: {
        app: path.join(__dirname, 'src', 'index.js')
    },

    output: {
        path: path.join(__dirname, 'dist'),
        filename: 'bundle.js'
    },
    devServer: {
        historyApiFallback: true
    },
    node: {
        fs: 'empty',
        child_process: 'empty',
        crypto: true,
        util: true,
        stream: true,
        path: 'empty',
    },
    externals: {
        shelljs: 'commonjs shelljs',
    },
    optimization: {
        minimizer: []
    }
}
```

## DApp 如何与 loom 侧链交互

我们把所有的交互代码放在 index.js 的 App 类中，不过前端 `index.html` 引入的是 经过webpack 打包后的 `bundle.js` 文件。

### 初始化`web3`

回顾初始化`web3`的代码，需要传入`Provider`对象，此时就需要用到 `LoomProvider`，更改后初始化web3的代码, 如下()：

```js src/index.js
import {
    LoomProvider
} from 'loom-js'

export default class App {
    initWeb3() {
      this.web3 = new Web3(new LoomProvider(this.client, this.privateKey))  // ❶
    }
}
```

❶  为初始化web3 代码， 构造 LoomProvider 对象时需要传入 client 对象和一个私钥，在侧链上发起的交易，将用这个私钥进行签名。

### 创建client对象

添加 client 的创建函数 createClient() 代码如下：

```js src/index.js
import { 
    Client,
    LoomProvider
} from 'loom-js'

export default class App {
    createClient() {   // ❶
        let writeUrl = 'ws://127.0.0.1:46658/websocket'
        let readUrl = 'ws://127.0.0.1:46658/queryws'
        let networkId = 'default'

        this.client = new Client(networkId, writeUrl, readUrl)

        this.client.on('error', msg => {
            console.error('Error on connect to client', msg)
            console.warn('Please verify if loom command is running')
        })
    }
    
    initWeb3() { ... }
    
}
```

client 的创建需要的信息，和我们在 上一篇[loom 上部署合约](https://learnblockchain.cn/2019/04/29/use-loom/)中 `truffle.js` 的配置相似，都是指定节点的 RPC 信息，可以参考[loom 官方文档](https://loomx.io/developers/docs/zh-CN/web3js-loom-provider-truffle.html)。

### 创建账号

私钥及账号创建代码如下：

```js src/index.js
import { 
    Client,
    LocalAddress,
    CryptoUtils,
    LoomProvider
} from 'loom-js'

export default class App {

    init() {
        this.createClient();
        this.createCurrentUserAddress();
        this.initWeb3();
    }

    createClient() { ... }
    createCurrentUserAddress() {   // ❶
        this.privateKey = CryptoUtils.generatePrivateKey()
        this.publicKey = CryptoUtils.publicKeyFromPrivateKey(this.privateKey)
        this.account =  LocalAddress.fromPublicKey(this.publicKey).toString();  
    }
    initWeb3() { ... }
}
```

❶ 行 createCurrentUserAddress 函数通过`CryptoUtils`创建私钥推导公钥创建账号。

### 构造合约对象

上面完成了web3对象的创建，现在可以开始构造合约对象，用 `initContract` 来执行这个过程，代码如下：


```js src/index.js

import NoteContract from '../build/contracts/NoteContract.json'  // ❶

export default class App {

    init() {
        this.createClient();
        this.createCurrentUserAddress();
        this.initWeb3();
        this.initContract();
    }
        
    async initContract() {
        const networkId = "13654820909954";    // ❷
        this.currentNetwork = NoteContract.networks[networkId]
        
        if (!this.currentNetwork) {
            throw Error('Contract not deployed on DAppChain')
        }
        const ABI = NoteContract.abi;

        var MyContract = this.web3.eth.contract(ABI);    // ❸
        this.noteIntance = MyContract.at(this.currentNetwork.address);  // ❹
        
    }
}
```

说明：
❶  从 [Truffle](https://learnblockchain.cn/docs/truffle/) 编译部署生成的Json文件引入 合约描述对像
❷  这是我们侧链的网络id，在[上一篇](https://learnblockchain.cn/2019/04/29/use-loom/#%E5%9C%A8%E4%BE%A7%E9%93%BE%E4%B8%8A%E5%BC%80%E5%8F%91%E5%92%8C%E9%83%A8%E7%BD%B2%E6%99%BA%E8%83%BD%E5%90%88%E7%BA%A6) 进行合约部署的时候，可以看到 Network id 的输出提示。

> 注: 在官方的示例中 networkId 使用的是 `default`， 不过我在实际运行时，使用 `default` 作为网络id会出错（找不到对应的合约部署地址）。

❸ ❹  web3.js 0.20 构造合约对象的方式。
> 注: 我也尝试过使用  web3.js 1.0 版本去构造合约对象， 不过获得合约对象总是合约抽象 AbstractContact ，Google 半天没有找到方案，只好作罢。


### 调用合约方法

直接使用 `this.noteIntance` 对象调用合约方法即可，和我们之前文章开发DApp时完全一样，如加载笔记的逻辑如下：

```js src/index.js
export default class App {
    getNotes() {
        var that = this;
        
        this.noteIntance.getNotesLen(this.account, function(err, len) { // ❶
            console.log(len + " 条笔记");
            if (len > 0) {
                that.loadNote(len - 1);
            }
        });
    }
    
   loadNote(index) {   // 加载每一条笔记
    ... 
   }
}
```

说明：

❶  直接使用合约实例 `this.noteIntance` 调用合约的函数，传入参数及回调方法，可参考文档：[web3.js 0.20 中文文档](https://learnblockchain.cn/docs/web3js-0.2x/web3.eth.html#contract)


完整代码在[GitHub](https://github.com/xilibi2003/note_dapp)，切换到loom 分支查看。


## 运行 DApp 

前面我们安装了 `webpack-dev-server` 服务器， 可以使用 `webpack-dev-server` 加载 DApp 的跟目录，命令如下：

 ```bash
 webpack-dev-server --hot --content-base ./dist
 
 ``` 
 
 为了方便，可以在package.js 加入一条脚本:
 
 ```js
 "scripts": {
     "serve": "webpack-dev-server --hot --content-base ./dist"
 }
 
 ```
 
 这样就可以使用 `npm run serve `来启动DApp , DApp运行的url 是 `http://localhost:8080/`，在浏览器输入这个地址就可以看到DApp界面，如下图，大家尝试添加几条笔记。
 
 ![DApp 界面](https://img.learnblockchain.cn/2019/15571945889674.jpg!wl/scale/60%)

> 注: 如果提示 `webpack-dev-server`命令找不到，可以使用`npm install webpack-dev-server -g ` 全局安装 


## Loom 目前的缺陷

在侧链上运行的DApp 交互响应时间好很多，不过当下任有一些问题。

### 无法和 MetaMask 配合使用

前面在编写 DApp 如何与 loom 侧链交互的代码时，有一个创建账号的步骤，即页面刷新的时候，每次都会用`CryptoUtils`重新创建一个账号，账号没有很好的办法复用是个挺大的问题，希望loom 能早日配合 MetaMask 钱包使用（或者开发出自己的钱包插件）。

有一个方法是把私钥存储在localStorage，实例代码如下:

```js
const storedKey = localStorage.getItem('loomKey')
let privKey
if (storedKey) {
    privKey = CryptoUtils.B64ToUint8Array(storedKey);
} else {
    privateKey = CryptoUtils.generatePrivateKey()
    localStorage.setItem('loomKey', CryptoUtils.Uint8ArrayToB64(privKey))
}     

```

> 根据Loom 在 medium的这篇[博客](https://medium.com/loom-network/universal-transaction-signing-seamless-layer-2-dapp-scaling-for-ethereum-b63a733fc65c) 说可以使用 ethers.js 的 signer 来通过 MetaMask 签名，不过我自己试验下来，并没有成功，希望成功的朋友可以留言讨论。


### 事件处理不完善

loom-js  对LoomProvider事件支持还不够完善，比如，我们添加事件监听代码：

```js 
        this.event = this.noteIntance.NewNote()
        this.event.watch(function(err, result) {
            console.log(" watch event: " + err);
        });
```

会提示错误：

```
watch event: Error: Method "eth_getFilterLogs" not supported on this provider
```

好在与侧链交互速度较快，这个问题不算严重，可以在发起交易之后，通过get的方式读取状态变化。


## 参考

1. [loom-js](https://github.com/loomnetwork/loom-js)
2. [loom sdk 文档](https://loomx.io/developers/docs/zh-CN/web3js-loom-provider-truffle.html)
3. [Plasma Cash Smart Contracts](https://github.com/loomnetwork/plasma-cash)
4. [deploying-your-first-app-to-loom-plasmachain](https://medium.com/loom-network/deploying-your-first-app-to-loom-plasmachain-installing-loom-setting-up-your-environment-and-b04aecfccf1f)
5. [Truffle 官方文档-中文版](https://learnblockchain.cn/docs/truffle/) 


加入[知识星球](https://learnblockchain.cn/images/zsxq.png)，和一群优秀的区块链从业者一起学习。
[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。


