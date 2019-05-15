---
title: Solidity是否有简单而通用的存储模式？
permalink: simple-storage-for-solidity
date: 2019-01-13 11:25:59
categories: 问与答
tags: Solidity
author: Rob Hitchens
---


> 问：对于[Solidity](https://learnblockchain.cn/docs/solidity/)新手来说，简单合适的使用数据结构去组织数据是一个挑战。对于区块链上的数据组织，是否有简单而通用的模式来帮助我们链上数据？

<!-- more -->

以下为回答：

以下是*一些*简单而有用的模式，按常用性递增顺序排列。

为简洁起见，省略了事件日志。 在实践中，希望为每个重要的状态变化发出事件。


### **使用数组表示简单的列表**

**优点**

* 可靠的时间顺序
* 提供计数
* 按索引id随机访问（不是key）

**缺点**

* 没法用任意的key访问
* 不保证唯一性
* 不检查重复项
* 元素不受控制的增长

**举例:**

```solidity
pragma solidity ^0.4.6;

contract simpleList {

  struct EntityStruct {
    address entityAddress;
    uint entityData;
    // more fields
  }

  EntityStruct[] public entityStructs;

  function newEntity(address entityAddress, uint entityData) public returns(uint rowNumber) {
    EntityStruct memory newEntity;
    newEntity.entityAddress = entityAddress;
    newEntity.entityData    = entityData;
    return entityStructs.push(newEntity)-1;
  }

  function getEntityCount() public constant returns(uint entityCount) {
    return entityStructs.length;
  }
}
```

### **映射中使用结构体（Mapping with Struct）**

**优点**

* 通过唯一key（id）进行随机访问
* key唯一性的保证
* 在每个“记录”中包含数组，映射，结构体

**缺点**

* 无法枚举键
* 无法计算键的数量
* 需要手动检查以区分默认值和明确的“全0”记录


**举例:**

```js
contract mappingWithStruct {

  struct EntityStruct {
    uint entityData;
    bool isEntity;
  }

  mapping (address => EntityStruct) public entityStructs;

  function isEntity(address entityAddress) public constant returns(bool isIndeed) {
    return entityStructs[entityAddress].isEntity;
  }

  function newEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(isEntity(entityAddress)) throw; 
    entityStructs[entityAddress].entityData = entityData;
    entityStructs[entityAddress].isEntity = true;
    return true;
  }

  function deleteEntity(address entityAddress) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    entityStructs[entityAddress].isEntity = false;
    return true;
  }

  function updateEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    entityStructs[entityAddress].entityData = entityData;
    return true;
  }
}
```

### **使用具有唯一ID的结构体数组**

**优点**

* 按下标(行号)随机访问
* 保证Id的唯一性
* 用每个“记录”包含数组，映射和结构体

* Random access by Row number
* Assurance of Id uniqueness
* Enclose arrays, mappings and structs with each "record"

**缺点**

* 不支持随机访问权限
* 列表不受控制的增长


**举例:**

```js
contract arrayWithUniqueIds {

  struct EntityStruct {
    address entityAddress;   //  唯一ID
    uint entityData;
  }

  EntityStruct[] public entityStructs;
  mapping(address => bool) knownEntity;

  function isEntity(address entityAddress) public constant returns(bool isIndeed) {
    return knownEntity[entityAddress];
  }

  function getEntityCount() public constant returns(uint entityCount) {
    return entityStructs.length;
  }

  function newEntity(address entityAddress, uint entityData) public returns(uint rowNumber) {
    if(isEntity(entityAddress)) throw;
    EntityStruct memory newEntity;
    newEntity.entityAddress = entityAddress;
    newEntity.entityData = entityData;
    knownEntity[entityAddress] = true;
    return entityStructs.push(newEntity) - 1;
  }

  function updateEntity(uint rowNumber, address entityAddress, uint entityData) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    if(entityStructs[rowNumber].entityAddress != entityAddress) throw;
    entityStructs[rowNumber].entityData    = entityData;
    return true;
  }
}
```

### **带索引的结构体映射**

**优点**

* 通过唯一ID或行号（索引下标）随机访问
* 保证Id的唯一性
* 在每个“记录”中包含数组，映射和结构
* 维持元素声明的顺序
* 可统计记录数量
* 可枚举每个项
* 通过设置布尔值来”软“删除项目

**缺点**

* 列表不受控制的增长

**举例:**

```js
contract MappedStructsWithIndex {

  struct EntityStruct {
    uint entityData;
    bool isEntity;
  }

  mapping(address => EntityStruct) public entityStructs;
  address[] public entityList;

  function isEntity(address entityAddress) public constant returns(bool isIndeed) {
      return entityStructs[entityAddress].isEntity;
  }

  function getEntityCount() public constant returns(uint entityCount) {
    return entityList.length;
  }

  function newEntity(address entityAddress, uint entityData) public returns(uint rowNumber) {
    if(isEntity(entityAddress)) throw;
    entityStructs[entityAddress].entityData = entityData;
    entityStructs[entityAddress].isEntity = true;
    return entityList.push(entityAddress) - 1;
  }

  function updateEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    entityStructs[entityAddress].entityData    = entityData;
    return true;
  }
}
```

### **可删除索引的结构体映射**

**优点**

* 通过唯一ID或行号随机访问
* 保证Id的唯一性
* 在每个“记录”中包含数组，映射和结构
* 统计记录数量
* 可枚举ID
* 使用删除功能逻辑控制列表的大小

**缺点**

* 增加了代码复杂性
* 存储成本更高
* 键列表是无序的

**2019 更新**

在 Solidity 0.5.1，这个模式已经有一个库实现[Solidity 实现增删改查-博客](https://medium.com/@robhitchens/solidity-crud-epilogue-e563e794fde)
[UnorderedKeySet GitHub库](https://github.com/rob-Hitchens/UnorderedKeySet)

举例:

```js
contract mappedWithUnorderedIndexAndDelete {

  struct EntityStruct {
    uint entityData;
    uint listPointer;  // 记录元素的位置
  }

  mapping(address => EntityStruct) public entityStructs;
  address[] public entityList;

  function isEntity(address entityAddress) public constant returns(bool isIndeed) {
    if(entityList.length == 0) return false;
    return (entityList[entityStructs[entityAddress].listPointer] == entityAddress);
  }

  function getEntityCount() public constant returns(uint entityCount) {
    return entityList.length;
  }

  function newEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(isEntity(entityAddress)) throw;
    entityStructs[entityAddress].entityData = entityData;
    entityStructs[entityAddress].listPointer = entityList.push(entityAddress) - 1;
    return true;
  }

  function updateEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    entityStructs[entityAddress].entityData = entityData;
    return true;
  }

  function deleteEntity(address entityAddress) public returns(bool success) {
    if(!isEntity(entityAddress)) throw;
    uint rowToDelete = entityStructs[entityAddress].listPointer;
    address keyToMove   = entityList[entityList.length-1];
    entityList[rowToDelete] = keyToMove;  // 最后一个元素放在删除的数组位置上
    entityStructs[keyToMove].listPointer = rowToDelete;
    entityList.length--;
    return true;
  }
}
```

最后一个在这里有一个[解释](https://medium.com/@robhitchens/solidity-crud-part-2-ed8d8b4f74ec#.ekc22r5lf)
以及[这个解释](https://bitbucket.org/rhitchens2/soliditycrud/src/83703dcaf4d0c4b0d6adc0377455c4f257aa29a7/docs/?at=master)

还有 [如何在 Solidity中 存储文件夹或对象树?](https://ethereum.stackexchange.com/questions/13845/how-can-we-organize-storage-of-a-folder-or-object-tree-in-solidity/13846#13846)

还有一个Solidity 双向链表 ：[linkedList.sol](https://github.com/ethereum/dapp-bin/blob/master/library/linkedList.sol) 

原问答链接：https://ethereum.stackexchange.com/questions/13167/are-there-well-solved-and-simple-storage-patterns-for-solidity

问答由深入浅出区块链社区成员整理。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链的都在这里，打造最好的区块链技术博客。
