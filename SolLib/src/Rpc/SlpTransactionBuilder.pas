{ ****************************************************************************** }
{ *                            SolLib Library                                  * }
{ *               Copyright (c) 2025 Ugochukwu Mmaduekwe                       * }
{ *                Github Repository <https://github.com/Xor-el>               * }
{ *                                                                            * }
{ *   Distributed under the MIT software license, see the accompanying file    * }
{ *   LICENSE or visit http://www.opensource.org/licenses/mit-license.php.     * }
{ *                                                                            * }
{ *                            Acknowledgements:                               * }
{ *                                                                            * }
{ *     Thanks to InstallAware (https://www.installaware.com/) for sponsoring  * }
{ *                   the development of this library                          * }
{ ****************************************************************************** }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit SlpTransactionBuilder;

{$I ..\Include\SolLib.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  SlpMessageBuilder,
  SlpMessageDomain,
  SlpAccount,
  SlpTransactionInstruction,
  SlpPublicKey,
  SlpTransactionDomain,
  SlpShortVectorEncoding,
  SlpDataEncoders;

type
  /// <summary>
  /// Defines the interface for transaction builders.
  /// </summary>
  ITransactionBuilder = interface
    ['{A49B5B03-39F5-4B9A-93A5-9DA205B7D902}']

    /// <summary>
    /// Serializes the message into a byte array.
    /// </summary>
    function Serialize: TBytes;

    /// <summary>
    /// Adds a signature to the current transaction.
    /// </summary>
    /// <param name="ASignature">The signature (bytes).</param>
    function AddSignature(const ASignature: TBytes): ITransactionBuilder; overload;

    /// <summary>
    /// Adds a signature to the current transaction.
    /// </summary>
    /// <param name="ASignature">The signature (Base58 string).</param>
    function AddSignature(const ASignature: string): ITransactionBuilder; overload;

    /// <summary>
    /// Sets the recent block hash for the transaction.
    /// </summary>
    /// <param name="ARecentBlockHash">The recent block hash as a base58 encoded string.</param>
    /// <returns>The transaction builder, so instruction addition can be chained.</returns>
    function SetRecentBlockHash(const ARecentBlockHash: string): ITransactionBuilder;

    /// <summary>
    /// Sets the nonce information for the transaction.
    /// <remarks>Whenever this is set, it is used instead of the blockhash.</remarks>
    /// </summary>
    /// <param name="ANonceInfo">The nonce information object to use.</param>
    /// <returns>The transaction builder, so instruction addition can be chained.</returns>
    function SetNonceInformation(const ANonceInfo: INonceInformation): ITransactionBuilder;

    /// <summary>
    /// Sets the priority fees information for the transaction.
    /// </summary>
    /// <param name="APriorityFeesInfo">The priority fees information object to use.</param>
    /// <returns>The transaction builder, so instruction addition can be chained.</returns>
    function SetPriorityFeesInformation(const APriorityFeesInfo: IPriorityFeesInformation): ITransactionBuilder;

    /// <summary>
    /// Sets the fee payer for the transaction.
    /// </summary>
    /// <param name="APublicKey">The public key of the account that will pay the transaction fee.</param>
    /// <returns>The transaction builder, so instruction addition can be chained.</returns>
    function SetFeePayer(const APublicKey: IPublicKey): ITransactionBuilder;

    /// <summary>
    /// Adds a new instruction to the transaction.
    /// </summary>
    /// <param name="AInstruction">The instruction to add.</param>
    /// <returns>The transaction builder, so instruction addition can be chained.</returns>
    function AddInstruction(const AInstruction: ITransactionInstruction): ITransactionBuilder;

    /// <summary>
    /// Compiles the transaction's message into wire format, ready to be signed.
    /// </summary>
    /// <returns>The serialized message.</returns>
    function CompileMessage: TBytes;

    /// <summary>
    /// Signs the transaction's message with the passed signer and adds it to the transaction, serializing it.
    /// </summary>
    /// <param name="ASigner">The signer.</param>
    /// <returns>The serialized transaction.</returns>
    function Build(const ASigner: IAccount): TBytes; overload;

    /// <summary>
    /// Signs the transaction's message with the passed list of signers and adds them to the transaction, serializing it.
    /// </summary>
    /// <param name="ASigners">The list of signers.</param>
    /// <returns>The serialized transaction.</returns>
    function Build(const ASigners: TList<IAccount>): TBytes; overload;
  end;

  /// <summary>
  /// Defines the interface for versioned (v0) transaction builders.
  /// </summary>
  IVersionedTransactionBuilder = interface
    ['{B3C7B9E5-1D19-4605-8E1B-4D5C2E8E2E92}']

    /// <summary>Serializes the transaction (signatures + versioned message) into a byte array.</summary>
    function Serialize: TBytes;

    /// <summary>Add a signature to the current transaction (bytes, will be Base58-encoded internally).</summary>
    function AddSignature(const ASignature: TBytes): IVersionedTransactionBuilder; overload;

    /// <summary>Add a signature to the current transaction (already Base58-encoded).</summary>
    function AddSignature(const ASignature: string): IVersionedTransactionBuilder; overload;

    /// <summary>Sets the recent block hash for the transaction.</summary>
    function SetRecentBlockHash(const ARecentBlockHash: string): IVersionedTransactionBuilder;

    /// <summary>Sets the durable nonce information (overrides blockhash if present).</summary>
    function SetNonceInformation(const ANonceInfo: INonceInformation): IVersionedTransactionBuilder;

    /// <summary>Sets the fee payer.</summary>
    function SetFeePayer(const APublicKey: IPublicKey): IVersionedTransactionBuilder;

    /// <summary>Add a v0 instruction to the message.</summary>
    function AddInstruction(const AInstruction: ITransactionInstruction): IVersionedTransactionBuilder;

    /// <summary>Add a single address table lookup to the message.</summary>
    function AddAddressTableLookup(const ALookup: IMessageAddressTableLookup): IVersionedTransactionBuilder;

    /// <summary>Add multiple address table lookups to the message.</summary>
    function AddAddressTableLookups(const ALookups: TList<IMessageAddressTableLookup>): IVersionedTransactionBuilder;

    /// <summary>Build (compile) the versioned message bytes without signing.</summary>
    function CompileMessage: TBytes;

    /// <summary>Sign & build with a single signer.</summary>
    function Build(const ASigner: IAccount): TBytes; overload;

    /// <summary>Sign & build with multiple signers.</summary>
    function Build(const ASigners: TList<IAccount>): TBytes; overload;
  end;

  /// <summary>
  /// Implements a builder for transactions.
  /// </summary>
  TTransactionBuilder = class(TInterfacedObject, ITransactionBuilder)
  public const
    /// <summary>
    /// The length of a signature.
    /// </summary>
    SignatureLength = 64;
  private
    /// <summary>
    /// The builder of the message contained within the transaction.
    /// </summary>
    FMessageBuilder: IMessageBuilder;

    /// <summary>
    /// The signatures present in the message.
    /// </summary>
    FSignatures: TList<string>;

    /// <summary>
    /// The message after being serialized.
    /// </summary>
    FSerializedMessage: TBytes;

    /// <summary>
    /// Sign the transaction message with each of the signer's keys.
    /// </summary>
    /// <param name="ASigners">The list of signers.</param>
    /// <exception cref="Exception">
    /// Throws when the list of signers is nil/empty or when the fee payer hasn't been set.
    /// </exception>
    procedure Sign(const ASigners: TList<IAccount>);

    /// <inheritdoc />
    function Serialize: TBytes;

    /// <inheritdoc />
    function AddSignature(const ASignature: TBytes): ITransactionBuilder; overload;

    /// <inheritdoc />
    function AddSignature(const ASignature: string): ITransactionBuilder; overload;

    /// <inheritdoc />
    function SetRecentBlockHash(const ARecentBlockHash: string): ITransactionBuilder;

    /// <inheritdoc />
    function SetNonceInformation(const ANonceInfo: INonceInformation): ITransactionBuilder;

    /// <inheritdoc />
    function SetPriorityFeesInformation(const APriorityFeesInfo: IPriorityFeesInformation): ITransactionBuilder;

    /// <inheritdoc />
    function SetFeePayer(const APublicKey: IPublicKey): ITransactionBuilder;

    /// <inheritdoc />
    function AddInstruction(const AInstruction: ITransactionInstruction): ITransactionBuilder;

    /// <inheritdoc />
    function CompileMessage: TBytes;

    /// <inheritdoc />
    function Build(const ASigner: IAccount): TBytes; overload;

    /// <inheritdoc />
    function Build(const ASigners: TList<IAccount>): TBytes; overload;
  public
    /// <summary>
    /// Default constructor that initializes the transaction builder.
    /// </summary>
    constructor Create;

    destructor Destroy; override;
  end;

    /// <summary>
  /// Implements a builder for versioned (v0) transactions.
  /// </summary>
  TVersionedTransactionBuilder = class(TInterfacedObject, IVersionedTransactionBuilder)
  public const
    /// <summary>The length of an Ed25519 signature.</summary>
    SignatureLength = 64;
  private
    /// <summary>The versioned message builder.</summary>
    FMessageBuilder: IVersionedMessageBuilder;
    /// <summary>Base58-encoded signatures (order matters: fee payer first).</summary>
    FSignatures: TList<string>;
    /// <summary>Cached serialized message.</summary>
    FSerializedMessage: TBytes;

    /// <summary>Sign the compiled message with each signer and append signatures.</summary>
    procedure Sign(const ASigners: TList<IAccount>);

    function Serialize: TBytes;
    function AddSignature(const ASignature: TBytes): IVersionedTransactionBuilder; overload;
    function AddSignature(const ASignature: string): IVersionedTransactionBuilder; overload;
    function SetRecentBlockHash(const ARecentBlockHash: string): IVersionedTransactionBuilder;
    function SetNonceInformation(const ANonceInfo: INonceInformation): IVersionedTransactionBuilder;
    function SetFeePayer(const APublicKey: IPublicKey): IVersionedTransactionBuilder;
    function AddInstruction(const AInstruction: ITransactionInstruction): IVersionedTransactionBuilder;
    function AddAddressTableLookup(const ALookup: IMessageAddressTableLookup): IVersionedTransactionBuilder;
    function AddAddressTableLookups(const ALookups: TList<IMessageAddressTableLookup>): IVersionedTransactionBuilder;
    function CompileMessage: TBytes;
    function Build(const ASigner: IAccount): TBytes; overload;
    function Build(const ASigners: TList<IAccount>): TBytes; overload;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TTransactionBuilder }

constructor TTransactionBuilder.Create;
begin
  inherited Create;
  FMessageBuilder := TMessageBuilder.Create;
  FSignatures := TList<string>.Create;
  FSerializedMessage := nil;
end;

destructor TTransactionBuilder.Destroy;
begin
  if Assigned(FSignatures) then
    FSignatures.Free;
  inherited;
end;

function TTransactionBuilder.Serialize: TBytes;
var
  SigLenEnc: TBytes;
  MS: TMemoryStream;
  Sig: string;
  SigBytes: TBytes;
  Capacity: Integer;
begin
  SigLenEnc := TShortVectorEncoding.EncodeLength(FSignatures.Count);

  if Length(FSerializedMessage) = 0 then
    FSerializedMessage := FMessageBuilder.Build;

  Capacity := Length(SigLenEnc) + (FSignatures.Count * SignatureLength) +
    Length(FSerializedMessage);
  MS := TMemoryStream.Create;
  try
    MS.Size := Capacity;
    MS.WriteBuffer(SigLenEnc[0], Length(SigLenEnc));

    for Sig in FSignatures do
    begin
      SigBytes := TEncoders.Base58.DecodeData(Sig);
      MS.WriteBuffer(SigBytes[0], Length(SigBytes));
    end;

    MS.WriteBuffer(FSerializedMessage[0], Length(FSerializedMessage));

    SetLength(Result, MS.Size);
    MS.Position := 0;
    MS.ReadBuffer(Result[0], MS.Size);
  finally
    MS.Free;
  end;
end;

function TTransactionBuilder.AddInstruction(const AInstruction
  : ITransactionInstruction): ITransactionBuilder;
begin
  FMessageBuilder.AddInstruction(AInstruction);
  Result := Self;
end;

function TTransactionBuilder.AddSignature(const ASignature: TBytes)
  : ITransactionBuilder;
begin
  FSignatures.Add(TEncoders.Base58.EncodeData(ASignature));
  Result := Self;
end;

function TTransactionBuilder.AddSignature(const ASignature: string)
  : ITransactionBuilder;
begin
  FSignatures.Add(ASignature);
  Result := Self;
end;

function TTransactionBuilder.Build(const ASigner: IAccount): TBytes;
var
  Signers: TList<IAccount>;
begin
  Signers := TList<IAccount>.Create;
  try
    Signers.Add(ASigner);
    Result := Build(Signers);
  finally
    Signers.Free;
  end;
end;

function TTransactionBuilder.Build(const ASigners: TList<IAccount>): TBytes;
begin
  Sign(ASigners);
  Result := Serialize;
end;

function TTransactionBuilder.CompileMessage: TBytes;
begin
  Result := FMessageBuilder.Build;
end;

function TTransactionBuilder.SetFeePayer(const APublicKey: IPublicKey)
  : ITransactionBuilder;
begin
  FMessageBuilder.FeePayer := APublicKey;
  Result := Self;
end;

function TTransactionBuilder.SetNonceInformation(const ANonceInfo
  : INonceInformation): ITransactionBuilder;
begin
  FMessageBuilder.NonceInformation := ANonceInfo;
  Result := Self;
end;

function TTransactionBuilder.SetPriorityFeesInformation(const APriorityFeesInfo
  : IPriorityFeesInformation): ITransactionBuilder;
begin
  FMessageBuilder.PriorityFeesInformation := APriorityFeesInfo;
  Result := Self;
end;

function TTransactionBuilder.SetRecentBlockHash(const ARecentBlockHash: string)
  : ITransactionBuilder;
begin
  FMessageBuilder.RecentBlockHash := ARecentBlockHash;
  Result := Self;
end;

procedure TTransactionBuilder.Sign(const ASigners: TList<IAccount>);
var
  Signer: IAccount;
  SignatureBytes: TBytes;
begin
  if (ASigners = nil) or (ASigners.Count = 0) then
    raise Exception.Create('no signers for the transaction');

  if FMessageBuilder.FeePayer = nil then
    raise Exception.Create('fee payer is required');

  FSerializedMessage := FMessageBuilder.Build;

  for Signer in ASigners do
  begin
    SignatureBytes := Signer.Sign(FSerializedMessage);
    FSignatures.Add(TEncoders.Base58.EncodeData(SignatureBytes));
  end;
end;

{ TVersionedTransactionBuilder }

constructor TVersionedTransactionBuilder.Create;
begin
  inherited Create;
  FMessageBuilder := TVersionedMessageBuilder.Create;
  FSignatures := TList<string>.Create;
  FSerializedMessage := nil;
end;

destructor TVersionedTransactionBuilder.Destroy;
begin
  if Assigned(FSignatures) then
    FSignatures.Free;
  inherited;
end;

function TVersionedTransactionBuilder.AddAddressTableLookup(
  const ALookup: IMessageAddressTableLookup): IVersionedTransactionBuilder;
begin
  FMessageBuilder.AddressTableLookups.Add(ALookup);
  Result := Self;
end;

function TVersionedTransactionBuilder.AddAddressTableLookups(
  const ALookups: TList<IMessageAddressTableLookup>): IVersionedTransactionBuilder;
begin
  FMessageBuilder.AddressTableLookups.AddRange(ALookups);
  Result := Self;
end;

function TVersionedTransactionBuilder.AddInstruction(
  const AInstruction: ITransactionInstruction): IVersionedTransactionBuilder;
begin
  FMessageBuilder.AddInstruction(AInstruction);
  Result := Self;
end;

function TVersionedTransactionBuilder.AddSignature(
  const ASignature: TBytes): IVersionedTransactionBuilder;
begin
  FSignatures.Add(TEncoders.Base58.EncodeData(ASignature));
  Result := Self;
end;

function TVersionedTransactionBuilder.AddSignature(
  const ASignature: string): IVersionedTransactionBuilder;
begin
  FSignatures.Add(ASignature);
  Result := Self;
end;

function TVersionedTransactionBuilder.Build(const ASigner: IAccount): TBytes;
var
  Signers: TList<IAccount>;
begin
  Signers := TList<IAccount>.Create;
  try
    Signers.Add(ASigner);
    Result := Build(Signers);
  finally
    Signers.Free;
  end;
end;

function TVersionedTransactionBuilder.Build(
  const ASigners: TList<IAccount>): TBytes;
begin
  Sign(ASigners);
  Result := Serialize;
end;

function TVersionedTransactionBuilder.CompileMessage: TBytes;
begin
  Result := FMessageBuilder.Build;
end;

function TVersionedTransactionBuilder.Serialize: TBytes;
var
  SigLenEnc: TBytes;
  MS: TMemoryStream;
  Sig: string;
  SigBytes: TBytes;
  Capacity: Integer;
begin
  SigLenEnc := TShortVectorEncoding.EncodeLength(FSignatures.Count);

  if Length(FSerializedMessage) = 0 then
    FSerializedMessage := FMessageBuilder.Build;

  Capacity := Length(SigLenEnc) + (FSignatures.Count * SignatureLength) + Length(FSerializedMessage);

  MS := TMemoryStream.Create;
  try
    MS.Size := Capacity;

    MS.WriteBuffer(SigLenEnc[0], Length(SigLenEnc));

    for Sig in FSignatures do
    begin
      SigBytes := TEncoders.Base58.DecodeData(Sig);
      MS.WriteBuffer(SigBytes[0], Length(SigBytes));
    end;

    MS.WriteBuffer(FSerializedMessage[0], Length(FSerializedMessage));

    SetLength(Result, MS.Size);
    MS.Position := 0;
    MS.ReadBuffer(Result[0], MS.Size);
  finally
    MS.Free;
  end;
end;

function TVersionedTransactionBuilder.SetFeePayer(
  const APublicKey: IPublicKey): IVersionedTransactionBuilder;
begin
  FMessageBuilder.FeePayer := APublicKey;
  Result := Self;
end;

function TVersionedTransactionBuilder.SetNonceInformation(
  const ANonceInfo: INonceInformation): IVersionedTransactionBuilder;
begin
  FMessageBuilder.NonceInformation := ANonceInfo;
  Result := Self;
end;

function TVersionedTransactionBuilder.SetRecentBlockHash(
  const ARecentBlockHash: string): IVersionedTransactionBuilder;
begin
  FMessageBuilder.RecentBlockHash := ARecentBlockHash;
  Result := Self;
end;

procedure TVersionedTransactionBuilder.Sign(const ASigners: TList<IAccount>);
var
  Signer: IAccount;
  SignatureBytes: TBytes;
begin
  if (ASigners = nil) or (ASigners.Count = 0) then
    raise Exception.Create('no signers for the transaction');

  if FMessageBuilder.FeePayer = nil then
    raise Exception.Create('fee payer is required');

  FSerializedMessage := FMessageBuilder.Build;

  for Signer in ASigners do
  begin
    SignatureBytes := Signer.Sign(FSerializedMessage);
    FSignatures.Add(TEncoders.Base58.EncodeData(SignatureBytes));
  end;
end;

end.

