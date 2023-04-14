unit Common;

interface

uses
  System.Classes, System.SysUtils;

/// <remarks> 加载黑名单列表 </remarks>
procedure LoadBlackList;

implementation

uses
  Global, uLog;

procedure LoadBlackList;
begin
  BlackList.Clear;
  BlackList.LoadFromFile(BLACKLIST_FILE_NAME);
  for var i := BlackList.Count - 1 downto 0 do begin
    if BlackList[i] = '' then
      BlackList.Delete(i);
  end;
  Log(Format('成功加载 %d 个连接黑名单。', [BlackList.Count]));
end;

initialization
  BlackList := TStringList.Create;


finalization
  BlackList.Free;

end.

