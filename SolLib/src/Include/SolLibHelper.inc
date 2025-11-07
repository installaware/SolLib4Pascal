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

{$MACRO ON}

{$IFDEF FPC}
  {$MESSAGE FATAL 'This Library does not support Free Pascal Compiler (FPC). Please use Delphi instead.'}
{$ENDIF}

{$IFDEF ENDIAN_BIG}
   {$MESSAGE FATAL 'This Library does not support "Big Endian" processors yet.'}
{$ENDIF}
// FPC 3.2.2 and Above
// Had to Include this here since Delphi does not allow it Compile in "SolLib.inc".
{$IF FPC_FULLVERSION < 30202}
   {$MESSAGE ERROR 'This Library requires FreePascal 3.2.2 or higher.'}
{$IFEND}

{$IF FPC_FULLVERSION > 30004}
   {$DEFINE FPC_GREATER_THAN_3.0.4}
{$IFEND}
