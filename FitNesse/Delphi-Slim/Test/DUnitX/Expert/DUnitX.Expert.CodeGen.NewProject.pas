{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
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

unit DUnitX.Expert.CodeGen.NewProject;
// This is done to Warnings that I can't control, as Embarcadero has
// deprecated the functions, but due to design you are still required to
// to implement.
{$WARN SYMBOL_DEPRECATED OFF}
interface

{$I DUnitX.inc}

uses
  {$IFDEF DELPHI_XE2_UP}
  PlatformAPI,
  {$ENDIF}
  ToolsAPI;

type
   TNewProject= class abstract(TNotifierObject,IOTACreator, IOTAProjectCreator,IOTAProjectCreator80)
   protected
    //IOTACreator
    function GetCreatorType: string; virtual;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    // IOTAProjectCreator
    function GetFileName: string;
    function GetOptionFileName: string; deprecated;
    function GetShowSource: Boolean;
    procedure NewDefaultModule; deprecated;
    function NewOptionSource(const ProjectName: string): IOTAFile; deprecated;
    procedure NewProjectResource(const Project: IOTAProject);
    function NewProjectSource(const ProjectName: string): IOTAFile; virtual; abstract;  // MUST OVERRIDE!
    // IOTAProjectCreator80
    function GetProjectPersonality: string;virtual;
    procedure NewDefaultProjectModule(const Project: IOTAProject);
  private
    procedure SetFileName(const Value: String);
  protected
    FFileName : String;
  public
     property FileName : String read GetFileName write SetFileName;
  end;

  {$IFDEF DELPHIX_SEATTLE_UP}
  TNewProjectEx = class(TNewProject, IOTAProjectCreator160)
  private
   FPersonality: string;
  protected
    function GetProjectPersonality: string;override;

    // IOTAProjectCreator160
    function GetPlatforms: TArray<string>;
    function GetFrameworkType: string;
    function GetPreferredPlatform: string;
    procedure SetInitialOptions(const NewProject: IOTAProject);
  public
    property Personality : string read FPersonality write FPersonality;
  end;
  {$ENDIF}

implementation

uses
  {$IFDEF USE_NS}
  System.SysUtils;
  {$ELSE}
  SysUtils;
  {$ENDIF}

{ TNewProject }

function TNewProject.GetCreatorType: string;
begin
 result := sConsole; // May want to change this in the future, at least making method virtual
end;

function TNewProject.GetExisting: Boolean;
begin
 result := false;
end;

function TNewProject.GetFileName: string;
begin
 result := FFileName;
end;

function TNewProject.GetFileSystem: string;
begin
 result := '';
end;

function TNewProject.GetOptionFileName: string;
begin
 result := '';
end;

function TNewProject.GetOwner: IOTAModule;
begin
 result := (BorlandIDEServices as IOTAModuleServices).MainProjectGroup;
end;

function TNewProject.GetProjectPersonality: string;
begin
 result := sDelphiPersonality;
end;

function TNewProject.GetShowSource: Boolean;
begin
 result := false;
end;

function TNewProject.GetUnnamed: Boolean;
begin
 result := true;
end;

procedure TNewProject.NewDefaultModule;
begin
end;

procedure TNewProject.NewDefaultProjectModule(const Project: IOTAProject);
begin
end;

function TNewProject.NewOptionSource(const ProjectName: string): IOTAFile;
begin
 result := nil;
end;

procedure TNewProject.NewProjectResource(const Project: IOTAProject);
begin
end;


procedure TNewProject.SetFileName(const Value: String);
begin
  FFileName := Value;
end;

{$IFDEF DELPHIX_SEATTLE_UP}
function TNewProjectEx.GetFrameworkType: string;
begin
  Result := '';
end;

function TNewProjectEx.GetPlatforms: TArray<string>;
begin
  if Personality = sDelphiPersonality then
    Result := TArray<string>.Create(cWin32Platform, cWin64Platform, cOSX32Platform, cAndroidPlatform, ciOSSimulatorPlatform {$IFDEF DELPHI_XE8_UP}, ciOSDevice32Platform, ciOSDevice64Platform {$ENDIF})
  else
    Result := TArray<string>.Create(cWin32Platform, cWin64Platform, cOSX32Platform, cAndroidPlatform {$IFDEF DELPHI_XE8_UP}, ciOSDevice32Platform, ciOSDevice64Platform {$ENDIF});
end;

function TNewProjectEx.GetPreferredPlatform: string;
begin
  Result := '';
end;

function TNewProjectEx.GetProjectPersonality: string;
begin
 if FPersonality.IsEmpty then
   result := sDelphiPersonality
 else
   result := FPersonality;
end;

procedure TNewProjectEx.SetInitialOptions(const NewProject: IOTAProject);
var
  LBuildConf: IOTAProjectOptionsConfigurations;
begin
  if Supports(NewProject.ProjectOptions, IOTAProjectOptionsConfigurations, LBuildConf) then
  begin
    LBuildConf.BaseConfiguration.AsBoolean['UsingDelphiRTL'] := True;
    if FPersonality = sCBuilderPersonality then
    begin
      LBuildConf.BaseConfiguration.PlatformConfiguration[cAndroidPlatform].AsBoolean['ILINK_LinkwithDUnitXRuntime'] := True;
      LBuildConf.BaseConfiguration.PlatformConfiguration[ciOSDevice32Platform].AsBoolean['ILINK_LinkwithDUnitXRuntime'] := True;
      LBuildConf.BaseConfiguration.PlatformConfiguration[ciOSDevice64Platform].AsBoolean['ILINK_LinkwithDUnitXRuntime'] := True;
    end;
  end;

end;
{$ENDIF}

end.
