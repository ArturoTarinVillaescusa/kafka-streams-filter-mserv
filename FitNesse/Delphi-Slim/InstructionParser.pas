unit InstructionParser;

interface

uses
  SlimDirective, Instruction;

type
  TInstructionBuilder = class
  public
    function Build(pDirective: TSlimDirective): TInstruction;
  protected
    function DoBuild(pDirective: TSlimDirective): TInstruction; virtual; abstract;
  end;

  TListInstructionBuilder = class(TInstructionBuilder)
  protected
    function DoBuild(pDirective: TSlimDirective): TInstruction; override;
  end;

  TImportInstructionBuilder = class(TInstructionBuilder)
  public
    function DoBuild(pDirective: TSlimDirective): TInstruction; override;
  end;

  TMakeInstructionBuilder = class(TInstructionBuilder)
  public
    function DoBuild(pDirective: TSlimDirective): TInstruction;  override;
  end;

  TCallInstructionBuilder = class(TInstructionBuilder)
  public
    function DoBuild(pDirective: TSlimDirective): TInstruction; override;
  end;

  TCallAndAssignInstructionBuilder = class(TInstructionBuilder)
  public
    function DoBuild(pDirective: TSlimDirective): TInstruction; override;
  end;

  TAssignInstructionBuilder = class(TInstructionBuilder)
  public
    function DoBuild(pDirective: TSlimDirective): TInstruction; override;
  end;

  TInstructionParser = class
  public
    function Parse(pDirective: TSlimDirective): TInstruction; virtual;
  private
    function GetInstructionBuilder(pDirective: TSlimDirective): TInstructionBuilder;
  end;

implementation

uses
  Slim.Logger, SysUtils;

{ TInstructionParser }

function TInstructionParser.GetInstructionBuilder(pDirective: TSlimDirective): TInstructionBuilder;
begin
  if pDirective.GetItem(0) is TSlimStringDirective then
  begin
    if pDirective.GetItemValue(1) = 'make' then
      Exit(TMakeInstructionBuilder.Create)
    else if pDirective.GetItemValue(1) = 'import' then
      Exit(TImportInstructionBuilder.Create)
    else if pDirective.GetItemValue(1) = 'call' then
      Exit(TCallInstructionBuilder.Create)
    else if pDirective.GetItemValue(1) = 'callAndAssign' then
      Exit(TCallAndAssignInstructionBuilder.Create)
    else if pDirective.GetItemValue(1) = 'assign' then
      Exit(TAssignInstructionBuilder.Create)
    else
      Exit(nil);
  end
  else
    Exit(TListInstructionBuilder.Create);
end;

function TInstructionParser.Parse(pDirective: TSlimDirective): TInstruction;
var
  instructionBuilder: TInstructionBuilder;
begin
  instructionBuilder := GetInstructionBuilder(pDirective);
  try
    Result := instructionBuilder.Build(pDirective);
  finally
    instructionBuilder.Free;
  end;
end;

{ TInstructionBuilder }

function TInstructionBuilder.Build(pDirective: TSlimDirective): TInstruction;
begin
  Result := DoBuild(pDirective);
  Result.Id := pDirective.GetItemValue(0);
end;

{ TMakeInstructionBuilder }

function TMakeInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  i: Integer;
  makeInstruction: TMakeInstruction;
begin
  makeInstruction := TMakeInstruction.Create;
  makeInstruction.InstanceName := pDirective.GetItemValue(2);
  makeInstruction.ClassToMake := pDirective.GetItemValue(3);
  for i := 4 to pDirective.Count - 1 do
    makeInstruction.AddArgument(pDirective.GetItemValue(i));
  Exit(makeInstruction);
end;

{ TImportInstructionBuilder }

function TImportInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  importInstruction: TImportInstruction;
begin
  importInstruction := TImportInstruction.Create;
  importInstruction.Path := pDirective.GetItemValue(2);
  Exit(importInstruction);
end;

{ TCallInstructionBuilder }

function TCallInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  i: Integer;
  callInstruction: TCallInstruction;
begin
  callInstruction := TCallInstruction.Create(pDirective.GetItemValue(2), pDirective.GetItemValue(3));
  for i := 4 to pDirective.Count - 1 do
  begin
    if (pDirective.GetItem(i).Count > 1) and (callInstruction.FunctionName.Equals('table')) then
      callInstruction.AddArgument(pDirective.GetItemList(i))
    else
      callInstruction.AddArgument(pDirective.GetItemValue(i));
  end;
  Exit(callInstruction);
end;

{ TListInstructionBuilder }

function TListInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  i: Integer;
  parser: TInstructionParser;
  instruction: TInstruction;
begin
  Result := TListInstruction.Create;
  for i := 0 to pDirective.Count - 1 do
  begin
    parser := TInstructionParser.Create;
    try
      instruction := parser.Parse(pDirective.GetItem(i));
      Result.Add(instruction);
    finally
      parser.Free;
    end;
  end;
end;

{ TCallAndAssignInstructionBuilder }

function TCallAndAssignInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  i: Integer;
  callAndAssignInstruction: TCallAndAssignInstruction;
begin
  callAndAssignInstruction := TCallAndAssignInstruction.Create;
  callAndAssignInstruction.VariableName := pDirective.GetItemValue(2);
  callAndAssignInstruction.InstanceName := pDirective.GetItemValue(3);
  callAndAssignInstruction.FunctionName := pDirective.GetItemValue(4);
  for i := 5 to pDirective.Count - 1 do
    callAndAssignInstruction.AddArgument(pDirective.GetItemValue(i));
  Exit(callAndAssignInstruction);
end;

{ TAssignInstructionBuilder }

function TAssignInstructionBuilder.DoBuild(pDirective: TSlimDirective): TInstruction;
var
  assignInstruction: TAssignInstruction;
begin
  assignInstruction := TAssignInstruction.Create;
  assignInstruction.VariableName := pDirective.GetItemValue(2);
  assignInstruction.VariableValue := pDirective.GetItemValue(3);
  Exit(assignInstruction);
end;

end.
