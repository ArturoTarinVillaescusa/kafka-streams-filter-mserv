unit TestSlimDirectiveSerializer;

interface

uses
  DUnitX.TestFramework,
  SlimDirective, SlimDirectiveSerializer;

type
  [TestFixture]
  TTestTSlimDirectiveSerializer = class
  public
    [Test]
    procedure TestSimpleString;
    [Test]
    procedure TestList;
    [Test]
    procedure TestListInList;
  end;

implementation

{ TTestTSlimDirectiveSerializer }

procedure TTestTSlimDirectiveSerializer.TestSimpleString;
var
  directive: TSlimDirective;
  serializer: TSlimDirectiveSerializer;
  result: string;
begin
  directive := TSlimStringDirective.Create('hello');
  try
    serializer := TSlimDirectiveSerializer.Create;
    try
      result := serializer.Serialize(directive);

      Assert.AreEqual('000005:hello', result);
    finally
      serializer.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTSlimDirectiveSerializer.TestList;
var
  directive: TSlimDirective;
  serializer: TSlimDirectiveSerializer;
  result: string;
begin
  directive := TSlimDirective.Create().Add('one').Add('two');
  try
    serializer := TSlimDirectiveSerializer.Create;
    try
      result := serializer.Serialize(directive);

      Assert.AreEqual('000031:[000002:000003:one:000003:two:]', result);
    finally
      serializer.Free;
    end;
  finally
    directive.Free;
  end;
end;

procedure TTestTSlimDirectiveSerializer.TestListInList;
var
  directive: TSlimDirective;
  serializer: TSlimDirectiveSerializer;
  result: string;
begin
  directive := TSlimDirective.Create().Add('one').Add(TSlimDirective.Create().Add('21').Add('22'));
  try
    serializer := TSlimDirectiveSerializer.Create;
    try
      result := serializer.Serialize(directive);

      Assert.AreEqual('000057:[000002:000003:one:000029:[000002:000002:21:000002:22:]:]', result);
    finally
      serializer.Free;
    end;
  finally
    directive.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTSlimDirectiveSerializer);

end.
