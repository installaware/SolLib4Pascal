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

{---------------------------- Compiler Family Switch -------------------------------}
{$IFDEF FPC}
  {$I SolLibHelper.inc}
{$ELSE}
  {$DEFINE DELPHI}
{$ENDIF}

{--------------------------- Common (Delphi & FPC) ----------------------------------}
{$SCOPEDENUMS ON}
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
{$POINTERMATH ON}
{$WARNINGS OFF}
{$HINTS OFF}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{$IFDEF FPC}
  {$MODE DELPHI}
  {$NOTES OFF}

  // ---- Optimizations ----
  {$OPTIMIZATION LEVEL3}
  {$IFDEF FPC_GREATER_THAN_3.0.4}
    {$OPTIMIZATION NOUSELOADMODIFYSTORE}
  {$ENDIF}
  {$OPTIMIZATION ORDERFIELDS}
  {$OPTIMIZATION DEADVALUES}
  {$IFDEF CPUI386}
    {$OPTIMIZATION USEEBP}
  {$ENDIF}
  {$IFDEF CPUX86_64}
    {$OPTIMIZATION USERBP}
  {$ENDIF}

{$ELSE} {------------------------------ Delphi --------------------------------------}

  {$IF CompilerVersion >= 34.0}
    {$DEFINE SYDNEY_UP}
  {$IFEND}
  {$IFNDEF SYDNEY_UP}
    {$MESSAGE ERROR 'This Library requires Delphi 10.4 Sydney or higher.'}
  {$ENDIF}

  {$DEFINITIONINFO ON}     // IDE navigation; no binary impact
  {$STRINGCHECKS OFF}
  {$WARN DUPLICATE_CTOR_DTOR OFF}

{$ENDIF}

