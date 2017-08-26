{******************************************************************************}
{                                                                              }
{       WiRL: RESTful Library for Delphi                                       }
{                                                                              }
{       Copyright (c) 2015-2017 WiRL Team                                      }
{                                                                              }
{       https://github.com/delphi-blocks/WiRL                                  }
{                                                                              }
{******************************************************************************}
unit Server.Filters;

interface

uses
  System.SysUtils, System.Classes,

  WiRL.Core.Registry,
  WiRL.http.Filters,
  WiRL.Core.Request,
  WiRL.Core.Response,
  WiRL.Core.Attributes,
  WiRL.Core.Exceptions,
  WiRL.Core.Auth.Context,
  WiRL.http.Accept.MediaType;

type
  [PreMatching]
  TGitHubRestifier = class(TInterfacedObject, IWiRLContainerRequestFilter)
  public
    procedure Filter(ARequestContext: TWiRLContainerRequestContext);
  end;

implementation

uses
  System.IOUtils;

{ TGitHubRestifier }

procedure TGitHubRestifier.Filter(ARequestContext: TWiRLContainerRequestContext);
var
  LResourcePath: string;
begin
  LResourcePath := ARequestContext.Request.HeaderFields.Values['X-GitHub-Event'];

  if LResourcePath.IsEmpty then
    Exit;

  if not ARequestContext.Request.PathInfo.EndsWith('/') then
    LResourcePath := '/' + LResourcePath;

  ARequestContext.Request.PathInfo := ARequestContext.Request.PathInfo + LResourcePath;
end;

initialization
  TWiRLFilterRegistry.Instance.RegisterFilter<TGitHubRestifier>;

end.
