unit uRoutes;

interface

uses
  Horse, System.JSON, DB, Ora, uODACDatabase, SysUtils;

procedure RegisterRoutes;
procedure GetUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegisterRoutes;
begin
  // Rota de teste
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  // Rota que chama diretamente a procedure GetUsuarios
  THorse.Get('/usuarios', GetUsuarios);
end;

procedure GetUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Query: TOraQuery;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
begin
  try
    Query := TOraQuery.Create(nil);
    try
      Query.Session := TDatabase.GetSession;

      Query.SQL.Text := 'SELECT ID_USUARIO, NOME_USUARIO FROM sct_usuario WHERE ROWNUM <= 10';
      Query.Open;

      JSONArray := TJSONArray.Create;
      try
        while not Query.Eof do
        begin
          JSONObj := TJSONObject.Create;
          JSONObj.AddPair('id', TJSONNumber.Create(Query.FieldByName('ID_USUARIO').AsInteger));
          JSONObj.AddPair('nome', Query.FieldByName('NOME_USUARIO').AsString);
          JSONArray.AddElement(JSONObj);
          Query.Next;
        end;

        // Envia como JSON com Content-Type explícito
        Res.ContentType('application/json; charset=utf-8').Send(JSONArray.ToString);
      except
        JSONArray.Free;
        raise;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Res.Status(500).ContentType('application/json; charset=utf-8').Send(TJSONObject.Create.AddPair('error', E.Message));
    end;
  end;
end;

end.
