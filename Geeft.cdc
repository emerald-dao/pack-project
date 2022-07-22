import NonFungibleToken from "./utilities/NonFungibleToken.cdc"

pub contract Geeft: NonFungibleToken {

  pub var totalSupply: UInt64

  pub let CollectionPublicPath: PublicPath
  pub let CollectionStoragePath: StoragePath

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // This represents a Geeft
  pub resource NFT: NonFungibleToken.INFT {
    pub let id: UInt64
    // Maps project name (ex. "FLOAT") -> array of NFTs
    pub var storedNFTs: @{String: [NonFungibleToken.NFT]}

    pub fun getProjects(): [String] {
      return self.storedNFTs.keys
    }

    pub fun open(): @{String: [NonFungibleToken.NFT]} {
      var storedNFTs: @{String: [NonFungibleToken.NFT]} <- {}
      self.storedNFTs <-> storedNFTs
      return <- storedNFTs
    }

    init(nfts: @{String: [NonFungibleToken.NFT]}) {
      self.id = self.uuid
      self.storedNFTs <- nfts
      Geeft.totalSupply = Geeft.totalSupply + 1
    }

    destroy() {
      pre {
        self.storedNFTs.keys.length == 0: "There are still NFTs left in this Geeft."
      }
      destroy self.storedNFTs
    }
  }

  pub fun sendGeeft(nfts: @{String: [NonFungibleToken.NFT]}, recipient: Address) {
    let geeft <- create NFT(nfts: <- nfts)
    let collection = getAccount(recipient).getCapability(Geeft.CollectionPublicPath)
                        .borrow<&Collection{NonFungibleToken.Receiver}>()
                        ?? panic("The recipient does not have a Geeft Collection")
    collection.deposit(token: <- geeft)
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun getProjectsInGeeft(geeftId: UInt64): [String]
  }

  pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let geeft <- token as! @NFT
      emit Deposit(id: geeft.id, to: self.owner?.address)
      self.ownedNFTs[geeft.id] <-! geeft
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let geeft <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This Geeft does not exist in this collection.")
      emit Withdraw(id: geeft.id, from: self.owner?.address)
      return <- geeft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    } 

    pub fun openGeeft(geeftId: UInt64): @{String: [NonFungibleToken.NFT]} {
      let geeft <- self.withdraw(withdrawID: geeftId) as! @NFT
      let nfts <- geeft.open()
      destroy geeft
      return <- nfts
    }

    pub fun getProjectsInGeeft(geeftId: UInt64): [String] {
      let nft = (&self.ownedNFTs[geeftId] as auth &NonFungibleToken.NFT?)!
      let geeft = nft as! &NFT
      return geeft.getProjects()
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  init() {
    self.CollectionStoragePath = /storage/GeeftCollection
    self.CollectionPublicPath = /public/GeeftCollection

    self.totalSupply = 0

    emit ContractInitialized()
  }

}