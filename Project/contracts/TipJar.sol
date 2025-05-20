// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TipJar {
    address public owner;
    mapping(address => bool) public allowedTokens;

    constructor(address[] memory _initialAllowedTokens) {
        owner = msg.sender;
        for (uint i = 0; i < _initialAllowedTokens.length; i++) {
            allowedTokens[_initialAllowedTokens[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function setAllowedToken(address tokenAddress, bool allowed) public onlyOwner {
        allowedTokens[tokenAddress] = allowed;
    }

    function tip(address tokenAddress, uint256 amount) public {
        require(allowedTokens[tokenAddress], "Token not allowed");
        require(amount > 0, "Tip must be greater than zero");

        IERC20 token = IERC20(tokenAddress);
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");
    }

    function getBalance(address tokenAddress) public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function withdraw(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        bool success = token.transfer(owner, balance);
        require(success, "Withdraw failed");
    }
}
