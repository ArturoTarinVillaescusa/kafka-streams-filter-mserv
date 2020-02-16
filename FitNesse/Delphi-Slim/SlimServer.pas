unit SlimServer;

interface

uses
  Windows, WinSock,
  System.SyncObjs, SysUtils, Classes,
  IdTCPServer, IdContext, IdGlobal,
  InputProcessor, SlimContext;

type
  EServerDisconnection = class(Exception);

  TSlimServer = class
  private
    FInputProcessor: TInputProcessor;
    FStopServer: TEvent;
    FTcpServer: TIdTCPServer;
    FPort: Integer;
    FSlimContext: TSlimContext;
    FPackagePaths: string;
    procedure TcpServerConnect(pContext: TIdContext);
    procedure TcpServerExecute(pContext: TIdContext);
    procedure WriteToClient(pContext: TIdContext; const pMsg: string; pNewLine: Boolean = False);
    function ReadInput(pContext: TIdContext): string;
    procedure AddPackagesPathsToContext(const pPackagePaths: string);
  public
    constructor Create(pPort: Integer; const pPackagePaths: string);
    destructor Destroy; override;

    property InputProcessor: TInputProcessor read FInputProcessor write FInputProcessor;
    property StopServer: TEvent read FStopServer;
    property SlimContext: TSlimContext read FSlimContext;
    procedure Start;
    procedure Stop;
  end;

implementation

uses
  ActiveX,
  ComObj,
  Slim.Logger;

constructor TSlimServer.Create(pPort: Integer; const pPackagePaths: string);
begin
  FTcpServer := nil;
  FStopServer := TEvent.Create;
  FInputProcessor := TInputProcessor.Create;

  FSlimContext := TSlimContext.Create;
  FPackagePaths := pPackagePaths;
  AddPackagesPathsToContext(FPackagePaths);
  FSlimContext.LoadPackages;

  FPort := pPort;
end;

destructor TSlimServer.Destroy;
begin
  FSlimContext.Free;
  FInputProcessor.Free;
  FStopServer.Free;
  FTcpServer.Free;

  inherited Destroy;
end;

procedure TSlimServer.Start;
begin
  if FTcpServer = nil then
  begin
    FTcpServer := TIdTCPServer.Create(nil);
    FTcpServer.DefaultPort := FPort;
    FTcpServer.OnConnect := TcpServerConnect;
    FTcpServer.OnExecute := TcpServerExecute;
  end;

  FTcpServer.Active := True;
end;

procedure TSlimServer.Stop;
begin
  if FTcpServer <> nil then
    FTcpServer.Active := False;
end;

procedure TSlimServer.AddPackagesPathsToContext(const pPackagePaths: string);
var
  paths: TStrings;
  i: Integer;
begin
  if not pPackagePaths.IsEmpty then
  begin
    paths := TStringList.Create;
    try
      ExtractStrings([';'], [' '], PChar(pPackagePaths), paths);
      for i := 0 to paths.Count - 1 do
        FSlimContext.AddPackagePath(paths[i]);
    finally
      paths.Free;
    end;
  end;
end;

procedure TSlimServer.TcpServerConnect(pContext: TIdContext);
begin
  WriteToClient(pContext, 'Slim -- V0.4', True);
end;

procedure TSlimServer.TcpServerExecute(pContext: TIdContext);
var
  input: string;
  response: TResponse;
begin
  LogMemory('TcpServerExecute Start');
  if GetEnvironmentVariable('DELPHISLIM_WAITS_DEBUGGER') <> '' then
    while not IsDebuggerPresent do
      Sleep(500);
  try
    try
      WriteLn(Output, 'Procesando petición');
      InternalLog('Procesando petición');

      CoInitialize(nil);
      CoInitFlags := 0;

      FSlimContext.Init;

      input := ReadInput(pContext);
      LogMemory('Request processing');
      response := InputProcessor.Process(input, SlimContext);
      try
        LogMemory('Request processed');
        if response.MustDisconnect then
        begin
          pContext.Connection.Disconnect;
          StopServer.SetEvent;
        end
        else
        begin
          WriteToClient(pContext, response.Output);
        end;
      finally
        response.Free;
        LogMemory('Response destroyed');
      end;
    except
      on E: Exception do
        Log(E.ClassName + ': ' + E.Message);
    end;
  finally
    LogMemory('TcpServerExecute Exit');
  end;
end;

function TSlimServer.ReadInput(pContext: TIdContext): string;
var
  sizePart: string;
  tailPart: string;
  size: Integer;
begin
  if pContext.Connection.IOHandler.Connected then
  begin
    sizePart := pContext.Connection.IOHandler.ReadString(6, IndyTextEncoding_UTF8);
    size := sizePart.ToInteger;
    if pContext.Connection.IOHandler.Connected then
    begin
      tailPart := pContext.Connection.IOHandler.ReadString(size + 1, IndyTextEncoding_UTF8);
      Result := sizePart + tailPart;
      Log('<-- ' + Result);
    end
    else
      raise EServerDisconnection.Create('Server shutdown');
  end
  else
    raise EServerDisconnection.Create('Server shutdown');
end;

procedure TSlimServer.WriteToClient(pContext: TIdContext; const pMsg: string; pNewLine: Boolean);
begin
  Log('--> ' + pMsg);
  if pNewLine then
    pContext.Connection.IOHandler.WriteLn(pMsg, IndyTextEncoding_UTF8)
  else
    pContext.Connection.IOHandler.Write(pMsg, IndyTextEncoding_UTF8);
end;

end.
