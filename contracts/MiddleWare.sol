// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./market/IMarket.sol";
import "./IComplexUniOwnNFT.sol";

interface IUniOwnNft is IComplexUniOwnNFT, IERC721Metadata {}

contract MiddleWare {
    struct UniOwnNftMarketInfo {
        uint256 originalNftId;
        uint128 orderPricePerDay;
        uint64 startTime;
        uint64 endTime;
        uint32 orderCreateTime;
        uint32 orderMinDuration;
        uint32 orderMaxEndTime;
        uint32 orderFee; //   ratio = fee / 1e5 , orderFee = 1000 means 1%
        uint8 orderType; // 0: Public, 1: Private, 2: Event_Private
        bool orderIsValid;
        address originalNftAddress;
        address owner;
        address user;
        address orderPrivateRenter;
        address orderPaymentToken;
    }

    function getNftOwnerAndUser(
        address originalNftAddr,
        uint256 orginalNftId,
        address uniOwnNftAddr
    ) public view returns (address owner, address user) {
        IBaseUniOwnNFT uniOwnNft = IBaseUniOwnNFT(uniOwnNftAddr);
        IERC721Metadata oNft = IERC721Metadata(originalNftAddr);

        try oNft.ownerOf(orginalNftId) returns (address ownerAddr) {
            owner = ownerAddr;
        } catch {}

        try uniOwnNft.getUser(orginalNftId) returns (address userAddr) {
            user = userAddr;
        } catch {}
    }

    function getNftOwner(address nftAddr, uint256 nftId)
        public
        view
        returns (address owner)
    {
        IERC721Metadata nft = IERC721Metadata(nftAddr);
        try nft.ownerOf(nftId) returns (address ownerAddr) {
            owner = ownerAddr;
        } catch {}
    }

    function getNftOwnerAndTokenURI(address nftAddr, uint256 nftId)
        public
        view
        returns (address owner, string memory uri)
    {
        IERC721Metadata nft = IERC721Metadata(nftAddr);
        try nft.ownerOf(nftId) returns (address ownerAddr) {
            owner = ownerAddr;
        } catch {}

        try nft.tokenURI(nftId) returns (string memory tokenURI) {
            uri = tokenURI;
        } catch {}
    }

    function getUniOwnNftMarketInfo(
        address nftAddr,
        uint256 nftId,
        address marketAddr
    ) public view returns (UniOwnNftMarketInfo memory UniOwnNFTInfo) {
        IUniOwnNft uniOwnNft = IUniOwnNft(nftAddr);
        IMarket market = IMarket(marketAddr);

        UniOwnNFTInfo.originalNftAddress = uniOwnNft.getOriginalNftAddress();
        UniOwnNFTInfo.orderFee =
            uint32(market.getFee()) +
            uint32(uniOwnNft.getRoyaltyFee());

        if (uniOwnNft.exists(nftId)) {
            (
                uint256 oid,
                ,
                uint64[] memory starts,
                uint64[] memory ends,

            ) = uniOwnNft.getUniOwnNftInfo(nftId);

            UniOwnNFTInfo.owner = uniOwnNft.ownerOf(nftId);
            UniOwnNFTInfo.originalNftId = oid;
            UniOwnNFTInfo.user = uniOwnNft.getUser(oid);
            UniOwnNFTInfo.startTime = starts[0];
            UniOwnNFTInfo.endTime = ends[0];
            UniOwnNFTInfo.orderIsValid = market.isLendOrderValid(nftAddr, nftId);
            if (UniOwnNFTInfo.orderIsValid) {
                IMarket.Lending memory order = market.getLendOrder(
                    nftAddr,
                    nftId
                );
                IMarket.PaymentNormal memory pNormal = market.getPaymentNormal(
                    nftAddr,
                    nftId
                );
                if (
                    order.orderType == IMarket.OrderType.Private ||
                    order.orderType == IMarket.OrderType.Event_Private
                ) {
                    UniOwnNFTInfo.orderPrivateRenter = market
                        .getRenterOfPrivateLendOrder(nftAddr, nftId);
                }
                UniOwnNFTInfo.orderType = uint8(order.orderType);
                UniOwnNFTInfo.orderMinDuration = uint32(order.minDuration);
                UniOwnNFTInfo.orderMaxEndTime = uint32(order.maxEndTime);
                UniOwnNFTInfo.orderCreateTime = uint32(order.createTime);
                UniOwnNFTInfo.orderPricePerDay = uint128(pNormal.pricePerDay);
                UniOwnNFTInfo.orderPaymentToken = pNormal.token;
            }
        }
    }

    function batchIsApprovedForAll(address owner, address[] calldata operators, address[] calldata erc721Array) external view returns (bool[] memory results) {
        results = new bool[](erc721Array.length);
        for(uint i = 0; i < erc721Array.length; i++) {
            results[i] = IERC721(erc721Array[i]).isApprovedForAll(owner, operators[i]);
        }
    }

    function batchGetUniOwnNftIdByONftId(address[] calldata uniOwnNftAddressArray, uint256[] calldata oNftIdArray) external view returns (uint256[] memory uniOwnNftIdArray) {
        require(uniOwnNftAddressArray.length == oNftIdArray.length, "invalid input data");
        uniOwnNftIdArray = new uint256[](uniOwnNftAddressArray.length);
        for(uint i = 0; i < uniOwnNftAddressArray.length; i++) {
            uniOwnNftIdArray[i] = IUniOwnNft(uniOwnNftAddressArray[i]).getVNftId(oNftIdArray[i]);
        }
    }

}
