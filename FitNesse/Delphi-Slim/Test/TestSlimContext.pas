unit TestSlimContext;

interface

uses
  DUnitX.TestFramework,
  SlimContext;

type
  [TestFixture]
  TTestTSlimMethod = class
  private
    FContext: TSlimContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestInitWithoutLibraries;
    [Test]
    procedure TestInitWithLibraries;
  end;

implementation

type
  TTest1 = class

  end;

  TTest2 = class

  end;

  TLibrary1 = class

  end;

{ TTestTSlimMethod }

procedure TTestTSlimMethod.Setup;
begin
  FContext := TSlimContext.Create;
end;

procedure TTestTSlimMethod.TearDown;
begin
  FContext.Free;
end;

procedure TTestTSlimMethod.TestInitWithLibraries;
var
  test1: TTest1;
  test2: TTest2;
  libraryTest: TLibrary1;
begin
  test1 := TTest1.Create;
  test2 := TTest2.Create;
  libraryTest := TLibrary1.Create;

  FContext.RegisterInstance('TestInstance1', 'TTest1', '', test1);
  FContext.RegisterInstance('TestInstance2', 'TTest2', '', test2);
  FContext.RegisterInstance('LibraryTestInstance', 'TLibrary1', '', libraryTest);

  Assert.IsNotNull(FContext.FindInstanceByName('TestInstance1').InstancedObject);
  Assert.IsNotNull(FContext.FindInstanceByName('TestInstance2').InstancedObject);
  Assert.IsNotNull(FContext.FindInstanceByName('LibraryTestInstance').InstancedObject);

  FContext.Init;

  Assert.IsNotNull(FContext.FindInstanceByName('LibraryTestInstance').InstancedObject);

  try
    Assert.IsNull(FContext.FindInstanceByName('TestInstance1').InstancedObject);
    Assert.Fail('Test Instance 1 was found after initialization');
  except

  end;

  try
    Assert.IsNull(FContext.FindInstanceByName('TestInstance2').InstancedObject);
    Assert.Fail('Test Instance 2 was found after initialization');
  except

  end;

end;

procedure TTestTSlimMethod.TestInitWithoutLibraries;
var
  test1: TTest1;
  test2: TTest2;
begin
  test1 := TTest1.Create;
  test2 := TTest2.Create;

  FContext.RegisterInstance('TestInstance1', 'TTest1', '', test1);
  FContext.RegisterInstance('TestInstance2', 'TTest2', '', test2);

  Assert.IsNotNull(FContext.FindInstanceByName('TestInstance1').InstancedObject);
  Assert.IsNotNull(FContext.FindInstanceByName('TestInstance2').InstancedObject);

  FContext.Init;

  try
    Assert.IsNull(FContext.FindInstanceByName('TestInstance1').InstancedObject);
    Assert.Fail('Test Instance 1 was found after initialization');
  except

  end;

  try
    Assert.IsNull(FContext.FindInstanceByName('TestInstance2').InstancedObject);
    Assert.Fail('Test Instance 2 was found after initialization');
  except

  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTSlimMethod);

end.
