unit SlimTestFixtures;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Math;

type
  {$M+}
  TTestDynamicDecisionTableFixture = class
  strict protected
    FDatosTabla: TList<TList<string>>;
    FValues: array of Integer;
    FOperation : String;
    FResult : String;
  public
    constructor Create;
    destructor Destroy; override;
  published
    function query: TList<TList<TList<string>>>;
    procedure table(pTable: TList<TList<string>>);
    procedure reset;
    procedure execute;
    function getValue(pColumn: string): string;
    procedure setValue(pColumn, pValue: string);
  end;
  {$M-}

implementation

constructor TTestDynamicDecisionTableFixture.Create();
begin
    SetLength(FValues, 1);
end;

destructor TTestDynamicDecisionTableFixture.Destroy;
begin
  FDatosTabla.Free;
  inherited;
end;

procedure TTestDynamicDecisionTableFixture.execute;
begin
  if FOperation.Equals('+') then
    FResult := SumInt(FValues).ToString
  else if FOperation.Equals('max') then
    FResult := MaxIntValue(FValues).ToString
  else FResult := 'OPERATION NOT FOUND';
end;

function TTestDynamicDecisionTableFixture.query: TList<TList<TList<string>>>;
begin
  Result := nil;
end;

procedure TTestDynamicDecisionTableFixture.reset;
begin
 SetLength(FValues, 1);
 FValues[0] := 0;
end;

procedure TTestDynamicDecisionTableFixture.table(pTable: TList<TList<string>>);
begin
  FDatosTabla := pTable;
end;

function TTestDynamicDecisionTableFixture.getValue(pColumn: string): string;
begin
  if pColumn.Equals('result') then
    Result := FResult
  else
    Result := '';
end;

procedure TTestDynamicDecisionTableFixture.setValue(pColumn, pValue: string);
begin
  if pColumn.Equals('operation') then
  begin
    FOperation := pValue;
  end
  else
  begin
    FValues[Length(FValues)-1] := pValue.ToInteger;
    SetLength(FValues, Length(FValues) + 1);
  end;

end;


end.
