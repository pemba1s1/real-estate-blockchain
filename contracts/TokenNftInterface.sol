// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface TokenNftInterface {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

}
