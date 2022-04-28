const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const tokens = require("./tokens.json");

async function main() {
  let tab = [];
  tokens.map((token) => {
    tab.push(token.address);
  });
  const leaves = tab.map((address) => keccak256(address));
  const tree = new MerkleTree(leaves, keccak256, { sort: true });
  const root = tree.getHexRoot();
  console.log("root : " + root);

  console.log("\nAdmin 0x7B0dc23E87febF1D053E7Df9aF4cce30F21fAe9C:\n" + tree.getHexProof(keccak256("0x7B0dc23E87febF1D053E7Df9aF4cce30F21fAe9C")));
  console.log("\nCreator 0x8531fEaAcD66599102adf9C5f701E6C490f44f1C:\n" + tree.getHexProof(keccak256("0x8531fEaAcD66599102adf9C5f701E6C490f44f1C")));
  console.log("\nConsumer 0xAb1fdD3F84b2019BEF47939E66fb6194532f9640:\n" + tree.getHexProof(keccak256("0xAb1fdD3F84b2019BEF47939E66fb6194532f9640")));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
