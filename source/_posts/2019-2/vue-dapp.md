---
title: 【教程】如何使用Vue.js 开发以太坊DApp
permalink: vue-dapp
date: 2019-12-20 15:10:54
categories: 
    - 以太坊
    - DApp
tags:
    - DApp
    - Vue.js
    - Web3.js
author: Tiny熊
---

Vue 是一套在前端开发中广泛采用的用于构建用户界面的渐进式JavaScript框架。Vue 通过响应的数据绑定和组合的视图组件让界面开发变得非常的简单。这篇文章来看看如何使用Vue开发以太坊DApp。

<!---more--->


## Vue 简介

Vue 除了是JavaScript框架，还提供了一个配套的命令行工具 Vue CLI，通常称之为脚手架工具，用来进行项目管理，比如快速开始零配置原型开发，安装插件库等。

Vue CLI 可以通过以下命令安装：

```
> npm install -g @vue/cli
```

运行以下命令来创建一个名为crowdfunding的新项目：

```
> vue create crowdfunding
```

命令会生成一个项目目录，并安装好相应的依赖库，生成的主要文件有：
```
├── package.json
├── public
│   ├── index.html
└── src
    ├── App.vue
    ├── assets
    │   └── logo.png
    ├── components
    │   ├── CrowdFund.vue
    │   └── HelloWorld.vue
    └── main.js
            
```

简单介绍一下Vue 生成的文件，更多的使用介绍，可参考 vue.js 文档[6]。

index.html 是入口文件，里面定义了一个div标签:
```
<div id="app"></div>
```

在main.js 中，会把APP.vue的组件的内容渲染到id 为app的div标签内：

```
new Vue({
  render: h => h(App),
}).$mount('#app')
```

APP.vue 组件又引用了Hello.vue 组件，创建完成后进入目录，就可以运行项目，命令如下：

```bash
> cd crowdfunding
> npm run serve (或 yarn serve)
```

此时会在8080端口下，启动一个Web服务，浏览器输入URL： `http://localhost:8080`，会打开前端页面。

## DApp 需求分析

在刚刚创建的工程下来完成众筹DApp，先分析下需求，假设我准备出版一本区块练技术书籍，但是不确定有多少人愿意购买这本书，于是我发起了一个众筹， 如果在一个月内，能筹集到10个ETH，我就进行写作，并给参与的读者每人赠送一本书，如果未能筹到足够的资金，参与的读者赎回之前投入的资金。 

同时，为了让读者积极参与，初始时，参与众筹的价格非常低（0.02 ETH），每筹集满1个ETH时，价格上涨0.002ETH。

归纳出合约三个对外动作（函数）：
1. 汇款进合约，可通过实现合约的回退函数来实现。
2. 读者赎回汇款，这个函数仅仅在众筹未达标之后，由读者本人调用生效。
3. 创作者提取资金，这个函数需要在众筹达标之后，由创作者调用。

