unit SlimContext;

interface

uses
  System.Classes, System.Generics.Defaults, System.Generics.Collections, System.RegularExpressions;

type
  TInstance = record
    Name: string;
    ClassName: string;
    Arguments: string;
    InstancedObject: TObject;
  end;

  TInstanceComparer = class(TComparer<TInstance>)
  public
    function Compare(const Left, Right: TInstance): Integer; override;
  end;

  TPackageList = TDictionary<HMODULE, string>;

  TSlimContext = class
  private
    FComparer: TInstanceComparer;
    FLoadedPackages: TPackageList;
    FInstances: TList<TInstance>;
    FVariables: TDictionary<string, string>;
    FVariablesRegEx: TRegEx;
    FImportPaths: TStrings;
    FPackagePaths: TStrings;
    function InternalMatchEvaluator(const pMatch: TMatch): string;
    procedure ClearInstances(pKeepLibraries: Boolean);
    procedure UnloadPackages;
  public
    constructor Create;
    destructor Destroy; override;

    property ImportPaths: TStrings read FImportPaths;
    property PackagePaths: TStrings read FPackagePaths;

    procedure AddImportPath(const pPath: string);
    procedure AddPackagePath(const pPath: string);
    procedure SetVariable(const pName, pValue: string);
    procedure LoadPackages;
    procedure Init;
    function FindInstanceByName(const pName: string): TInstance;
    function GetRegisteredInstances: TList<TInstance>;
    procedure RegisterInstance(const pInstanceName, pClassName, pArguments: string; pInstance: TObject);
    procedure ReplaceVariables(pArguments: TStrings);
  end;

implementation

uses
  System.SysUtils,
  Slim.Logger;

{ TInstanceComparer }

function TInstanceComparer.Compare(const Left, Right: TInstance): Integer;
begin
  Result := CompareStr(Left.Name + Left.ClassName + Left.Arguments, Right.Name + Right.ClassName + Right.Arguments);
end;

{ TSlimContext }

procedure TSlimContext.AddImportPath(const pPath: string);
begin
  ImportPaths.Add(pPath);
end;

procedure TSlimContext.AddPackagePath(const pPath: string);
begin
  PackagePaths.Add(pPath);
end;

constructor TSlimContext.Create;
begin
  LogMemory('Creating Context');

  FImportPaths := TStringList.Create;
  FPackagePaths := TStringList.Create;
  FLoadedPackages := TPackageList.Create;
  FComparer :=  TInstanceComparer.Create;
  FInstances :=  TList<TInstance>.Create(FComparer);
  FVariables := TDictionary<string, string>.Create;
  // From FitNesse documentation:
  //   Variable names may contain letters, numbers, periods and underscores;
  //   e.g., MYTEST.someVar or user.name or USER_NAME
  FVariablesRegEx.Create('\$([a-zA-Z0-9._]+)');

  LogMemory('Context Created');
end;

destructor TSlimContext.Destroy;
begin
  LogMemory('Destroying Context');

  FVariables.Free;
  ClearInstances(False);
  FInstances.Free; // TList frees its comparer
  UnloadPackages;
  FLoadedPackages.Free;
  FPackagePaths.Free;
  FImportPaths.Free;

  LogMemory('Context Destroyed');

  inherited;
end;

function TSlimContext.FindInstanceByName(const pName: string): TInstance;
var
  instance: TInstance;
begin
  for instance in FInstances do
  begin
    if instance.Name.ToLower.Equals(pName.ToLower) then
      Exit(instance);
  end;

  raise Exception.CreateFmt('Instance %s not found', [pName]);
end;

procedure TSlimContext.ClearInstances(pKeepLibraries: Boolean);
var
  instance: TInstance;
  contInstances: Integer;
begin
  LogMemory('Instances clearing');
  contInstances := FInstances.Count - 1;
  while (contInstances >= 0) do
  begin
    instance := FInstances[contInstances];

    if not(instance.Name.ToLower.Contains('library') and pKeepLibraries) then
    begin
      instance.InstancedObject.Free;
      FInstances.Remove(instance);
    end;

    Dec(contInstances);
  end;
  LogMemory('Instances cleared');
end;

procedure TSlimContext.UnloadPackages;
var
  package: HMODULE;
begin
  LogMemory('Packages unloading');
  for package in FLoadedPackages.Keys do
  begin
    // LogMemory('Unloading package ' + ExtractFileName(FLoadedPackages[package]));
    UnloadPackage(package);
    //LogMemory('Unloaded package ' + ExtractFileName(FLoadedPackages[package]));
  end;
  FLoadedPackages.Clear;
  LogMemory('Packages unloaded');
end;

procedure TSlimContext.LoadPackages;
var
  packagePath: string;
  module: HMODULE;
begin
  UnloadPackages;

  LogMemory('Packages loading');

  for packagePath in PackagePaths do
  begin
    try
      module := LoadPackage(packagePath);
      FLoadedPackages.AddOrSetValue(module, packagePath);
    except
      on E: Exception do
      begin
        Log(E.ClassName + ': ' + E.Message);
        InternalLog('Error cargando BPLS: ' + E.ClassName + ': ' + E.Message);
      end;
    end;
  end;
  LogMemory('Packages loaded');
end;

procedure TSlimContext.Init;
begin
  LogMemory('Initializating');
  ClearInstances(True);
  LogMemory('Initializated');
end;

function TSlimContext.InternalMatchEvaluator(const pMatch: TMatch): string;
begin
  if (pMatch.Groups.Count <= 1) or not FVariables.TryGetValue(pMatch.Groups[1].Value, Result) then
    Result := pMatch.Value;
end;

procedure TSlimContext.RegisterInstance(const pInstanceName, pClassName, pArguments: string; pInstance: TObject);
var
  newInstance: TInstance;
begin
  newInstance.Name := pInstanceName;
  newInstance.ClassName := pClassName;
  newInstance.Arguments := pArguments;
  newInstance.InstancedObject := pInstance;
  if not FInstances.Contains(newInstance) then
    FInstances.Add(newInstance);
end;

procedure TSlimContext.ReplaceVariables(pArguments: TStrings);
var
  i: Integer;
begin
  for i := 0 to pArguments.Count - 1 do
    pArguments[i] := FVariablesRegEx.Replace(pArguments[i], InternalMatchEvaluator);
end;

procedure TSlimContext.SetVariable(const pName, pValue: string);
begin
  FVariables.AddOrSetValue(pName, pValue);
end;

function TSlimContext.GetRegisteredInstances: TList<TInstance>;
begin
  Result := FInstances;
end;

end.
