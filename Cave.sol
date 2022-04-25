// SPDX-License-Identifier: MIT


pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Cave is ERC721Enumerable, Ownable {
    string public baseURI;
    string public baseExtension = ".json";
    string public notRevealedUri;
    
    uint256 public constant maxCaveSupply = 101;
    
    bytes32 public MerkleRoot;

    mapping(address => uint256) public Minted;

    bool public revealed = false;
    bool public salelive = false;
    bool public nftLocked = true;


    constructor(
        string memory _BaseURI,
        string memory _NotRevealedUri
    ) ERC721("Cavemen", "CAVE") {
        setBaseURI(_BaseURI);
        setNotRevealedURI(_NotRevealedUri);
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setLockState(bool  _nftLocked) public onlyOwner{
        nftLocked = _nftLocked;
    }


    function setBaseExtension(string calldata _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMerkleRoot(bytes32 _MerkleRoot)
        external
        onlyOwner
    {
        MerkleRoot = _MerkleRoot;
    }

    function _Verify(bytes32 leaf, bytes32[] memory proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, MerkleRoot, leaf);
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");


        if (revealed == false) {
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(tokenId),
                        baseExtension
                    )
                )
                : "";
    }

    function setSaleState(bool _state) public onlyOwner {
        salelive = _state;
    }

    function reveal(bool _state) public onlyOwner {
        revealed = _state;
    }


    function _beforeTokenTransfer(address from,address to,uint256 tokenId)
        internal
        virtual
        override(ERC721){
            super._beforeTokenTransfer(from, to, tokenId);
            require(from == address(0) || !nftLocked,"Transfer is not allowed");
        }

    function mint(uint256 _mintAmount, uint256 allowance, bytes32[] calldata proof) public {
        uint256 totalSupply = _owners.length;
        bytes32 Leaf = keccak256(abi.encodePacked(msg.sender, allowance));
        require(_Verify(Leaf, proof), "Invalid Proof Supplied.");
        require(
            Minted[msg.sender] + _mintAmount <= allowance,
            "Exceeds white list mint Allowance"
        );
        require(salelive, "minting is not currently available"); //ensure Public Mint is on
        require(
            totalSupply + _mintAmount < maxCaveSupply,
            "Sorry, this would exceed maximum Cave mints"
        ); //require that the max number has not been exceeded
        for (uint256 i; i < _mintAmount; i++) {
            _mint(_msgSender(), totalSupply + i);
        }
        Minted[msg.sender] += _mintAmount;
    }


    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function burn(uint256 tokenId) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Not approved to burn."
        );
        _burn(tokenId);
    }

    function batchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIds
    ) public {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            transferFrom(_from, _to, _tokenIds[i]);
        }
    }

    function batchSafeTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIds,
        bytes memory data_
    ) public {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            safeTransferFrom(_from, _to, _tokenIds[i], data_);
        }
    }

    function isOwnerOf(address account, uint256[] calldata _tokenIds)
        external
        view
        returns (bool)
    {
        for (uint256 i; i < _tokenIds.length; ++i) {
            if (_owners[_tokenIds[i]] != account) return false;
        }

        return true;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }


    function _mint(address to, uint256 tokenId) internal virtual override {
        _owners.push(to);
        emit Transfer(address(0), to, tokenId);
    }
}

