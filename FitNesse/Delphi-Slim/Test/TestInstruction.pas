unit TestInstruction;

interface

uses
  DUnitX.TestFramework,
  Instruction, SlimContext;

type
  [TestFixture]
  TTestTInstruction = class
  private
    FContext: TSlimContext;
  public
    [Test]
    procedure TestMake;
    [Test]
    procedure TestMakeWithClassNotFound;
    [Test]
    procedure TestListExecution;
    [Test]
    procedure TestImport;
    [Test]
    procedure TestMakeWithImportedPath;
    [Test]
    procedure TestContextGivenToListItems;
    [Test]
    procedure TestCallProcedureWithoutArgs;
    [Test]
    procedure TestCallFunctionWithoutArgs;
    [Test]
    procedure TestCallUnknownMethod;
    [Test]
    procedure TestCallProcedureWithArg;
    [Test]
    procedure TestSetRegularFunctionName;
    [Test]
    procedure TestSetReservedFunctionName;
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
  end;

implementation

uses
  SlimDirective, MockInstruction, DummyFixtures;

{ TTestTInstruction }

procedure TTestTInstruction.SetUp;
begin
  FContext := TSlimContext.Create;
end;

procedure TTestTInstruction.TearDown;
begin
  FContext.Free;
end;

procedure TTestTInstruction.TestMake;
var
  instruction: TMakeInstruction;
  response: TSlimDirective;
begin
  instruction := TMakeInstruction.Create('an_id', 'DummyFixtures.TDummyFixture', 'inst');
  try
    DummyFixtures.TDummyFixture.ClassName; // rtti must load class

    response := instruction.Execute(FContext);
    try
      Assert.IsNotNull(response);
      Assert.AreEqual(2, response.Count);
      Assert.AreEqual('an_id', response.GetItemValue(0));
      Assert.AreEqual('OK', response.GetItemValue(1));
      Assert.AreEqual(FContext.FindInstanceByName('inst').InstancedObject.ClassName, TDummyFixture.ClassName);
    finally
      response.Free;
    end;
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestMakeWithClassNotFound;
var
  instruction: TMakeInstruction;
  response: TSlimDirective;
begin
  instruction := TMakeInstruction.Create('an_id', 'TUnknownClass', '');
  try
    response := instruction.Execute(FContext);
    try
      Assert.IsNotNull(response);
      Assert.AreEqual(2, response.Count);
      Assert.AreEqual('an_id', response.GetItemValue(0));
      Assert.AreEqual('__EXCEPTION__:message:<<NO_CLASS TUnknownClass>>', response.GetItemValue(1));
    finally
      response.Free;
    end;
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestImport;
var
  instruction: TImportInstruction;
  response: TSlimDirective;
begin
  instruction := TImportInstruction.Create('id', 'DummyFixtures');
  try
    response := instruction.Execute(FContext);
    try
      Assert.AreEqual(2, response.Count);
      Assert.AreEqual('id', response.GetItemValue(0));
      Assert.AreEqual('OK', response.GetItemValue(1));
      Assert.AreEqual(0, FContext.ImportPaths.IndexOf('DummyFixtures'));
    finally
      response.Free;
    end;
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestMakeWithImportedPath;
var
  makeResponse: TSlimDirective;
begin
  DummyFixtures.TDummyFixture.ClassName; // rtti must load class
  FContext.AddImportPath('DummyFixtures');

  makeResponse := TMakeInstruction.Create('id', 'TDummyFixture', '').Execute(FContext);
  try
    Assert.AreEqual('OK', makeResponse.GetItemValue(1));
  finally
    makeResponse.Free;
  end;
end;

procedure TTestTInstruction.TestSetRegularFunctionName;
var
  instruction: TCallInstruction;
begin
  instruction := TCallInstruction.Create;

  instruction.FunctionName := 'whateverFunction';
  Assert.AreEqual('whateverFunction', instruction.FunctionName, 'A regular function name should be set as-is');

  instruction.Free;
end;

procedure TTestTInstruction.TestSetReservedFunctionName;
var
  instruction: TCallInstruction;
