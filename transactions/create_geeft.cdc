import NonFungibleToken from "../utilities/NonFungibleToken.cdc"
import Geeft from "../Geeft.cdc"

transaction(ids: {String: [UInt64]}, storagePaths: {String: String}, recipient: Address) {
  prepare(signer: AuthAccount) {
    let preparedNFTs: @{String: [NonFungibleToken.NFT]} <- {}
    for project in ids.keys {
      let batch: @[NonFungibleToken.NFT] <- []
      let collection = signer.borrow<&{NonFungibleToken.Provider}>(from: StoragePath(identifier: storagePaths[project]!)!)!
      for id in ids[project]! {
        batch.append(<- collection.withdraw(withdrawID: id))
      }
      preparedNFTs[project] <-! batch
    }

    Geeft.sendGeeft(nfts: <- preparedNFTs, recipient: recipient)
  }

  execute {

  }
}