---
title: OpenZeppelin ERC777 源码解析
permalink: erc777-code
date: 2019-09-26 15:10:54
categories: 
    - 以太坊
    - 智能合约
tags:
    - ERC777
    - ERC1820
    - OpenZeppelin
author: Tiny熊
---

这篇文章是对[ERC777 功能型代币（通证）最佳实践](https://learnblockchain.cn/2019/09/27/erc777/) 的一个补充，如果你仅仅是要实现一个自己的 ERC777 代币， 那么阅读另一篇就够了， 如果想对ERC777进行一些自己的定制，那么就有需要对源码有理解。

<!-- more -->

## ERC777 源码解析

本文源码来自 OpenZeppelin， [GitHub 代码库地址](https://github.com/OpenZeppelin/openzeppelin-contracts) 当前基于 OpenZeppelin 2.3.0 版本，源码文件路径为：` contracts/token/ERC777/ERC777.sol`

下面在源码进行注释进行解析：

```js
pragma solidity ^0.5.0;

import "./IERC777.sol";
import "./IERC777Recipient.sol";
import "./IERC777Sender.sol";
import "../../token/ERC20/IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";
import "../../introspection/IERC1820Registry.sol";

// 合约实现兼容了 ERC20
contract ERC777 is IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    // ERC1820 注册表合约地址
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    // 发送者接口hash 硬编码 keccak256("ERC777TokensSender") 为了减少 gas， 用户查询是否实现了对应的接口。
    bytes32 constant private TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    // keccak256("ERC777TokensRecipient")
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    // 保存默认操作者列表
    address[] private _defaultOperatorsArray;

    // 为了索引默认操作者状态 使用的mapping
    mapping(address => bool) private _defaultOperators;

    // 保存授权的操作者
    mapping(address => mapping(address => bool)) private _operators;
    // 保存取消授权的默认操作者
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    // 为了兼容 ERC20 （授权信息）
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
     * @dev `defaultOperators` 可以为空.
     */
    constructor(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) public {
        _name = name;
        _symbol = symbol;

        _defaultOperatorsArray = defaultOperators;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
            _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

        // 注册接口
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    //  为了兼容 ERC20
    function decimals() public pure returns (uint8) {
        return 18;
    }

    // 默认粒度为1，粒度表示代币最小的分隔单位 
    function granularity() public view returns (uint256) {
        return 1;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view returns (uint256) {
        return _balances[tokenHolder];
    }

    // ERC777 定义的转账函数， 同时触发 ERC20的 `Transfer` 事件
    function send(address recipient, uint256 amount, bytes calldata data) external {
        _send(msg.sender, msg.sender, recipient, amount, data, "", true);
    }

    // 为兼容 ERC20，同时触发 `Sent` 事件
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = msg.sender;

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        //最后一个参数表示不要求接收者实现钩子函数 `tokensReceived`
        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    // 为了兼容 ERC20， 触发 `Transfer` 事件
    function burn(uint256 amount, bytes calldata data) external {
        _burn(msg.sender, msg.sender, amount, data, "");
    }

    // 是否是操作员
    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view returns (bool) {
        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    // 授权操作员
    function authorizeOperator(address operator) external {
        require(msg.sender != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[msg.sender][operator];
        } else {
            _operators[msg.sender][operator] = true;
        }

        emit AuthorizedOperator(operator, msg.sender);
    }

    // 撤销操作员
    function revokeOperator(address operator) external {
        require(operator != msg.sender, "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[msg.sender][operator] = true;
        } else {
            delete _operators[msg.sender][operator];
        }

        emit RevokedOperator(operator, msg.sender);
    }

    // 默认操作者
    function defaultOperators() public view returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    // 转移代币，需要有操作者权限，触发 `Sent` 和 `Transfer` 事件
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    )
    external
    {
        require(isOperatorFor(msg.sender, sender), "ERC777: caller is not an operator for holder");
        _send(msg.sender, sender, recipient, amount, data, operatorData, true);
    }

    // 销毁
    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, account), "ERC777: caller is not an operator for holder");
        _burn(msg.sender, account, amount, data, operatorData);
    }

    // 为了兼容 ERC20
    function allowance(address holder, address spender) public view returns (uint256) {
        return _allowances[holder][spender];
    }

    // 为了兼容 ERC20
    function approve(address spender, uint256 value) external returns (bool) {
        address holder = msg.sender;
        _approve(holder, spender, value);
        return true;
    }

   // 注意， 操作员没有权限调用（除非经过approve）
   // 触发 `Sent` and `Transfer`事件

    function transferFrom(address holder, address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = msg.sender;

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    // 铸币函数（即常说的挖矿）
    function _mint(
        address operator,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal
    {
        require(account != address(0), "ERC777: mint to the zero address");

        // Update state variables
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    // 转移 token
    //  最后一个参数 requireReceptionAck 表示是否必须实现 ERC777TokensRecipient
    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    // 销毁代币实现
    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        private
    {
        require(from != address(0), "ERC777: burn from the zero address");

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        // Update state variables
        _totalSupply = _totalSupply.sub(amount);
        _balances[from] = _balances[from].sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

//  转移所有权
    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) private {
        // TODO: restore this require statement if this function becomes internal, or is called at a new callsite. It is
        // currently unnecessary.
        //require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    // 尝试调用持有者的 tokensToSend() 函数
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        address implementer = _erc1820.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

   // 尝试调用接收者的 tokensReceived()
   function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        address implementer = _erc1820.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }
}

```



[深入浅出区块链](https://learnblockchain.cn/) - 打造高质量区块链技术博客，学区块链都来这里，关注[知乎](https://www.zhihu.com/people/xiong-li-bing/activities)、[微博](https://weibo.com/517623789) 掌握区块链技术动态。
