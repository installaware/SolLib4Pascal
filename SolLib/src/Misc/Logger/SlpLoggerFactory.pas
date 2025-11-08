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

unit SlpLoggerFactory;

interface

uses
  System.SysUtils,
  SlpLogger,
  ConsoleLogger;

type
  /// Minimal logger factory that currently creates console loggers.
  TLoggerFactory = class(TInterfacedObject, ILoggerFactory)
  private
    FMinLevel: TLogLevel;
  public
    constructor Create(AMinLevel: TLogLevel = TLogLevel.Trace);
    function CreateLogger(const CategoryName: string): ILogger;
    procedure SetMinimumLevel(ALevel: TLogLevel);
    function GetMinimumLevel: TLogLevel;
  end;

implementation

{ TLoggerFactory }

constructor TLoggerFactory.Create(AMinLevel: TLogLevel);
begin
  inherited Create;
  FMinLevel := AMinLevel;
end;

function TLoggerFactory.CreateLogger(const CategoryName: string): ILogger;
begin
  // Currently we only return console loggers; later we can keep a list of providers.
  // Use CreateWithCategory so category shows up in output.
  Result := TConsoleLogger.CreateWithCategory(CategoryName, FMinLevel);
end;

procedure TLoggerFactory.SetMinimumLevel(ALevel: TLogLevel);
begin
  FMinLevel := ALevel;
end;

function TLoggerFactory.GetMinimumLevel: TLogLevel;
begin
  Result := FMinLevel;
end;

end.

