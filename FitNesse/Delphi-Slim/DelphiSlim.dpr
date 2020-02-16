// JCL_DEBUG_EXPERT_GENERATEJDBG ON
program DelphiSlim;

{$SetPEFlags $0020}
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  StrUtils,
  SlimServer in 'SlimServer.pas',
  InputProcessor in 'InputProcessor.pas',
  SlimDirectiveDeserializer in 'SlimDirectiveDeserializer.pas',
  SlimDirective in 'SlimDirective.pas',
  InstructionParser in 'InstructionParser.pas',
  Instruction in 'Instruction.pas',
  InstructionExecutor in 'InstructionExecutor.pas',
  SlimDirectiveSerializer in 'SlimDirectiveSerializer.pas',
  Slim.Logger in 'Slim.Logger.pas',
  SlimContext in 'SlimContext.pas',
  SlimMethod in 'SlimMethod.pas',
  Configuration in 'Configuration.pas';

const
  VERSION='2.03.000';

function LoadConfigFile(const pFilePath: string): TStringList;
begin
  Result := TStringList.Create;
  Result.LoadFromFile(pFilePath);
end;

procedure Start;
var
  port: Integer;
  portStr: string;
  packagesPaths : string;
  slimServer : TSlimServer;
  aFile, configFile: TStringList;
begin
  LogMemory('Delphislim Start');
  aFile := TStringList.Create;
  try
    try
      configFile := LoadConfigFile('bin/bpl.ini');
      try
        packagesPaths := AnsiReplaceStr(configFile.CommaText, ',' , ';');
      finally
        configFile.Free;
      end;

      aFile.Clear;
      aFile.Add(packagesPaths);
      aFile.SaveToFile('bpls_cargados.txt');

      portStr := ParamStr(2);

      aFile.Clear;
      aFile.Add(portStr);
      aFile.SaveToFile('puerto.txt');

      if ( ParamStr(3) = 'memory' ) then
        doMemoryLog := True;

      LogMemory('SlimServer Starting');
      port := StrToInt(portStr);
      slimServer := TSlimServer.Create(port, packagesPaths);
      try
        LogMemory('SlimServer Started');
        WriteLn(Output, 'Goldcar DelphiSlim for FitNesse v' + VERSION);
        WriteLn(Output, 'Servidor lanzado en el puerto: ' + port.ToString);
        InternalLog('Servidor lanzado en el puerto: ' + port.ToString);

        slimServer.Start;

        WriteLn(Output, 'slimServer.Start');
        slimServer.StopServer.WaitFor(INFINITE);
      finally
        LogMemory('SlimServer Destroying');
        slimServer.Free;
        LogMemory('SlimServer Destroyed');
      end;
    except
      on E: Exception do
      begin
        aFile.Add(E.Message);
        aFile.SaveToFile('./errores.txt');
        Log(E.ClassName + ': ' + E.Message);
        InternalLog(E.ClassName + ': ' + E.Message);
      end;
    end;

  finally
    aFile.Free;
    LogMemory('Delphislim End');
  end;
end;

begin
  Start;
end.
