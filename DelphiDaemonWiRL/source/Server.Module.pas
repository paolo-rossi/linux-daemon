unit Server.Module;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext;

type
  TServerModule = class(TDataModule)
    httpServer: TIdHTTPServer;
    procedure httpServerCommandGet(AContext: TIdContext; ARequestInfo:
        TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure httpServerCommandOther(AContext: TIdContext; ARequestInfo:
        TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    procedure OnCommand(AContext: TIdContext; ARequestInfo:
        TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure ConfigurePort(APort: Integer);
    procedure Start;
    procedure Stop;
  end;

var
  ServerModule: TServerModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TServerModule }

procedure TServerModule.ConfigurePort(APort: Integer);
begin
  Stop;
  httpServer.DefaultPort := APort;
  Start;
end;

procedure TServerModule.httpServerCommandGet(AContext: TIdContext;
    ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  OnCommand(AContext, ARequestInfo, AResponseInfo);
end;

procedure TServerModule.httpServerCommandOther(AContext: TIdContext;
    ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  OnCommand(AContext, ARequestInfo, AResponseInfo);
end;

procedure TServerModule.OnCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  // Server Event
end;

procedure TServerModule.Start;
begin
  httpServer.Active := True;
end;

procedure TServerModule.Stop;
begin
  httpServer.Active := False;
end;

end.
