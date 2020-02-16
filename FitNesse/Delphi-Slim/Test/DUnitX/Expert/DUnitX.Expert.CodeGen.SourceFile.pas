{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DUnitX.Expert.CodeGen.SourceFile;

interface

{$I DUnitX.inc}

uses
  {$IFDEF USE_NS}
  System.SysUtils,
  System.Classes,
  ToolsAPI;
  {$ELSE}
  SysUtils,
  Classes,
  ToolsAPI;
  {$ENDIF}


type
  TSourceFile = class(TInterfacedObject, IOTAFile)
  private
    FSource: string;
  public
    function GetSource: string;
    function GetAge: TDateTime;
    constructor Create(const Source: string; const Args: array of const );
  end;

implementation

{ TSourceFile }

constructor TSourceFile.Create(const Source: string;
  const Args: array of const );
begin
  FSource := Format(Source, Args);
end;

function TSourceFile.GetAge: TDateTime;
begin
  result := now;
end;

function TSourceFile.GetSource: string;
begin
  result := FSource;
end;

end.

