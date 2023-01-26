// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ISafe {
    function isOwner(address owner) external view returns (bool);
}