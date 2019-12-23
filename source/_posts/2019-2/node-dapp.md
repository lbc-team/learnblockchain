---
title: 使用Node.js后台监听合约事件及提供服务
permalink: node-dapp
date: 2019-12-23 15:10:54
categories: 
    - 以太坊
    - DApp
tags:
    - DApp
    - Node.js
    - Web3.js
author: Tiny熊
---


在上个文章[众筹案例](https://learnblockchain.cn/2019/12/20/vue-dapp/)中，每个参与者可以看到自己的参与的状态，创作者却没有办法查看所有参与者，这篇文章我们实现在合约中加入参与事件，后台通过监听参与事件记录所有的参与者。

<!---more--->

## 需求背景

其实有二个办法实现查看所有参与者：
1. 加入一个状态变量：address[] joinAccouts ，这是一个[Solidity数组类型](https://learnblockchain.cn/docs/solidity/types.html#arrays)，用来记录所有参与者的地址，每当有新的参与者进来时，给数组加入参与者地址。
2. 通过触发事件把参与者地址记录到日志中，然后通过启动一个服务程序监听事件，当事件触发时，把参与者地址记录到数据库中，并提供一个后端服务，它数据库中的参与者列表返回给前端。

两种方法各有优缺点，方法1的gas消耗会远高于方法2，优点是更加简单，方法2则相反，并且方法2可以实时获取到状态，这在一些场合非常有用。来看看方法二如何实现。


## Node.js 及 Express 简介

这里使用Node.js来作为后端服务，Node.js 就是运行在服务端的 JavaScript。Node.js 是一个基于Google的V8 引擎运行时建立的一个事件驱动I/O服务端JavaScript环境，速度非常快，性能非常好。

Express 是一个简洁而灵活的 node.js Web应用框架, 提供了一系列强大特性帮助创建各种 Web 应用。

下面通过编写一个简单的Hello World来看看如何使用Express 如何使用，在众筹项目目录下新建一个文件夹server，进入此目录并将其作为后端项目工作目录,命令如下：

```
> mkdir server
> cd server
> npm init
```


然后通过`npm init`命令进行初始化，npm init 会创建一个 package.json 文件进行包管理，同时还会要求我们输入几个参数，例如此应用的名称和版本，命令效果如下：

```
> npm init
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help json` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg>` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
package name: (server) server
version: (1.0.0)
description: 众筹监听后台demon
entry point: (index.js)
test command:
git repository:
keywords:
author:
license: (ISC)
About to write to /User/xxx/crowdfunding/server/package.json:

{
  "name": "server",
  "version": "1.0.0",
  "description": "众筹监听后台demon",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}


Is this OK? (yes) yes
```

大部分直接按“回车”键接受默认设置即可，这个时候，就可以看到在server目录下产生了一个pacckage.json 文件，继续安装Express， 命令如下：

```bash
npm install express --save
```

环境完成了，新建一个文件 `index.js` ，编写一段服务端的程序HelloWorld， 代码如下:

```js
const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(3000, () => console.log('Start Server, listening on port 3000!'))
```

上面代码中，引入了 express 模块，它在后台常驻运行，并监听着3000 端口，当客户端发起请求后，响应 "Hello World!" 字符串，通过以下命令启动服务：

```
> node index.js
Start Server, listening on port 3000! 
```

启动后，在浏览器访问地址: http://localhost:3000 就可以看到Hello World!， 如下图

![Express 启动](https://img.learnblockchain.cn/2019/12/15770880657240.jpg)


## 监听合约事件

Express 会启动一个常驻在后台的服务，对刚刚编写的index.js 进行下修改，加入web3 就能够实现监听合约事件。

### 合约加入事件

先在Crowdfunding合约中加入一个事件：
```
event Join(address indexed, uint price);
```

然后在回退函数中加入触发事件：

```
emit Join(msg.sender, msg.value); 
```

### 监听事件

修改合约后，使用`truffle migrate --reset` 命令重新编译部署，之后在 index.js中加入监听Join事件代码，代码如下：

```js
// express 启动代码
...

// 引入web库
var Web3 = require('web3');
// 使用WebSocket协议 连接节点
let web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:7545'));


// 获取合约实例
var Crowdfunding = require('../build/contracts/Crowdfunding.json');
const crowdFund = new web3.eth.Contract(
  Crowdfunding.abi,
  Crowdfunding.networks[2337].address
);

//  监听Join 加速事件
crowdFund.events.Join(function(error, event) {
  if (error) {
    console.log(error);
  }

  // 打印出交易hash 及区块号
  console.log("交易hash:" + event.transactionHash);
  console.log("区块高度:" + event.blockNumber);

  //   获得监听到的数据：
  console.log("参与地址:" + event.returnValues.user);
  console.log("参与金额:" + event.returnValues.price);
});
});
```

除以上注释外，对以上代码关键点进行下介绍：
* 在初始化web3时，使用了 WebsocketProvider，通过 WebSocket 通信协议与节点通信，如果是使用 geth 节点需要使用选项 `--ws` 开启服务，开发使用的Ganache默认开启了WebSocket服务。

    > 补充知识： HTTP 协议有一个缺陷是只能单向通行，通信只能由客户端发起， 只能通过"轮询"去获取状态的更新，而WebSocket 支持双向通行，服务端可以主动向客户端推送信息，客户端也可以主动向服务器发送信息（注意 Express 服务在与节点程序通信时，节点是作为服务端角色）。
    
* 获取合约实例时，使用的合约的ABI 及合约地址参数，均是通过Truffle 编译部署生成的文件 Crowdfunding.json 获取。
* 通过Web3合约实例后，可以通过 myContract.events.EventName()函数传入一个回调函数监听事件的变化。 更多的监听事件可以查看Web3.js文档

重新启动后台服务：

```
> node index.js
Start Server, listening on port 3000! 
```

另开一个命令行控制台窗口，启动前端：
``` 
> npm run serve（或  yarn serve ）
```

浏览器输入：`http://localhost:8080/` 进入前端页面，点击“参与众筹”，切换到后端的命令行控制台窗口， 可以看到打印出了四条日志：
```
> node index.js
Start Server, listening on port 3000!
交易hash: 0x6c1c5172eae236e9c1f535e...5d45d45254a2435b1cd3891e83635
区块高度: 58
参与地址: 0x132f44857fe61526...6b4109A198ea...
参与金额: 20000000000000000
```

为了方便管理，接下来把监听到的数据写入数据库里。

## 建数据库及表

我们这里选用的是MySQL，读者也可以根据自己的喜好选用其他的如PostgreSQL数据库， 这里假定数据库已经安装配置好（如何安装大家可自行搜索），连接上MySQL服务器， 使用以下命令创建数据库和表来存储众筹数据：

```
CREATE DATABASE crowdfund;
use crowdfund;

CREATE TABLE joins(
  id INT UNIQUE AUTO_INCREMENT,
  address VARCHAR(42) UNIQUE,
  price FLOAT NOT NULL,
  tx VARCHAR(66) NOT NULL,
  block_no INT NOT NULL,
  created_at datetime,
  PRIMARY KEY (id)
);
```

以上MySQL代码可以复制到MySQL客户端中执行，它创建名为 crowdfund 的数据库，并在数据库中创建joins表，joins表从来存储用户参与众筹信息，包含列有：主键id，地址address，价格price， 交易hash，区块号blockNo，以及插入数据时间。 

##  监听数据入库

先安装 [node-mysql](https://github.com/mysqljs/mysql) 驱动，它提供在Node.js程序里连接MySQL服务器的接口，安装命令如下：

```
> cd server
> npm install mysql --save
```

在inde.js 中引入mysql，并加入一个插入数据库函数，代码如下：
```js
var mysql  = require('mysql');

// 定义数据插入数据库函数
function insertJoins(address, price, tx, blockNo) {

// 连接数据库 (请使用你自己的mysql连接信息)
  var connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'username',
    password : 'pwd',
    port     : '3306',
    database : 'crowdfund'
  });

  connection.connect();
  
  // 构建插入语句
  const query = `INSERT into joins (
        address,
        price,
        tx,
        block_no,
        created_at
    ) Values (?,?,?,?,NOW())`;
  const params = [address, price, tx, blockNo];  

// 执行插入操作
  connection.query(query, params, function (error, results) {
    if (error) throw error;
  });

  connection.end();
}
```

并在上面监听打印日志的后面加入调用insertJoins()函数插入数据库， 调用代码如下：

```js
  insertJoins(event.returnValues.user,
  // 把以wei为单位的价格转为ether单位
    web3.utils.fromWei(event.returnValues.price),
    event.transactionHash,
    event.blockNumber )
```

使用node重新启动index.js：
```
node index.js，
```

在前端切换不同的账号点击“参与众筹”后，可以在数据库查询到相应的众筹记录，如下图所示:

![查询数据众筹数据](https://img.learnblockchain.cn/2019/12/15770893230206.jpg)

##  为前端提供众筹记录

### 后端提供接口

通过读取数据库的数据，并在Express加入一个路由，接受前端请求后返回读取到的数据，在index.js 先加入一个getJoins()函数来读取数据库数据：

```js
// 通过一个回调函数把结果返回出去
function getJoins(callback) {
// 获取数据库链接
  var connection = getConn();
  connection.connect();

// 查询 SQL
  const query = `SELECT address, price from joins`;
  const params = [];
    // 查询数据库
  connection.query(query, params, (err, rows)=>{
      if(err){
          return callback(err);
      }
      console.log(`result=>`, rows);        
      callback(rows);
  });

  connection.end();
}
```

getJoins() 和 insertJoins()  都需要获取数据库连接，为了代码复用，抽象出了getConn() 函数：

```js
// 请使用你自己的mysql连接信息
function getConn() {
  return mysql.createConnection({
    host     : 'localhost',
    user     : 'username',
    password : 'pwd',
    port     : '3306',
    database : 'crowdfund'
  });
}
```

加入一个新的路由`/joins`，代码如下：

```
app.get('/joins', (req, res) => {
  getJoins( rows=> {
    //  设置允许跨域访问
    res.set({'Access-Control-Allow-Origin': '*'})
    .send(rows)
  });
})
```

使用`node index.js`，重新启动index.js， 浏览器访问：`http://localhost:3000/joins`， 将返回参与众筹用户的JSON数组： 

```js
[
  {
    "address": "0x...b7579156EcD9A...",
    "price": 0.02
  },
  {
    "address": "0x...D4FCDF3332BcB31770...",
    "price": 0.02
  },
  {
    "address": "0x...45730F3756a5E8C8f0D3B...",
    "price": 0.02
  }
]

```

### 前端通过接口获取数据

现在前端组件就可以通过Ajax请求访问`/joins`获取众筹列表，前端可以安装Axios来进行HTTP请求，依旧通过npm 来安装：

```
> npm install axios (在项目根目录下执行)
```

修改前端 CrowdFund.vue , 加入获取众筹列表 getJoins()函数：

```
import axios from 'axios'
...
    // 获取众筹列表
    getJoins() {
      axios.get('http://localhost:3000/joins')
        .then(response => {
          this.joinList = response.data
        })
        .catch(function (error) { // Ajax请求失败处理
          console.log(error);
        });
    }
```


以上代码把axios获取到的众筹列表赋值给`joinList`变量。

### 前端渲染数据

在HTML模板中加入`joinList`的渲染：

```HTML
<!--  如果是创作者，显示 -->
  <div class="box" v-if="isAuthor">
    <div >
      <p v-bind:key="item" v-for="item in joinList" >
        <label> 地址：{{ item.address }} </label>
        金额：<b> {{ item.price }} </b>
      </p>
    </div>
   <button :disabled="closed" @click="withdrawFund"> 提取资金</button>
</div>
```

浏览器输入 `http://localhost:8080`，MetaMask切换到创作者账号，可以看到输出的众筹列表，效果如下图：

![展示众筹列表](https://img.learnblockchain.cn/2019/12/15770900010513.jpg)

通过Vue 开发前端，后端使用Node.js监控合约事件，这个案例就介绍完了，书中对于Vue及Node.js的使用也仅仅是抛砖引玉，毕竟不是本书的重点，相关知识点，需要读者自己扩展。

书中展示的代码略有删减，完整代码请订阅我的[小专栏](https://xiaozhuanlan.com/blockchaincore)。


[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。