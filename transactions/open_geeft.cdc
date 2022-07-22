import NonFungibleToken from "../utilities/NonFungibleToken.cdc"
import Geeft from "../Geeft.cdc"

transaction(id: UInt64) {
  prepare(signer: AuthAccount) {
    let GeeftCollection = signer.borrow<&Geeft.Collection>(from: Geeft.CollectionStoragePath)
                            ?? panic("The signer does not have a Geeft Collection set up.")
    
    let nfts: @{Type: [NonFungibleToken.NFT]} <- GeeftCollection.openGeeft(geeftId: id)

    // Collection 1
    if signer.borrow<&Geeft.Collection>(from: Geeft.CollectionStoragePath) == nil {
        signer.save(<- Geeft.createEmptyCollection(), to: Geeft.CollectionStoragePath)
    }
    if signer.getCapability<&Geeft.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Geeft.CollectionPublic}>(Geeft.CollectionPublicPath).borrow() == nil {
        signer.unlink(Geeft.CollectionPublicPath)
        signer.link<&Geeft.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Geeft.CollectionPublic}>(Geeft.CollectionPublicPath, target: Geeft.CollectionStoragePath)
    }
    let collection1 = signer.borrow<&Geeft.Collection>(from: Geeft.CollectionStoragePath)!
    let collection1Type: Type = collection1.getType()
    let collection1NFTs: @[NonFungibleToken.NFT] <- nfts.remove(key: collection1Type) ?? panic("Collection 1 does not exist in here.")
    var i1 = 0
    while i1 < collection1NFTs.length {
      collection1.deposit(token: <- collection1NFTs.removeFirst())
      i1 = i1 + 1
    }
    assert(collection1NFTs.length == 0, message: "Did not empty out Collection 1")
    destroy collection1NFTs

    // Collection 2
    if signer.borrow<&Geeft.Collection>(from: Geeft.CollectionStoragePath) == nil {
        signer.save(<- Geeft.createEmptyCollection(), to: Geeft.CollectionStoragePath)
    }
    if signer.getCapability<&Geeft.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Geeft.CollectionPublic}>(Geeft.CollectionPublicPath).borrow() == nil {
        signer.unlink(Geeft.CollectionPublicPath)
        signer.link<&Geeft.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Geeft.CollectionPublic}>(Geeft.CollectionPublicPath, target: Geeft.CollectionStoragePath)
    }
    let collection2 = signer.borrow<&Geeft.Collection>(from: Geeft.CollectionStoragePath)!
    let collection2Type: Type = collection2.getType()
    let collection2NFTs: @[NonFungibleToken.NFT] <- nfts.remove(key: collection2Type) ?? panic("Collection 2 does not exist in here.")
    var i2 = 0
    while i2 < collection2NFTs.length {
      collection1.deposit(token: <- collection2NFTs.removeFirst())
      i2 = i2 + 1
    }
    assert(collection2NFTs.length == 0, message: "Did not empty out Collection 2")
    destroy collection2NFTs

    assert(nfts.keys.length == 0, message: "There are still NFTs left in the Geeft.")
    destroy nfts
  }

  execute {

  }
}