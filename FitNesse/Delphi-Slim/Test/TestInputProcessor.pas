unit TestInputProcessor;

interface

uses
  DUnitX.TestFramework,
  InputProcessor, SlimDirective, InstructionExecutor, Instruction, InstructionParser, SlimContext;

type
  TInstructionEvent = procedure (pInstruction: TInstruction; pContext: TSlimContext) of object;

  TMockInstructionExecutor = class(TInstructionExecutor)
  private
    FOnLastInstruction: TInstructionEvent;
    // FResponse will be freed by the InputProcessor
    FResponse: TSlimDirective;
  public
    constructor Create(pLastInstructionProcedure: TInstructionEvent);

    property Response: TSlimDirective read FResponse write FResponse;

    function Execute(pInstruction: TInstruction; pContext: TSlimContext): TSlimDirective; override;
  end;

  TDirectiveParsedEvent = procedure (pParsedDirective: TSlimDirective) of object;

  TMockInstructionParser = class(TInstructionParser)
  private
    FOnDirectiveParsed: TDirectiveParsedEvent;
    // FInstructionToReturn will be freed by the InputProcessor
    FInstructionToReturn: TInstruction;
  public
    constructor Create(pDirectiveParsedProcedure: TDirectiveParsedEvent);

    property InstructionToReturn: TInstruction read FInstructionToReturn write FInstructionToReturn;

    function Parse(pDirective: TSlimDirective): TInstruction; override;
  end;

  [TestFixture]
  TTestTInputProcessor = class
  private
    FDirectiveParsed: string;
    FLastInstructionID: string;
    [Weak] FLastContextUsed: TSlimContext;

    FProcessor: TInputProcessor;

    FMockInstructionExecutor: TMockInstructionExecutor;
    FMockInstructionParser: TMockInstructionParser;

    procedure DoDirectiveParsed(pParsedDirective: TSlimDirective);
    procedure DoInstructionExecuted(pInstruction: TInstruction; pContext: TSlimContext);
  public
    [Setup]
    procedure SetUp;
    [Test]
    procedure TestBye;
    [Test]
    procedure TestDontDisconnectOnOtherInputs;
    [Test]
    procedure TestInputIsWellProcessed;
    [Test]
    procedure TestContextIsGivenToInstructionExecutor;
  end;

implementation

uses
  System.SysUtils;

{ TTestTInputProcessor }

procedure TTestTInputProcessor.DoDirectiveParsed(pParsedDirective: TSlimDirective);
begin
  if pParsedDirective = nil then
    FDirectiveParsed := string.Empty
  else
    FDirectiveParsed := pParsedDirective.Value;
end;

procedure TTestTInputProcessor.DoInstructionExecuted(pInstruction: TInstruction; pContext: TSlimContext);
begin
  if pInstruction = nil then
    FLastInstructionID := string.Empty
  else
    FLastInstructionID := pInstruction.Id;

  FLastContextUsed := pContext;
end;

procedure TTestTInputProcessor.SetUp;
begin
  FDirectiveParsed := string.Empty;
  FLastInstructionID := string.Empty;
  FLastContextUsed := nil;

  FProcessor := TInputProcessor.Create;
  FMockInstructionExecutor := TMockInstructionExecutor.Create(DoInstructionExecuted);
  FProcessor.InstructionExecutor := FMockInstructionExecutor;
  FMockInstructionParser := TMockInstructionParser.Create(DoDirectiveParsed);
  FProcessor.InstructionParser := FMockInstructionParser;
end;

procedure TTestTInputProcessor.TestBye;
var
  response: TResponse;
begin
  response := FProcessor.Process('000003:bye', nil);
  try
    Assert.IsNotNull(response, 'I need a response');
    Assert.IsTrue(response.MustDisconnect, 'The client must be disconnected');
    Assert.IsEmpty(FDirectiveParsed, 'No directive should be parsed');
    Assert.IsEmpty(FLastInstructionID); //(FMockInstructionExecutor.LastInstruction);
  finally
    response.Free;
  end;
end;

procedure TTestTInputProcessor.TestDontDisconnectOnOtherInputs;
var
  response: TResponse;
begin
  response := FProcessor.Process('hello', nil);
  try
    Assert.IsFalse(response.MustDisconnect, 'The client must not be disconnected');
  finally
    response.Free;
  end;
end;

procedure TTestTInputProcessor.TestInputIsWellProcessed;
const
  EXPECTED_INSTRUCTION_ID = 'INSTRUCTION';
var
  response: TResponse;
  instruction: TInstruction;
begin
  FMockInstructionExecutor.Response := TSlimStringDirective.Create('OK');
  instruction := TInstruction.Create(EXPECTED_INSTRUCTION_ID);
  FMockInstructionParser.InstructionToReturn := instruction;

  response := FProcessor.Process('000005:hello', nil);
  try
    Assert.AreEqual('000002:OK', response.Output);
    Assert.AreEqual(EXPECTED_INSTRUCTION_ID, FLastInstructionID, 'The last instruction wasn''t correct');
    Assert.AreEqual('hello', FDirectiveParsed);
  finally
    response.Free;
  end;
end;

procedure TTestTInputProcessor.TestContextIsGivenToInstructionExecutor;
var
  context: TSlimContext;
begin
  context := TSlimContext.Create;
  try
    FProcessor.Process('000005:hello', context);

    Assert.AreSame(context, FLastContextUsed);
  finally
    context.Free;
  end;
end;

{ TMockInstructionExecutor }

constructor TMockInstructionExecutor.Create(pLastInstructionProcedure: TInstructionEvent);
begin
  FOnLastInstruction := pLastInstructionProcedure;
  FResponse := TSlimStringDirective.Create('any');
end;

function TMockInstructionExecutor.Execute(pInstruction: TInstruction; pContext: TSlimContext): TSlimDirective;
begin
  if Assigned(FOnLastInstruction) then
    FOnLastInstruction(pInstruction, pContext);

  Result := FResponse;
end;

{ TMockInstructionParser }

constructor TMockInstructionParser.Create(pDirectiveParsedProcedure: TDirectiveParsedEvent);
begin
  FOnDirectiveParsed := pDirectiveParsedProcedure;
end;

function TMockInstructionParser.Parse(pDirective: TSlimDirective): TInstruction;
begin
  if Assigned(FOnDirectiveParsed) then
    FOnDirectiveParsed(pDirective);
  Result := FInstructionToReturn;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTInputProcessor);

end.
