unit SlimDirective;

interface

uses
  System.Generics.Collections;

type
  TStringListList = TList<TList<string>>;

  TSlimDirective = class
  private
    FDirectives: array of TSlimDirective;
  protected
    procedure ClearDirectives; virtual;
    function GetValue: string; virtual;
    function GetLength: Integer; virtual;
  public
    constructor ListWith(const pDirective: string);
    destructor Destroy; override;

    function GetItem(pIndex: Integer): TSlimDirective;
    function GetItemValue(pIndex: Integer): string;
    function GetItemList(pIndex: Integer): TStringListList;
    function Add(pDirective: TSlimDirective): TSlimDirective; overload;
    function Add(const pDirective: string): TSlimDirective; overload;
    property Count: Integer read GetLength;
    property Value: string read GetValue;
  end;

  TSlimStringDirective = class(TSlimDirective)
  private
    FValue: string;
  protected
    procedure ClearDirectives; override;
    function GetValue: string; override;
    function GetLength: Integer; override;
  public
    constructor Create(const pValue: string);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

{ TSlimDirective }

function TSlimDirective.Add(pDirective: TSlimDirective): TSlimDirective;
var
  l: Integer;
begin
  l := Count;
  SetLength(FDirectives, l + 1);
  FDirectives[l] := pDirective;
  Result := Self;
end;

function TSlimDirective.Add(const pDirective: string): TSlimDirective;
begin
  Add(TSlimStringDirective.Create(pDirective));
  Result := Self;
end;

function TSlimDirective.GetItem(pIndex: Integer): TSlimDirective;
begin
  Result := FDirectives[pIndex];
end;

function TSlimDirective.GetItemValue(pIndex: Integer): string;
begin
  if GetItem(pIndex) <> nil then
    Result := GetItem(pIndex).Value
  else
    Result := string.Empty;
end;

function TSlimDirective.GetItemList(pIndex: Integer): TStringListList;
var
  i, j: Integer;
  rows, cols: TSlimDirective;
begin
  rows := GetItem(pIndex);
  Result := TList<TList<string>>.Create;
  for i := 0 to rows.Count - 1 do
  begin
    Result.Add(TList<string>.Create);
    cols := rows.GetItem(i);
    for j := 0 to cols.Count - 1 do
    begin
      Result[i].Add(cols.GetItemValue(j));
    end;
  end;
end;

function TSlimDirective.GetLength: Integer;
begin
  Result := Length(FDirectives);
end;

function TSlimDirective.GetValue: string;
begin
  Result :=  string.Empty;
end;

constructor TSlimDirective.ListWith(const pDirective: string);
begin
  Add(pDirective);
end;

procedure TSlimDirective.ClearDirectives;
var
  i: Integer;
begin
  for i := 0 to Length(FDirectives) - 1 do
    GetItem(i).Free;
end;

destructor TSlimDirective.Destroy;
begin
  ClearDirectives;

  inherited;
end;

{ TSlimStringDirective }

procedure TSlimStringDirective.ClearDirectives;
begin
  FValue := string.Empty;
end;

constructor TSlimStringDirective.Create(const pValue: string);
begin
  FValue := pValue;
end;

destructor TSlimStringDirective.Destroy;
begin

  inherited;
end;

function TSlimStringDirective.GetLength: Integer;
begin
  Result := 1;
end;

function TSlimStringDirective.GetValue: string;
begin
  Result := FValue;
end;

end.
