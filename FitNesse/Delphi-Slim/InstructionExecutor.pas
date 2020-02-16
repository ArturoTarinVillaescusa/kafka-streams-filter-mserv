unit InstructionExecutor;

interface

uses
  SlimDirective, Instruction, SlimContext;

type
  TInstructionExecutor = class
    function Execute(pInstruction: TInstruction; pContext: TSlimContext) : TSlimDirective; virtual;
  end;

implementation

{ TInstructionExecutor }

function TInstructionExecutor.Execute(pInstruction : TInstruction; pContext : TSlimContext): TSlimDirective;
begin
  Result := pInstruction.Execute(pContext);
end;

end.
