unit TestInstructionParser;

interface

uses
  DUnitX.TestFramework,
  InstructionParser;

type
  [TestFixture]
  TTestTInstructionParser = class
  private
    FParser: TInstructionParser;
  public
    [Test]
    procedure TestMakeInstruction;
    [Test]
    procedure TestImportInstruction;
    [Test]
    procedure TestCallInstruction;
    [Test]
    procedure TestListOfInstructions;
    [Test]
    procedure TestCallWithArguments;
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
  end;


implementation

uses
  SlimDirective, Instruction;

{ TestTSlimInstructionParser }

procedure TTestTInstructionParser.SetUp;
begin
  FParser := TInstructionParser.Create;
end;

procedure TTestTInstructionParser.TearDown;
begin
  FParser.Free;
end;

procedure TTestTInstructionParser.TestMakeInstruction;
var
  directive: TSlimDirective;
  instruction: TInstruction;
begin
  directive := TSlimDirective.ListWith('id_0').Add('make')
    .Add('instance').Add('AnyClass').Add('argument');

  try
    instruction := FParser.Parse(directive);
    try
      Assert.AreEqual(instruction.ClassName, TMakeInstruction.ClassName);
      Assert.AreEqual('id_0', Instruction.Id);
      Assert.AreEqual('instance', (instruction as TMakeInstruction).InstanceName);
      Assert.AreEqual('AnyClass', (instruction as TMakeInstruction).ClassToMake);
    finally
      instruction.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTInstructionParser.TestImportInstruction;
var
  directive: TSlimDirective;
  instruction: TInstruction;
begin
  directive := TSlimDirective.ListWith('id_import').Add('import').Add('a path');
  try
    instruction := FParser.Parse(directive);
    try
      Assert.AreEqual(instruction.ClassName, TImportInstruction.ClassName);
      Assert.AreEqual('id_import', Instruction.Id);
      Assert.AreEqual('a path', (instruction as TImportInstruction).Path);
    finally
      instruction.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTInstructionParser.TestCallInstruction;
var
  directive: TSlimDirective;
  instruction: TInstruction;
begin
  directive := TSlimDirective.ListWith('id_call').Add('call').Add('instance').Add('function');
  try
    instruction := FParser.Parse(directive);
    try
      Assert.AreEqual(TCallInstruction.ClassName, instruction.ClassName);
      Assert.AreEqual('id_call', Instruction.Id);
      Assert.AreEqual('instance', (instruction as TCallInstruction).InstanceName);
      Assert.AreEqual('function', (instruction as TCallInstruction).FunctionName);
    finally
      instruction.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTInstructionParser.TestCallWithArguments;
var
  directive: TSlimDirective;
  instruction: TInstruction;
  callInstruction: TCallInstruction;
begin
  directive := TSlimDirective.ListWith('id').Add('call').Add('inst').Add('fct').Add('arg1').Add('arg2');
  try
    instruction := FParser.Parse(directive);
    try
      callInstruction := instruction as TCallInstruction;
      Assert.IsNotNull(callInstruction.Arguments);
      Assert.AreEqual(2, callInstruction.Arguments.Count);
    finally
      instruction.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTInstructionParser.TestListOfInstructions;
var
  directive: TSlimDirective;
  instruction: TInstruction;
begin
  directive := TSlimDirective.Create;
  try
    directive.Add(TSlimDirective.ListWith('id_make').Add('make').Add('instance').Add('fixture'));
    directive.Add(TSlimDirective.ListWith('id_call').Add('call').Add('instance').Add('f'));

    instruction := FParser.Parse(directive);
    try
      Assert.AreEqual(instruction.ClassName, TListInstruction.ClassName);
      Assert.AreEqual(2, instruction.Count);
      Assert.AreEqual('id_make', instruction.GetItem(0).Id);
      Assert.AreEqual('id_call', instruction.GetItem(1).Id);
    finally
      instruction.Free;
    end;
  finally
    directive.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTInstructionParser);
end.
