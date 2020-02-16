unit TestRtti;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestTRtti = class
    [Test]
    procedure TestFindType;
    [Test]
    procedure TestFindTypeInCompiledUnit;
    [Test]
    procedure TestGetTypedInstanceAfterCreation;
    [Test]
    procedure TestInvokeMethodOnStaticInstance;
    [Test]
    procedure TestInvokeMethodOnDynamicInstance;
  end;

type
  TDummyClass = class
    procedure MyMethod;
  end;

implementation

uses
  System.Rtti, System.SysUtils, System.Classes;

var
  MyMethodCalled: Boolean;

{ TTestTRtti }

procedure TTestTRtti.TestFindType;
var
  context: TRttiContext;
  foundType: TRttiType;
begin
  context := TRttiContext.Create;
  TDummyClass.ClassName; // to let Rtti know about this class

  foundType := context.FindType('TestRtti.TDummyClass');
  Assert.IsNotNull(foundType);
end;

procedure TTestTRtti.TestFindTypeInCompiledUnit;
var
  package: HMODULE;
  context: TRttiContext;
  foundType: TRttiType;
begin
  package := LoadPackage('..\..\CompiledUnits\FixturesPackage.bpl');
  try
    context := TRttiContext.Create;

    foundType := context.FindType('CompiledFixtures.TCompiledFixture');
    Assert.IsNotNull(foundType);
  finally
    UnloadPackage(package);
  end;
end;

procedure TTestTRtti.TestInvokeMethodOnDynamicInstance;
var
  context: TRttiContext;
  foundType: TRttiInstanceType;
  dummy: TValue;
begin
  context := TRttiContext.Create;
  TDummyClass.ClassName; // to let Rtti know about this class
  foundType := context.FindType('TestRtti.TDummyClass') as TRttiInstanceType;
  dummy := foundType.GetMethod('Create').Invoke(foundType.MetaclassType, []);

  foundType.GetMethod('MyMethod').Invoke(dummy, []);
  Assert.IsTrue(dummy.IsInstanceOf(TDummyClass));
  Assert.IsTrue(MyMethodCalled);
end;

procedure TTestTRtti.TestGetTypedInstanceAfterCreation;
var
  context: TRttiContext;
  foundType: TRttiInstanceType;
  dummy: TValue;
  dummyInstance: TDummyClass;
begin
  context := TRttiContext.Create;
  TDummyClass.ClassName; // to let Rtti know about this class
  foundType := context.FindType('TestRtti.TDummyClass') as TRttiInstanceType;
  dummy := foundType.GetMethod('Create').Invoke(foundType.MetaclassType, []);
  MyMethodCalled := False;

  dummyInstance := dummy.AsType<TDummyClass>;
  try
    dummyInstance.MyMethod;

    Assert.IsTrue(MyMethodCalled);
  finally
    dummyInstance.Free;
  end;
end;

procedure TTestTRtti.TestInvokeMethodOnStaticInstance;
var
  dummy: TDummyClass;
  method: TRttiMethod;
  context: TRttiContext;
  foundType: TRttiInstanceType;
begin
  context := TRttiContext.Create;
  foundType := context.FindType('TestRtti.TDummyClass') as TRttiInstanceType;
  MyMethodCalled := False;

  dummy := TDummyClass.Create;
  try
    method := foundType.GetMethod('MyMethod');
    method.Invoke(dummy, []);

    Assert.IsTrue(MyMethodCalled);
  finally
    dummy.Free;
  end;
end;

{ TDummyClass }

procedure TDummyClass.MyMethod;
begin
  MyMethodCalled := True;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTRtti);

end.
