unit SlimDirectiveSerializer;

interface

uses
  System.Generics.Collections,
  SlimDirective;

type
  TStringListListList = TList<TList<TList<string>>>;

  TSlimDirectiveSerializer = class
  public
    function Serialize(pDirective: TSlimDirective; shouldReturnLengthInBytes: Boolean = True): string;
    class function QueryResultToString(pQueryResult: TStringListListList): string;
  private
    class function LengthString(pLen: Integer): string; overload;
    class function LengthString(const pStr: string): string; overload;
  end;

implementation

uses
  System.SysUtils, System.StrUtils,
  Slim.Logger;

{ TSlimDirectiveSerializer }

function TSlimDirectiveSerializer.Serialize(pDirective: TSlimDirective; shouldReturnLengthInBytes: Boolean): string;
var
  i: Integer;
begin
  if pDirective is TSlimStringDirective then
  begin
    Result := LengthString(pDirective.Value) + ':' + pDirective.Value;
  end
  else
  begin
    Result := '[' + LengthString(pDirective.Count) + ':';
    for i := 0 to pDirective.Count - 1 do
    begin
      Result := Result + Serialize(pDirective.GetItem(i), False) + ':';
    end;
    Result := Result + ']';
    if shouldReturnLengthInBytes then
      Result := LengthString(Length(UTF8String(Result))) + ':' + Result
    else
      Result := LengthString(Result.Length) + ':' + Result;
  end;
end;

class function TSlimDirectiveSerializer.LengthString(pLen: Integer): string;
begin
  Result := IntToStr(pLen);
  Result := DupeString('0', 6 - Length(Result)) + Result;
end;

class function TSlimDirectiveSerializer.LengthString(const pStr: string): string;
begin
  Result := LengthString(pStr.Length);
end;

class function TSlimDirectiveSerializer.QueryResultToString(pQueryResult: TStringListListList): string;
var
  i, j, k: Integer;
  pairValue, row: string;
begin
  for i := 0  to pQueryResult.Count - 1 do
  begin
    row := string.Empty;
    for j := 0  to pQueryResult[i].Count - 1 do
    begin
      pairValue := '';
      for k := 0  to pQueryResult[i][j].Count - 1 do
      begin
        pairValue := pairValue + LengthString(pQueryResult[i][j][k]) + ':' + pQueryResult[i][j][k] + ':';
      end;
      pairValue := '[' + LengthString(pQueryResult[i][j].Count) + ':' + pairValue + ']';
      row := row + ':' + LengthString(pairValue) + ':' + pairValue;
    end;
    row := '[' + LengthString(pQueryResult[i].Count) + row + ':]';
    Result := Result + ':' + LengthString(row) + ':' + row;
  end;
  Result := '[' + LengthString(pQueryResult.Count) + Result + ':]';
end;

end.
