// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./utils/TransactionUtils.sol";

contract Enum {
    enum Operation {Call, DelegateCall}
}

contract CensoTransfersOnlyGuard is TransactionUtils {
    string internal ILLEGAL_TO_ADDRESS = "CS000";
    string internal ILLEGAL_OPERATION = "CS001";
    string internal NOT_A_TRANSFER = "CS003";

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256, // safeTxGas,
        uint256, // baseGas,
        uint256, // gasPrice,
        address, // gasToken,
        address payable, // refundReceiver,
        bytes memory, // signatures,
        address // msgSender
    ) public view {
        // do not allow any transactions which might alter the state of this safe
        // either because the target is the safe
        require(to != msg.sender, ILLEGAL_TO_ADDRESS);
        // or because it's a delegatecall to another contract which could then alter our
        // state
        require(operation != Enum.Operation.DelegateCall, ILLEGAL_OPERATION);
        // check that this transaction is either a simple ETH transfer (by requiring `data` to be empty)
        // or it looks like a token transfer (and the ETH value is 0)
        require(data.length == 0 || (value == 0 && looksLikeTokenTransfer(data)), NOT_A_TRANSFER);
    }

    function checkAfterExecution(bytes32 txHash, bool success) public {}
}
