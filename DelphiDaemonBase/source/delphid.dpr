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
program delphid;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  Posix.Stdlib,
  Posix.SysStat,
  Posix.SysTypes,
  Posix.Unistd,
  Posix.Signal,
  Posix.Fcntl,
  Posix.Syslog in 'Posix.Syslog.pas';

const
  // Missing from linux/StdlibTypes.inc !!! <stdlib.h>
  EXIT_FAILURE = 1;
  EXIT_SUCCESS = 0;

var
  pid, sid: pid_t;
  fid: Integer;
  idx: Integer;
  running: Boolean;

// 1. If SIGTERM is received, shut down the daemon and exit cleanly.
// 2. If SIGHUP is received, reload the configuration files, if this applies.
procedure HandleSignals(SigNum: Integer); cdecl;
begin
  case SigNum of
    SIGTERM:
    begin
      running := False;
    end;
    SIGHUP:
    begin
      syslog(LOG_NOTICE, 'daemon: reloading config');
      // Reload configuration
    end;
  end;
end;

begin
  // syslog() will call openlog() with no arguments if the log is not currently open.
  openlog(nil, LOG_PID or LOG_NDELAY, LOG_DAEMON);

  // If the parent process is the init process then the current process is already a daemon
  // Remarks: this check here
	if getppid() = 1 then
  begin
    syslog(LOG_NOTICE, 'Nothing to do, I''m already a daemon');
    Exit; // already a daemon
  end;

  syslog(LOG_NOTICE, 'before 1st fork() - original process');

  // Call fork(), to create a background process.
  pid := fork();

  syslog(LOG_NOTICE, 'after 1st fork() - the child is born');

  if pid < 0 then
    raise Exception.Create('Error forking the process');

  // Call exit() in the first child, so that only the second
  // child (the actual daemon process) stays around
  if pid > 0 then
    Halt(EXIT_SUCCESS);

  syslog(LOG_NOTICE, 'the parent is killed!');

  // This call will place the server in a new process group and session and
  // detaches its controlling terminal
  sid := setsid();
  if sid < 0 then
    raise Exception.Create('Impossible to create an independent session');

  syslog(LOG_NOTICE, 'session created and process group ID set');

  // Catch, ignore and handle signals
  signal(SIGCHLD, TSignalHandler(SIG_IGN));
  signal(SIGHUP, HandleSignals);
  signal(SIGTERM, HandleSignals);

  syslog(LOG_NOTICE, 'before 2nd fork() - child process');

  // Call fork() again, to be sure daemon can never re-acquire the terminal
  pid := fork();

  syslog(LOG_NOTICE, 'after 2nd fork() - the grandchild is born');

  if pid < 0 then
    raise Exception.Create('Error forking the process');

  // Call exit() in the first child, so that only the second child
  // (the actual daemon process) stays around. This ensures that the daemon
  // process is re-parented to init/PID 1, as all daemons should be.
  if pid > 0 then
    Halt(EXIT_SUCCESS);
  syslog(LOG_NOTICE, 'the 1st child is killed!');

  // Open descriptors are inherited to child process, this may cause the use
  // of resources unneccessarily. Unneccesarry descriptors should be closed
  // before fork() system call (so that they are not inherited) or close
  // all open descriptors as soon as the child process starts running

  // Close all opened file descriptors (stdin, stdout and stderr)
  for idx := sysconf(_SC_OPEN_MAX) downto 0 do
    __close(idx);

  syslog(LOG_NOTICE, 'file descriptors closed');

  // Route I/O connections to > dev/null

  // Open STDIN
  fid := __open('/dev/null', O_RDWR);
  // Dup STDOUT
  dup(fid);
  // Dup STDERR
  dup(fid);

  syslog(LOG_NOTICE, 'stdin, stdout, stderr redirected to /dev/null');

  // if you don't redirect the stdout the program hangs
  Writeln('Test writeln');
  syslog(LOG_NOTICE, 'if you see this message the daemon isn''t crashed writing on stdout!');

  // Set new file permissions:
  // most servers runs as super-user, for security reasons they should
  // protect files that they create, with unmask the mode passes to open(), mkdir()

  // Restrict file creation mode to 750
	umask(027);

  syslog(LOG_NOTICE, 'file permission changed to 750');

  // The current working directory should be changed to the root directory (/), in
  // order to avoid that the daemon involuntarily blocks mount points from being unmounted
  chdir('/');
  syslog(LOG_NOTICE, 'changed directory to "/"');

  // TODO: write the daemon PID (as returned by getpid()) to a PID file, for
  // example /run/delphid.pid to ensure that the daemon cannot be started more than once

  syslog(LOG_NOTICE, 'daemon started');

  // deamon main loop
  running := True;
  try
    while running do
    begin
      // deamon actual code
      Sleep(1000);
    end;

    ExitCode := EXIT_SUCCESS;
  except
    on E: Exception do
    begin
      syslog(LOG_ERR, 'Error: ' + E.Message);
      ExitCode := EXIT_FAILURE;
    end;
  end;

  syslog(LOG_NOTICE, 'daemon stopped');
  closelog();
end.
