# CLE  for Automated AI content moderation with zkAutomation
#### decentralized moderation of AI generated content that is fully transparent and carried out by zkOracles powered by ora cle and AI oracle, can be further extended to any kind of DAO model for decentralized AI content generation with safeguards for the kind of content generated instead of having a central body censoring in a secret manner like OpenAI/Google

contract address on sepolia - 0x7769A74A69e2c5F1dABa35E972D56Bc341b39477

![Architecture and Development Flow](https://cdn.discordapp.com/attachments/785528427398430780/1221735618082639932/image.png?ex=6613a8f6&is=660133f6&hm=bc15ddcd8df21c7a14ab8fdfb56a456a87f11beb2fa55a346489c4bba8a27072&)

## Usage CLI

> Note: Only `full` image will be processed by zkOracle node. `unsafe` (define `unsafe: true` in the `cle.yaml`) means the CLE is compiled locally and only contains partial computation (so that proving and executing will be faster).

The workflow of local CLE development must follow: `Develop` (code in /src) -> `Compile` (get compiled wasm image) -> `Execute` (get expected output) -> `Prove` (generate input and pre-test for actual proving in zkOracle) -> `Verify` (verify proof on-chain).

To upload and publish your CLE, you should `Upload` (upload code to IPFS), and then `Publish` (register CLE on onchain CLE Registry).

## Commonly used commands

- **compile**: `npx cle compile`
- **exec**: `npx cle exec <block id>`
- **prove**: ` npx cle prove <block id> <expected state> -i|-t|-p`  
- ……

Read more: https://github.com/ora-io/cle-cli#cli
