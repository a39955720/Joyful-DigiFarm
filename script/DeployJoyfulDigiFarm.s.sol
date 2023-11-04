// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {JoyfulDigiFarm} from "../src/JoyfulDigiFarm.sol";

contract DeployJoyfulDigiFarm is Script {
    // Define an array of IPFS URIs for the CCN token Uris
    string[6] jdnTokenUris = [
        "ipfs://QmeaFmg8GYNMkpc9HkP54pVDzHXtCDMrDhUPEeKPK36vWf",
        "ipfs://Qmc3XjaKwSgRDNPATfxr5RpkJT3qofG8r9WFFsuZCsxjGg",
        "ipfs://QmS9rcwku5G3s7c4NhJVqyy5kBkUryjzPuscKG49vAehS5",
        "ipfs://QmVAvLknEzdcNjJjcNCd6Y1yaHvmTThcLVRLE1v1LADCgD",
        "ipfs://QmUa1dzt5C2RYTQyBun3k4PvyPSjDCeZ7RsU5U83Fto3LW",
        "ipfs://QmQJT1L5TgjwzzF3K4AfzrFJ8jiWp2TLs4RZQpFRe8VYxb"
    ];

    uint64 subscriptionId = 224;
    bytes32 gasLane =
        0x83d1b6e3388bed3d76426974512bb0d270e9542a765cd667242ea26c0cc0b730;
    uint32 callbackGasLimit = 500000;
    address vrfCoordinatorV2 = 0x6D80646bEAdd07cE68cab36c27c626790bBcf17f;

    uint256 deployerKey = vm.envUint("PRIVATE_KEY");

    function run() external returns (JoyfulDigiFarm) {
        vm.startBroadcast(deployerKey);
        JoyfulDigiFarm joyfulDigiFarm = new JoyfulDigiFarm(
            jdnTokenUris,
            vrfCoordinatorV2,
            subscriptionId,
            gasLane,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return joyfulDigiFarm;
    }
}
