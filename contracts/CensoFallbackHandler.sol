pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/handler/DefaultCallbackHandler.sol";

contract CensoFallbackHandler is DefaultCallbackHandler {
    string internal ILLEGAL_ADDRESS = "CS010";
    string internal ALREADY_WHITELISTED = "CS011";
    string internal UNKNOWN_ADDRESS = "CS012";
    string internal CANNOT_REMOVE_SENTINEL = "CS013";
    address internal constant SENTINEL_ADDRESS = address(0x1);
    uint internal constant MAX_ADDRESSES_TO_REMOVE = 100;

    event WhitelistedAddress(address wallet, address whitelisted, bytes12 nameHash);
    event UnwhitelistedAddress(address wallet, address unwhitelisted);
    event SetNameHash(address wallet, bytes32 nameHash);

    // `whitelists` is a per-wallet linked-list of whitelisted addresses
    mapping(address => mapping(address => address)) public whitelists;
    // `hashes` is a per-wallet map with a name hash for each whitelisted address
    mapping(address => mapping(address => bytes12)) public hashes;
    // `nameHashes` is a map from wallet address to a name hash for that wallet
    mapping(address => bytes32) public nameHashes;

    function updateWhitelist(bytes32[] calldata addressesToAddOrRemove) public {
        if (whitelists[msg.sender][SENTINEL_ADDRESS] == address(0x0)) {
            whitelists[msg.sender][SENTINEL_ADDRESS] = SENTINEL_ADDRESS;
        }

        address previous = SENTINEL_ADDRESS;
        for (uint i = 0; i < addressesToAddOrRemove.length; i++) {
            // Each entry in `addressesToAddOrRemove` is either a single address to remove,
            // or it is an instruction to remove 1 or more addresses (up to MAX_ADDRESSES_TO_REMOVE).
            // The first 12 bytes of each entry is either the name hash of the address, or the count of
            // how many addresses to remove. When removing addresses, the remaining bytes are the address
            // of the predecessor of the first address to remove.
            bytes32 addressToAddOrRemove = addressesToAddOrRemove[i];
            bytes12 nameHashOrNumberToRemove = bytes12(addressToAddOrRemove);
            address addressOrPredecessor = address(uint160(uint256(addressToAddOrRemove)));
            uint96 numberToRemove = uint96(nameHashOrNumberToRemove);
            require(numberToRemove > 0, ILLEGAL_ADDRESS);
            if (numberToRemove < MAX_ADDRESSES_TO_REMOVE) {
                address current = whitelists[msg.sender][addressOrPredecessor];
                require(current != address(0x0), UNKNOWN_ADDRESS);
                address next = SENTINEL_ADDRESS;
                for (uint j = 0; j < numberToRemove; j++) {
                    require(current != SENTINEL_ADDRESS, CANNOT_REMOVE_SENTINEL);
                    next = whitelists[msg.sender][current];
                    whitelists[msg.sender][current] = address(0x0);
                    emit UnwhitelistedAddress(msg.sender, current);
                    current = next;
                }
                whitelists[msg.sender][addressOrPredecessor] = next;
            } else {
                // address to whitelist cannot be null or sentinel.
                require(addressOrPredecessor != address(0x0) && addressOrPredecessor != SENTINEL_ADDRESS, ILLEGAL_ADDRESS);
                // address cannot be added twice.
                require(whitelists[msg.sender][addressOrPredecessor] == address(0x0), ALREADY_WHITELISTED);

                whitelists[msg.sender][addressOrPredecessor] = whitelists[msg.sender][SENTINEL_ADDRESS];
                hashes[msg.sender][addressOrPredecessor] = nameHashOrNumberToRemove;
                whitelists[msg.sender][SENTINEL_ADDRESS] = addressOrPredecessor;
                emit WhitelistedAddress(msg.sender, addressOrPredecessor, nameHashOrNumberToRemove);
            }
        }
    }

    function getWhitelistPaginated(address wallet, address start, uint256 pageSize) external view returns (address[] memory array, address next) {
        // Init array with max page size
        array = new address[](pageSize);

        // Populate return array
        uint256 addressCount = 0;
        address currentAddress = whitelists[wallet][start];
        while (currentAddress != address(0x0) && currentAddress != SENTINEL_ADDRESS && addressCount < pageSize) {
            array[addressCount] = currentAddress;
            currentAddress = whitelists[wallet][currentAddress];
            addressCount++;
        }
        next = currentAddress;
        // Set correct size of returned array
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(array, addressCount)
        }
    }

    function addressIsWhitelisted(address wallet, address addr) external view returns (bool whitelisted) {
        whitelisted = whitelists[wallet][addr] != address(0x0);
    }

    function setNameHash(bytes32 nameHash) public {
        nameHashes[msg.sender] = nameHash;
        emit SetNameHash(msg.sender, nameHash);
    }
}
