unit Configuration;

interface

const
  LOG_FILE_NAME = 'SlimTests.txt';
  INTERNAL_LOG_FILE_NAME = 'log_interno';

type
  TConfiguration = class
  private
    FLogFileName: string;
    FInternalLogFileName: string;

    function GetLogFilenameFromFile(pFile: string): string;
    function GetLogFilenameFromMemory: string;
    function GetInternalLogFileNameFromMemory: string;
  public
    constructor Create(const pFile: string);

    // Path and name of the log file
    property LogFileName: string read FLogFileName;
    property InternalLogFileName: string read FInternalLogFileName;
  end;

implementation

uses
  // Delphi libraries
  System.SysUtils, System.Inifiles;

{ TConfiguration }

constructor TConfiguration.Create(const pFile: string);
begin
  FLogFileName := GetLogFilenameFromMemory;
  FInternalLogFileName := GetInternalLogFileNameFromMemory;

  if FileExists(pFile) then
    FLogFileName := GetLogFilenameFromFile(pFile);
end;

function TConfiguration.GetLogFilenameFromFile(pFile: string): string;
var
  iniFile: TMemIniFile;
begin
  iniFile := TMemIniFile.Create(pFile);
  try
    Result := iniFile.ReadString('Files', 'LogFileName', GetLogFilenameFromMemory);
  finally
    iniFile.Free;
  end;
end;

function TConfiguration.GetLogFilenameFromMemory: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + LOG_FILE_NAME;
end;

function TConfiguration.GetInternalLogFileNameFromMemory: string;
var
  logPath: string;
begin
  logPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Logs';
  ForceDirectories(logPath);
  Result := IncludeTrailingPathDelimiter(logPath) + INTERNAL_LOG_FILE_NAME + FormatDateTime('dd_mm_yyyy', Now) + '.txt';
end;

end.
