---
title: 编写 Fabric 链码（chaincode）程序
permalink: chaincode-write
un_reward: true
date: 2019-07-16 07:14:53
categories:
    - 联盟链
    - Fabric
tags:
    - Fabric
    - chaincode
author: kunpeng
---


## chaincode 基本结构

### 入口main函数

  main 函数是合约的入口, 创建(new)一个chaincode结构体后，由shim启动合约进程，如下：

  ```go
  func main() {
  	err := shim.Start(new(StudentChaincode))
  	if err != nil {
  		fmt.Printf("error: %s", err.Error())
  	}
  }
  ```


 ### chaincode结构体

  chaincode的结构体，必须包含`Init`和`Invoke`两个接口，作为链码的`instantiate`/`upgrade`操作和`invoke`/`query`操作。

  函数体如下：

  ```go
  func (t *StudentChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response;
  func (t *StudentChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response
  ```

  - 参数：stub，peer chaincode 指令或sdk传入的字符串数组参数，需要stub.GetFunctionAndParameters解析。

  - 返回值：pb.Response，pb是peer包，封装了返回结果的数据，返回结果或从chaincode容器传入到peer节点中。

    成功示例：return shim.Success([]byte("Success"))

    失败示例：return shim.Error("Failed")


 ### Init初始化

  chaincode的初始化可以预处理数据，通过参数将数据传入接口，存入state database或者内存中。

  Init函数同时作为instantiate和upgrade操作的入口


 ### Invoke执行函数

  Invoke函数通过stub函数传入的参数，进行相应的处理，可以通过stub的第一个参数作为函数指令，区分不同的接口，如下：

  ```go
  func (t *StudentChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
  	function, args := stub.GetFunctionAndParameters()
  	if function == "invoke" {
  		return t.invoke(stub, args)
  	} else if function == "query" {
  		return t.query(stub, args)
  	} else {
  		return shim.Error("Haven't function")
  	}
  }
  ```

  Invoke函数同时是invoke和query操作的入口。

  invoke操作是对state database写数据，query操作是对state database读数据。



## chaincode 调用的包

* peer包

  peer包是fabric的数据结构，由`protobuf`生成，如上例中的`pb.Response`就是`proposal_response.proto`而来。

* shim包

  shim包是合约内置函数的主体，包括以下两大部分：

  1. 链码内置函数，当中包括三十几种内置函数，具体可参考：`./github.com/hyperledger/fabric/core/chaincode/shim/interfaces.go`中的接口列表。其他的就是返回值的结构封装，mock单元测试等。

  2. 扩展函数，参考`./github.com/hyperledger/fabric/core/chaincode/shim/ext`

     * attrmgr，基于msp的x509证书解析库
     * cid，ca认证接口库
     * entities，bccsp算法接口库
     * statebased，背书策略接口库


## chaincode 内置函数（一）

### 参数获取

 **GetFunctionAndParameters**：该方法负责接收调用者传过来的参数。

 **GetArgs**：获取调用者传入参数，返回二维字节切片

 **GetStringArgs**：获取调用者传入参数，返回一维字符串切片

 **GetArgsSlice**：获取调用者传入参数，返回字节切片



### 数据存储

 **PutState**：该方法负责把数据保存到fabric账本中。

 **GetState**：该方法负责从fabric账本中读取数据

 **DelState**：DelState用来删除账本中的key,如果对一个不存在的的key-value进行删除不会返回错误



### 事务id，事务时间戳，通道id

 **GetTxID**：获取当前调用交易的ID号

 **GetTxTimestamp**：获取事务时间戳

 **GetChannelID**：返回链码处理提议的通道ID

