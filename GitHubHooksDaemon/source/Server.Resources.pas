{******************************************************************************}
{                                                                              }
{       GitHub WebHooks Daemon with WiRL                                       }
{                                                                              }
{       Author: Paolo Rossi (2017)                                             }
{                                                                              }
{       http://www.paolorossi.net                                              }
{       http://blog.paolorossi.net                                             }
{       https://github.com/paolo-rossi                                         }
{                                                                              }
{******************************************************************************}
unit Server.Resources;

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Comp.Client,

  WiRL.Core.Engine,
  WiRL.Core.Attributes,
  WiRL.Core.Request,
  WiRL.http.Accept.MediaType,
  WiRL.Core.MessageBody.Default,
  WiRL.Data.MessageBody.Default,
  WiRL.Console.Factory,
  WiRL.Core.JSON;

type
  [Path('hook')]
  TRepositoryResource = class
  protected
    [Context] Request: TWiRLRequest;
  public
    [POST, Path('push')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function RepoPush([Headerparam('X-GitHub-Event')] const AEvent: string; [BodyParam] AJSON: TJSONObject): TJSONObject;

    [POST, Path('watch')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function RepoWatch([Headerparam('X-GitHub-Event')] const AEvent: string; [BodyParam] AJSON: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.IOUtils, Datasnap.DBClient,
  WiRL.Core.Registry;

function TRepositoryResource.RepoPush(const AEvent: string; AJSON: TJSONObject): TJSONObject;
var
  LProject: string;
begin
  TWiRLConsoleLogger.LogInfo(Request.HeaderFields.Text);
  TWiRLConsoleLogger.LogInfo('Body: ');
  TWiRLConsoleLogger.LogInfo(AJSON.ToJSON);

  LProject := AJSON.GetValue('project').Value;

  TWiRLConsoleLogger.LogInfo('project: ' + LProject);

  Result := TJSONObject.Create;
  Result.AddPair('result', TJSONTrue.Create);
  Result.AddPair('project', LProject);
end;

function TRepositoryResource.RepoWatch(const AEvent: string;
  AJSON: TJSONObject): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('event', AEvent);
end;

initialization
  TWiRLResourceRegistry.Instance.RegisterResource<TRepositoryResource>;

end.
