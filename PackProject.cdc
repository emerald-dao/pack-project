import NonFungibleToken from "./utilities/NonFungibleToken.cdc"

pub contract PackProject {

  pub var totalPacks: UInt64
  access(self) var packs: @{Address: [Pack]}

  pub let CollectionPublicPath: PublicPath
  pub let CollectionStoragePath: StoragePath

  pub resource Pack {
    pub var storedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun getIDs(): [UInt64] {
      return self.storedNFTs.keys
    }

    pub fun withdraw(id: UInt64): @NonFungibleToken.NFT {
      let nft <- self.storedNFTs.remove(key: id) ?? panic("This NFT does not exist.")
      return <- nft
    }

    init(nfts: @{UInt64: NonFungibleToken.NFT}) {
      self.storedNFTs <- nfts
      PackProject.totalPacks = PackProject.totalPacks + 1
    }

    destroy() {
      destroy self.storedNFTs
    }
  }

  // If the recipient already has a collection, give it to the collection.
  // If not, give it to the `packs` dictionary so they can claim it at a later point.
  pub fun createPack(nfts: @{UInt64: NonFungibleToken.NFT}, recipient: Address) {
    let pack <- create Pack(nfts: <- nfts)
    if let collection = getAccount(recipient).getCapability(PackProject.CollectionPublicPath).borrow<&Collection{CollectionPublic}>() {
      collection.deposit(pack: <- pack)
      return
    }

    if PackProject.packs[recipient] == nil {
      PackProject.packs[recipient] <-! []
    }
    
    PackProject.packs[recipient]?.append!(<- pack)
  }

  pub resource interface CollectionPublic {
    pub fun deposit(pack: @Pack)
    pub fun getIDs(): [UInt64]
  }

  pub resource Collection: CollectionPublic {
    pub var ownedPacks: @{UInt64: Pack}

    pub fun deposit(pack: @Pack) {
      self.ownedPacks[pack.uuid] <-! pack
    }

    pub fun withdraw(id: UInt64): @Pack {
      let pack <- self.ownedPacks.remove(key: id) ?? panic("This Pack does not exist in this collection.")
      return <- pack
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedPacks.keys
    }

    // Call this to function to get all your packs from the `packs` dictionary
    pub fun claimPacks() {
      if let packsRef = (&PackProject.packs[self.owner!.address] as &[Pack]?) {
        while packsRef.length > 0 {
          let pack <- packsRef.removeFirst()
          self.deposit(pack: <- pack)
        } 
      }
    }

    init() {
      self.ownedPacks <- {}
    }

    destroy() {
      destroy self.ownedPacks
    }
  }

  init() {
    self.CollectionStoragePath = /storage/PackProjectCollection
    self.CollectionPublicPath = /public/PackProjectCollection

    self.totalPacks = 0
    self.packs <- {}
  }

}