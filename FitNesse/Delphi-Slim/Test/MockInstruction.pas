unit MockInstruction;

interface

uses
  Instruction, SlimDirective, SlimContext;

type
  TMockInstruction = class(TInstruction)
  private
    FExecuted: Boolean;
    FExecutionResult: TSlimDirective;
    FContextUsed: TSlimContext;
  public
    constructor Create; overload;
    constructor Create(const pResult: string); overload;

    property Executed: Boolean read FExecuted;
    property ExecutionResult: TSlimDirective read FExecutionResult;
    property ContextUsed: TSlimContext read FContextUsed;

    function Execute(pContext: TSlimContext): TSlimDirective; override;
  end;

implementation

{ TMockInstruction }

constructor TMockInstruction.Create(const pResult: string);
begin
  FExecutionResult := TSlimStringDirective.Create(pResult);
end;

constructor TMockInstruction.Create;
begin
  FExecutionResult := TSlimStringDirective.Create('');
end;

function TMockInstruction.Execute(pContext: TSlimContext): TSlimDirective;
begin
  FExecuted := True;
  Result := ExecutionResult;
  FContextUsed := pContext;
end;

end.
