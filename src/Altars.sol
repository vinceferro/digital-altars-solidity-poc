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
        address owner;
        OfferingType offering;
    }

    mapping(uint256 => Altar) private _altars;
    mapping(address => uint256[]) private _altarsByOwner;

    event AltarCreated(uint256 altarId, address indexed owner);
    event AltarDestroyed(uint256 altarId, address indexed owner);
    event OfferingUpdated(uint256 indexed altarId, OfferingType newOffering);

    error IncorrectOwner(address sender, uint256 altarId, address owner);
    error InvalidAltarId(uint256 altarId);
    error NonexistentAltar(uint256 altarId);

    constructor() {}

    function createAltar(
        uint256 altarId,
        string memory name,
        string memory altarStyleURI,
        string memory pictureURI
    ) public {
        if (_exists(altarId)) {
            revert InvalidAltarId(altarId);
        }

        Altar memory newAltar = Altar({
            name: name,
            altarStyleURI: altarStyleURI,
            pictureURI: pictureURI,
            owner: msg.sender,
            offering: OfferingType.None
        });

        _altars[altarId] = newAltar;
        _altarsByOwner[msg.sender].push(altarId);

        emit AltarCreated(altarId, msg.sender);
    }

    function updateOffering(uint256 altarId, OfferingType newOffering) public {
        _checkOwnership(altarId);

        Altar storage altar = _altars[altarId];
        altar.offering = newOffering;

        emit OfferingUpdated(altarId, newOffering);
    }

    function destroyAltar(uint256 altarId) public {
        _checkOwnership(altarId);

        delete _altars[altarId];

        uint256[] storage ids = _altarsByOwner[msg.sender];
        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] == altarId) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
                break;
            }
        }

        emit AltarDestroyed(altarId, msg.sender);
    }

    function altarsIdsByOwner(
        address owner
    ) public view returns (uint256[] memory) {
        return _altarsByOwner[owner];
    }

    function altarsByOwner(address owner) public view returns (Altar[] memory) {
        uint256[] memory ids = _altarsByOwner[owner];
        Altar[] memory altars = new Altar[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            altars[i] = _altars[ids[i]];
        }

        return altars;
    }

    function _checkOwnership(uint256 altarId) internal view {
        address altarOwnedBy = _ownerOf(altarId);
        if (altarOwnedBy == address(0)) {
            revert NonexistentAltar(altarId);
        }

        if (altarOwnedBy != msg.sender) {
            revert IncorrectOwner(msg.sender, altarId, altarOwnedBy);
        }
    }

    function _exists(uint256 altarId) internal view returns (bool) {
        return _ownerOf(altarId) != address(0);
    }

    function _ownerOf(uint256 altarId) internal view virtual returns (address) {
        return _altars[altarId].owner;
    }
}
