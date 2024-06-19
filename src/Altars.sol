// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Altars {
    enum OfferingType {
        None,
        Apple,
        Orange,
        Rice
    }

    struct Altar {
        string name;
        string altarStyleURI;
        string pictureURI;
        OfferingType currentOffering;
    }

    mapping(uint256 => address) private _owners;
    mapping(uint256 => Altar) private _altars;

    event AltarCreated(uint256 altarId, address indexed owner);
    event AltarDestroyed(uint256 altarId, address indexed owner);
    event OfferingUpdated(uint256 indexed altarId, OfferingType newOffering);

    error InvalidOwner(address owner);
    error NonexistentAltar(uint256 altarId);
    error IncorrectOwner(address sender, uint256 altarId, address owner);

    constructor() {}

    function createAltar(
        uint256 altarId,
        string memory name,
        string memory altarStyleURI,
        string memory pictureURI
    ) public {
        _requireAvailable(altarId);

        Altar memory newAltar = Altar({
            name: name,
            altarStyleURI: altarStyleURI,
            pictureURI: pictureURI,
            currentOffering: OfferingType.None
        });

        _altars[altarId] = newAltar;
        _owners[altarId] = msg.sender;

        emit AltarCreated(altarId, msg.sender);
    }

    function updateOffering(uint256 altarId, OfferingType newOffering) public {
        require(_exists(altarId), "Token ID does not exist");

        Altar storage altar = _altars[altarId];
        altar.currentOffering = newOffering;

        emit OfferingUpdated(altarId, newOffering);
    }

    function ownerOf(uint256 altarId) public view virtual returns (address) {
        return _requireOwned(altarId);
    }

    function _requireAvailable(uint256 altarId) internal view {
        if (!_exists(altarId)) {
            revert NonexistentAltar(altarId);
        }
    }

    function _requireOwned(uint256 altarId) internal view returns (address) {
        address owner = _ownerOf(altarId);
        if (owner == address(0)) {
            revert NonexistentAltar(altarId);
        }
        return owner;
    }

    function _exists(uint256 altarId) internal view returns (bool) {
        return _ownerOf(altarId) != address(0);
    }

    function _ownerOf(uint256 altarId) internal view virtual returns (address) {
        return _owners[altarId];
    }
}
