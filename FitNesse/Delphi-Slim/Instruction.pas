unit Instruction;

interface

uses
  System.Rtti, System.Classes, System.Generics.Collections,
  SlimDirective, SlimContext, SlimMethod;

type
  TInstruction = class
  private
    FId: string;
    FRttiContextInitialized: Boolean;
    FRttiContext: TRttiContext;
    FInstructions: array of TInstruction;
    procedure SetId(const Value: string);
  protected
    FCurrentContext: TSlimContext;
    function RttiContext: TRttiContext;
    function GetLength: Integer; virtual;
  public
    constructor Create; overload;
    constructor Create(pId: string); overload;
    destructor Destroy; override;

    property Id: string read FId write SetId;
    property Count: Integer read GetLength;
    function GetItem(pIndex: Integer): TInstruction;
    function Execute(pContext: TSlimContext): TSlimDirective; virtual;
    procedure Add(pItem: TInstruction);
 end;

  TListInstruction = class(TInstruction)
  public
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

  TMakeInstruction = class(TInstruction)
  private
    FArguments: TStrings;
    FInstanceName: string;
    FClassToMake: string;
    function FindType(pContext: TSlimContext) : TRttiInstanceType;
    function GetQualifiedNamesToTry(pContext: TSlimContext) : TStrings;
    function CreateInstance(pRttiType: TRttiInstanceType) : TObject;
    function GetArguments(pMethod: TRttiMethod): TArray<TValue>;
    procedure SetClassToMake(const Value: string);
    procedure SetInstanceName(const Value: string);
  public
    constructor Create; overload;
    constructor Create(const pId, pClassToMake, pInstanceName: string); overload;
    destructor Destroy; override;

    property InstanceName: string read FInstanceName write SetInstanceName;
    property ClassToMake: string read FClassToMake write SetClassToMake;
    property Arguments: TStrings read FArguments;
    procedure AddArgument(const pArgument: string);
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

  TImportInstruction = class(TInstruction)
  private
    FPath: string;
    procedure SetPath(const Value: string);
  public
    constructor Create; overload;
    constructor Create(const pId, pPath: string); overload;

    property Path: string read FPath write SetPath;
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

  TCallInstruction = class(TInstruction)
  protected
    FArguments: TStrings;
    FInstanceName: string;
    FFunctionName: string;
    FVariableName: string;
    function MethodToCall: TRttiMethod;
    function InstanceType: TRttiType;
    function Instance: TObject;
    function SlimMethod: TSlimMethod;
    function SearchSuitableInstance: TInstance;
  private
    function FixMethodNamesWithDelphiReservedWords(methodName: string): string;
    procedure SetFunctionName(const Value: string);
    procedure SetInstanceName(const Value: string);
    procedure SetVariableName(const Value: string);
  public
    constructor Create; overload;
    constructor Create(const pInstanceToCall, pFunctionToCall: string); overload;
    constructor Create(const pId, pInstanceName, pFunctionToCall: string); overload;
    destructor Destroy; override;

    property InstanceName: string read FInstanceName write SetInstanceName;
    property FunctionName: string read FFunctionName write SetFunctionName;
    property VariableName: string read FVariableName write SetVariableName;
    property Arguments: TStrings read FArguments;
    procedure AddArgument(const pArgument: string); overload;
    procedure AddArgument(pArgument: TStringListList); overload;
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

  TCallAndAssignInstruction = class(TCallInstruction)
  public
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

  TAssignInstruction = class(TInstruction)
  private
    FVariableName: string;
    FVariableValue: string;
    procedure SetVariableName(const Value: string);
    procedure SetVariableValue(const Value: string);
  public
    constructor Create;

    property VariableName: string read FVariableName write SetVariableName;
    property VariableValue: string read FVariableValue write SetVariableValue;
    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

implementation

uses
  System.SysUtils,
  Slim.Logger;

{ TInstruction }

procedure TInstruction.Add(pItem: TInstruction);
var
  l: Integer;
begin
  l := GetLength();
  SetLength(FInstructions, l + 1);
  FInstructions[l] := pItem;
end;

constructor TInstruction.Create;
begin
  FID := string.Empty;
end;

constructor TInstruction.Create(pId: string);
begin
  FId := pId;
end;

destructor TInstruction.Destroy;
var
  i: Integer;
begin
  for i := 0 to GetLength - 1 do
  begin
    GetItem(i).Free;
  end;

  inherited;
end;

function TInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  Result := TSlimDirective.Create;
  Result.Add(Id);
end;

function TInstruction.GetItem(pIndex: Integer): TInstruction;
begin
  Result := FInstructions[pIndex];
end;

function TInstruction.GetLength: Integer;
begin
  Result := Length(FInstructions);
end;

function TInstruction.RttiContext: TRttiContext;
begin
  if not FRttiContextInitialized then
    FRttiContext := TRttiContext.Create;
  Result := FRttiContext;
end;

