import MetadataViews from "../utilities/MetadataViews.cdc"

pub fun main(user: Address): {String: {UInt64: MetadataViews.Display?}} {
  var nfts: {String: {UInt64: MetadataViews.Display?}} = {}
  let acct = getAuthAccount(user)
  let paths: [Paths] = [
    Paths(name: "TopShot", pp: "MomentCollection", sp: "MomentCollection"),
    Paths(name: "Flunks", pp: "FlunksCollection", sp: "FlunksCollection")
  ]

  for path in paths {
    let tempPublicPath: PublicPath = PublicPath(identifier: "Geeft".concat(path.publicPath))!
    acct.link<&{MetadataViews.ResolverCollection}>(tempPublicPath, target: StoragePath(identifier: path.storagePath)!)

    let structs: {UInt64: MetadataViews.Display?} = {}
    if let collection = acct.getCapability(tempPublicPath).borrow<&{MetadataViews.ResolverCollection}>() {
      for id in collection.getIDs() {
        let viewResolver: &{MetadataViews.Resolver} = collection.borrowViewResolver(id: id)
        structs[id] = MetadataViews.getDisplay(viewResolver)
      }
    }

    nfts[path.name] = structs
  }

  return nfts
}

pub struct Paths {
  pub let name: String
  pub let publicPath: String
  pub let storagePath: String

  init(name: String, pp: String, sp: String) {
    self.name = name
    self.publicPath = pp
    self.storagePath = sp
  }
}