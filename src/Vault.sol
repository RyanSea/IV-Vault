// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import { ERC4626 } from "src/solmate-upgradeable/ERC4626.sol";

import { ERC20 } from "solmate/tokens/ERC20.sol";

import { ISafe } from "src/interfaces/ISafe.sol";

/// @title IV League Vault
contract Vault is ERC4626 {

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    ISafe internal safe;

    constructor() {
        _disableInitializers();
    }

    function initialize(bytes calldata data) external payable initializer {
        (
            string memory _name,    /// @param name of token
            string memory _symbol,  /// @param symbol of token
            ERC20 _asset,           /// @param asset underlying vault
            address _safe,          /// @param safe address
            uint amount,            /// @param amount of initial deposit
            address receiver        /// @param receiver for initial deposit shares

        ) = abi.decode(data,(string,string,ERC20,address,uint256,address));

        safe = ISafe(_safe);

        // initialize ERC4626
        _ERC4626_init(_asset, _name, _symbol);

        // initial deposit to avoid vulnterability
        ERC4626.deposit(amount, receiver);
    }

    /*//////////////////////////////////////////////////////////////
                             ERC4626 LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        require(safe.isOwner(msg.sender), "NOT_IV");

        shares = ERC4626.deposit(assets, receiver);
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /*//////////////////////////////////////////////////////////////
                             CALL FUNCTION
    //////////////////////////////////////////////////////////////*/

    function makeCall(bytes calldata data) external payable {
        require(msg.sender == address(safe), "NOT_ADMIN");

        (address target, bytes memory call) = abi.decode(data,(address,bytes));

        (bool success, ) = target.call{ value : msg.value }(call);

        require(success, "CALL_UNSUCCESSFUL");
    }

    /*//////////////////////////////////////////////////////////////
                                 META
    //////////////////////////////////////////////////////////////*/

    function getSafe() external view returns (address) {
        return address(safe);
    }

    function changeSafe(address _safe) external {
        require(msg.sender == address(safe), "NOT_ADMIN");

        safe = ISafe(_safe);
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == address(safe), "NOT_ADMIN");
    }
}
