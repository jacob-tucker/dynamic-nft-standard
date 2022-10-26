# Dynamic NFT Standard

A Dynamic NFT is one that can be changed after minting. In this standard, a NFT's metadata can be changed by an Administrator.

## When would this be used?

An example use case would be when a project wants to upgrade their holder's NFTs upon certain criteria being met or action having been taken. More specifically, if an Administrator wants to upgrade a user's NFT to be a more powerful one once they have unlocked a powerup in a video game.

## Deploying & Testing Your Own Dynamic NFT Contract

> Follow the below instructions to deploy your own Dynamic NFT Contract on a local emulator.

### Install the Flow CLI

Follow [these steps](https://developers.flow.com/tools/flow-cli/install) to install the Flow CLI.

### Steps to Mint

In Terminal #1: 

```
flow emulator start -v
```

In Terminal #2:

```
flow project deploy
flow transactions send ./transactions/setupAccount.cdc
flow transactions send ./transactions/mintNFT.cdc 0xf8d6e0586b0a20c7 "Weak Weapon" "This is the weakest weapon you can own" "Random CID" {}
```

### View NFTs in Account

In Terminal #2:

```
flow scripts execute ./scripts/getNFTs.cdc 0xf8d6e0586b0a20c7
```

### How to Update Metadata

The account with the `Administrator` resource would use the `transactions/updateNFTMetadata.cdc` transaction to do this. You pass in the NFT's id as well as the current owner of the NFT, and pass in a new name, description, thumbnail, and metadata dictionary. This will automatically update the NFT owned by the current owner with the specific id to that new metadata.

In Terminal #2:

```
flow transactions send ./transactions/updateNFTMetadata.cdc 0xf8d6e0586b0a20c7 [INSERT THE NFT ID FROM "How to Update Metadata" Section] "Strong Weapon" "This weapon is the next strongest weapon after the Weak Weapon." "Random CID" {}
```

Now follow the "How to Update Metadata" section again to see the NFT's updated metadata.