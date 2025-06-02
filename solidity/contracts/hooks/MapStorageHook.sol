// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {MailboxClient} from "../client/MailboxClient.sol";
import {IPostDispatchHook} from "../interfaces/hooks/IPostDispatchHook.sol";
import {Indexed} from "../libs/Indexed.sol";
import {Message} from "../libs/Message.sol";

contract StorageMapHook is IPostDispatchHook, MailboxClient, Indexed {
    using Message for bytes;

    // Tracks seen message IDs.
    mapping(bytes32 => bool) internal _store;

    // Event emitted when a message is stored
    event MessageStored(bytes32 indexed id, bytes message);

    constructor(address _mailbox) MailboxClient(_mailbox) {}

    /// @inheritdoc IPostDispatchHook
    function hookType() external pure override returns (uint8) {
        return uint8(IPostDispatchHook.Types.STORAGE_MAP_HOOK);
    }

    /// @inheritdoc IPostDispatchHook
    function supportsMetadata(
        bytes calldata
    ) external pure override returns (bool) {
        return false;
    }

    /// @inheritdoc IPostDispatchHook
    function postDispatch(
        bytes calldata,
        bytes calldata message
    ) external payable override {
        require(msg.value == 0, "StorageMapHook: no value expected");

        bytes32 id = message.id();

        require(!_store[id], "Message already stored");
        require(_isLatestDispatched(id), "message not dispatching");

        _store[id] = true;

        emit MessageStored(id, message);
    }

    /// @inheritdoc IPostDispatchHook
    function quoteDispatch(
        bytes calldata,
        bytes calldata
    ) external pure override returns (uint256) {
        return 0;
    }
}
