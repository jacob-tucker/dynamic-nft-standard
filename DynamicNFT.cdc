/* 
*
*  This is an example of how to implement Dynamic NFTs on Flow.
*  A Dynamic NFT is one that can be changed after minting. In 
*  this contract, a NFT's metadata can be changed by an Administrator.
*   
*/

import NonFungibleToken from "./utility/NonFungibleToken.cdc"
import MetadataViews from "./utility/MetadataViews.cdc"

pub contract DynamicNFT: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, by: Address, name: String, description: String, thumbnail: String)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub struct NFTMetadata {
      pub let name: String
      pub let description: String
      pub let thumbnail: String
      access(self) let metadata: {String: AnyStruct}

      init(
        name: String,
        description: String,
        thumbnail: String,
        metadata: {String: AnyStruct}
      ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.metadata = metadata
      }
    }

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let sequence: UInt64
        pub var metadata: NFTMetadata
    
        pub fun getViews(): [Type] {
          return [
            Type<MetadataViews.Display>()
          ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
          let template: NFTMetadata = self.getMetadata()
          switch view {
            case Type<MetadataViews.Display>():
              return MetadataViews.Display(
                name: template.name,
                description: template.description,
                thumbnail: MetadataViews.HTTPFile(
                  url: template.thumbnail
                )
              )
          }
          return nil
        }

        pub fun getMetadata(): NFTMetadata {
          return self.metadata
        }

        access(contract) fun updateMetadata(newMetadata: NFTMetadata) {
          self.metadata = newMetadata
        }

        init(metadata: NFTMetadata) {
          self.id = self.uuid
          self.sequence = DynamicNFT.totalSupply
          self.metadata = metadata
          DynamicNFT.totalSupply = DynamicNFT.totalSupply + 1
        }
    }

    pub resource interface CollectionPublic {
      pub fun deposit(token: @NonFungibleToken.NFT)
      pub fun getIDs(): [UInt64]
      pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
      pub fun borrowAuthNFT(id: UInt64): &DynamicNFT.NFT? {
        post {
            (result == nil) || (result?.id == id):
                "Cannot borrow DynamicNFT reference: the ID of the returned reference is incorrect"
        }
      }
    }

    pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
      pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

      pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
        let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
        emit Withdraw(id: token.id, from: self.owner?.address)
        return <- token
      }

      pub fun deposit(token: @NonFungibleToken.NFT) {
        let token <- token as! @DynamicNFT.NFT
        emit Deposit(id: token.id, to: self.owner?.address)
        self.ownedNFTs[token.id] <-! token
      }

      pub fun getIDs(): [UInt64] {
        return self.ownedNFTs.keys
      }

      pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
        return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
      }

      pub fun borrowAuthNFT(id: UInt64): &DynamicNFT.NFT? {
        if self.ownedNFTs[id] != nil {
          let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
          return ref as! &DynamicNFT.NFT
        }
        return nil
      }

      pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
        let token = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        let nft = token as! &DynamicNFT.NFT
        return nft as &AnyResource{MetadataViews.Resolver}
      }

      init () {
        self.ownedNFTs <- {}
      }

      destroy() {
          destroy self.ownedNFTs
      }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
      return <- create Collection()
    }

    pub resource Administrator {
      pub fun mintNFT(
        recipient: &Collection{NonFungibleToken.Receiver}, 
        name: String, 
        description: String, 
        thumbnail: String, 
        metadata: {String: AnyStruct}
      ) {
        let nft <- create NFT(metadata: NFTMetadata(name: name, description: description, thumbnail: thumbnail, metadata: metadata))
        emit Minted(id: nft.id, by: self.owner!.address, name: name, description: description, thumbnail: thumbnail)
        recipient.deposit(token: <- nft)
      }

      pub fun updateMetadata(
        id: UInt64, 
        currentOwner: Address, 
        name: String, 
        description: String, 
        thumbnail: String, 
        metadata: {String: AnyStruct}
      ) {
        let newMetadata = NFTMetadata(name: name, description: description, thumbnail: thumbnail, metadata: metadata)
        let ownerCollection = getAccount(currentOwner).getCapability(DynamicNFT.CollectionPublicPath)
                                .borrow<&Collection{CollectionPublic}>()
                                ?? panic("This person does not have a DynamicNFT Collection set up properly.")
        let nftRef = ownerCollection.borrowAuthNFT(id: id) ?? panic("This account does not own an NFT with this id.")
        nftRef.updateMetadata(newMetadata: newMetadata)
      }
    }

    init() {
        self.totalSupply = 0

        self.CollectionStoragePath = /storage/DynamicNFTCollection
        self.CollectionPublicPath = /public/DynamicNFTCollection
        self.MinterStoragePath = /storage/DynamicNFTMinter

        self.account.save(<- create Administrator(), to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}
 