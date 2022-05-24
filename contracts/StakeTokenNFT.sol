// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeTokenNFT is Ownable{

    constructor(address owner_){
         _transferOwnership(owner_);
    }

}