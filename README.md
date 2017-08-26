# Delphi implementation of a Linux deamon

This is the code for the blog articles:

- [Building a (real) Linux daemon with Delphi - Part 1](http://blog.paolorossi.net/2017/07/11/building-a-real-linux-daemon-with-delphi-part-1-2/)
- [Building a (real) Linux daemon with Delphi - Part 2](http://blog.paolorossi.net/building-a-real-linux-daemon-with-delphi-part-2) (not yet published)

The first demo (DelphiDaemonBase folder) is the exact code showed in the article, it's a simple but fully functional Linux daemon implementation in a `.dpr` project with the `syslog.pas` unit.

The second demo (DelphiDaemonWiRL folder) is built with two (independent) units from the [WiRL library](https://github.com/delphi-blocks/WiRL):
`WiRL.Console.Posix.Daemon.pas` and `WiRL.Console.Posix.Syslog.pas` that contains the (same) code to build a Linux daemon but incapsulated in easy-to-use Delphi classes.

The third demo (GitHubHooksDaemon folder) is a fully featured **REST Linux daemon** built with the [WiRL library](https://github.com/delphi-blocks/WiRL) and it shows how to encapsulate further the code logic to build a console application that behave as standard console app in debug and a daemon in release.
