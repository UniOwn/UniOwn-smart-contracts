// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../VipUniOwnNFT.sol";
import "./IDCL.sol";
import "./DCL.sol";

contract DclUniOwnNFT is VipUniOwnNFT {
    function getUser(uint256 originalNftId)
        public
        view
        virtual
        override
        returns (address)
    {
        return DCL(oNftAddress).updateOperator(originalNftId);
    }

    function setUser(
        uint256 oid,
        address to,
        uint64 expiredAt
    ) internal virtual override {
        super.setUser(oid, to, expiredAt);
        IDCL(oNftAddress).setUpdateOperator(oid, to);
    }
}
