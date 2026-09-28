// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

import {HookMiner} from "../lib/v4-periphery/test/shared/HookMiner.sol";

import {BeersDamesBurnHook} from "../src/BeersDamesBurnHook.sol";

contract DeployBeersDamesHook is Script {
    address constant POOL_MANAGER =
        0x8366a39CC670B4001A1121B8F6A443A643e40951;

    address constant CREATE2_DEPLOYER =
        0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function run() external {
        uint160 flags =
            Hooks.BEFORE_SWAP_FLAG
            | Hooks.AFTER_SWAP_FLAG
            | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
            | Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG;

        bytes memory constructorArgs =
            abi.encode(IPoolManager(POOL_MANAGER));

        (address predictedAddress, bytes32 salt) =
            HookMiner.find(
                CREATE2_DEPLOYER,
                flags,
                type(BeersDamesBurnHook).creationCode,
                constructorArgs
            );

        console2.log("Flags:", flags);
        console2.log("Expected flags: 204 / 0xCC");
        console2.log("Predicted hook:", predictedAddress);
        console2.logBytes32(salt);

        vm.startBroadcast();

        BeersDamesBurnHook hook =
            new BeersDamesBurnHook{salt: salt}(
                IPoolManager(POOL_MANAGER)
            );

        vm.stopBroadcast();

        require(
            address(hook) == predictedAddress,
            "HOOK_ADDRESS_MISMATCH"
        );

        console2.log("Deployed hook:", address(hook));
    }
}