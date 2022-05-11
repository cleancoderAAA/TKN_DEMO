async function main() {
    const TKNDEMO = await ethers.getContractFactory("TKN")
  
    // Start deployment, returning a promise that resolves to a contract object
    const _TKNDEMO = await TKNDEMO.deploy()
    console.log("Contract deployed to address:", _TKNDEMO.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  