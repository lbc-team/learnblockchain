---
title: Blockchain-how mining works and transactions are processed in seven steps
permalink: block-mining
un_reward: false
date: 2019-10-22 09:28:18
categories:
tags:
author: Jimi S.
---









Ever wondered how the mining process on a blockchain works, or how a transaction gets confirmed and is added to the blockchain? So have I. And since I couldn’t find any clear step by step explanation of this process, I decided to write one myself. Here is how a blockchain transaction is processed on a blockchain, in seven steps.











![](media/1*S9Mv3bEQ7BcX12mX6LI_pQ.png)

![](media/1*S9Mv3bEQ7BcX12mX6LI_pQ.png)









* **Step 1**: A user signs off on a transaction from their wallet application, attempting to send a certain crypto or token from them to someone else.
* **Step 2**: The transaction is broadcasted by the wallet application and is now awaiting to be picked up by a miner on the according blockchain. As long as it is not picked up, it hovers in a ‘pool of unconfirmed transactions’. This pool is a collection of unconfirmed transactions on the network that are waiting to be processed. These unconfirmed transactions are usually not collected in one giant pool, but more often in small subdivided local pools.
* **Step 3**: Miners on the network (sometimes referred to as [nodes](https://medium.com/coinmonks/blockchain-what-is-a-node-or-masternode-and-what-does-it-do-4d9a4200938f), but not [quite the same](https://medium.com/@JimiS/blockchain-what-is-a-node-or-masternode-and-what-does-it-do-4d9a4200938f)!) select transactions from these pools and form them into a ‘block’. A block is basically a collection of transactions (at this moment in time, still unconfirmed transactions), in addition to some extra metadata. Every miner constructs their own *block of transactions. *Multiple miners can select the same transactions to be included in their block.

**Example**: two miners, miner A and miner B. Both miner A and miner B can decide to include transaction X into their block. Each blockchain has its own maximum block size. On the Bitcoin blockchain, the maximum block size of one block is 1 MB of data. Before adding a transaction to their block, a miner needs to check if the transaction is eligible to be executed according to the blockchain history. If the sender’s wallet balance has sufficient funds according to the existing blockchain history, the transaction is considered valid and can be added to the block. If a Bitcoin owner wants to speed up their transaction, they can choose to offer a higher mining reward. Miners will usually prioritise transactions such transactions over others, because they provide a better mining reward.

* **Step 4**: By selecting transactions and adding them to their block, miners create a block of transactions. To add this block of transactions to the blockchain (which means having all the nodes on the blockchain register the transactions in this block), the block first needs a signature (also referred to as a* ‘proof of work’*). This signature is created by solving a very complex mathematical problem that is unique to each block of transactions. Each block has a different mathematical problem, so every miner will work on a different problem unique to the block they formed. Each block’s problem is equally hard to solve. In order to solve this mathematical problem, a lot of *computational power* is used (and thus a lot of electricity). You can compare it to running a calculation on a calculator, only this is much heavier and on done a computer. This is the process referred to as **mining**. If you want to know more about how the mathematical problem works exactly (it’s not actually that complicated), please continue reading *below,* otherwise, in case you want to keep it a little more simple, skip to [step 5.](https://blog.goodaudience.com/how-a-miner-adds-transactions-to-the-blockchain-in-seven-steps-856053271476#92ef)











![](media/1*ZWQMcP4fEEoBdF-E9WKyOw.jpeg)

![](media/1*ZWQMcP4fEEoBdF-E9WKyOw.jpeg)















* * *







## Mining aka hashing (Proof of Work consensus algorithm)

The mathematical problem every miner is facing when trying to add a block to the blockchain is to find a **hash output (aka signature) **for the data in its block, that starts with a certain amount of consecutive zero’s. That sounds complicated, right? But it isn’t really that hard. Let me try to explain this to you in a simple way.

Before we proceed, it is important to know what a *hash function* is. A hash function is simply put a mathematical problem that is very **hard to solve**, but where the answer is very **easy** to verify.

A hash function takes an input string of numbers and letters (literally any string of random letters, numbers and/or symbols), and turns it into a new *32 digit string* existing out of **random** letters and numbers. This 32 digit string is the **hash output**. If any number or letter in the input string is changed, the hash output will also change randomly. However, the same string of input will **always** give the same string of output.

Now consider the data inside a block to be the **hash input **(a string of data). When this input is hashed, it gives a **hash output** (32 digit string). A rule of the Bitcoin blockchain is that a block can *only* be added to the blockchain if its signature, the hash output, starts with a certain amount of zeros. However, the output string generated by an input string is always random for each different input string, so what if the data string of the block does not lead to a signature (hash output) that starts with so many consecutive zeros? Well, this is why miners repeatedly *change* a part of the data inside their block called the **nonce**. Every time a miner changes the nonce, it slightly changes the composition of the block’s data. And when the composition of the block’s data changes (it’s input), it’s signature (it’s output) also changes. So every time the nonce of a block is changed, the block gets a new random signature.

Miners repeat this process of changing the nonce indefinitely until they randomly hit an output string that meets the signature requirements (the zeros). Below illustrates this in an example. This example uses seven zeros, but the amount of zeros really depends on the [block difficulty](https://blog.goodaudience.com/blockchain-the-mystery-of-mining-difficulty-and-block-time-f07f0ee64fd0) of a blockchain. Block difficulty is a little more complicated though, so I suggest you save that for later.





















![](media/1*MJMd3OVd89GDUUyjluPmSQ-1.png)

![](media/1*MJMd3OVd89GDUUyjluPmSQ-1.png)



















This is how miners need to find an eligible signature to their block, and it is also the reason that so much computational power is needed to solve this mathematical problem. Guessing so many different nonces takes a lot of time and computational power. Also, when more hashing power (miners) joins a blockchain, the difficulty of it’s mathematical problem will increase and lead to higher average electricity expenses to solve a block ([more about this here](https://blog.goodaudience.com/blockchain-the-mystery-of-mining-difficulty-and-block-time-f07f0ee64fd0)). Good work if you followed through, now let’s move on to step 5.

Note: This process is actually not defined as a mathematical problem, but rather as a deterministic thing — computers are performing pre-determined operations on a number to see if the output is desirable.







* * *







* **Step 5**: The miner that finds an eligible signature for its block first, broadcasts this block and its signature to all the other miners.
* **Step 6**: Other miners now verify the signature’s legitimacy by taking the string of data of the broadcasted block, and hashing it to see if its hash output indeed leads to its included signature of so many zeros (hard to solve, easy to **verify**, remember?). If it is valid, the other miners will confirm its validity and agree that the block can be added to the blockchain (they reach *consensus*, aka they all agree with each other, hence the term consensus algorithm). This is also where the definition ‘proof of work’ comes from. The signature is the ‘proof’ of the work performed (the computational power that was spent). The block can now be added to the blockchain, and is distributed to all other nodes on the network. The other nodes will accept the block and save it to their transaction data as long as all transactions inside the block can be executed according to the blockchain’s history.
* **Step 7**: After a block has been added to the chain, every other block that is added on top of it counts as a ‘*confirmation’* for that block. For example, if my transaction is included in block 502, and the blockchain is 507 blocks long, it means my transaction has 5 confirmations (507–502). It is referred to as a confirmation because every time another block is added on top of it, the blockchain reaches consensus again on the complete transaction history, including your transaction and your block. You could say that your transaction has been confirmed 5 times by the blockchain at that point. This is also what Etherscan is referring to when showing you your transaction details. The more confirmations your transaction has (aka the deeper the block is embedded in the chain), the harder it is for attackers to alter it ([you can read more about how this works here](https://medium.com/coinmonks/what-is-a-51-attack-or-double-spend-attack-aa108db63474)). After a new block is added to the blockchain, all miners need to start over again at step three by forming a new block of transactions. Miners cannot continue (well, they can, but that is quite irrelevant in this article) mining aka solving the problem of the block they were working on earlier because of two reasons:

**One**: it may contain transactions that have been confirmed by the last block that was added to the blockchain (remember, multiple miners can select/include the same transactions(s) in the block they are solving) already. Any of those transactions initiated again could render them invalid, because the source balance might no longer suffice.

**And two:** every block needs to add the hash output (signature) of the *last block* that was added to the blockchain into* their metadata*. This is what makes it a block*chain*. If a miner keeps mining the block they were already working on, other miners will notice that the hash output does not correspond with that of the latest added block on the blockchain, and will therefore reject the block.

Interested in more? See the follow-ups below.







* * *







Was this article helpful? Help others find it by applauding or sharing. You can read more easy to understand blockchain explanations about:

## Beginner 1: [How blockchain works in 7 steps](https://medium.com/coinmonks/blockchain-for-beginners-what-is-blockchain-519db8c6677a)

## Beginner 2: [How mining works and how transactions are processed](https://medium.com/coinmonks/how-a-miner-adds-transactions-to-the-blockchain-in-seven-steps-856053271476) (this article)

## Beginner 3: [How a hacker performs a 51% attack](https://medium.com/coinmonks/what-is-a-51-attack-or-double-spend-attack-aa108db63474)

## Beginner 4: [Nodes and masternodes](https://medium.com/coinmonks/blockchain-what-is-a-node-or-masternode-and-what-does-it-do-4d9a4200938f)

## Beginner 5: [Mining difficulty and block time](https://blog.goodaudience.com/blockchain-the-mystery-of-mining-difficulty-and-block-time-f07f0ee64fd0)

## [Blockchain Terminology: Basic terminology to get you started](https://medium.com/@JimiS/blockchain-terminology-d903758d6bd)

## [Want to test your blockchain knowledge? Take the 20 questions test here and see if you are at beginner, advanced or expert level.](https://medium.com/@JimiS/blockchain-test-your-knowledge-beginner-advanced-or-expert-75c9f601718e)





