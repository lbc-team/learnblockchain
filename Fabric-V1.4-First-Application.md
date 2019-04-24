# Fabric-V1.4-First-Application

标签（空格分隔）： 文章分享

---

接上两篇内容，这里实验下First-Application。
[官网示例教程：](https://hyperledger-fabric.readthedocs.io/en/latest/write_first_app.html#writing-your-first-application)https://hyperledger-fabric.readthedocs.io/en/latest/write_first_app.html#writing-your-first-application

![屏幕快照 2019-04-03 下午6.29.45.png-163.7kB][1]

### 实验环境：

Centos7.4  CPU：4C、内存：16G、硬盘：50G

---

笔者使用之前的测试环境，那么在实验前，建议重置后再进行以下操作。

```
./byfn.sh down
docker rm -f $(docker ps -aq)
docker ps -a (查看)
```

进入下列目录：
```
cd /usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/fabcar
执行：./startFabric.sh javascript
```
执行完成如下图：
![屏幕快照 2019-04-04 上午10.50.26.png-324.5kB][2]

进入下一级目录：
```
cd /usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/fabcar/javascript
提前修改：
vi package.json
把里面1.0.0版本改成1.4.0
npm install（如报错执行下列命令）
npm install --unsafe-perm
```

执行成功后.

注册admin用户：
当前文件夹中执行：
```
node enrollAdmin.js
```
执行完成后如下图，可以看到wallet中的admin相关信息。可通过查看
```
docker logs -f ca.example.com查看输出的log内容。
```

![屏幕快照 2019-04-04 上午10.54.11.png-80.9kB][3]

注册user用户：
```
node registerUser.js
```
注册完成后如图：

![屏幕快照 2019-04-04 下午12.00.31.png-156.2kB][4]

可以看到在：/usr/go/src/github.com/hyperledger/fabric/scripts/fabric-samples/fabcar/javascript/wallet目录中有相关的admin和user1
的信息。

查询账本，区块链中每个节点都有一个账本副本，那么通过user1来查看：
```
node query.js
```
结果如图：
![屏幕快照 2019-04-04 下午12.03.11.png-441.9kB][5]

---

更新账本：

可以通过vim来打开阅读、修改query.js文件，这里修改如下：
```
// Evaluate the specified transaction.
// queryCar transaction - requires 1 argument, ex: ('queryCar', 'CAR4')
// queryAllCars transaction - requires no arguments, ex: ('queryAllCars')
// const result = await contract.evaluateTransaction('queryAllCars');
const result = await contract.evaluateTransaction('queryCar','CAR1');
console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
```
再次执行：node query.js会发现只显示CAR1：

![屏幕快照 2019-04-04 下午12.12.55.png-103.2kB][6]

那么区块链网络包含多个peer，每个peer都维护一份账本副本，并且选择性的维护一个智能合约副本，除此之外，网络还包括一个排序服务。

执行：
```
node invoke.js
```
来创建一个新车，成功结果如下：
![屏幕快照 2019-04-04 下午12.15.20.png-135.1kB][7]

那么再次查看刚才的交易是否成功，修改query.js来对比：
![屏幕快照 2019-04-04 下午12.22.32.png-478.6kB][8]
比之前的查询多了CAR12，那么单独查询修改之前的代码CAR1为CAR12

再次执行：
![屏幕快照 2019-04-04 下午12.24.54.png-101.3kB][9]

交易这辆Honda：
可以看到车现在是Tom，那么交易给Jacky
修改vim invoke.js文件：
```
// await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');
await contract.submitTransaction('changeCarOwner', 'CAR12', 'Jacky');
```
修改完成后执行：
```
node invoke.js
node query.js
```
显示如下：
车子已经是Jacky。
![屏幕快照 2019-04-04 下午12.32.48.png-234.1kB][10]

---

（未完待续）


参考：
1.https://blog.csdn.net/ASN_forever/article/details/87778013
2.https://hyperledger-fabric.readthedocs.io/en/latest/developapps/developing_applications.html


  [1]: http://static.zybuluo.com/JackyJin/6hdu7ox87hcrtkvqc5w744fb/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-03%20%E4%B8%8B%E5%8D%886.29.45.png
  [2]: http://static.zybuluo.com/JackyJin/x98bojfagof9xhkc35yk0j51/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8A%E5%8D%8810.50.26.png
  [3]: http://static.zybuluo.com/JackyJin/cgxakdw5orvve6wgo0zklyz3/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8A%E5%8D%8810.54.11.png
  [4]: http://static.zybuluo.com/JackyJin/my72qd6ab3qejmmdbtub2mtc/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.00.31.png
  [5]: http://static.zybuluo.com/JackyJin/6795bm6m98g4id7mszzbuksl/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.03.11.png
  [6]: http://static.zybuluo.com/JackyJin/bljnpwc4hs4lf47xs9w9g1v7/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.12.55.png
  [7]: http://static.zybuluo.com/JackyJin/x3v3v04qf2tishzhno5y3xfh/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.15.20.png
  [8]: http://static.zybuluo.com/JackyJin/gs3lssfwowz47y38l9w3k8yj/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.22.32.png
  [9]: http://static.zybuluo.com/JackyJin/37wbxer59cplbghgo5sxzmkz/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.24.54.png
  [10]: http://static.zybuluo.com/JackyJin/f6pz8l9zs6veizr2rlng9syn/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-04%20%E4%B8%8B%E5%8D%8812.32.48.png