procedure TInstruction.SetId(const Value: string);
begin
  FId := Value;
end;

{ TMakeInstruction }

constructor TMakeInstruction.Create;
begin
  inherited;
  FArguments := TStringList.Create;
  FClassToMake := string.Empty;
  FInstanceName := string.Empty;
end;

procedure TMakeInstruction.AddArgument(const pArgument: string);
begin
  Arguments.Add(pArgument);
end;

constructor TMakeInstruction.Create(const pId, pClassToMake, pInstanceName: string);
begin
  inherited Create(pId);
  FArguments := TStringList.Create;
  FClassToMake := pClassToMake;
  FInstanceName := pInstanceName;
end;

destructor TMakeInstruction.Destroy;
begin
  FArguments.Free;
  inherited;
end;

function TMakeInstruction.Execute(pContext: TSlimContext): TSlimDirective;
var
  foundType: TRttiInstanceType;
begin
  Result := inherited;
  foundType := FindType(pContext);
  if foundType = nil then
    Result.Add('__EXCEPTION__:message:<<NO_CLASS ' + ClassToMake + '>>')
  else
  begin
    try
      pContext.ReplaceVariables(Arguments);
      pContext.RegisterInstance(InstanceName, ClassToMake, Arguments.CommaText, CreateInstance(foundType));
      Result.Add('OK');
    except
      on E: Exception do
      begin
        Result.Add('__EXCEPTION__:message:<<' + E.Message + '>>');
      end;
    end;
  end;
end;

function TMakeInstruction.CreateInstance(pRttiType: TRttiInstanceType): TObject;
var
  msg: string;
  instance: TValue;
  methods: TArray<TRttiMethod>;
  methodIndex: Integer;
begin
  try
    methods := pRttiType.GetMethods('Create');
    methodIndex := 0;
    while High(methods[methodIndex].GetParameters) <> Arguments.Count - 1 do
      Inc(methodIndex);
    instance := methods[methodIndex].Invoke(pRttiType.MetaclassType, GetArguments(methods[methodIndex]));
    Result := instance.AsObject;
  except
    on E: Exception do
    begin
      msg := E.ClassName + ': ' + E.Message;
      Log(msg);
      raise Exception.Create(msg);
    end;
  end;
end;

function TMakeInstruction.GetArguments(pMethod: TRttiMethod): TArray<TValue>;
begin
  Result := TSlimMethod.BuildArgValues(pMethod, Arguments);
end;

function TMakeInstruction.FindType(pContext: TSlimContext): TRttiInstanceType;
var
  qualifiedName: string;
  qualifiedNamesList: TStrings;
begin
  Result := nil;
  qualifiedNamesList := GetQualifiedNamesToTry(pContext);
  try
    for qualifiedName in qualifiedNamesList do
    begin
      Result := RttiContext.FindType(qualifiedName) as TRttiInstanceType;
      if Result <> nil then
        Break;
    end;
  finally
    qualifiedNamesList.Free;
  end;
end;

function TMakeInstruction.GetQualifiedNamesToTry(pContext: TSlimContext): TStrings;
var
  importPath: string;
begin
  Result := TStringList.Create;
  Result.Add(ClassToMake);
  for importPath in pContext.ImportPaths do
  begin
    Result.Add(importPath + '.' + ClassToMake);
  end;
end;

procedure TMakeInstruction.SetClassToMake(const Value: string);
begin
  FClassToMake := Value;
end;

procedure TMakeInstruction.SetInstanceName(const Value: string);
begin
  FInstanceName := Value;
end;

{ TImportInstruction }

constructor TImportInstruction.Create(const pId, pPath: string);
begin
  inherited Create(pId);
  FPath := pPath;
end;

constructor TImportInstruction.Create;
begin
  inherited;
  FPath := string.Empty;
end;

function TImportInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  Result := inherited;
  Result.Add('OK');
  pContext.AddImportPath(Path);
end;

procedure TImportInstruction.SetPath(const Value: string);
begin
  FPath := Value;
end;

{ TCallInstruction }

constructor TCallInstruction.Create;
begin
  inherited;
  FArguments := TStringList.Create;
end;

constructor TCallInstruction.Create(const pInstanceToCall, pFunctionToCall: string);
begin
  inherited Create;
  FArguments := TStringList.Create;
  FFunctionName := FixMethodNamesWithDelphiReservedWords(pFunctionToCall);
  FInstanceName := pInstanceToCall;
end;

constructor TCallInstruction.Create(const pId, pInstanceName, pFunctionToCall: string);
begin
  inherited Create(pId);
  FArguments := TStringList.Create;
  FFunctionName := FixMethodNamesWithDelphiReservedWords(pFunctionToCall);
  FInstanceName := pInstanceName;
end;

destructor TCallInstruction.Destroy;
begin
  FArguments.Free;
  inherited;
end;

