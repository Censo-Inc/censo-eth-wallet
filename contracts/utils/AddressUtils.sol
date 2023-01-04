// SPDX-License-Identifier: GPLv3
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/interfaces/IERC165.sol";

contract AddressUtils {
    string internal NOT_VALID_CONTRACT = "CS020";

    function extractDestinationAddress(
        address to,
        bytes memory data
    ) public view returns (address) {
        if (data.length >= 4) {
            uint32 funcHash;
            assembly {
                funcHash := mload(add(data, 0x4))
            }
            if (funcHash == 0xa9059cbb) { // ERC20 transfer(address,uint256)
                return toAddress(data, 16);
            }
            if (funcHash == 0x23b872dd) { // ERC20/ERC721 transferFrom(address,address,uint256)
                return toAddress(data, 48);
            }
            if (funcHash == 0x42842e0e) { // ERC721 safeTransferFrom(address,address,uint256)
                require(supportsERC165Interface(to, 0x01ffc9a780ac58cd), NOT_VALID_CONTRACT);
                return toAddress(data, 48);
            }
            if (funcHash == 0xf242432a ||   // ERC1155 safeTransferFrom(address,address,uint256,uint256,bytes)
                funcHash == 0x2eb2c2d6) {   // ERC1155 safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
                require(supportsERC165Interface(to, 0x01ffc9a7d9b67a26), NOT_VALID_CONTRACT);
                return toAddress(data, 48);
            }
        }
        return to;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "CS010");
        address tempAddress;

        assembly {
            tempAddress := shr(96, mload(add(add(_bytes, 0x20), _start)))
        }

        return tempAddress;
    }

    function supportsERC165Interface(address account, bytes8 selectorAndInterfaceId) internal view returns (bool) {
        bytes memory encodedParams = new bytes(36);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            mstore(add(encodedParams, 32), selectorAndInterfaceId)
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}