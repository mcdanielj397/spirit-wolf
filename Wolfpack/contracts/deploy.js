const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("\n═══════════════════════════════════════");
    console.log("  NFT FORGE — Deploy Script");
    console.log("═══════════════════════════════════════");
    console.log("  Contract : WolfPack");
    console.log("  Standard : ERC721A");
    console.log("  Deployer :", deployer.address);
    console.log("  Balance  :", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");
    console.log("═══════════════════════════════════════\n");

    const Contract = await ethers.getContractFactory("WolfPack");
    console.log("Deploying...");

    const contract = await Contract.deploy();
    await contract.waitForDeployment();

    const address = await contract.getAddress();
    console.log("✅ Deployed to:", address);

    // Post-deploy setup
    console.log("\nPost-deploy configuration:");
    // Enable public mint (uncomment when ready)
    // await contract.setPublicMint(true);
    // console.log("  ✓ Public mint enabled");

    console.log("\n── Verification ──");
    console.log("Run: npx hardhat verify --network <network>", address);
    console.log("\n── Next Steps ──");
    console.log("1. Verify contract on Etherscan");
    console.log("2. Upload metadata to IPFS");
    console.log("3. Call setBaseURI() with your IPFS CID");
    console.log("4. Enable public mint via setPublicMint(true)");
    console.log("5. Test on testnet before mainnet");

    // Save deployment info
    const fs = require("fs");
    const deployInfo = {
        contractName: "WolfPack",
        standard: "erc721a",
        address: address,
        deployer: deployer.address,
        deployedAt: new Date().toISOString(),
        network: (await ethers.provider.getNetwork()).name
    };
    fs.writeFileSync("deployment.json", JSON.stringify(deployInfo, null, 2));
    console.log("\n✅ deployment.json saved");
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
