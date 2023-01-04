// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.7.0 < 0.9.0;

interface Fallback {
  function setNameHash(bytes32 nameHash) external;
}

contract CensoSetup {
  // keccak256("guard_manager.guard.address")
  bytes32 internal constant GUARD_STORAGE_SLOT = 0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8;

  // the `modules` mapping is stored at slot 1 in the gnosis safe, and the sentinel value is also 1
  // keccak256(ONE . ONE)
  bytes32 internal constant ONE = 0x0000000000000000000000000000000000000000000000000000000000000001;
  bytes32 internal constant SENTINEL_MODULE_STORAGE_SLOT = 0xcc69885fda6bcc1a4ace058b4a62bf5e179ea78fd58a1ccd71c22cc9b688792f;

  function censoSetup(address guard, address vault, address fallbackContract, bytes32 nameHash) public {
    bytes32 vaultAddress = bytes32(uint256(uint160(vault)));
    // add the vault to the `modules` mapping
    bytes32 vaultModuleStorage = keccak256(abi.encodePacked(vaultAddress, ONE));
    // solhint-disable-next-line no-inline-assembly
    assembly {
      sstore(GUARD_STORAGE_SLOT, guard)
      sstore(vaultModuleStorage, ONE)
      sstore(SENTINEL_MODULE_STORAGE_SLOT, vaultAddress)
    }
    Fallback(fallbackContract).setNameHash(nameHash);
  }
}
