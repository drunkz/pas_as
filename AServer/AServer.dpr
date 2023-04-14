program AServer;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses
  Vcl.Forms,
  uFormMain in 'uFormMain.pas' {FormMain},
  Global in 'Global.pas',
  uLog in 'uLog.pas',
  Common in 'Common.pas',
  uNet in 'uNet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
