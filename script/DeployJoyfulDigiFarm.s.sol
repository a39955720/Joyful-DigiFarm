// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {JoyfulDigiFarm} from "../src/JoyfulDigiFarm.sol";

contract DeployJoyfulDigiFarm is Script {
    // Define an array of IPFS URIs for the CCN token Uris
    string[6] jdnTokenUris = [
        "ipfs://QmRZtjUVePYYQRZYrVemuhZKphjTjZWaxgDBLU2Mk7fyNz",
        "ipfs://QmQ3uzTAgZD95dNNDemTPH2wHseLThaRkshfzXYjfix5zf",
        "ipfs://QmXDsTQDHBcCxwBPt39JHheT1Mnmdmnm6bdnpus93DMP1T",
        "ipfs://QmXiG54CPssgkWLS3ZT85HsiHdifUoC61aP1JAFzd17iHT",
        "ipfs://QmexkesvvjyEK26Wzu7zkDBSgbDmrkBXRCYQ3tDmXR8EzQ",
        "ipfs://QmUXYKy95gdTMBtuV4WLb5wY4t66MMewDBks84T7v3jfVM"
    ];

    uint64 subscriptionId = 226;
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
