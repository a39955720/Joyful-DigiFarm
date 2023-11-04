// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error JoyfulDigiFarm__ControllerStateNotOpen();
error JoyfulDigiFarm__YouHaveAlreadyMintedPleaseWaterItFirst();
error JoyfulDigiFarm__PleaseMintNFTFirst();

contract JoyfulDigiFarm is ERC721URIStorage, VRFConsumerBaseV2 {
    enum ControllerState {
        OPEN,
        CALCULATING
    }

    enum NFT {
        VIOLET,
        SUNFLOWER,
        LOTUS,
        GERMINATION,
        MATURES,
        WILTEDPLANT
    }

    struct CurrentPlantStatus {
        uint256 tokenId;
        uint256 lastWateredTime;
        bool isMinted;
        NFT nft;
    }

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    ControllerState private s_controllerState;
    string[6] private s_jdnTokenUris;
    uint256 private s_tokenCounter;
    mapping(address => CurrentPlantStatus) private s_currentPlantStatus;

    event RequestedRandNum(uint256 indexed requestId);

    constructor(
        string[6] memory jdnTokenUris,
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Joyful DigiFarm NFT", "JDN") {
        s_jdnTokenUris = jdnTokenUris;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
    }

    function mintNFT() public {
        if (s_currentPlantStatus[msg.sender].isMinted == true) {
            revert JoyfulDigiFarm__YouHaveAlreadyMintedPleaseWaterItFirst();
        }
        _safeMint(msg.sender, s_tokenCounter);
        _setTokenURI(s_tokenCounter, s_jdnTokenUris[uint8(NFT.GERMINATION)]);
        s_currentPlantStatus[msg.sender].nft = NFT.GERMINATION;
        s_currentPlantStatus[msg.sender].tokenId = s_tokenCounter;
        s_currentPlantStatus[msg.sender].lastWateredTime = block.timestamp;
        s_currentPlantStatus[msg.sender].isMinted = true;
        s_tokenCounter++;
    }

    function watering() public {
        if (s_currentPlantStatus[msg.sender].isMinted == false) {
            revert JoyfulDigiFarm__PleaseMintNFTFirst();
        }

        if (
            block.timestamp >
            s_currentPlantStatus[msg.sender].lastWateredTime + 180
        ) {
            _setTokenURI(
                s_currentPlantStatus[msg.sender].tokenId,
                s_jdnTokenUris[uint8(NFT.WILTEDPLANT)]
            );
            s_currentPlantStatus[msg.sender].nft = NFT.WILTEDPLANT;
            s_currentPlantStatus[msg.sender].isMinted = false;
        }

        if (s_currentPlantStatus[msg.sender].nft == NFT.GERMINATION) {
            _setTokenURI(
                s_currentPlantStatus[msg.sender].tokenId,
                s_jdnTokenUris[uint8(NFT.MATURES)]
            );
            s_currentPlantStatus[msg.sender].nft = NFT.MATURES;
            s_currentPlantStatus[msg.sender].lastWateredTime = block.timestamp;
        } else if (s_currentPlantStatus[msg.sender].nft == NFT.MATURES) {
            if (s_controllerState != ControllerState.OPEN) {
                revert JoyfulDigiFarm__ControllerStateNotOpen();
            }
            s_controllerState = ControllerState.CALCULATING;
            uint256 requestId = i_vrfCoordinator.requestRandomWords(
                i_gasLane,
                i_subscriptionId,
                REQUEST_CONFIRMATIONS,
                i_callbackGasLimit,
                NUM_WORDS
            );
            emit RequestedRandNum(requestId);
        }
    }

    function fulfillRandomWords(
        uint256 /* requestId*/,
        uint256[] memory randomWords
    ) internal override {
        uint8 randNum = uint8(randomWords[0] % 3);
        _setTokenURI(
            s_currentPlantStatus[msg.sender].tokenId,
            s_jdnTokenUris[uint8(getIndex(randNum))]
        );
        s_currentPlantStatus[msg.sender].isMinted = false;
        s_controllerState = ControllerState.OPEN;
    }

    function getIndex(uint8 randNum) private pure returns (NFT) {
        if (randNum == 0) {
            return NFT.VIOLET;
        } else if (randNum == 1) {
            return NFT.SUNFLOWER;
        } else {
            return NFT.LOTUS;
        }
    }
}
