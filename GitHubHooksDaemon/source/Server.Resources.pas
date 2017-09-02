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

    [POST, Path('fork')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function RepoFork([Headerparam('X-GitHub-Event')] const AEvent: string; [BodyParam] AJSON: TJSONObject): TJSONObject;

    [POST, Path('watch')]
    [Produces(TMediaType.APPLICATION_JSON)]
    function RepoWatch([Headerparam('X-GitHub-Event')] const AEvent: string; [BodyParam] AJSON: TJSONObject): TJSONObject;
  end;

implementation

uses
  System.IOUtils, Datasnap.DBClient,
  WiRL.Core.Registry;

function TRepositoryResource.RepoFork(const AEvent: string;
  AJSON: TJSONObject): TJSONObject;
var
  LForkee: string;
begin
  TWiRLConsoleLogger.LogInfo(Request.HeaderFields.Text);
  TWiRLConsoleLogger.LogInfo('Body: ');
  TWiRLConsoleLogger.LogInfo(AJSON.ToJSON);

  LForkee := AJSON.GetValue<string>('forkee.owner.login', '');

  TWiRLConsoleLogger.LogInfo('forkee: ' + LForkee);

  Result := TJSONObject.Create;
  Result.AddPair('result', TJSONTrue.Create);
  Result.AddPair('forkee', LForkee);
end;

function TRepositoryResource.RepoPush(const AEvent: string; AJSON: TJSONObject): TJSONObject;
var
  LRepoName: string;
begin
  TWiRLConsoleLogger.LogInfo(Request.HeaderFields.Text);
  TWiRLConsoleLogger.LogInfo('Body: ');
  TWiRLConsoleLogger.LogInfo(AJSON.ToJSON);

  LRepoName := AJSON.GetValue<string>('repository.full_name', '');

  TWiRLConsoleLogger.LogInfo('repository: ' + LRepoName);

  Result := TJSONObject.Create;
  Result.AddPair('result', TJSONTrue.Create);
  Result.AddPair('repository', LRepoName);
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
