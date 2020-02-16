program DelphiSlimTests;
{

  Projet de test DUnit Delphi
  -------------------------
  Ce projet contient le framework de test DUnit et les exécuteurs de test GUI/Console.
  Ajoutez "CONSOLE_TESTRUNNER" à l'entrée des définitions conditionnelles des options
  de projet pour utiliser l'exécuteur de test console.  Sinon, l'exécuteur de test GUI sera
  utilisé par défaut.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  InputProcessor in '..\InputProcessor.pas',
  SlimServer in '..\SlimServer.pas',
  InstructionParser in '..\InstructionParser.pas',
  SlimDirective in '..\SlimDirective.pas',
  SlimDirectiveDeserializer in '..\SlimDirectiveDeserializer.pas',
  Instruction in '..\Instruction.pas',
  InstructionExecutor in '..\InstructionExecutor.pas',
  SlimDirectiveSerializer in '..\SlimDirectiveSerializer.pas',
  SlimContext in '..\SlimContext.pas',
  SlimMethod in '..\SlimMethod.pas',
  Slim.Logger in '..\Slim.Logger.pas',
  Configuration in '..\Configuration.pas',
  TestInputProcessor in 'TestInputProcessor.pas',
  TestSlimMethod in 'TestSlimMethod.pas',
  TestSlimServer in 'TestSlimServer.pas',
  TestSlimDirectiveDeserializer in 'TestSlimDirectiveDeserializer.pas',
  TestInstructionParser in 'TestInstructionParser.pas',
  TestInstruction in 'TestInstruction.pas',
  TestSlimDirectiveSerializer in 'TestSlimDirectiveSerializer.pas',
  TestInstructionExecutor in 'TestInstructionExecutor.pas',
  MockInstruction in 'MockInstruction.pas',
  DummyFixtures in 'DummyFixtures.pas',
  TestRTTi in 'TestRTTi.pas',
  TestSlimContext in 'TestSlimContext.pas';

{$R *.RES}

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := False;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;
    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
