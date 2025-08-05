unit uODACDatabase;

interface

uses
  SysUtils, Classes, DB, Ora, OraSmart, IniFiles, SyncObjs;

type
  TDatabase = class
  private
    class var FOraSession: TOraSession;
    class var FLock: TCriticalSection;
  public
    class constructor Create;
    class destructor Destroy;
    class function GetSession: TOraSession;
    class procedure Connect;
  end;

implementation

class constructor TDatabase.Create;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TDatabase.Destroy;
begin
  FreeAndNil(FOraSession);
  FreeAndNil(FLock);
end;

class procedure TDatabase.Connect;
var
  Ini: TIniFile;
  Host, User, Password, DB: string;
begin
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
    try
      Host := Ini.ReadString('database', 'host', '');
      User := Ini.ReadString('database', 'user', '');
      Password := Ini.ReadString('database', 'password', '');
      DB := Ini.ReadString('database', 'service_name', '');
    finally
      Ini.Free;
    end;

    if (Host = '') or (User = '') or (Password = '') or (DB = '') then
      raise Exception.Create('Invalid database configuration in config.ini');

    FOraSession := TOraSession.Create(nil);
    try
      FOraSession.Username := User;
      FOraSession.Password := Password;
      FOraSession.Server := Host + ':'  + DB;

      FOraSession.Options.Direct := True;
      FOraSession.LoginPrompt := False;

      FOraSession.Connected := True;
      if not FOraSession.Connected then
        raise Exception.Create('Failed to connect to database');
    except
      FreeAndNil(FOraSession);
      raise;
    end;
  except
    on E: Exception do
      raise Exception.Create('Database connection failed: ' + E.Message);
  end;
end;

class function TDatabase.GetSession: TOraSession;
begin
  FLock.Acquire;
  try
    if FOraSession = nil then
      Connect;
    Result := FOraSession;
  finally
    FLock.Release;
  end;
end;

end.