除此之外，还需要一个状态变量来保存以下状态：
1. 用户众筹的金额，使用一个[mapping](https://learnblockchain.cn/docs/solidity/types.html#mapping-types) 来保存。
2. 当前众筹的价格，以及一个相应的内部函数逐步上涨价格。价格可以使用一个[uint](https://learnblockchain.cn/docs/solidity/types.html#index-3)来保存。
3. 合约众筹的截止时间，用uint来保存， 在合约创建时往后追加30天，在构造函数中完成。
4. 记录合约众筹的收益者，即创作者，在合约创建时在构造函数中进行赋值，合约创建者就是创作者。
5. 再加入众筹状态，如果众筹停止阻止用户在参与。创作者提取资金时及时关闭众筹。

##  实现众筹合约

DApp的开发，我们依然可以使用[Truffle框架](https://learnblockchain.cn/docs/truffle/)，先进入crowdfunding目录，使用 `truffle init `进行一下 truffle 项目初始化：

```
> truffle init
```

初始化完成后， 会在当前目录下生成 truffle-config.js 配置文件及 `contracts` `migrations` 文件夹等内容，之后，就可以在项目下使用 `truffle compile` 来编译合约及 `truffle migrate` 来部署合约。


在contracts 下创建一个合约文件Crowdfunding.sol:

```js
pragma solidity >=0.4.21 <0.7.0;


contract Crowdfunding {
    // 创作者
    address public author;

    // 参与金额
    mapping(address => uint) public joined;

    // 众筹目标
    uint constant Target = 10 ether;

    // 众筹截止时间
    uint public endTime;

    // 记录当前众筹价格
    uint public price  = 0.02 ether ;

    // 作者提取资金之后，关闭众筹
    bool public closed = false;

    // 部署合约时调用，初始化作者以及众筹结束时间
    constructor() public {
        author = msg.sender;
        endTime = now + 30 days;
    }

    // 更新价格，这是一个内部函数
    function updatePrice() internal {
        uint rise = address(this).balance / 1 ether * 0.002 ether;
        price = 0.02 ether + rise;
    }

    // 用户向合约转账时 触发的回调函数
    function () external payable {
        require(now < endTime && !closed  , "众筹已结束");
        require(joined[msg.sender] == 0 , "你已经参与过众筹");

        require (msg.value >= price, "出价太低了");
        joined[msg.sender] = msg.value;

        updatePrice();
    } 

    // 作者提取资金
    function withdrawFund() external {
        require(msg.sender == author, "你不是作者");
        require(address(this).balance >= Target, "未达到众筹目标");
        closed = true;   
        msg.sender.transfer(address(this).balance);
    }

    // 读者赎回资金
    function withdraw() external {
        require(now > endTime, "还未到众筹结束时间");
        require(!closed, "众筹达标，众筹资金已提取");
        require(Target > address(this).balance, "众筹达标，你没法提取资金");
        
        msg.sender.transfer(joined[msg.sender]);
    }

}

```

代码的介绍，我以注释的形式加入在代码中，除此之外，在合约代码中，使用到了Solidity语言中的一些知识点：
 1. `ether` : 这是货币单位。
 2. `days` : 这是时间单位，1 days 对应1天的秒数。
 3. `now`  : 这是一个Solidity的内置属性，用于获取当前的时间戳，单位是秒。
 4. `require` : 如果条件不满足回退交易。
 5. `address.transfer(value)` : 对某一个地址进行转账。 

有关Solidity 语言特性，大家可参考深入浅出区块链社区翻译的[Solidity中文文档](https://learnblockchain.cn/docs/solidity/units-and-global-variables.html)

## 合约部署

在migrations下创建一个部署脚本 2_crowfunding.js , 和[宠物商店DApp](https://learnblockchain.cn/2018/01/12/first-dapp/)类似，内容如下：

```
const crowd = artifacts.require("Crowdfunding");

module.exports = function(deployer) {
  deployer.deploy(crowd);
};

```

在`truffe-config.js` 配置要部署的网络，同时确保对应的网络节点程序是开启状态，方法参考[宠物商店DApp](https://learnblockchain.cn/2018/01/12/first-dapp/)或[链上笔记本](https://learnblockchain.cn/2019/03/30/dapp_noteOnChain/)投票合约案例中一样，然后就可以`truffle migrate` 进行部署。


## 众筹Web界面实现

默认会有一个HelloWorld.vue, 新写一个组件 CrowdFund.vue ，把App.vue中对HelloWorld.vue的引用替换掉。

App.vue 修改为：
```
<template>
  <div id="app">
    <CrowdFund/>
  </div>
</template>

<script>
import CrowdFund from './components/CrowdFund.vue'

export default {
  name: 'app',
  components: {
    CrowdFund
  }
}
</script>
```

利用CrowdFund.vue来众筹界面，众筹界面需要显示以下几个部分：
1. 当前众筹到金额。
2. 众筹的截止时间。
3. 当前众筹的价格，参与众筹按钮。
4. 如果是已经参与，显示其参与的价格以及赎回按钮。
5. 如果是创作者，显示一个提取资金按钮。

因为Vue 具有很好的数据绑定及条件渲染特性，因此前端写起来会更简单，只需要把相应的数据用变量替代，代码如下：

```html
<template>
<div class="content">
  <h3> 新书众筹</h3>
  <span>以最低的价格获取我的新书 </span>

  <!-- 众筹的总体状态  -->
  <div class="status">
    <div v-if="!closed">已众筹资金：<b>{{ total }} ETH </b></div>
    <div v-if="closed"> 众筹已完成 </div>
    <div>众筹截止时间：{{ endDate }}</div>
  </div>

  <!-- 当读者参与过，显示如下div  -->
  <div v-if="joined" class="card-bkg">
    <div class="award-des">
      <span> 参与价格 </span>
      <b> {{ joinPrice }} ETH </b>
    </div>

    <button :disabled="closed" @click="withdraw">赎回</button>
  </div>

  <!-- 当读者未参与，显示如下div  -->
  <div v-if="!joined" class="card-bkg">
    <div class="award-des">
      <span> 当前众筹价格 </span>
      <b> {{ price }} ETH </b>
    </div>

    <button :disabled="closed" @click="join">参与众筹</button>
  </div>

  <!--  如果是创作者，显示 -->
  <div v-if="isAuthor">
    <button :disabled="closed" @click="withdrawFund"> 提取资金</button>
  </div>

</div>
</template>
```

代码中使用Vue的特性包含：
1. 使用`v-if` 进行条件渲染，例如 `v-if="joined"` 表示当joined变量为true 时，才渲染标签。
2. 使用 `{{ 变量 }}` 进行数据绑定， 例如：`<b>{{ price }} ETH </b>`， price会用其真实的值进行渲染，并且当price变量的值更新时，标签会自动更新。
3. 使用`@click`指令来监听事件，`@click` 实际上是 `v-on:click` 的缩写，例如：`@click="join"` 表示当标签点击时，会调用join函数。
4. 使用 `:disabled` 绑定一个属性，这实际是` v-bind:disabled`， 属性的值来源于一个变量。

## 与众筹合约交互

现在来编写JavaScript逻辑部分，前端界面与合约进行交互时，需要使用到 `truffle-contract` 及 `web3` ，因为Vue 工程本身也是通过NPM进行包管理，因此可以直接通过npm进行安装，命令如下：

```
npm install --save truffle-contract web3
```

先把JavaScript逻辑的主体框架代码编写出来：

```js
<script>


export default {
  name: 'CrowdFund',
  // 定义上面HTML模板中使用的变量
  data() {
    return {
      price: null,
      total: 0,
      closed: true,
      joinPrice: null,
      joined: false,
      endDate: "null",
      isAuthor: true,
    }
  },

  // 当前Vue组件被创建时回调的hook 函数
  async created() {
    //  初始化 web3及账号
    await this.initWeb3Account()
     //  初始化合约实例
    await this.initContract()
     //  获取合约的状态信息
    await this.getCrowdInfo()
  },

  methods: {

    async initWeb3Account() {}
    async initContract() {}
    async getCrowdInfo() {}
  }
}
</script>
```

以上代码通过data() 定义好了上面HTML模板中使用的变量， 当Vue组件被创建时通过回调的created()函数, 来进行初始化工作（这里使用了async/await 来简化异步调用）， 在created()函数中调用了三个函数：
 * initWeb3Account()
 * initContract()
 * getCrowdInfo()


依次来进行实现：

initWeb3Account() 用来完成 web3及账号初始化，代码和投票案例基本类似，代码如下： 
```js
   import Web3 from "web3";

    async initWeb3Account() {
      if (window.ethereum) {
        this.provider = window.ethereum;
        try {
          await window.ethereum.enable();
        } catch (error) {
          //   console.log("User denied account access");
        }
      } else if (window.web3) {
        this.provider = window.web3.currentProvider;
      } else {
        this.provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545");
      }
      this.web3 = new Web3(this.provider);
      this.web3.eth.getAccounts().then(accs  => {
        this.account = accs[0]
      })
    },
```

通过这段代码完成了 `this.provider` `this.web3` `this.account` 三个变量的赋值，在后面的代码中会使用到。

initContract() 初始化合约实例：
```js
import contract from "truffle-contract";
import crowd from '../../build/contracts/Crowdfunding.json';

    async initContract() {
      const crowdContract = contract(crowd)
      crowdContract.setProvider(this.provider)
      this.crowdFund = await crowdContract.deployed()
    },
```

this.crowdFund 变量就是部署的众筹合约对应得JavaScript 中的实例， 下面就可以通过this.crowdFund来调用合约的函数，获取相关变量的值，也就是实现`getCrowdInfo` 函数：

```js
    async getCrowdInfo() {

      // 获取合约的余额
      this.web3.eth.getBalance(this.crowdFund.address).then(
        r => {
          this.total = this.web3.utils.fromWei(r)
        }
      )

      // 获取读者的参与金额
      this.crowdFund.joined(this.account).then(
        r => {
          if (r > 0) {
            this.joined = true
            this.joinPrice = this.web3.utils.fromWei(r)
          }
        }
      )

     // 获取合约的关闭状态
      this.crowdFund.closed().then(
        r => this.closed = r
      )

      // 获取当前的众筹价格
      this.crowdFund.price().then(
        r => this.price = this.web3.utils.fromWei(r)
      )

      // 获取众筹截止时间
      this.crowdFund.endTime().then(r => {
        var endTime = new Date(r * 1000)
        // 把时间戳转化为本地时间
        this.endDate = endTime.toLocaleDateString().replace(/\//g, "-") + " " + endTime.toTimeString().substr(0, 8);
      })

      // 获取众筹创作者地址
      this.crowdFund.author().then(r => {
        if (this.account == r) {
          this.isAuthor = true
        } else {
          this.isAuthor = false
        }
      })

    }
```

对代码中使用到的几个技术点，进行下解释：
1. 合约实例 this.crowdFund 调用的函数 `joined()` `closed()` `price() ` 是由合约中是public 的状态变量，自动生成相应的访问器函数。可以回顾第6章。
2. 代码中使用的 `this.web3.eth.getBalance()` 和 `this.web3.utils.fromWei()` 是Web3.js 中定义的函数，分别用来获取余额及把单位wei转化为ether。

至此，完成DApp的状态数据的获取，接下来开始处理3个点击动作（即html模板中@click触发的函数）：
1. 读者参与众筹的join()函数；
2. 读者赎回的withdraw()函数；
3. 创作者提取资金的withdrawFund()函数。

join() 需要完成的实际上是由读者账号向众筹合约账号发起一笔转账，通过`web3.eth.sendTransaction` 完成，代码如下：

```js
    join() {
      this.web3.eth.sendTransaction({
        from: this.account,
        to: this.crowdFund.address,
        value: this.web3.utils.toWei(this.price)
      }).then(() =>
        this.getCrowdInfo()
      )
    }
```

读者进行转账时，就会触发合约的回退函数。

如果众筹未达标，读者可以点击赎回，对应withdraw()函数实现如下：

```js
    withdraw() {
      this.crowdFund.withdraw({
        from: this.account
      }).then(() => {
        this.getCrowdInfo()
      })
    },
```

如果众筹达标，创作者提取资金withdrawFund()函数实现如下：

```js
    withdrawFund() {
      this.crowdFund.withdrawFund({
        from: this.account
      }).then(() => {
        this.getCrowdInfo()
      })
    }
```

到这里众筹案例就全部完成了，完整的代码请大家[订阅小专栏](https://xiaozhuanlan.com/blockchaincore)。

## DApp 运行

在项目的目录下，输入以下命令：

``` 
> npm run serve（或  yarn serve ）
```

浏览器输入 http://localhost:8080， 效果如下图：

![参与众筹](https://img.learnblockchain.cn/2019/12/15768242114420.jpg)


如果是参与过众筹（创作者账号还会显示一个”提取资金“），界面如下图：
![参与过众筹](https://img.learnblockchain.cn/2019/12/15768242457900.jpg)


在运行DApp 时，要确保MetaMask链接的网络和合约部署的网络一致，这样DApp才能正确的通过web3获取到合约的数据。

## DApp 发布

通过以下命令:

``` 
> npm run build（或  yarn build ）
```

会再dist目录下，构建出用户发布的完整的前端代码，其文件如下：
```
dist
├── css
│   └── app.40b6ecb0.css
├── favicon.ico
├── index.html
└── js
    ├── app.5b2f814c.js
    ├── app.5b2f814c.js.map
    ├── chunk-vendors.787aba35.js
    └── chunk-vendors.787aba35.js.map
```

index.html 就是DApp前端入口文件，把dist目录下的所有文件拷贝到公网的服务器即可。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，[学区块链](https://learnblockchain.cn/2018/01/11/guide/)都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789)。