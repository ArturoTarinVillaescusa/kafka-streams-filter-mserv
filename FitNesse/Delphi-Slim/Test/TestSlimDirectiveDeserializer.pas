unit TestSlimDirectiveDeserializer;

interface

uses
  DUnitX.TestFramework,
  SlimDirectiveDeserializer, SlimDirective;

type
  [TestFixture]
  TTestTSlimDirectiveDeserializer = class
  private
    FDeserializer: TSlimDirectiveDeserializer;
  public
    [Test]
    procedure TestSimpleString;
    [Test]
    procedure TestDirectiveWithListOfOneString;
    [Test]
    procedure TestDirectiveWithTwoStrings;
    [Test]
    procedure TestListInList;
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
  end;

implementation

{ TTestTSlimDirectiveDeserializer }

procedure TTestTSlimDirectiveDeserializer.SetUp;
begin
  FDeserializer := TSlimDirectiveDeserializer.Create;
end;

procedure TTestTSlimDirectiveDeserializer.TearDown;
begin
  FDeserializer.Free;
end;

procedure TTestTSlimDirectiveDeserializer.TestSimpleString;
var
  directive: TSlimDirective;
begin
  directive := FDeserializer.Deserialize('000005:hello');
  try
    Assert.AreEqual(1, directive.Count);
    Assert.IsTrue(directive is TSlimStringDirective);
    Assert.AreEqual('hello', directive.Value);
  finally
    directive.Free;
  end;
end;

procedure TTestTSlimDirectiveDeserializer.TestDirectiveWithListOfOneString;
var
  directive: TSlimDirective;
begin
  directive := FDeserializer.Deserialize('000022:[000001:000007:bonjour:]');
  try
    Assert.AreEqual(1, directive.Count);
    Assert.AreEqual('bonjour', directive.GetItem(0).Value);
    Assert.AreEqual('bonjour', directive.GetItemValue(0));
  finally
    directive.Free;
  end;
end;

procedure TTestTSlimDirectiveDeserializer.TestDirectiveWithTwoStrings;
var
  directive: TSlimDirective;
begin
  directive := FDeserializer.Deserialize('000037:[000002:000005:Hello:000007:world !:]');
  try
    Assert.AreEqual(2, directive.Count);
    Assert.AreEqual('Hello', directive.GetItemValue(0));
    Assert.AreEqual('world !', directive.GetItemValue(1));
  finally
    directive.Free;
  end;
end;

procedure TTestTSlimDirectiveDeserializer.TestListInList;
var
  directive: TSlimDirective;
  sublist: TSlimDirective;
begin
  directive := FDeserializer.Deserialize('000068:[000002:000005:Hello:000041:[000002:000009:wonderful:000007:world !:]:]');
  try
    Assert.AreEqual(2, directive.Count);
    Assert.AreEqual('Hello', directive.GetItemValue(0));
    sublist := directive.GetItem(1);

    Assert.AreEqual(2, sublist.Count);
    Assert.AreEqual('wonderful', sublist.GetItemValue(0));
    Assert.AreEqual('world !', sublist.GetItemValue(1));
  finally
    directive.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTSlimDirectiveDeserializer);

end.
