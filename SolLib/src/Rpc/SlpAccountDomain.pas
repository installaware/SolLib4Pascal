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

unit SlpAccountDomain;

{$I ..\Include\SolLib.inc}

interface

uses
  System.SysUtils,
  System.Math,
  System.Generics.Collections,
  System.Generics.Defaults,
  SlpPublicKey;

type
  IAccountMeta = interface
    ['{A7F57C9C-6C5A-4E08-9A4E-3B2A6E7E5B3C}']
    function GetPublicKey: IPublicKey;
    function GetIsSigner: Boolean;
    procedure SetIsSigner(Value: Boolean);
    function GetIsWritable: Boolean;
    procedure SetIsWritable(Value: Boolean);

    function Clone: IAccountMeta;

    property PublicKey: IPublicKey read GetPublicKey;
    property IsSigner: Boolean read GetIsSigner write SetIsSigner;
    property IsWritable: Boolean read GetIsWritable write SetIsWritable;
  end;

  /// <summary>
  /// Implements the account meta logic, which defines if an account represented by public key is a signer, a writable account or both.
  /// </summary>
  TAccountMeta = class(TInterfacedObject, IAccountMeta)
  private
    FPublicKey : IPublicKey;
    FIsSigner  : Boolean;
    FIsWritable: Boolean;

    function GetPublicKey: IPublicKey;
    function GetIsSigner: Boolean;
    procedure SetIsSigner(Value: Boolean);
    function GetIsWritable: Boolean;
    procedure SetIsWritable(Value: Boolean);

  public
    constructor Create(const APublicKey: IPublicKey; const AIsWritable, AIsSigner: Boolean);

    function Clone: IAccountMeta;

    /// <summary>
    /// Initializes an AccountMeta for a writable account with the given PublicKey
    /// and a bool that signals whether the account is a signer or not.
    /// </summary>
    class function Writable(const APublicKey: IPublicKey; const AIsSigner: Boolean): IAccountMeta; static;
    /// <summary>
    /// Initializes an AccountMeta for a read-only account with the given PublicKey
    /// and a bool that signals whether the account is a signer or not.
    /// </summary>
    class function ReadOnly(const APublicKey: IPublicKey; const AIsSigner: Boolean): IAccountMeta; static;
  end;

type
  /// <summary>
  /// A wrapper around a list of <see cref="AccountMeta"/>s that takes care of deduplication
  /// and ordering according to the wire format specification.
  /// </summary>
  TAccountKeysList = class
  private
    FAccounts: TList<IAccountMeta>;
    function GetCount: Integer;
    function GetAccountList: TList<IAccountMeta>;
    function CompareAccountMeta(const A, B: IAccountMeta): Integer;
    function FindByPublicKey(const Key: IPublicKey): IAccountMeta;
  public
    /// <summary>
    /// Initialize the account keys list for use within transaction building.
    /// </summary>
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Get the accounts as a list.
    /// Returns a NEW sorted list instance.
    /// </summary>
    property AccountList: TList<IAccountMeta> read GetAccountList;

    property Count: Integer read GetCount;

    /// <summary>
    /// Add an account meta to the list of accounts.
    /// </summary>
    /// <param name="AccountMeta">The account meta to add.</param>
    procedure Add(AccountMeta: IAccountMeta); overload;

    /// <summary>
    /// Add a list of account metas to the list of accounts.
    /// </summary>
    /// <param name="AccountMetas">The account metas to add.</param>
    procedure Add(const AccountMetas: array of IAccountMeta); overload;

    /// <summary>
    /// Add a list of account metas to the list of accounts.
    /// </summary>
    /// <param name="AccountMetas">The account metas to add.</param>
    procedure Add(const AccountMetas: TList<IAccountMeta>); overload;
  end;

implementation

{ TAccountMeta }

constructor TAccountMeta.Create(const APublicKey: IPublicKey; const AIsWritable, AIsSigner: Boolean);
begin
  inherited Create;
  if not Assigned(APublicKey) then
    raise EArgumentNilException.Create('PublicKey');
  FPublicKey  := APublicKey;
  FIsWritable := AIsWritable;
  FIsSigner   := AIsSigner;
end;

function TAccountMeta.GetPublicKey: IPublicKey;
begin
  Result := FPublicKey;