begin
  instruction := TCallInstruction.Create;

  instruction.FunctionName := 'get';
  Assert.AreEqual('getValue', instruction.FunctionName, 'A function named as "get" should be renamed');

  instruction.FunctionName := 'set';
  Assert.AreEqual('setValue', instruction.FunctionName, 'A function named as "set" should be renamed');

  instruction.Free;
end;

procedure TTestTInstruction.TestListExecution;
var
  instruction: TListInstruction;
  response: TSlimDirective;
begin
  instruction := TListInstruction.Create;
  try
    instruction.Add(TMockInstruction.Create('response_1'));
    instruction.Add(TMockInstruction.Create('response_2'));

    response := instruction.Execute(nil);
    try
      Assert.AreEqual(2, response.Count);
      Assert.AreEqual('response_1', response.GetItemValue(0));
      Assert.AreEqual('response_2', response.GetItemValue(1));
    finally
      response.Free;
    end;
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestContextGivenToListItems;
var
  instruction: TListInstruction;
  childInstruction: TMockInstruction;
begin
  instruction := TListInstruction.Create;
  try
    childInstruction := TMockInstruction.Create;

    instruction.Add(childInstruction);

    instruction.Execute(FContext);

    Assert.AreSame(FContext, childInstruction.ContextUsed);
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestCallProcedureWithoutArgs;
var
  instruction: TCallInstruction;
  dummyFixture: TDummyFixture;
  response: TSlimDirective;
begin
  dummyFixture := TDummyFixture.Create;
  FContext.RegisterInstance('instance', dummyFixture.ClassName, '', dummyFixture);

  instruction := TCallInstruction.Create('id', 'instance', 'DummyMethod');
  try
    response := instruction.Execute(FContext);
    try
      Assert.IsTrue(dummyFixture.DummyMethodCalled, 'I expected the method would be called');
      Assert.AreEqual(2, response.Count);
      Assert.AreEqual('id', response.GetItemValue(0));
      Assert.AreEqual('/__VOID__/', response.GetItemValue(1));
    finally
      response.Free;
    end;
  finally
    instruction.Free;
  end;
end;

procedure TTestTInstruction.TestCallFunctionWithoutArgs;
var
  instruction: TCallInstruction;
  dummyFixture: TDummyFixture;
  response: TSlimDirective;
begin
  dummyFixture := TDummyFixture.Create;
  dummyFixture.TheAnswer := '42';
  FContext.RegisterInstance('instance', dummyFixture.ClassName, '', dummyFixture);
  instruction := TCallInstruction.Create('id', 'instance', 'DummyFunction');

  response := instruction.Execute(FContext);

  Assert.AreEqual('42', response.GetItemValue(1));
end;

procedure TTestTInstruction.TestCallUnknownMethod;
var
  instruction: TCallInstruction;
  response: TSlimDirective;
  dummyFixture: TDummyFixture;
begin
  dummyFixture := TDummyFixture.Create;
  FContext.RegisterInstance('instance', dummyFixture.ClassName, '', dummyFixture);
  instruction := TCallInstruction.Create('id', 'instance', 'UnknownMethod');

  response := instruction.Execute(FContext);

  Assert.AreEqual(2, response.Count);
  Assert.AreEqual('__EXCEPTION__:message:<<NO_METHOD_IN_CLASS UnknownMethod TDummyFixture>>', response.GetItemValue(1));
end;

procedure TTestTInstruction.TestCallProcedureWithArg;
var
  instruction: TCallInstruction;
  dummyFixture: TDummyFixture;
  response: TSlimDirective;
begin
  dummyFixture := TDummyFixture.Create;
  FContext.RegisterInstance('instance', dummyFixture.ClassName, '', dummyFixture);
  instruction := TCallInstruction.Create('id', 'instance', 'MethodWithArg');
  instruction.AddArgument('hello');

  response := instruction.Execute(FContext);

  Assert.AreEqual('hello', dummyFixture.ArgUsedToCallMethod);
  Assert.AreEqual(2, response.Count);
  Assert.AreEqual('id', response.GetItemValue(0));
  Assert.AreEqual('/__VOID__/', response.GetItemValue(1));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTInstruction);

end.
