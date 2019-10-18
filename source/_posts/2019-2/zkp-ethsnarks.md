---
title: 零知识证明-ethsnarks源代码导读
permalink: zkp-ethsnarks
un_reward: true
date: 2019-09-29 10:58:21
categories: 零知识证明
tags:
    - 零知识证明
    - libsnark
    - ethsnarks
author: Star Li
---

之前有一篇文章分析了 [libsnark 源代码](https://learnblockchain.cn/2019/08/15/libsnark-source/)，ethsnarks在libsnark的基础上，实现了以太坊上与zkSNARK相关的智能合约和电路。

<!-- more --->

>题外：*最近看知乎，发现知乎上有些文章真的醍醐灌顶。印象比较深的是，文因互联CEO 鲍捷的一篇文章：最快的成长方式就是慢慢来。创业最关键的能力，就是“不被卡住”的能力。这才是“探索力”的根本，是创业“执行力”的核心。*

>*很多人都熟悉让别人告知一个明确的目标，然后清晰的执行。但是，创业是一种探索，没有人会告诉你这样的明确的目标。探索，是一种反人性的活动。大多数人会对探索畏惧，恐惧，抵触，茫然。*

>*“不被卡住”，需要掌握好“任务分解，快速迭代”的方法论，需要建立“交付”的态度（每个时期结束都有可交付的状态），需要“勤于沟通”， 需要”不固执己见“，更需要”不断复盘“。”不被卡住“，还有个要注意的是，有多少本钱打多少仗，不要总想着打大仗，要学会从小仗慢慢打。*

ethsnarks在[libsnark](https://learnblockchain.cn/2019/08/15/libsnark-source/)的基础上，实现了以太坊上与zkSNARK相关的智能合约和电路。ethsnarks本身也是libsnark应用很好的学习示例。

ethsnarks的源代码地址：

https://github.com/HarryR/ethsnarks.git

本文中使用的ethsnarks源代码的最后一个commit如下：

```
commit 9adc64355adb9154ba5042c0fadf84c438b8a08a
Author: Wanseob Lim <email@wanseob.com>
Date:   Fri Aug 16 01:49:19 2019 +0900

 Add Fr field class to the field.py
```

##01 源代码结构

![源代码结构](https://img.learnblockchain.cn/2019/09/29/001.webp)
**contracts** - 实现了groth16的验证智能合约（Verifier.sol），椭圆曲线的计算，MerkleTree以及MiMC Hash计算的智能合约。这些智能合约可以通过truffle进行部署测试。部署相关的脚本在migrations目录下。

**ethsnarks** - python实现的相关功能，包括pedersen/mimc/poseidon等hash函数，groth16验证，以及椭圆曲线的计算。

**test** - 以上两个功能的测试代码，采用python语言实现。

**depends** - 依赖库，包括libsnark，libfqfft等等。

**src** - 基于libsnark的gadget1库实现的更多的gadget。本文着重介绍这些gadget的实现。

##02 gadget实现
src目录下的源代码结构如下：
![src目录下的源码结构](https://img.learnblockchain.cn/2019/09/29/002.webp)

###2.1 ethsnarks.hpp

libsnark的gadget1库主要围绕sha256（基于bit的hash函数）实现各种gadgets。ethsnarks在alt_bn128这条椭圆曲线上实现了基于Field的hash函数（mimc，pedersen，poseidon等）。

libsnark的电路中各种定义都非常长。libsnark定义一个变量数组类型：`pb_variable_array<FieldT>`。

ethsnarks.hpp精简了在alt_bn128这条椭圆曲线相关的类型声明：

```cpp
namespace ethsnarks {

typedef libff::bigint<libff::alt_bn128_r_limbs> LimbT;
typedef libff::alt_bn128_G1 G1T;
typedef libff::alt_bn128_G2 G2T;
typedef libff::alt_bn128_pp ppT;
typedef libff::Fq<ppT> FqT;
typedef libff::Fr<ppT> FieldT;
typedef libsnark::r1cs_constraint<FieldT> ConstraintT;
typedef libsnark::protoboard<FieldT> ProtoboardT;
typedef libsnark::pb_variable<ethsnarks::FieldT> VariableT;
typedef libsnark::pb_variable_array<FieldT> VariableArrayT;
typedef libsnark::pb_linear_combination<FieldT> LinearCombinationT;
typedef libsnark::pb_linear_combination_array<FieldT> LinearCombinationArrayT;
typedef libsnark::linear_term<FieldT> LinearTermT;
typedef libsnark::gadget<ethsnarks::FieldT> GadgetT;

typedef libsnark::r1cs_gg_ppzksnark_zok_proof<ppT> ProofT;
typedef libsnark::r1cs_gg_ppzksnark_zok_proving_key<ppT> ProvingKeyT;
typedef libsnark::r1cs_gg_ppzksnark_zok_verification_key<ppT> VerificationKeyT;
typedef libsnark::r1cs_gg_ppzksnark_zok_primary_input<ppT> PrimaryInputT;
typedef libsnark::r1cs_gg_ppzksnark_zok_auxiliary_input<ppT> AuxiliaryInputT;
}
```
其中，FieldT特指在alt_bn128线上的点的个数。

###2.2 utils.hpp/utils.cpp

utils实现了电路实现中常用的功能性函数。

```cpp
 inline const VariableT make_variable( ProtoboardT &in_pb, const std::string &annotation )
 {
     VariableT x;
     x.allocate(in_pb, annotation);
     return x;
 }
```

make_variable创建一个VariableT。

```cpp
 const VariableArrayT flatten( const std::vector<VariableArrayT> &in_scalars )
 {
     size_t total_sz = 0;
     for( const auto& scalar : in_scalars )
         total_sz += scalar.size();

     VariableArrayT result;
     result.resize(total_sz);
     size_t offset = 0;
     for( const auto& scalar : in_scalars )
     {
         for( size_t i = 0; i < scalar.size(); i++ )
         {
             result[offset++].index = scalar[i].index;
         }
     }
     return result;
 }
```
flatten函数将多个VariableArrayT合并成一个VariableArray。其实也很简单，就是把VariableArray中的index都合并到一个VariableArray中。

###2.3 r1cs_gg_ppzksnark_zok

在libsnark的r1cs_gg_ppzksnark的基础上，稍做改动，让以太坊的预编译智能合约能验证groth16的算法。r1cs_gg_ppzksnark_zok目录中的README.md很清晰的解释了改动的原因。

从以太坊的拜占庭硬分叉之后，以太坊引入了基于ALT_BN128的配对函数计算的预编译合约，合约实现的功能如下：

给定ALT_BN128上两个基点（G1/G2）一系列的点(a1, b1, a2, b2, ..., ak, bk)，预编译合约能检查：

e(a1, b1) * ... * e(ak, bk) 是否等于1？

Groth16原有的验证系数为：vk.alpha_beta，vk.gamma以及vk.delta。Groth16的验证等式为：

vk.alpha_beta = e(A, B) * e(-x, vk.gamma) * e(-C, vk.delta)

其中vk.alpha_beta为e(alpha, beta)。

如果直接用之前的验证等式，以太坊上的预编译合约没法实现。在不影响Groth16的安全性的情况下，将Groth16的验证系数变为：vk.alpha，vk.beta，vk.gamma以及vk.delta。Groth16的验证等式也变为：

e(A, B) * e(-x, vk.gamma) * e(-C, vk.delta) * e(-alpha, beta) = 1

r1cs_gg_ppzksnark_zok目录就是实现如上的改动。同时提供了stubs.hpp/stubs.cpp，从json文件中读取相应的验证参数进行验证。

###2.4 poseidon

poseidon算法的实现在gadgets/poseidon.hpp文件中。
```cpp

 template<unsigned nInputs, unsigned nOutputs, bool constrainOutputs=true>
 using Poseidon128 = Poseidon_gadget_T<6, 1, 8, 57, nInputs, nOutputs, constrainOutputs>;
```
Poseidon128是Poseidon_gadget_T的一个实例。前面四个参数是poseidon算法的参数，后续会写文章详细介绍poseidon算法以及这些参数的含义（6，1，8，57是默认的配置）。nInputs指定算法的输入的个数，nOutputs指定输出的个数，contrainOutputs指定是否对输出进行约束。

Poseidon_gadget_T的构造函数如下：
```cpp
     Poseidon_gadget_T(
         ProtoboardT &pb,
         const VariableArrayT& in_inputs,
         const std::string& annotation_prefix
     ) :
         GadgetT(pb, annotation_prefix),
         inputs(in_inputs),
         constants(poseidon_params<param_t, param_F, param_P>()),
         first_round(pb, constants.C[0], constants.M, in_inputs, FMT(annotation_prefix, ".round[0]")),
         prefix_full_rounds(
             make_rounds<FullRoundT>(
                 1, partial_begin, pb,
                 first_round.outputs, constants, annotation_prefix)),
         partial_rounds(
             make_rounds<PartialRoundT>(
                 partial_begin, partial_end, pb,
                 prefix_full_rounds.back().outputs, constants, annotation_prefix)),
         suffix_full_rounds(
             make_rounds<FullRoundT>(
                 partial_end, total_rounds-1, pb,
                 partial_rounds.back().outputs, constants, annotation_prefix)),
         last_round(pb, constants.C.back(), constants.M, suffix_full_rounds.back().outputs, FMT(annotation_prefix, ".round[%u]", total_rounds-1)),
         _output_vars(constrainOutputs ? make_var_array(pb, nOutputs, ".output") : VariableArrayT())
     {
     }
```
poseidon算法的计算由好几轮组成：first_round（第一轮），prefix_full_rounds（预处理，完整轮），partial_rounds(中间，不完整轮)，suffix_full_rounds（后处理，完整轮）以及last_round（最后一轮）。

_output_vars是输出的变量。这些轮都是通过make_rounds函数实现。

```cpp
     template<typename T>
     static const std::vector<T> make_rounds(
         unsigned n_begin, unsigned n_end,
         ProtoboardT& pb,
         const std::vector<libsnark::linear_combination<FieldT> >& inputs,
         const PoseidonConstants& constants,
         const std::string& annotation_prefix)
     {
         std::vector<T> result;
         result.reserve(n_end - n_begin);

         for( unsigned i = n_begin; i < n_end; i++ )
         {
             const auto& state = (i == n_begin) ? inputs : result.back().outputs;
             result.emplace_back(pb, constants.C[i], constants.M, state, FMT(annotation_prefix, ".round[%u]", i));
         }

         return result;
     }
```
make_rounds就是为每一轮准备合适的参数。每一轮的具体实现通过Poseidon_Round实现。

在Poseidon_Round的封装下，Poseidon_gadget_T的generate_r1cs_constraints以及generate_r1cs_witness相对简单，小伙伴们可以自行查看源代码。

##03 示例代码

在ethsnarks的基础上，实现Poseidon函数的电路就非常简单了。构造一个简单的电路，给大家参考一下。

**电路的需求**：实现Poseidon计算，输入为两个FieldT，输出为一个FieldT。输出作为电路的public input。

```cpp
#include "ethsnarks.hpp"
#include "gadgets/poseidon.hpp"

 using namespace ethsnarks;

 namespace testproject {
     using TestHash = Poseidon128<2, 1>;

     class test_gadget : public GadgetT {
         public:
           VariableT output;
             VariableT input0;
             VariableT input1;

             TestHash tHash;

             test_gadget(
                 ProtoboardT& pb,
                 const std::string& prefix
             ) : GadgetT(pb, prefix),
               output(make_variable(pb,  FMT(prefix, ".output"))),
                 input0(make_variable(pb,  FMT(prefix, ".input0"))),
                 input1(make_variable(pb,  FMT(prefix, ".input1"))),
                 tHash(pb, create_var_array({input0, input1}), FMT(prefix, ".testhash"))
             {
             }

             void generate_r1cs_witness(
                     ethsnarks::FieldT w_input0,
                     ethsnarks::FieldT w_input1,
                     ethsnarks::FieldT w_output)
             {
                 pb.val(input0) = w_input0;
                 pb.val(input1) = w_input1;
                 pb.val(output) = w_output;

                 tHash.generate_r1cs_witness();
             }

             void generate_r1cs_constraints()
             {
               pb.set_input_sizes(1);
                 tHash.generate_r1cs_constraints();

                 pb.add_r1cs_constraint(ConstraintT(output, 1, tHash.result()),
                         FMT(annotation_prefix, " output == Poseidon(input0 || input1)"));
             }
     };
 };

```

##总结：

ethsnarks在libsnark的基础上，实现了以太坊上与zkSNARK相关的智能合约和电路。ethsnarks本身也是libsnark应用很好的学习示例。libsnark的gadget1库主要围绕sha256（基于bit的hash函数）实现各种gadgets。ethsnarks在alt_bn128这条椭圆曲线上实现了基于Field的hash函数（mimc，pedersen，poseidon等）。


本文作者为深入浅出区块链共建者：Star Li，他的公众号**星想法**有很多原创高质量文章，欢迎大家扫码关注。

![公众号-星想法](https://img.learnblockchain.cn/2019/15572190575887.jpg!/scale/20%)

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。

