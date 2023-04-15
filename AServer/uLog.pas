unit uLog;

interface

uses
  System.SysUtils;

procedure Log(str: string);

procedure LogErr(str: string);

implementation

uses
  uFormMain;

procedure Log(str: string);
begin
  if FormMain.mmoLog.Lines.Count >= 1000 then
    FormMain.mmoLog.Clear;
  FormMain.mmoLog.Lines.Add(Format('%s %s', [DateTimeToStr(Now), str]));
end;

procedure LogErr(str: string);
begin
  Log(Format('[ERR] %s', [str]))
end;

end.

