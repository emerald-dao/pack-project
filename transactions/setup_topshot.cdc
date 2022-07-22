import NonFungibleToken from "../utilities/NonFungibleToken.cdc"
import MetadataViews from "../utilities/MetadataViews.cdc"
import TopShot from "../projects/TopShot/TopShot.cdc"

transaction() {
  prepare(signer: AuthAccount) {
    // signer.save(<- TopShot.createEmptyCollection(), to: /storage/MomentCollection)
    // signer.link<&TopShot.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(/public/MomentCollection, target: /storage/MomentCollection)

    let collection = signer.getCapability(/public/MomentCollection)
                        .borrow<&{MetadataViews.ResolverCollection}>()!
    let cType: Type = collection.getType()
    log(cType)
    log(cType == Type<@TopShot.Collection>())
  }

  execute {

  }
}