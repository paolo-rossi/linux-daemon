{******************************************************************************}
{                                                                              }
{       Linux Daemon with Delphi                                               }
{                                                                              }
{       Author: Paolo Rossi (2017)                                             }
{                                                                              }
{       http://www.paolorossi.net                                              }
{       http://blog.paolorossi.net                                             }
{       https://github.com/paolo-rossi                                         }
{                                                                              }
{******************************************************************************}
program dhttpd;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Server.Module in '..\source\Server.Module.pas' {ServerModule: TDataModule},
  WiRL.Console.Posix.Daemon in '..\..\WiRL\Source\Extensions\WiRL.Console.Posix.Daemon.pas',
  WiRL.Console.Posix.Syslog in '..\..\WiRL\Source\Extensions\WiRL.Console.Posix.Syslog.pas';

begin
  TPosixDaemon.Setup(
    procedure (ASignal: TPosixSignal)
    begin
      case ASignal of
        TPosixSignal.Termination:
        begin
          ServerModule.Stop;
        end;

        TPosixSignal.Reload:
        begin
          // Reload configuration
          ServerModule.ConfigurePort(8080);
        end;
      end;
    end
  );

  ServerModule.Start;
  TPosixDaemon.Run(1000);
end.
