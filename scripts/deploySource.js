
//0x73ba674cdB87B367853c6Ab83A8e8FDFBBb3F4df

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;


  const source = await ethers.getContractFactory("SourceGreeter");
  const lock = await source.deploy("0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a","0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1","0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6");

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
