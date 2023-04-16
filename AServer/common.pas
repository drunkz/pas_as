unit Common;

interface

uses
  System.Classes, System.SysUtils;

const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * 1024;

/// <remarks> 加载黑名单列表 </remarks>
procedure LoadBlackList;

function FormatByteSize(const uByte: LongWord): string;

implementation

uses
  Global, uLog;

procedure LoadBlackList;
begin
  // 文件如果不存在先创建
  if not FileExists(BLACKLIST_FILE_NAME) then begin
    var FileStream := TFileStream.Create(BLACKLIST_FILE_NAME, fmCreate);
    FileStream.Free;
  end;

  BlackList.Clear;
  BlackList.LoadFromFile(BLACKLIST_FILE_NAME);
  for var i := BlackList.Count - 1 downto 0 do begin
    if BlackList[i] = '' then
      BlackList.Delete(i);
  end;
  Log(Format('成功加载 %d 个连接黑名单。', [BlackList.Count]));
end;

function FormatByteSize(const uByte: LongWord): string;
begin
  if (uByte < KB) then
    Result := Format('%u B', [uByte])
  else if (uByte < MB) then
    Result := Format('%.2f KB', [uByte / KB])
  else if (uByte < GB) then
    Result := Format('%.2f MB', [uByte / MB])
  else
    Result := Format('%.2f GB', [uByte / GB])
end;

initialization
  BlackList := TStringList.Create;


finalization
  BlackList.Free;

end.

