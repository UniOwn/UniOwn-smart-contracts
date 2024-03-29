// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ComplexUniOwnNFT.sol";
import "./CheckInMgr.sol";
import "./DoubleSVG.sol";

abstract contract VipUniOwnNft is ComplexUniOwnNFT, CheckInMgr {
    function mintVNft(uint256 oid)
        public
        virtual
        override
        nonReentrant
        returns (uint256 tid)
    {
        require(oid2vid[oid] == 0, "already wraped");
        require(
            onlyApprovedOrOwner(msg.sender, oNftAddress, oid),
            "only approved or owner"
        );
        address lastOwner = ERC721(oNftAddress).ownerOf(oid);
        ERC721(oNftAddress).safeTransferFrom(lastOwner, address(this), oid);
        tid = mintUniOwnNft(
            lastOwner,
            oid,
            uint64(block.timestamp),
            type(uint64).max
        );
        oid2vid[oid] = tid;
        setUser(oid, lastOwner, type(uint64).max);
    }

    function checkIn(
        address to,
        uint256 tokenId,
        uint256 durationId
    ) public virtual override {
        BaseUniOwnNft.checkIn(to, tokenId, durationId);
        Duration storage duration = durationMapping[durationId];
        setUser(uniOwnNFTMapping[tokenId].oid, to, duration.end);
    }
}
