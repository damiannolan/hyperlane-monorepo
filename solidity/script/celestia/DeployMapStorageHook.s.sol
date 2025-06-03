// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Script} from "forge-std/Script.sol";
import {MapStorageHook} from "../../contracts/hooks/MapStorageHook.sol";
import {Mailbox} from "../../contracts/Mailbox.sol";

contract DeployMapStorageHook is Script {
    function run() external {
        address mailbox = vm.envAddress("MAILBOX");

        vm.startBroadcast();

        MapStorageHook hook = new MapStorageHook(mailbox);
        Mailbox(mailbox).setDefaultHook(address(hook));

        vm.stopBroadcast();
    }
}