end;

function TAccountMeta.GetIsSigner: Boolean;
begin
  Result := FIsSigner;
end;

procedure TAccountMeta.SetIsSigner(Value: Boolean);
begin
  FIsSigner := Value;
end;

function TAccountMeta.GetIsWritable: Boolean;
begin
  Result := FIsWritable;
end;

procedure TAccountMeta.SetIsWritable(Value: Boolean);
begin
  FIsWritable := Value;
end;

function TAccountMeta.Clone: IAccountMeta;
begin
  Result := TAccountMeta.Create(FPublicKey.Clone, FIsWritable, FIsSigner);
end;

class function TAccountMeta.Writable(const APublicKey: IPublicKey; const AIsSigner: Boolean): IAccountMeta;
begin
  Result := TAccountMeta.Create(APublicKey, True, AIsSigner);
end;

class function TAccountMeta.ReadOnly(const APublicKey: IPublicKey; const AIsSigner: Boolean): IAccountMeta;
begin
  Result := TAccountMeta.Create(APublicKey, False, AIsSigner);
end;

{ TAccountKeysList }

constructor TAccountKeysList.Create;
begin
  inherited Create;
  FAccounts := TList<IAccountMeta>.Create();
end;

destructor TAccountKeysList.Destroy;
begin
  if Assigned(FAccounts) then
    FAccounts.Free;
  inherited Destroy;
end;

function TAccountKeysList.FindByPublicKey(const Key: IPublicKey): IAccountMeta;
var
  I: Integer;
  Item: IAccountMeta;
begin
  Result := nil;
  for I := 0 to FAccounts.Count - 1 do
  begin
    Item := FAccounts[I];
    if (Item.PublicKey.Equals(Key)) then
    begin
      Exit(Item);
    end;
  end;
end;

function TAccountKeysList.CompareAccountMeta(const A, B: IAccountMeta): Integer;
begin
  // Signers always come before non-signers
  if A.IsSigner <> B.IsSigner then
  begin
    if A.IsSigner then Exit(-1) else Exit(1);
  end;

  // Writable accounts always come before read-only accounts
  if A.IsWritable <> B.IsWritable then
  begin
    if A.IsWritable then Exit(-1) else Exit(1);
  end;

  // Otherwise, sort by pubkey, stringwise.
  Result := Sign(CompareText(A.PublicKey.Key, B.PublicKey.Key));
end;

function TAccountKeysList.GetCount: Integer;
begin
  Result := FAccounts.Count;
end;

function TAccountKeysList.GetAccountList: TList<IAccountMeta>;
var
  I: Integer;
begin
  // Return a newly allocated list
  Result := TList<IAccountMeta>.Create();
  try
    for I := 0 to FAccounts.Count - 1 do
    begin
      Result.Add(FAccounts[I]);
    end;

    // Sort using CompareAccountMeta
    Result.Sort(
      TComparer<IAccountMeta>.Construct(
        function(const L, R: IAccountMeta): Integer
        begin
          Result := CompareAccountMeta(L, R);
        end
      )
    );
  except
    Result.Free;
    raise;
  end;
end;

procedure TAccountKeysList.Add(AccountMeta: IAccountMeta);
var
  Existing: IAccountMeta;
begin
  if AccountMeta = nil then
    Exit;

  Existing := FindByPublicKey(AccountMeta.PublicKey);

  if Existing = nil then
  begin
    FAccounts.Add(AccountMeta)
  end
  else
  begin
    // Merge flags:
    // if existing is not signer but new is signer -> promote
    if (not Existing.IsSigner) and AccountMeta.IsSigner then
      Existing.IsSigner := True;

    // if existing is not writable but new is writable -> promote
    if (not Existing.IsWritable) and AccountMeta.IsWritable then
      Existing.IsWritable := True;
  end;
end;

procedure TAccountKeysList.Add(const AccountMetas: array of IAccountMeta);
var
  I: Integer;
begin
  for I := 0 to High(AccountMetas) do
    Add(AccountMetas[I]);
end;

procedure TAccountKeysList.Add(const AccountMetas: TList<IAccountMeta>);
var
  I: Integer;
begin
  for I := 0 to AccountMetas.Count - 1 do
    Add(AccountMetas[I]);
end;

end.

