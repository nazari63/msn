// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MSNToken is IERC20 {
    uint public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;
    
    string public override name = "msn";
    string public override symbol = "MSN";
    uint8 public override decimals = 18;

    constructor() {
        totalSupply = 1_000_000_000 * 10 ** uint(decimals); // 1 میلیارد توکن
        balanceOf[msg.sender] = totalSupply; // همه توکن‌ها به سازنده داده می‌شود
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer function with Checks-Effects-Interactions pattern
    function transfer(address recipient, uint amount) public override returns (bool) {
        require(amount <= balanceOf[msg.sender], "Insufficient balance");
        require(!isContract(recipient), "Cannot send tokens to a contract");

        // Checks-Effects-Interactions pattern
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(amount <= balanceOf[sender], "Insufficient balance");
        require(amount <= allowance[sender][msg.sender], "Allowance exceeded");
        require(!isContract(recipient), "Cannot send tokens to a contract");

        // Checks-Effects-Interactions pattern
        allowance[sender][msg.sender] -= amount;
        
        if (allowance[sender][msg.sender] == 0) {
            allowance[sender][msg.sender] = 0; // Optional but for clarity
        }
        
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Functions to increase or decrease allowance
    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        require(subtractedValue <= allowance[msg.sender][spender], "Decreased allowance below zero");
        allowance[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    // Function to check if address is a contract
    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
