unit TestSlimMethod;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestTSlimMethod = class
  public
    [Test]
    procedure TestConvertReturnValueToString;
    [Test]
    procedure TestConvertIntegerArgument;
    [Test]
    procedure TestConvertSeveralIntegerArguments;
  end;

implementation

uses
  System.Classes,
  SlimMethod;

type
  TDummy = class
    function GetInt42: Integer;
    function Successor(pValue: Integer): Integer;
    function Sum(a, b, c: Integer): Integer;
  end;

{ TTestTSlimMethod }

procedure TTestTSlimMethod.TestConvertIntegerArgument;
var
  dummy: TDummy;
  slimMethod: TSlimMethod;
  callResult: string;
begin
  dummy := TDummy.Create;
  try
    slimMethod := TSlimMethod.Create(TDummy.Create, 'Successor');
    try
      callResult := slimMethod.Call(['42']);

      Assert.AreEqual('43', callResult);
    finally
      slimMethod.Free;
    end;
  finally
    dummy.Free;
  end;
end;

procedure TTestTSlimMethod.TestConvertReturnValueToString;
var
  dummy: TDummy;
  slimMethod: TSlimMethod;
  callResult: string;
begin
  dummy := TDummy.Create;
  try
    slimMethod := TSlimMethod.Create(TDummy.Create, 'GetInt42');
    try
      callResult := slimMethod.Call(TStringList.Create);

      Assert.AreEqual('42', callResult);
    finally
      slimMethod.Free;
    end;
  finally
    dummy.Free;
  end;
end;

procedure TTestTSlimMethod.TestConvertSeveralIntegerArguments;
var
  dummy: TDummy;
  slimMethod: TSlimMethod;
  callResult: string;
begin
  slimMethod := TSlimMethod.Create(TDummy.Create, 'Sum');
  dummy := TDummy.Create;
  try
    callResult := slimMethod.Call(['1', '2', '3']);

    Assert.AreEqual('6', callResult);
  finally
    dummy.Free;
  end;
end;

{ TDummy }

function TDummy.GetInt42: Integer;
begin
  Result := 42;
end;

function TDummy.Successor(pValue: Integer): Integer;
begin
  Result := pValue + 1;
end;

function TDummy.Sum(a, b, c: Integer): Integer;
begin
  Result := a + b + c;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTSlimMethod);

end.
