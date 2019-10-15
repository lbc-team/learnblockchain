---
title: 零知识证明 - 一种新型的Merkle树（Shrubs）
permalink: Shrubs
un_reward: true
date: 2019-10-15 13:51:39
categories: 
    - 基础理论
    - 零知识证明
tags: 
    - Merkle 树
    - Shrubs
    - 零知识证明
author: Star Li
---

这几天在日本大阪正在举办Devcon 5。议题中有个topic吸引我的眼球：

Shrubs - A New Gas Efficient Privacy Protocol

<!-- more -->

![Shrubs](https://img.learnblockchain.cn/2019/10/15/101.jpg)

在以太坊上，传统的Merkle树（深度为33）添加一个叶子节点，除了计算33次Hash函数外，还需要更新33个节点（也就是需要读并且更新33个存储空间）。而更新一个节点的存储费用是昂贵的。更新33个256bit的存储，大约需要180w的GAS费用。


Shrubs就提出了一种Merkle树的变种，每次添加一个叶子节点，只需要O(1)次存储更新。这种变种的Merkle树，不只是用一个树根节点来“代表”整棵树。而是用**一系列节点（个数等于深度）来”代表“整棵树**，保证所有的叶子节点都能”索引“到这些节点。在变种的Merkle上，每一层选择一个节点。在添加叶子节点的时候，在不破坏其他“子树”的根的前提下，只要更新到离该叶子节点最近的子树根即可。

可以想象成，Shrubs的变种Merkle树，其实是**由一棵棵的子树的树根**组成。这些子树能覆盖所有的已经添加的叶子节点。这些子树的树根可以代表一棵完整的Merkle树（唯一性）。而且通过**子树的路**径证明，就能证明某个叶子节点在这颗完整的Merkle树上。因为每次只需要更新子树的树根，所以，每次添加叶子节点只需要一次节点数据的更新。

这些子树的树根，又能推导出整个merkle树最右边的path。这也是，Shrubs的说明中，用merkle树的最右边path代表merkle树的原因。

## 01 核心算法

Shrubs的变种Merkle树的算法原型昨天更新到[Github](https://github.com/celo-org/shrubs
)上，核心算法逻辑在`contracts/MerkleTreeLib.sol`中的insert和verify函数。

### 1. 插入节点

insert函数实现了叶子节点的插入逻辑。`filled_subtrees`就是每个选择的子树的根。insert函数的主要逻辑，就是选择子树，更新子树的根。

```js
     function insert(uint256 leaf) internal {
         uint32 leaf_index = next_index;
         uint32 current_index = next_index;
         next_index += 1;

         uint256 current_level_hash = leaf;
         uint256 left;
         uint256 right;

         bool all_were_right = true;
         for (uint8 i = 0; i < levels; i++) {
             if (current_index % 2 == 0) {
                 left = current_level_hash;
                 right = zeros[i];
                 filled_subtrees[i] = current_level_hash;
                 break;
             } else {
                 left = filled_subtrees[i];
                 right = current_level_hash;
             }
             current_level_hash = HashLeftRight(left, right);
             current_index /= 2;
         }
         tree_leaves.push(leaf);
     }
```

filled_subtrees采用空节点初始化。在新插入一个节点时，找到它最低的左节点作为选择的子树，并更新树根。current_index是每一层上节点的序号。选择左边节点是通过current_index%2==0实现。

以深度为4的Merkle树为例，添加第一个叶子节点后，各个子树的树根如下（青色节点是初始化的filled_subtrees节点，蓝色是更新的节点）：

![各个子树的树根](https://img.learnblockchain.cn/2019/10/15/102.jpg!/scale/40%)

添加第二和三个叶子节点分别如下：

![添加第二](https://img.learnblockchain.cn/2019/10/15/103.jpg!/scale/40%)

![和三个叶子](https://img.learnblockchain.cn/2019/10/15/104.jpg!/scale/40%)

整个添加过程如下面动图效果（橙色连线代表hash计算）：

![添加过程](https://img.learnblockchain.cn/2019/10/15/640.gif)

#### **1.2 验证节点**

verify函数是验证某个叶子节点在Merkle树上的示例。只要能给定一条路径，能计算出一个子树根即可。

```js
function verify(uint256 leaf, uint256[] memory path, uint32 leaf_index) internal {
       uint32 current_index = leaf_index;
       uint256 current_level_hash = leaf;
       uint256 left;
       uint256 right;
       for (uint8 i = 0; i < levels; i++) {
         if (mode == 0 && filled_subtrees[i] == current_level_hash) {
           emit LeafVerified(leaf, leaf_index, i, true);
           return;
         }
         if (current_index % 2 == 0) {
           left = current_level_hash;
           right = path[i];
         } else {
           left = path[i];
           right = current_level_hash;
         }
         current_level_hash = HashLeftRight(left, right);
         current_index /= 2;
       }
     }
 }
```

## 02 性能分析

### 2.1 数据更新

Shrubs变种Merkle树，每次添加节点，只需要更新一个子树的树根。从数据更新角度，算法复杂度O(1)。

### 2.2 hash计算

从hash计算的角度，在添加左节点时，无需hash计算。在添加右节点时，hash计算和选择的子树深度相等。越靠右的节点，子树选择也高，hash计算也越多。即使这样，也比传统的Merkle树计算量小。

假设Merkle树的树高是n，则传统Merkle树添加所有的叶子节点，需要2^n\*n次计算。Shrubs变种Merkle树添加所有的叶子节点，只需要(1+2+...+n) = (n\*(n-1))/2次计算

## 03 测试结果

在Devcon5上，Shrubs公开了变种Merkle树的测试结果。叶子插入的gas消耗，平均情况下，9.6w。

![变种Merkle树的测试结果](https://img.learnblockchain.cn/2019/10/15/105.jpg)

图中，Shrubs最坏情况下的GAS消耗应该不是168w，应该在40w左右。

如果使用Groth16零知识证明的话，大约需要不到50w的GAS（EIP1008情况下）。

![使用Groth16零知识证明](https://img.learnblockchain.cn/2019/10/15/106.jpg)

值得一提的是，使用Groth16零知识证明，需要将所有的子树的树根作为public input。



## **总结：**

为了解决以太坊智能合约中Merkle树更新存储开销较大的问题，Shrubs提出了一种新型的Merkle树变种。这种变种的Merkle树用多个子树的树根来代表一个Merkle树。每次添加一个叶子节点，只需要O(1)次存储更新，平均情况下，只需要9.6w的GAS。使用Groth16算法，证明叶子节点在树上，也只需要不到50w的GAS。



附上，好朋友从现场发回的其他照片，也分享给小伙伴们（图片中有一些地方有错误，发现错误的小伙伴留言，有奖励～）：

![照片1](https://img.learnblockchain.cn/2019/10/15/107.jpg)
![照片2](https://img.learnblockchain.cn/2019/10/15/108.jpg)
![照片3](https://img.learnblockchain.cn/2019/10/15/109.jpg)
![照片4](https://img.learnblockchain.cn/2019/10/15/110.jpg)
![照片5](https://img.learnblockchain.cn/2019/10/15/111.jpg)
![照片6](https://img.learnblockchain.cn/2019/10/15/112.jpg)




本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
