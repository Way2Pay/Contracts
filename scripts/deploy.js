async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;


  const dest = await ethers.getContractFactory("DestinationGreeter");
  const lock = await dest.deploy("0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1","0xE592427A0AEce92De3Edee1F18E0157C05861564");

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