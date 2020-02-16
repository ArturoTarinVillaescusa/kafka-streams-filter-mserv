unit TestInstructionExecutor;

interface

uses
  DUnitX.TestFramework, InstructionExecutor, MockInstruction;

type
  [TestFixture]
  TTestTInstructionExecutor = class
  private
    FExecutor: TInstructionExecutor;
    FMockInstruction: TMockInstruction;
  public
    [Test]
    procedure TestExecution;
    [Test]
    procedure TestExecutionWithContext;
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
end;

implementation

uses
  SlimDirective, SlimContext;

{ TTestTInstructionExecutor }

procedure TTestTInstructionExecutor.SetUp;
begin
  inherited;
  FExecutor := TInstructionExecutor.Create;
  FMockInstruction := TMockInstruction.Create('ok');
end;

procedure TTestTInstructionExecutor.TearDown;
begin
  FMockInstruction.Free; // ??
  FExecutor.Free;
end;

procedure TTestTInstructionExecutor.TestExecution;
var
  result: TSlimDirective;
begin
  result := FExecutor.Execute(FMockInstruction, nil);
  try
    Assert.IsTrue(FMockInstruction.Executed, 'Instruction not executed');
    Assert.AreSame(FMockInstruction.ExecutionResult, result);
  finally
    result.Free;
  end;
end;

procedure TTestTInstructionExecutor.TestExecutionWithContext;
var
  context: TSlimContext;
begin
  context := TSlimContext.Create;
  try
    FExecutor.Execute(FMockInstruction, context);

    Assert.AreSame(context, FMockInstruction.ContextUsed);
  finally
    context.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTInstructionExecutor);

end.
