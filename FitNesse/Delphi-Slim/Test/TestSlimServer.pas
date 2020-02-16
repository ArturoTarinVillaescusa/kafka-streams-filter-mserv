unit TestSlimServer;

interface

uses
  DUnitX.TestFramework,
  IdTCPClient,
  SlimServer, InputProcessor, SlimContext;

type
  TMockInputProcessor = class(TInputProcessor)
  public
    ProcessedInput: string;
    ProcessResult: TResponse;
    ContextUsed: TSlimContext;
    constructor Create;
    function Process(const pInput: string; pContext: TSlimContext): TResponse; override;
  end;

  [TestFixture]
  TTestTSlimServer = class
  private
    const HELLO_MSG = '000005:hello';
    const SLEEP_TIME = 5;
  private
    FSlimServer: TSlimServer;
    FClient: TIdTCPClient;
    FMockInputProcessor: TMockInputProcessor;
    FWelcomeLineRead: string;
    function CreateClient(pPort: Integer): TIdTCPClient;
    procedure WriteToServer(const pMsg: string);
    function PackageIsLoaded(const pPackageName: string): Boolean;
  public
    [Test]
    procedure TestWillReceiveVersionOnConnect;
    [Test]
    procedure TestBye;
    [Test]
    procedure TestCommandProcessed;
    [Test]
    procedure TestSeveralCommands;
    [Test]
    procedure TestAContextIsUsed;
    [Test]
    procedure TestTheSameContextIsUsedForEachInput;
    [Test]
    procedure TestPackagePathsAreGivenToContext;
    [Test]
    procedure TestPackagePathsAreGivenToContext2;
    [Test]
    [Ignore('See how to call init context')]
    procedure TestPackagesAreLoaded;
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Rtti,
  IdExceptionCore, IdStack, IdException,
  Slim.Logger;

procedure TTestTSlimServer.SetUp;
begin
  doLog := False;

  FSlimServer := TSlimServer.Create(5555, '');
  FMockInputProcessor := TMockInputProcessor.Create;
  FSlimServer.InputProcessor := FMockInputProcessor;
  FSlimServer.Start;

  FClient := CreateClient(5555);
  FClient.Connect;

  FWelcomeLineRead := FClient.IOHandler.ReadLn();
end;

procedure TTestTSlimServer.TearDown;
begin
  FClient.Disconnect;
  FClient.Free;
  FClient := nil;

  FSlimServer.Stop;
  FSlimServer.Free;

  // FMockInputProcessor is freed by FSlimServer
  FMockInputProcessor := nil;
end;

procedure TTestTSlimServer.TestWillReceiveVersionOnConnect;
begin
  Assert.AreEqual('Slim -- V0.4', FWelcomeLineRead);
end;

procedure TTestTSlimServer.TestBye;
begin
  FMockInputProcessor.ProcessResult := TResponse.Disconnection;

  FClient.IOHandler.Write('000003:bye');

  try
    FClient.IOHandler.ReadLn();
    Assert.Fail('Connection should be closed');
  except
    on EIdConnClosedGracefully do ;
  end;
end;

procedure TTestTSlimServer.TestCommandProcessed;
begin
  WriteToServer(HELLO_MSG);

  Assert.AreEqual(HELLO_MSG, FMockInputProcessor.ProcessedInput);
end;

procedure TTestTSlimServer.TestSeveralCommands;
begin
  WriteToServer(HELLO_MSG);
  FMockInputProcessor.ProcessResult := TResponse.Normal('second response');

  WriteToServer('000006:second');

  Assert.AreEqual('second response', FClient.IOHandler.ReadString(15));
end;

procedure TTestTSlimServer.TestAContextIsUsed;
begin
  WriteToServer(HELLO_MSG);

  Assert.IsNotNull(FMockInputProcessor.ContextUsed);
end;

procedure TTestTSlimServer.TestTheSameContextIsUsedForEachInput;
var
  contextUsedForFirstInput: TSlimContext;
begin
  WriteToServer(HELLO_MSG);
  contextUsedForFirstInput := FMockInputProcessor.ContextUsed;

  // The last mocked response was freed by the server
  FMockInputProcessor.ProcessResult := TResponse.Create;
  WriteToServer('000005:there');

  Assert.AreSame(FMockInputProcessor.ContextUsed, contextUsedForFirstInput);
end;

procedure TTestTSlimServer.TestPackagePathsAreGivenToContext;
var
  anotherServer: TSlimServer;
  context: TSlimContext;
begin
  anotherServer := TSlimServer.Create(1234, 'packagePath1;packagePath2');
  try
    context := anotherServer.SlimContext;

    Assert.IsNotNull(context.PackagePaths);
    Assert.AreEqual(2, context.PackagePaths.Count);
    Assert.AreEqual('packagePath1', context.PackagePaths[0]);
    Assert.AreEqual('packagePath2', context.PackagePaths[1]);
  finally
    anotherServer.Free;
  end;
end;

procedure TTestTSlimServer.TestPackagePathsAreGivenToContext2;
var
  anotherServer: TSlimServer;
  context: TSlimContext;
begin
  anotherServer := TSlimServer.Create(1234, 'pac1;pac 2;pac 3');
  try
    context := anotherServer.SlimContext;

    Assert.IsNotNull(context.PackagePaths);
    Assert.AreEqual(3, context.PackagePaths.Count);
    Assert.AreEqual('pac1', context.PackagePaths[0]);
    Assert.AreEqual('pac 2', context.PackagePaths[1]);
    Assert.AreEqual('pac 3', context.PackagePaths[2]);
  finally
    anotherServer.Free;
  end;
end;

procedure TTestTSlimServer.TestPackagesAreLoaded;
var
  server: TSlimServer;
begin
  server := TSlimServer.Create(1234, '..\..\CompiledUnits\FixturesPackage.bpl');

  Assert.IsTrue(PackageIsLoaded('CompiledUnits\FixturesPackage.bpl'));

  server.SlimContext.Free;
end;

function TTestTSlimServer.PackageIsLoaded(const pPackageName: string): Boolean;
var
  rttiContext: TRttiContext;
  packages: TArray<TRttiPackage>;
  i: Integer;
begin
  rttiContext := TRttiContext.Create;
  packages := rttiContext.GetPackages();
 for i := Low(packages) to High(packages) do
  begin
    if  Pos(pPackageName, packages[i].Name) > 0 then
      Exit(True);
  end;
  Exit(False);
end;

function TTestTSlimServer.CreateClient(pPort: Integer): TIdTCPClient;
begin
  Result := TIdTCPClient.Create(nil);
  Result.Port := pPort;
  Result.Host := '127.0.0.1';
  Result.ReadTimeout := 50;
end;

procedure TTestTSlimServer.WriteToServer(const pMsg: string);
begin
  FClient.IOHandler.Write(pMsg);
  Sleep(SLEEP_TIME);
end;

{ TMockInputProcessor }

constructor TMockInputProcessor.Create;
begin
  ProcessResult := TResponse.Create;
end;

function TMockInputProcessor.Process(const pInput: string; pContext: TSlimContext): TResponse;
begin
  ProcessedInput := pInput;
  Result := ProcessResult;
  ContextUsed := pContext;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTSlimServer);
end.
