unit DummyFixtures;

interface

type
  TDummyFixture = class
  private
    FDummyMethodCalled: Boolean;
    FArgUsedToCallMethod: string;
    FTheAnswer: string;
  public
    property DummyMethodCalled: Boolean read FDummyMethodCalled;
    property ArgUsedToCallMethod: string read FArgUsedToCallMethod;
    property TheAnswer: string read FTheAnswer write FTheAnswer;

    procedure DummyMethod;
    function DummyFunction: string;
    procedure MethodWithArg(const pArg: string);
  end;

implementation

{ TDummyFixture }

procedure TDummyFixture.DummyMethod;
begin
  FDummyMethodCalled := True;
end;

procedure TDummyFixture.MethodWithArg(const pArg: string);
begin
  FArgUsedToCallMethod := pArg;
end;

function TDummyFixture.DummyFunction: string;
begin
  Result := TheAnswer;
end;

end.