function TCallInstruction.FixMethodNamesWithDelphiReservedWords(methodName: string): string;
begin
  Result := methodName;
  //Note: Dynamic Decision Table (http://fitnesse.org/FitNesse.FullReferenceGuide.UserGuide.WritingAcceptanceTests.SliM.DynamicDecisionTable)
  //calls 'set' and 'get' functions to pass the cell values.
  //But 'set' is a Delphi reserved word, so you can't declare a function named as 'set'
  //For the sake of consistency I replace both 'set' and 'get' calls to 'setValue' and 'getValue'
  if (methodName.ToLower.CompareTo('get') = 0) or (methodName.ToLower.CompareTo('set') = 0) then
    Result := methodName + 'Value';
end;

procedure TCallInstruction.AddArgument(const pArgument: string);
begin
  Arguments.Add(pArgument);
end;

procedure TCallInstruction.AddArgument(pArgument: TStringListList);
begin
  // pArgument is owned by TSlimContext, TCallInstruction is used by TSlimContext and freed by the latter
  Arguments.AddObject('OBJ', pArgument);
end;

function TCallInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  Result := inherited;
  FCurrentContext := pContext;
  pContext.ReplaceVariables(Arguments);
  Result.Add(SlimMethod.Call(Arguments));
end;

function TCallInstruction.SlimMethod: TSlimMethod;
begin
  if MethodToCall = nil then
    Result := TNullSlimMethod.Create
  else
    Result := TSlimMethod.Create;

  Result.FunctionName := FunctionName;
  Result.Instance := Instance;
end;

function TCallInstruction.MethodToCall: TRttiMethod;
var
  suitableInstance: TInstance;
begin
  suitableInstance := SearchSuitableInstance;
  if suitableInstance.InstancedObject <> nil then
    Result :=  RttiContext.GetType(suitableInstance.InstancedObject.ClassType).GetMethod(FunctionName)
  else
    Result := nil;
end;

function TCallInstruction.SearchSuitableInstance: TInstance;
var
  registeredInstances: TList<TInstance>;
  i: integer;
begin
  registeredInstances := FCurrentContext.GetRegisteredInstances;
  Result.InstancedObject := nil;

  //Posible instances are searched in reversed order
  //See: http://www.fitnesse.org/FitNesse.UserGuide.WritingAcceptanceTests.SliM.SlimProtocol
  i := registeredInstances.Count - 1;
  while (i >= 0) and (Result.InstancedObject = nil) do
  begin
    if (RttiContext.GetType(registeredInstances[i].InstancedObject.ClassType).GetMethod(FunctionName) <> nil) then
        Result := registeredInstances[i];
    Dec(i);
  end;
end;

procedure TCallInstruction.SetFunctionName(const Value: string);
begin
  FFunctionName := FixMethodNamesWithDelphiReservedWords(Value);
end;

procedure TCallInstruction.SetInstanceName(const Value: string);
begin
  FInstanceName := Value;
end;

procedure TCallInstruction.SetVariableName(const Value: string);
begin
  FVariableName := Value;
end;

function TCallInstruction.InstanceType: TRttiType;
begin
  Result := RttiContext.GetType(Instance.ClassType);
end;

function TCallInstruction.Instance: TObject;
begin
  Result := SearchSuitableInstance.InstancedObject;
  if Result = nil then
    Result := FCurrentContext.GetRegisteredInstances[FCurrentContext.GetRegisteredInstances.Count - 1].InstancedObject;
end;

{ TListInstruction }

function TListInstruction.Execute(pContext: TSlimContext): TSlimDirective;
var
  i: Integer;
begin
  try
    Result := TSlimDirective.Create;
    WriteLn(Output, 'Ejecutando llamadas');
    InternalLog('Ejecutando llamadas');

    for i := 0 to GetLength - 1 do
    begin
      Result.Add(GetItem(i).Execute(pContext));
    end;
  except
    on E: Exception do
    begin
      Log(E.ClassName + ': ' + E.Message);
      raise;
    end;
  end;
end;

{ TCallAndAssignInstruction }

function TCallAndAssignInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  Result := inherited;
  // Value returned by the 'TCallInstruction.Execute' call will be the last value of Result.
  // That value must be added to the context
  FCurrentContext.SetVariable(VariableName, Result.GetItemValue(Result.Count - 1));
end;

{ TAssignInstruction }

constructor TAssignInstruction.Create;
begin
  inherited;

  FVariableName := string.Empty;
  FVariableValue := string.Empty;
end;

function TAssignInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  Result := inherited;
  try
    FCurrentContext := pContext;
    FCurrentContext.SetVariable(VariableName, VariableValue);
     Result.Add('OK');
  except
    on E: Exception do
      Result.Add('__EXCEPTION__:message:<<' + E.Message + '>>');
  end;
end;

procedure TAssignInstruction.SetVariableName(const Value: string);
begin
  FVariableName := Value;
end;

procedure TAssignInstruction.SetVariableValue(const Value: string);
begin
  FVariableValue := Value;
end;

end.
