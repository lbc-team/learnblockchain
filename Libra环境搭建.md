# Libra环境搭建

标签（空格分隔）： 文章分享

---

这几天应该都被Libra刷屏了。FB的Libra在2020年底会推出。这里暂且不详细来讨论Libra的意义和阶段性影响。目前来看Libra是区块链一个阶段性的需求，至于如何发展持续关注。
笔者尝试搭建Libra环境~

### Libra资源相关

这里列举相关Libra的相关资源链接，仅供参考：
[Libra官网](https://libra.org/en-US/): https://libra.org/en-US/
[白皮书](https://libra.org/en-US/white-paper/)： https://libra.org/en-US/white-paper/
[Libra技术白皮书](https://developers.libra.org/docs/assets/papers/the-libra-blockchain.pdf)： https://developers.libra.org/docs/assets/papers/the-libra-blockchain.pdf
[Libra开发者技术文档](https://developers.libra.org/)： 
[Libra-github](https://github.com/libra/libra):  https://github.com/libra/libra

---

### Libra-基础环境搭建

基于参考：https://developers.libra.org/docs/my-first-transaction
来搭建Libra并连接到测试网络。

### 实验环境

* Centos7.5、16C、192G、1000G

---

### 系统安装配置

基本的系统安装，安装好之后无外乎关闭selinux、防火墙这些基本的配置。
这里建议安装好之后设置阿里yum，设置完成后：
```
yum update
```

### 下载Libra及相关软件安装

下载Libra：
```
git clone https://github.com/libra/libra.git
```
在制定文件夹解压：
```
cd libra 即可看到下载Libra的项目内容。
```

---

* 安装Golang

安装Golang
如果单独去下载安装包麻烦的话，那么直接通过wget来下载解压，配置环境变量。

```
wget https://studygolang.com/dl/golang/go1.12.5.linux-amd64.tar.gz
tar -xvf go1.12.5.linux-amd64.tar.gz
```
配置环境变量。修改/etc/profile文件,路径根据下载安装路径来。
```
vim /etc/profile
添加
export GOROOT=/usr/go
export GOPATH=/usr/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

---

* 安装Rust等相关

安装rust

```
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly-2019-05-22-x86_64-unknown-linux-gnu
rustup override set nightly-2019-05-22
```

安装完成后查看版本信息：
```
root@libra libra]# rustc --version
rustc 1.36.0-nightly (50a0defd5 2019-05-21)
[root@libra libra]# rustup --version
rustup 1.18.3 (435397f48 2019-05-22)
```

---

* 安装cmake

在官网：https://cmake.org/download/
选择对应操作系统版本下载，下载后解压：

```
tar -xvzf cmake-3.15.0-rc2.tar.gz
cd cmake-3.15.0-rc2/
./bootstrap
gmake
gmake install
以上步骤有点慢，耐心等待~
```

* protocol安装配置

文件下载地址：https://github.com/protocolbuffers/protobuf/releases/tag/v3.6.1

选择对应的版本：

```
tar -xvf protobuf-all-3.8.0.tar.gz
cd protobuf-3.8.0/
./configure
make
make check
sudo make install
protoc --version
显示：libprotoc 3.8.0
```

### 安装测试Libra环境

```
cd libra
./scripts/dev_setup.sh
```

显示如下：
```
Installing CMake......
CMake is already installed
Installing Go......
Go is already installed
Installing Protobuf......
Protobuf is already installed

Finished installing all dependencies.

You should now be able to build the project by running:
	source /root/.cargo/env
	cargo build
```

测试网络脚本运行：
```
./scripts/cli/start_cli_testnet.sh
比较慢耐心等待~~~
```
完成后显示如下：
![屏幕快照 2019-06-20 下午4.12.41.png-349.9kB][1]

---

### 创建账户及账户状态查看

根据官网的指导，先查看account内容：

![屏幕快照 2019-06-20 下午4.23.30.png-210.4kB][2]

* 创建账户 Alice、Bob

```
libra% account create
>> Creating/retrieving next account from wallet
Created/retrieved account #0 address c94d5411d85442374cc24c0eb0203f1666c9cd681eb4eeedf366905c950c20ee
libra% account create
>> Creating/retrieving next account from wallet
Created/retrieved account #1 address 39c0ff0bdc00b710599e6f4c8c32d2fa873ce360f20b100703eca748e0941f24
libra%
```

通过account list查看内容：

![屏幕快照 2019-06-20 下午4.26.02.png-115.4kB][3]

将Libra Coins添加到Alice和Bob的账户。

根据之前的建account顺序，那么0为Alice、1为Bob，110和50为Libra coin。
```
libra% account mint 0 110
>> Minting coins
Mint request submitted
libra% account mint 1 52
>> Minting coins
Mint request submitted
libra%
```
检查下0、1account的余额：

```
libra% query balance 0
Balance is: 110
libra% query balance 1
Balance is: 52
libra%
```

查看账户序列：

```
ibra% query sequence 0
>> Getting current sequence number
Sequence number is: 0
libra% query sequence 1
>> Getting current sequence number
Sequence number is: 0
libra%
```

### 交易

根据例子，我们转移10个Libra coin从Alice到Bob：

transfer 0 1 10

* 0是Alice的帐户的索引。
* 1是Bob的帐户索引。
* 10是从Alice的账户转移到Bob的账户的Libra的数量。

```
transfer 0 1 10
```

下图清晰显示账户转账后的状态：

![屏幕快照 2019-06-20 下午4.35.13.png-190.1kB][4]

### 总结

大致搭建了Lbra的环境，根据官方开发文档实现一些基本的功能。在搭建过程中我把相关软件的版本都列举出来，可能会有一些软件版本的问题导致在编译的时候不通过，建议按照列出的版本来安装。有兴趣可联系我一块交流~~
（未完待续）


  [1]: http://static.zybuluo.com/JackyJin/cvz7xvt8sj4uwke9qwhktgri/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-06-20%20%E4%B8%8B%E5%8D%884.12.41.png
  [2]: http://static.zybuluo.com/JackyJin/bzy2vegs92mgx0ec2s81acpx/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-06-20%20%E4%B8%8B%E5%8D%884.23.30.png
  [3]: http://static.zybuluo.com/JackyJin/86hywoq2pbs9ad56yko3bzkh/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-06-20%20%E4%B8%8B%E5%8D%884.26.02.png
  [4]: http://static.zybuluo.com/JackyJin/n272ao0c885sg316pflnenrb/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-06-20%20%E4%B8%8B%E5%8D%884.35.13.png