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
program githubhooksd;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Types,
  WiRL.Console.Base,
  WiRL.Console.Factory,
  WiRL.http.Server.Indy,
  Server.Resources in '..\source\Server.Resources.pas',
  Server.Filters in '..\source\Server.Filters.pas';

var
  WiRLConsole: TWiRLConsoleBase;

begin
  try
    WiRLConsole := TWiRLConsoleFactory.NewConsole(
      procedure (AServer: TWiRLhttpServerIndy)
      begin
        AServer.ConfigureEngine('/rest')
          .SetName('GitHubWebHooks')
          .SetPort(8088)
          .SetThreadPoolSize(10)

          // Adds and configures an application
          .AddApplication('/github')
            .SetResources([
              'Server.Resources.TRepositoryResource'
            ])
            .SetFilters('*')
            ;
        ;
      end
    );
    try
      WiRLConsole.Start;
    finally
      WiRLConsole.Free;
    end;

    ExitCode := 0;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      TWiRLConsoleLogger.LogError('Exception: ' + E.Message);
    end;
  end;
end.
