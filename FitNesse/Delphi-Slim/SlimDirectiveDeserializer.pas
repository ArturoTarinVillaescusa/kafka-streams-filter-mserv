unit SlimDirectiveDeserializer;

interface

uses
  SlimDirective;

type
  TSlimDirectiveDeserializer = class
  public
    function Deserialize(const pInput: string): TSlimDirective;
  private
    function ParseString(const pInput: string): TSlimDirective;
    function ParseList(const pInput: string): TSlimDirective;
  end;

implementation

uses
  System.StrUtils, System.SysUtils;

{ TSlimDirectiveDeserializer }

function TSlimDirectiveDeserializer.Deserialize(const pInput: string): TSlimDirective;
var
  lStr: string;
begin
  lStr := RightStr(pInput, Length(pInput) - 7);
  Result := ParseString(lStr);
end;

function TSlimDirectiveDeserializer.ParseString(const pInput: string): TSlimDirective;
var
  lStr: string;
begin
  if pInput.StartsWith('[') then
  begin
    lStr := Copy(pInput, 2,  Length(pInput) - 2);
    Result := ParseList(lStr);
  end
  else
    Result := TSlimStringDirective.Create(pInput);
end;

function TSlimDirectiveDeserializer.ParseList(const pInput: string): TSlimDirective;
var
  i: Integer;
  lStr: string;
  size: Integer;
  count: Integer;
  currentPos: Integer;
  directive: TSlimDirective;
begin
  Result := TSlimDirective.Create;

  currentPos := 8;
  count := StrToInt(LeftStr(pInput, 6));
  for i := 1 to count do
  begin
    size := StrToInt(Copy(pInput, currentPos, 6));
    lStr := Copy(pInput, currentPos + 7, size);
    directive := ParseString(lStr);
    Result.Add(directive);
    Inc(currentPos, 8 + size);
  end;
end;

end.
