unit InputProcessor;

interface

uses
  System.Classes,
  InstructionExecutor, InstructionParser, SlimContext;

type
  TResponse = class
  private
    _mustDisconnect: Boolean;
    _output: string;
  public
    constructor Normal(const output: string);
    constructor Disconnection;

    property MustDisconnect: Boolean read _mustDisconnect;
    property Output: string read _output;
 end;

type
  TInputProcessor = class
  public
    InstructionExecutor: TInstructionExecutor;
    InstructionParser: TInstructionParser;
    constructor Create;
    function Process(const input: string; context: TSlimContext): TResponse; virtual;
  end;

implementation

uses
  SlimDirectiveSerializer, SlimDirectiveDeserializer, SlimDirective, Instruction, Slim.Logger;

{ TInputProcessor }

constructor TInputProcessor.Create;
begin
  InstructionParser := TInstructionParser.Create;
  InstructionExecutor := TInstructionExecutor.Create;
end;

function TInputProcessor.Process(const input: string; context: TSlimContext): TResponse;
var
  serializer: TSlimDirectiveSerializer;
  deserializer: TSlimDirectiveDeserializer;
  directiveResponse: TSlimDirective;
  instructionToExecute: TInstruction;
  directive: TSlimDirective;
begin
  if input = '000003:bye' then
    Exit(TResponse.Disconnection);

  serializer := nil;
  deserializer := nil;
  directive := nil;
  instructionToExecute := nil;
  directiveResponse := nil;
  try
    deserializer := TSlimDirectiveDeserializer.Create;
    directive := deserializer.Deserialize(input);
    instructionToExecute := InstructionParser.Parse(directive);
    directiveResponse := InstructionExecutor.Execute(instructionToExecute, context);
    serializer := TSlimDirectiveSerializer.Create;

    Result := TResponse.Normal(serializer.Serialize(directiveResponse));
  finally
    serializer.Free;
    directiveResponse.Free;
    instructionToExecute.Free;
    directive.Free;
    deserializer.Free;
  end;
end;

{ TResponse }

constructor TResponse.Disconnection;
begin
  _mustDisconnect := True;
end;

constructor TResponse.Normal(const output: string);
begin
  _output := output;
  _mustDisconnect := False;
end;

end.
