# Bridge contract to swap Aztec's shielded assets on Uniswap (Ethereum mainnet).

## Information

 `src/UniswapBridge.sol` is the bridge contract, deployed on a mainnet fork by  
  _0x28C6c06298d514Db089934071355E5743bf21d60_ for tests purposes
(see `.dapprc`).  
  
  `src/Uniswap.t.sol` is the test contract. The address of the `rollupProcessor` is set to the  
  address of this contract, once again for tests purposes.
  
The purpose of the bridge contrat is to be able to receive an `inputAssetA` (ERC20 tokens or  
ETH) from the `rollupProcessor`, execute the intended swap on Uniswap and send the  
`outputAssetA` to the `rollupProcessor`.

## Local deployment
### 
* Install Nix :

```
# user must be in sudoers
$ curl -L https://nixos.org/nix/install | sh
# Run this or login again to use Nix
$ . "$HOME/.nix-profile/etc/profile.d/nix.sh"
```
_NOTE: Run the installer and dapptools under rosetta 2 if you're on M1 Mac._
* Then install dapptools : 
```
$ curl https://dapp.tools/install | sh
```  
(See the [dapptools installation guide](https://github.com/dapphub/dapptools#installation) for further installation tips.)
* Clone this repository, `cd` into it, in the `.env` set "ETH_RPC_URL" to a valid rpc url  
connected to Ethereum mainnet. You can use Alchemy or Infura for this.
* Once your rpc url set, while in the root directory of the project, run:
```
$ dapp test
```
This should be the output (logs depending on the price of `outputAssetA` at the time of testing):
```
dapp-test: rpc block: latest
Running 5 tests for src/UniswapBridge.t.sol:UniswapBridgeTest
[PASS] test_convert_tokensForEth() (gas: 183139)
[PASS] test_convert_tokensForTokens_weth_paired() (gas: 243324)
[PASS] test_convert_ethForTokens() (gas: 135292)
[PASS] testFail_convert_tokensForTokens_invalid_pair() (gas: 47879)
[PASS] test_convert_tokensForTokens_paired() (gas: 160969)  

  Success: test_convert_tokensForTokens_paired
  
  amount of DAI swapped: 10000
  amount of USDT received: 9965  
  
  Success: testFail_convert_tokensForTokens_invalid_pair  

  Success: test_convert_ethForTokens
  
  amount of ETH swapped: 1
  amount of DAI received: 4014  
  
  Success: test_convert_tokensForTokens_weth_paired
  
  amount of DAI swapped: 10000
  approximate amount of FLX received: 15  
  
  Success: test_convert_tokensForEth
  
  amount of DAI swapped: 10000
  approximate amount of ETH received: 2
```


