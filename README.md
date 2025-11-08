SolLib4Pascal: Solana for Modern Object Pascal [![License](http://img.shields.io/badge/license-MIT-green.svg)](https://github.com/Xor-el/SolLib4Pascal/blob/master/LICENSE)
========================================

# Introduction

⚡ **Bringing Solana to Object Pascal.**

**SolLib** is an Object Pascal SDK for the **Solana blockchain**, designed to integrate seamlessly with the Object Pascal ecosystem.  

Whether you’re a seasoned developer or just getting started, **SolLib** provides clear examples, and powerful APIs that make building on Solana with Object Pascal simple and efficient.


## Features
- JSON RPC API coverage
- Streaming JSON RPC API coverage
- Wallet and accounts
- Keystore
- Transaction decoding/encoding (base64 and wire format)
- Message decoding/encoding (base64 and wire format)
- Instruction decompilation
- Programs
    - Native Programs
      - System Program
    - Loader Programs
      - BPF Loader Program
    - Solana Program Library (SPL)
      - Compute Budget Program
      - Address Lookup Table Program
      - Memo Program
      - Token Program
      - Associated Token Account Program
      - Shared Memory Program


## Supported Compilers
- Delphi 10.4 and Above

## Build Dependencies
- [SimpleBaseLib4Pascal](https://github.com/Xor-el/SimpleBaseLib4Pascal)
- [HashLib4Pascal](https://github.com/Xor-el/HashLib4Pascal)
- [CryptoLib4Pascal](https://github.com/Xor-el/CryptoLib4Pascal)

## Installation

Add the **SolLib** sources and it's dependencies to your compiler search path.

## Quickstart

A minimal example to fetch a balance and send a memo:

```pascal
var
  LRpc: IRpcClient;
  LHttpClient: IHttpApiClient;
  LWallet: IWallet;
  LFrom: IAccount;
  LBlock: IRequestResult<TResponseValue<TLatestBlockHash>>;
  LBalance: IRequestResult<TResponseValue<UInt64>>;
  LTxBytes: TBytes;
  LSignature, LMnemonicWords: string;
  LBuilder: ITransactionBuilder;
  LPriorityFees: IPriorityFeesInformation;
begin
  LHttpClient := THttpApiClient.Create();
  LRpc    := TClientFactory.GetClient(TCluster.MainNet, LHttpClient);

  LMnemonicWords := 'Your Mnemonic Words';
  LWallet := TWallet.Create(LMnemonicWords);
  LFrom   := LWallet.GetAccountByIndex(0);

  // Get balance
  LBalance := LRpc.GetBalance(LFrom.PublicKey.Key);
  if LBalance.WasSuccessful then
    Writeln(Format('Balance: %d lamports', [LBalance.Result.Value]))
  else
    Writeln('Balance: <unavailable>');

  LBlock := LRpc.GetLatestBlockHash;
  if (LBlock = nil) or (not LBlock.WasSuccessful) or (LBlock.Result = nil) then
    raise Exception.Create('Failed to fetch recent blockhash.');

  // Build priority fee information
  LPriorityFees := TPriorityFeesInformation.Create(
    TComputeBudgetProgram.SetComputeUnitLimit(400000), // limit
    TComputeBudgetProgram.SetComputeUnitPrice(100000)  // price (micro-lamports)
  );

  // Build transaction (Send a simple memo transaction)
  LBuilder := TTransactionBuilder.Create;
  LTxBytes :=
    LBuilder
      .SetRecentBlockHash(LBlock.Result.Value.Blockhash)
      .SetFeePayer(LFrom.PublicKey)
      .SetPriorityFeesInformation(LPriorityFees)
      .AddInstruction(TMemoProgram.NewMemo(LFrom.PublicKey, 'Hello from SolLib'))
      .Build(LFrom);

  LSignature := LRpc.SendTransaction(LTxBytes);
  Writeln(Format('Transaction Signature: %s', [LSignature]));
end;
```

## Examples

Samples can be found in the `SolLib.Examples` folder.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Sponsors

* [InstallAware](https://www.installaware.com/)
