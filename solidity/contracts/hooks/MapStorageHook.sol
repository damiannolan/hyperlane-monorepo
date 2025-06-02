// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import {MailboxClient} from "../client/MailboxClient.sol";
import {IPostDispatchHook} from "../interfaces/hooks/IPostDispatchHook.sol";
import {Indexed} from "../libs/Indexed.sol";
import {Message} from "../libs/Message.sol";

contract MapStorageHook is IPostDispatchHook, MailboxClient, Indexed {
    using Message for bytes;

    // Simple map storage: (message id -> bool)
    mapping(bytes32 => bool) internal _store;

    // Event emitted when a message id is stored
    event MessageStored(bytes32 indexed id, bytes message);

    // MailBoxClient is used to call into _isLatestDispatched
    constructor(address _mailbox) MailboxClient(_mailbox) {}

    /// @inheritdoc IPostDispatchHook
    function hookType() external pure override returns (uint8) {
        return uint8(IPostDispatchHook.Types.MAP_STORAGE_HOOK);
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
        require(msg.value == 0, "MapStorageHook: no value expected");

        bytes32 id = message.id();

        // ensure the message is not already stored and is the latest mailbox msg
        require(!_store[id], "message already stored");
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
