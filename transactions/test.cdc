import NonFungibleToken from "../utilities/NonFungibleToken.cdc"
import Geeft from "../Geeft.cdc"

transaction() {
  prepare(signer: AuthAccount) {
    
    let collection = signer.borrow<&{NonFungibleToken.Provider}>(from: StoragePath(identifier: "MomentCollection")!)!
    let cType: Type = collection.getType()
    log(cType)
  }

  execute {

  }
}