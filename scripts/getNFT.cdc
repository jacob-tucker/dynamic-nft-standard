import DynamicNFT from "../DynamicNFT.cdc"

pub fun main(user: Address, id: UInt64): &DynamicNFT.NFT? {
  let collection = getAccount(user).getCapability(DynamicNFT.CollectionPublicPath)
                      .borrow<&DynamicNFT.Collection{DynamicNFT.CollectionPublic}>()
                      ?? panic("User does not have a DynamicNFT Collection set up.")

  return collection.borrowAuthNFT(id: id)
}