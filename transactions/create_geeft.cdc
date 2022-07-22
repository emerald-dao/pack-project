import NonFungibleToken from "../utilities/NonFungibleToken.cdc"
import Geeft from "../Geeft.cdc"

/* ids
{
  "FLOAT": [1, 2, 3],
  "Flovatar: [1, 2, 3]
}
*/

/* storagePaths
{
  "FLOAT": "FLOATCollectionStoragePath",
  "Flovatar": "FlovatarCollection"
}
*/

transaction(ids: {String: [UInt64]}, storagePaths: {String: String}, recipient: Address) {
  prepare(signer: AuthAccount) {
    let preparedNFTs: @{Type: [NonFungibleToken.NFT]} <- {}
    for project in ids.keys {
      let batch: @[NonFungibleToken.NFT] <- []
      let collection = signer.borrow<&{NonFungibleToken.Provider}>(from: StoragePath(identifier: storagePaths[project]!)!)!
      let cType: Type = collection.getType()
      for id in ids[project]! {
        batch.append(<- collection.withdraw(withdrawID: id))
      }
      preparedNFTs[collection.getType()] <-! batch
    }

    Geeft.sendGeeft(nfts: <- preparedNFTs, recipient: recipient)
  }

  execute {

  }
}