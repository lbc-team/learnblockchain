---
title: 解读MOAC白皮书技术路线 by 李正鹏
permalink: moac-tech
date: 2019-08-26 09:10:54
categories: MOAC
tags: MOAC
author: 李正鹏
---

编者按：本文根据硅谷MOAC BlockChain Tech李正鹏先生在“王者归来-MOAC自治社区共识群”的语音分享整理而成

<!-- more -->

大家好，我是李正鹏，今天很高兴有机会跟大家交流一下MOAC最新版的白皮书。

目前大家看到的白皮书，一共有三版。第一版是2017年5月份的时候发布的。第二版是主网上线的时候，即2018年的五月份，主要是把一年开发中的一些成果跟大家呈现一下，并且做了一些综合。2019年发布的第三版白皮书，是把MOAC最新的一些进展在白皮书上进行了更新。我会在介绍完MOAC的架构之后，把去年的进展跟大家介绍一下。

首先介绍一下MOAC平台。大家如果是关注MOAC时间比较长的话，会了解MOAC平台是一种分层的技术架构。这种分层的架构，在17年提出来的时候还是非常新颖的，当时就是要解决以太坊系统的问题，就是它把所有的普通交易和合约的调用都放在一起，导致了整个系统性能的下降。

![](https://img.learnblockchain.cn/2019/08/29_193061300.jpg)

MOAC平台设计的时候就采用了分层的结构，首先是将交易和智能合约分开，MOAC的底层，一般称之为母链，借鉴了当时最流行的以太坊的pow方式，主要处理机制和以太坊是很相近的，但是在里面加入了很重要的一部分，就是可以跟上层形成接口，这个就为我们现在叫应用链，以前叫子链的这么一个结构，提供了可扩展的性能。

MOAC设计的分层架构，当时提出来的时候，是有前瞻性的。后来的一些新的区块链项目提到架构时，有不少都是借鉴了MOAC的分层技术。除了分层技术之外，MOAC当时也提到了基于分层而实现的分片技术，那就是Sharding。在母链和子链分层之后，每个子链的工作，不会过多地影响母链的处理速度，这就使得不同的子链，可以同时处理比较高的并发率，这种情况，也就是我们这里提到的分片工作，每一个子链都可以处理自己相应的一个DAPP的应用。比如说以太猫，可能和另外一个以太狗，他们的用户之间不会相互干扰。

通过子链，MOAC就可以使得用智能合约来完成DAPP，直接拥有自己的处理速度，开发自己的子链结构，形成一些比较独特的商业逻辑。这也是我们在慢慢地开发中发现的，因为有不同的子链，它会有一些特别的要求，比如说我们最早开发的那个子链的设计时，在上面并没有定义子链的原生货币，当时国内有一些需求，叫做无币区块链，所以最初的设计，子链原生货币这块儿是没有的。所以最早的子链结构是无币子链，但是后来我们发现，这个子链，有的项目有这种需求的，需要有自己的原生货币。所以后来我们在这个无币区块链的基础上，开发另外两种。也就是现在叫做ASM和AST的两种子链。

他们的主要区别是什么呢，ASM它的英文叫做Atomic Swap of MOAC, AST是Atomic Swap oftoken。就是说子链的原生货币，我们要求它和母链上的MOAC进行绑定，要么是母链上的某种token（比如是ERC20的这种token）进行绑定，这样你才可能在子链上发你的原生货币，而不是说无中生有的就可以在子链上发数字货币。

这样做的好处，可以保持应用链上的原生货币，可以和母链上有机地联合起来，也保证了子链原生币的价值，同时也就提供了跨链的这种货币交换方式，也就是说母链上的MOAC和TOKEN可以转成为子链的原生币，而这一切都是已经设立好了通过原子跨链交易来实现。

除了这种子链上面的货币会有不同之外，我们后来也设计了可以使用不同共识算法的子链。那么我们现有的子链就是使用DPOS，就是prove of stake，国内叫做权益证明。后来，我们进一步开发了一个叫做proof of activity，有点儿像活动证明啊，或者说行为挖矿这种情况，还有可以用耗时证明（Proof of Time），或者说位置证明。

我们最早实现的子链，现在叫做ProcWind，是一个权益证明的子链。

我们实现的第二种子链形式，就是filestorm，大家可能也了解这个项目，这个也是目前市场上的一个明星项目。

现在我们正在开发的，有两种新型的子链，一种就是RandDrop，用BLS阈值签名算法。这种可以从共识层支持多个节点的签名字段，合并后得到阈值签名，并以此为基础产生随机数。这个随机数可以在里面的合约里面直接调用。它的优点，就是可以对单个节点杜绝最终签名的这种操作性，可以保证需要全网才能达成这种随机，而不是说你一个人可以决定这个随机数，就像现在这种中心化的方式。它采用的是一种去中心化方式生成，这种随机数可以更加安全可靠。

另一种是IOTMist，在目前的双层架构上构建更多的垂直分层，可以用来支持海量节点。IOtmist子链目的主要是为了将来跟物联网这种信息相结合。相对于现在的区块链节点，物联网的节点是会有数量级的增加，现有的这种两层架构的基础设施，支持物联网这么多的节点就有一定的困难，所以我们就采用了横向与纵向相结合的方式，可以对物联网上的海量节点有一个支持的方式，这个计划现在正在开发中，年底会有一个更新。

另外，在子链的开发过程中，我们觉得子链上的一些服务也需要为大家提供更方便和简洁的工具，提出了“子链暨服务”的这么一个概念，就是希望大家在子链上开发合约的时候，类似于现在可以使用平台一样方便，大家可以方便地部署子链，也就是我们现在提出“一键发链”的一个工具，这个工具还在不断的优化中，我们也会跟技术开发者、生态节点等进行了相互交流和培训。

对于应用来说，接到MOAC平台有两种方式，第一种就是最直接的，直接移植到MOAC的母链上来，因为MOAC的母链，是对以太坊的架构进行了一个优化，本身它的处理速度就比以太坊要快。另外一种，就是移到我们的子链平台上来。子链平台有两大优势，第一，子链对用户来讲，是不用收费的，用户可以直接上来使用商业逻辑。这样就降低了很多用户上来的门槛，比如说在之前以太坊，包括现在的MOAC的母链和其他很多链，如果在链上要调一个合约的话，一般来讲，你需要先购买他们的数字货币，然后才能使用。那么在MOAC子链上，就不用先购买数字货币，当然你必须要有自己的帐号，就可以直接在子链上进行一些操作。

另外一个，就是我之前提到的在子链上的商业逻辑，你可以制定一些自己的商业逻辑、有特点的共识方式。比如说我们现在的这个Filestorm，它采取的共识方式就和我们之前的那个POS方式有所不同，它加入了一些跟IPFS相关的机制。

当然，MOAC的子链也同时有跨链功能，也就是说我们子链上面的货币，或者一些其他的账号信息，是可以和母链上进行交互的。比如说你在母链上发了一个ERC20的token，然后，你可以在子链开发好了自己的程序之后，基本上就可以无缝的链接到子链上的应用。

MOAC平台设计了三种形式的跨链，首先，就是母链和子链之间的原子交换跨链，这部分目前已经实现了，可以完成母链的原生通证，或者说这个ERC20和子链原生通证之间的互换。

另外两个正在开发的，一个就是在子链之间的原子跨链的互换，类似于子链货币的交易。实现了这个之后，各项目方之间的货币交换也可以用这个机制进行流转。第三步，希望再加入其他的区块链系统和MOAC系统进行原子跨链交换。

MOAC平台在最初的时候设计了两种类型的挖矿，第一种，当然就是母链的pow挖矿，当时来讲，只有pow方式是真正的经过实践检验的一种公链共识方式，因为大家都知道比特币和以太坊，都是经过实践检验的，他们都用的是Pow方式。从当时和现在来看，其他的一些共识方式，比如POS、PBFT，实际上在当时都没有经过大范围的证明。所以POW还是大家比较容易接受的一种公链挖矿方式。

另外，我们也设计了关于子链的挖矿。当时的考虑就是，在项目方运行子链的时候，需要有一定的硬件支持，那么如何能够吸引比较多的子链矿工来帮助构建子链系统呢？因为我们的子链也可以是一个公链系统，大家都可以参与，我们就设计了子链挖矿的机制。也就是说，项目方需要拿出一定数量的MOAC，使得子链验证节点的提供方可以得到一定的收益，这样来鼓励大家参与子链节点的挖矿。目前实现得比较好的就是filestorm的子链挖矿方式，当然，他们并不是完全的股权证明，加了一些IPFS的机制在里面。

MOAC系统我们也做了相应的钱包和支付系统，现在用的比较多的，一个是在线的、开源的web钱包，moacwalletonline.com，另外也有一些移动端对我们的支持，大家可能了解的比较多的，像TP钱包、墨宝钱包、正在做的斜杠钱包，这些都是第三方的，他们可以比较容易与MOAC相连。

我们也为开发者提供了专门的API和一些软件库，在我们官方的github的wiki上面有链接，也尽量把所有的文档都归档在两个用readdoc写成的文档里面去(https://moacdocs-chn.readthedocs.io/ )和(https://moac-docs.readthedocs.io/ ）。

大家可能也听说过墨子实验室，这个也是我们对之前这种一旦发生智能合约出现漏洞，没有人把关这么一个问题的解决方式。我们和专门的安全团队合作，主要是北京的苗博士团队在做。他们可以独立地为智能合约进行审核，为项目方提供安全保障。

![](https://img.learnblockchain.cn/2019/08/29_209066612.jpg)
 
MOAC子链上第一个真正完全去中心化的应用，叫做链问。大家可能用的不多，这个是我们当时内部用来做开发测试的一个项目，目的主要是在MOAC子链上面开发DAPP的流程要完全走通。只有我们走通之后，才能为第三方开发DAPP提供足够的技术支持。现在看起来的话，我们的技术方面的实现，还是比较有借鉴性的，但是可能没有太多的考虑社区的需求，所以运营做的并不是很好，也希望大家能给我们多提意见。希望大家能够试着使用一下这个应用，并对我们提出一些改进意见，看看在这个基础上能不能继续开发成为一种大家可以接受的，类似于知乎这样的软件。

第二个主要的子链应用就是星际风暴（filestorm），可能不少人都了解，现在叫做FST，这个项目是2018年初开始开发的，主要是由傅献农主导，我们这边的团队也是全力配合，把这个东西做出来了。

另外一个很重要的MOAC链项目叫做PAS，可能有人听说过，就是高精度信任链网。它是将MOAC区块链和一个硬件终端进行绑定，硬件终端是由井融团队开发的，主要是为用户提供厘米级的高精度定位系统。PAS项目主要是利用区块链的激励方式，把这种高精度的定位服务，以去中心化的方式，快速地全球组网。大家现在也可以看到他们的一些布网方式。他们现在的整个布网在国外推广得非常迅速。PAS就是利用了区块链这种通证经济，你前期购买了他们的矿机之后，开始架构你的基站，把数据传回到链上，系统判定你的服务正常之后，给你派发相应的通证。用这种区块链的方式实现通证激励机制，就可以使得使用者和建设者的经济效益形成正向反馈。目前该项目正在推广中，大家可以参考一下他们的项目网站（pasnet.io），还是很有创新性和借鉴意义的。

第四个就是我们已经为大数据交易所开发出来的一个大数据交易平台，也是通过MOAC子链对大数据产品进行确权和交易的一个平台。这里面的主要解决的问题就是保障数据交易中的数据安全和交易记录，因为传统的数据交易平台的他一般会拿到卖方数据。但是我们这个去中心化的子链交易，可以完全地避免交易平台拿到这个数据，从而减少数据泄密的可能性。

最后，我们回顾一下MOAC的发展历程。MOAC项目最早的想法的提出是在2017年的一月份，当时是在硅谷，主要是周沙先生和陈小虎先生，再加上当时其他的几位同事一起讨论的时候提出的。

在2017年七月份，我们成功的募集到了足够的资金来启动这个项目，在17年的10月份我们测试网就发布了，基本上按照这个时间线，在2018年4月30日上线了主网。经过几次升级，到2018年的年底，我们主要的一些项目、一些想法都已经实现了。
![](https://img.learnblockchain.cn/2019/08/29_493883216.jpg)
今年，MOAC几个子链上的应用已经推出，并变得成熟，同时也在继续完善MOAC子链系统和相应的周边工具，并且与国内更多的生态伙伴合作，进一步推广商业性的应用，把我们的生态系统建立成全世界第一公链。

-------------------------------------  

**提问**：多谢李总分享！我看了MOAC和井通的白皮书，井通对于分层的表述是：合约层，价值层，数据层，区块层，网络层。MOAC对分层的表述为：上层子链与智能合约，事件处理，全局母链，p2p网络。能否解读一下其中的差别？


 

李正鹏：好的，井通和MOAC，对分层的表述确实有所不同，首先来讲，井通的系统在最初设计的时候，设计的比较早，当时主要是针对价值的交换。井通当时主要借鉴的是瑞波和后来的恒星系统，所以其中比较强调的一点就是价值的交换，也就是TOKEN的互换，包括你可以在上面直接挂单、完成一些交易。它可能对应的就是现在类似于liberal这种系统吧。它和MOAC的这种分层，在底层的是比较相似的，就是一个网络层，都是P2P网络构建的。全局母链的区块层和数据层也有一定的对应。通过价值之间的交换，可以在这上面，在这个基础之上再构建上智能合约。因为井通上的智能合约开发得比较晚，它等于是在MOAC这边开发基本完成之后在上面构建的一个新的层次，所以我们也在考虑对井通的整个系统进行升级，现在在设计中，真正推出要到明年了。


**提问**：MOAC现在的主网运行，感觉在脱离矿工的基础上也能正常进行，那么矿工对MOAC的生态还重要吗？

 

李正鹏：MOAC的主网不可能脱离矿工，现在我们MOAC的主网挖矿主要是在欧洲有一些节点挖得比较多，另外北美也有一些。国内的应该也有，但是好像比之前是少了一些。矿工的减少也就是算力的下降，肯定对主网有影响，所以我们希望能够把算力保持在500G以上，将来希望能够提高到1T以上。矿工对MOAC的生态当然重要，我们必须有足够的矿工来支持我们底层母链的运行。当然现在来说，Token价格比较低可能确实会对生态造成一定的影响。但是我们也可以看到，虽然现在跌了不少，但我们的主网算力还是保持在一个不错的水平。现在看起来，游戏博彩这方面的项目，并不是我们所希望的、为生态系统带来长久利益的一个项目。我们更希望类似于FST、书签购物和PAS这些项目。同时，我们也希望能够创建一个好的子链挖矿，就像白皮书上提到的，一个是母链POW挖矿，另外也可以进行子链挖矿。现在子链挖矿做得比较好的，当然就是FST项目，有一些比较好的机制，可以鼓励大家来参与。




**提问**：MOAC设计之初面向的潜在客户是哪些？现在有什么变化吗？MOAC在国外有什么应用吗？

李正鹏：MOAC设计之初面向的潜在用户，当时主要是考虑把以太坊上面的一些类似于像以太猫这样的项目能够接过来，这些项目在当时看来会引起很高的热度，可以造成以太坊的主网拥堵。相对而言，MOAC在国外的用户比较多，我们这边有英文的telegram群，俄文的telegram群。虽说大家不是很活跃，也还有一定的热度，可以跟我们联系，开发他们的商业应用。就国外来讲，现在真正落到实地的应用还是比较少的。这块儿可能国内的进展会更快一些。关于MOAC在国外的应用，这个一方面来讲的话，就是有一些矿工在挖矿，另外，在美国这边我们也接洽过不同的客户，包括像英国，有一个做区块链媒体的，类似于像这种区块链的媒体分发平台，之前跟我们联系过，但是最近没有听到他们动静。另外，目前在美国这边，也跟我们在接洽的，有一个是这种大数据交易的，就是我们之前提到的那个大数据交易所。在这个基础上，他们也有一些新的需求修改，这块儿我们正在跟他们接洽。


**提问**：子链和侧链的区别？

李正鹏：MAOC的子链与很多的侧链的形式相比，子链的安全性是由母链来保证的。这块白皮书中提到的，因为你是没法直接攻击我们子链的节点。但是对于一个侧链而言，你可以直接攻击侧链节点，导致整个侧链的瘫痪。

[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里。
