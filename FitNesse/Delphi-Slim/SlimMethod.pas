unit SlimMethod;

interface

uses
  System.Rtti, System.Classes,
  SlimDirectiveSerializer, SlimContext;

type
  TSlimMethod = class
  private
    FFunctionName: string;
    FInstance: TObject;
    FRttiContextInitialized: Boolean;
    FRttiContext: TRttiContext;
    function RttiContext: TRttiContext;
    function MethodToCall: TRttiMethod;
    function BuildArgValues(pArguments: TStrings): TArray<TValue>; overload;
  protected
    function InstanceType: TRttiType;
  public
    class function BuildArgValues(pMethod: TRttiMethod; pArguments: TStrings): TArray<TValue>; overload;
  public
    constructor Create; overload;
    constructor Create(pInstance: TObject; const pFunctionName: string); overload;

    property FunctionName: string read FFunctionName write FFunctionName;
    property Instance: TObject read FInstance write FInstance;

    function Call(pArguments: TStrings): string; overload; virtual;
    function Call(const pArguments: array of string): string; overload; virtual;
  end;

  TNullSlimMethod = class(TSlimMethod)
  private
    function TypeName: string;
  public
    function Call(pArguments: TStrings): string; overload; override;
  end;

implementation

uses
  System.SysUtils, System.TypInfo, System.Generics.Collections,
  Slim.Logger;

{ TSlimMethod }

constructor TSlimMethod.Create;
begin

end;

constructor TSlimMethod.Create(pInstance: TObject; const pFunctionName: string);
begin
  FInstance := pInstance;
  FFunctionName := pFunctionName;
end;

function TSlimMethod.Call(const pArguments: array of string): string;
var
  i: integer;
  argList: TStringList;
begin
  argList := TStringList.Create;
  try
    for i := Low(pArguments) to High(pArguments) do
      argList.Add(pArguments[i]);

    Result := Call(argList);
  finally
    argList.Free;
  end;
end;

function TSlimMethod.Call(pArguments: TStrings): string;
var
  list: TStringListListList;
  returnedValue: TValue;
  params: TArray<TValue>;
  method: TRttiMethod;
begin
  try
    params := BuildArgValues(pArguments);
    method := MethodToCall;
    WriteLn(Output, #9 + method.Parent.Name + '->' + method.ToString);
    InternalLog(#9 + method.Parent.Name + '->' + method.ToString);

    returnedValue := method.Invoke(Instance, params);
    if returnedValue.IsEmpty then
      Exit('/__VOID__/')
    else if returnedValue.TypeInfo.Name = 'TList<System.Generics.Collections.TList<System.Generics.Collections.TList<System.string>>>' then
    begin
      list := TStringListListList(returnedValue.AsObject);
      Result := TSlimDirectiveSerializer.QueryResultToString(list);
      list.Free;
    end
    else
      Exit(returnedValue.ToString);
  except
    on E: Exception do
      Exit('__EXCEPTION__:message:<<' + E.Message + '>>');
  end;
end;

class function TSlimMethod.BuildArgValues(pMethod: TRttiMethod; pArguments: TStrings): TArray<TValue>;
var
  i: Integer;
  paramType: TRttiType;
  parameters: TArray<TRttiParameter>;
begin
  parameters := pMethod.GetParameters;
  if parameters <> nil then
  begin
    SetLength(Result, pArguments.Count);
    for i := 0 to pArguments.Count - 1 do
    begin
      paramType := parameters[i].ParamType;
      if paramType.TypeKind = TTypeKind.tkInteger then
        Result[i] := TValue.From(StrToInt(pArguments[i]))
      else if (paramType.TypeKind = TTypeKind.tkClass) and (pArguments.Objects[i] <> nil) then
         TValue.Make(NativeInt(pArguments.Objects[i]), parameters[i].ParamType.Handle, Result[i])
      else
        Result[i] := TValue.From(pArguments[i]);
    end
  end
  else
    Result := [];
end;

function TSlimMethod.BuildArgValues(pArguments: TStrings): TArray<TValue>;
begin
  Result := BuildArgValues(MethodToCall, pArguments);
end;

function TSlimMethod.MethodToCall: TRttiMethod;
begin
  Result := InstanceType.GetMethod(FunctionName);
end;

function TSlimMethod.InstanceType: TRttiType;
begin
  Result := RttiContext.GetType(Instance.ClassType);
end;

function TSlimMethod.RttiContext: TRttiContext;
begin
  if not FRttiContextInitialized then
    FRttiContext := TRttiContext.Create;
  Result := FRttiContext;
end;

{ TNullSlimMethod }

function TNullSlimMethod.Call(pArguments: TStrings): string;
begin
  Result := '__EXCEPTION__:message:<<NO_METHOD_IN_CLASS ' + FunctionName + ' ' + TypeName +'>>';
end;

function TNullSlimMethod.TypeName: string;
begin
  Result := InstanceType.Name;
end;

end.
