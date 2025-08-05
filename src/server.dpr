program Server;
{$APPTYPE CONSOLE}
uses
  Horse,
  System.SysUtils,
  uODACDatabase in 'uODACDatabase.pas',
  uRoutes in 'uRoutes.pas';

begin
  RegisterRoutes;
  THorse.Listen(9000);
//  try
//    THorseFireDAC.SetConfigFile('config.ini');
//    THorseFireDAC.StartConnection;
//
//    RegisterRoutes;
//
//    WriteLn('Servidor rodando em http://localhost:9000');
//    THorse.Listen(9000);
//  except
//    on E: Exception do
//      Writeln(E.ClassName, ': ', E.Message);
//  end;
end.