
//0x73ba674cdB87B367853c6Ab83A8e8FDFBBb3F4df

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;


  const source = await ethers.getContractFactory("SourceGreeter");
  const lock = await source.deploy("0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a", "0xeDb95D8037f769B72AAab41deeC92903A98C9E16");

  await lock.waitForDeployment();

  console.log(
    ` deployed to ${lock.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
