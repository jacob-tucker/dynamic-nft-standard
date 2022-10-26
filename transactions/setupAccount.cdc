import NonFungibleToken from "../utility/NonFungibleToken.cdc"
import DynamicNFT from "../DynamicNFT.cdc"
import MetadataViews from "../utility/MetadataViews.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        if signer.borrow<&DynamicNFT.Collection>(from: DynamicNFT.CollectionStoragePath) == nil {
            signer.save(<- DynamicNFT.createEmptyCollection(), to: DynamicNFT.CollectionStoragePath)

            signer.link<&DynamicNFT.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, DynamicNFT.CollectionPublic, MetadataViews.ResolverCollection}>(
                DynamicNFT.CollectionPublicPath,
                target: DynamicNFT.CollectionStoragePath
            )
        }
    }
}