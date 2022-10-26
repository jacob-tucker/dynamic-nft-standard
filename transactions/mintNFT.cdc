import DynamicNFT from "../DynamicNFT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"

transaction(
  recipient: Address,
  name: String,
  description: String,
  thumbnail: String,
  metadata: {String: AnyStruct}
) {

  let Minter: &DynamicNFT.Administrator
  let Recipient: &DynamicNFT.Collection{NonFungibleToken.Receiver}

  prepare(signer: AuthAccount) {
    self.Minter = signer.borrow<&DynamicNFT.Administrator>(from: DynamicNFT.MinterStoragePath)
                    ?? panic("This is not the Minter account.")
  
    self.Recipient = getAccount(recipient).getCapability(DynamicNFT.CollectionPublicPath)
                      .borrow<&DynamicNFT.Collection{NonFungibleToken.Receiver}>()
                      ?? panic("This account does not have a collection set up.")
  }

  execute {
    self.Minter.mintNFT(
      recipient: self.Recipient,
      name: name,
      description: description,
      thumbnail: thumbnail,
      metadata: metadata
    )
  }
}