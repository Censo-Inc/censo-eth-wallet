// SPDX-License-Identifier: GPLv3
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/interfaces/IERC165.sol";

contract TransactionUtils {
    function looksLikeTokenTransfer(
        bytes memory data
    ) public view returns (bool) {
        if (data.length >= 4) {
            uint32 funcHash;
            assembly {
                funcHash := mload(add(data, 0x4))
            }
            return funcHash == 0xa9059cbb || // ERC20 transfer(address,uint256)
                   funcHash == 0x23b872dd || // ERC20/ERC721 transferFrom(address,address,uint256)
                   funcHash == 0x42842e0e || // ERC721 safeTransferFrom(address,address,uint256)
                   funcHash == 0xf242432a || // ERC1155 safeTransferFrom(address,address,uint256,uint256,bytes)
                   funcHash == 0x2eb2c2d6;   // ERC1155 safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
        } else {
            return false;
        }
    }
}