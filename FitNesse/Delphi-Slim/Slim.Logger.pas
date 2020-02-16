unit Slim.Logger;

interface

var
  doLog: Boolean = True;
  doMemoryLog: Boolean = False;

procedure Log(const pMsg: string);
procedure InternalLog(const pMsg: string);
procedure LogMemory(const pMsg: string);

implementation

uses
  // Delphi Libraries
  WinApi.Windows, WinApi.PsAPI,
  System.SysUtils,
  // Own Libraries
  Configuration;

var
  debugConfiguration: TConfiguration;
  iniFilename, logFileName, InternalLogFileName: string;
  previousMemoryUsage: NativeUInt = 0;
  previousAppMemoryUsage: NativeUInt = 0;

procedure Log(const pMsg : string);
var
  f: TextFile;
begin
  if doLog then
  begin
    AssignFile(f, logFileName);
    if FileExists(logFileName) then
      Append(f)
    else
      ReWrite(f);
    Writeln(f, '[' + DateTimeToStr(Now) + ']: ' + pMsg);
    CloseFile(f);
  end;
end;

procedure InternalLog(const pMsg : string);
var
  f: TextFile;
begin
  if doLog then
  begin
    AssignFile(f, InternalLogFileName);
    if FileExists(InternalLogFileName) then
      Append(f)
    else
      ReWrite(f);
    Writeln(f, '[' + DateTimeToStr(Now) + ']: ' + pMsg);
    CloseFile(f);
  end;
end;

function TotalMemoryInUse: NativeUInt;
var
  pmc: PPROCESS_MEMORY_COUNTERS;
  cb: NativeUInt;
  num: NativeUInt;
begin
  cb := SizeOf(TProcessMemoryCounters);
  GetMem(pmc, cb);
  try
    pmc^.cb := cb;
    if GetProcessMemoryInfo(GetCurrentProcess(), pmc, cb) then
      num := pmc^.WorkingSetSize
    else
      num := 0;
    Result := num; // / 1024 / 1000;
  finally
   FreeMem(pmc);
  end;
end;

function MemoryReservedByApp: NativeUInt;
var
  st: TMemoryManagerState;
  sb: TSmallBlockTypeState;
begin
  GetMemoryManagerState(st);
  Result := st.TotalAllocatedMediumBlockSize + st.TotalAllocatedLargeBlockSize;
  for sb in st.SmallBlockTypeStates do
  begin
     Result := Result + sb.UseableBlockSize * sb.AllocatedBlockCount;
  end;
end;

procedure LogMemory(const pMsg : string);
var
  usedMemory, appMemory: NativeUInt;
  memoryDelta, appMemoryDelta: NativeInt;
begin
  if doMemoryLog then
  begin
    usedMemory := TotalMemoryInUse;
    appMemory := MemoryReservedByApp;

    memoryDelta := UsedMemory - previousMemoryUsage;
    appMemoryDelta := appMemory - previousAppMemoryUsage;


    Log(Format('[MEM] <%s> PROCESS USAGE: %d (d:%d) APP: %d (d:%d)', [pMsg, UsedMemory, memoryDelta, appMemory, appMemoryDelta]));
    previousMemoryUsage := UsedMemory;
    previousAppMemoryUsage := appMemory;
  end;
end;

initialization

  iniFilename := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'DelphiSlim.ini';

  debugConfiguration := TConfiguration.Create(iniFilename);
  try
   logFileName := debugConfiguration.LogFileName;
   InternalLogFileName := debugConfiguration.InternalLogFileName;
  finally
   debugConfiguration.Free;
  end;

end.
