import DynamicNFT from "../DynamicNFT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"

transaction(
  currentOwner: Address,
  id: UInt64,
  name: String,
  description: String,
  thumbnail: String,
  metadata: {String: AnyStruct}
) {

  let Admin: &DynamicNFT.Administrator

  prepare(signer: AuthAccount) {
    self.Admin = signer.borrow<&DynamicNFT.Administrator>(from: DynamicNFT.MinterStoragePath)
                    ?? panic("This is not the Minter account.")
  }

  execute {
    self.Admin.updateMetadata(
      id: id, 
      currentOwner: currentOwner, 
      name: name, 
      description: description, 
      thumbnail: thumbnail, 
      metadata: metadata
    )
  }
}