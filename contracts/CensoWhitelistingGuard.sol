// SPDX-License-Identifier: GPLv3
pragma solidity >=0.7.0 <0.9.0;

import "./CensoFallbackHandler.sol";
import "./utils/AddressUtils.sol";

contract Enum {
    enum Operation {Call, DelegateCall}
}

contract CensoWhitelistingGuard is AddressUtils {
    string internal ILLEGAL_TO_ADDRESS = "CS000";
    string internal ILLEGAL_OPERATION = "CS001";
    string internal NOT_WHITELISTED = "CS002";

    CensoFallbackHandler internal _fallbackHandler;

    constructor(address fallbackHandlerAddress) {
        _fallbackHandler = CensoFallbackHandler(fallbackHandlerAddress);
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) public {
        // do not allow any transactions which might alter the state of this safe
        // either because the target is the safe
        require(to != msg.sender, ILLEGAL_TO_ADDRESS);
        // or because it's a delegatecall to another contract which could then alter our
        // state
        require(operation != Enum.Operation.DelegateCall, ILLEGAL_OPERATION);

        require(_fallbackHandler.addressIsWhitelisted(msg.sender, extractDestinationAddress(to, data)), NOT_WHITELISTED);
    }

    function checkAfterExecution(bytes32 txHash, bool success) public {}
}
