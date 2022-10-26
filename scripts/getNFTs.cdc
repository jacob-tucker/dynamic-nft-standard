import DynamicNFT from "../DynamicNFT.cdc"

pub fun main(user: Address): [&DynamicNFT.NFT?] {
  let answer: [&DynamicNFT.NFT?] = []
  let collection = getAccount(user).getCapability(DynamicNFT.CollectionPublicPath)
                      .borrow<&DynamicNFT.Collection{DynamicNFT.CollectionPublic}>()
                      ?? panic("User does not have a DynamicNFT Collection set up.")
  
  for id in collection.getIDs() {
    answer.append(collection.borrowAuthNFT(id: id))
  }

  return answer
}