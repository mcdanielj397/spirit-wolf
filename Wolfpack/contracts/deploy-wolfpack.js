// Wolfpack NFT — Deploy Script (ESM)
// Usage: npx hardhat run deploy-wolfpack.js --network polygonAmoy

import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deploying from: ${deployer.address}`);

  const artist = process.env.ARTIST_ADDRESS;
  const feeRecipient = "0xC8D6AB0928F9A8bAbB77B739401504f3354580cD";
  const signer = deployer.address;

  if (!artist) {
    console.error("Set ARTIST_ADDRESS in .env");
    process.exit(1);
  }

  console.log(`Artist (3% royalty): ${artist}`);
  console.log(`Fee recipient (1%): ${feeRecipient}`);
  console.log(`Signer (allowlist): ${signer}`);

  const Wolfpack = await hre.ethers.getContractFactory("Wolfpack");
  const wolfpack = await Wolfpack.deploy(artist, feeRecipient, signer);
  await wolfpack.waitForDeployment();

  const address = await wolfpack.getAddress();
  console.log(`\nWolfpack deployed to: ${address}`);
  console.log(`View: https://amoy.polygonscan.com/address/${address}`);

  console.log(`\nMinting 10 reserved to artist...`);
  const tx = await wolfpack.ownerMint(artist, 10);
  await tx.wait();
  console.log(`Minted 10 to ${artist}`);
  console.log(`Total supply: ${await wolfpack.totalSupply()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
