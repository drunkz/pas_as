unit uLog;

interface

uses
  System.SysUtils;

procedure Log(str: string);

implementation

uses
  uFormMain;

procedure Log(str: string);
begin
  if FormMain.mmoLog.Lines.Count >= 300 then
    FormMain.mmoLog.Clear;
  FormMain.mmoLog.Lines.Add(Format('%s %s', [DateTimeToStr(Now), str]));
end;

end.

