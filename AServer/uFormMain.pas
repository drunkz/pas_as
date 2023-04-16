unit uFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, Vcl.StdCtrls, System.Win.ScktComp,
  Vcl.Menus, Vcl.Grids, Vcl.ExtCtrls;

type
  TFormMain = class(TForm)
    dbConn: TFDConnection;
    dbQuery: TFDQuery;
    mmoLog: TMemo;
    serverMain: TServerSocket;
    MenuMain: TMainMenu;
    MenuItemControl: TMenuItem;
    MenuItemReloadBlackList: TMenuItem;
    GridClientInfo: TStringGrid;
    TimerSecond: TTimer;
    MenuItemView: TMenuItem;
    MenuItemViewConnNum: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure serverMainListen(Sender: TObject; Socket: TCustomWinSocket);
    /// <remarks> 客户连接成功后 </remarks>
    procedure serverMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    /// <remarks> 菜单项_重载黑名单列表 </remarks>
    procedure MenuItemReloadBlackListClick(Sender: TObject);
    /// <remarks> 客户断开连接后 </remarks>
    procedure serverMainClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure serverMainClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure serverMainClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure serverMainGetSocket(Sender: TObject; Socket: NativeInt; var ClientSocket: TServerClientWinSocket);
    /// <remarks> 菜单项_查看总连接数量 </remarks>
    procedure MenuItemViewConnNumClick(Sender: TObject);
    procedure TimerSecondTimer(Sender: TObject);
  private
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  Global, uLog, Common, uNet;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // dkz：检测IP、Mac地址
  GridClientInfo.Cells[0, 0] := 'IP';
  GridClientInfo.Cells[1, 0] := '已收到数据量';
  GridClientInfo.Cells[2, 0] := '已收数据包数';
  GridClientInfo.Cells[3, 0] := '当前每秒收到量';
  GridClientInfo.Cells[4, 0] := '最大每秒收到量';
  GridClientInfo.Cells[5, 0] := '已发送数据量';
  for var i := 0 to GridClientInfo.ColCount - 1 do
    GridClientInfo.ColAlignments[i] := taLeftJustify;
  dbConn.Params.Database := DB_FILE_NAME;
  try
    dbQuery.ExecSQL('create table if not exists Account (id integer primary key, uname text, pwd text, qq text, tel text, expiration integer, bindMac text)');
  except
    on e: Exception do begin
      LogErr(Format('数据库初始化错误：%s', [e.Message]));
      Exit;
    end;
  end;
  serverMain.Active := True;
  LoadBlackList;
end;

procedure TFormMain.MenuItemReloadBlackListClick(Sender: TObject);
begin
  LoadBlackList;
end;

procedure TFormMain.MenuItemViewConnNumClick(Sender: TObject);
begin
  Log(Format('总连接数: %d', [serverMain.Socket.ActiveConnections]));
end;

procedure TFormMain.serverMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  var IPAddress := Socket.RemoteAddress;
  Log(Format('客户(%s)建立连接。', [IPAddress]));
  if BlackList.IndexOf(IPAddress) >= 0 then begin
    Socket.Close;
    Log(Format('客户(%s)位于黑名单中，拒绝连接。', [IPAddress]));
    Exit;
  end;
  // 禁止同客户多个连接
  var connNum: Word := 0;
  for var i := 0 to serverMain.Socket.ActiveConnections - 1 do begin
    if serverMain.Socket.Connections[i].RemoteAddress = IPAddress then begin
      Inc(connNum);
    end;
  end;
  if (connNum >= 2) and (IPAddress <> '127.0.0.1') and not IPAddress.StartsWith('192.168.') then begin
    Socket.Close;
    Log(Format('客户(%s)已有连接，本次拒绝。', [IPAddress]));
    Exit;
  end;
end;

procedure TFormMain.serverMainClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log(Format('客户(%s)断开连接。', [Socket.RemoteAddress]));
end;

procedure TFormMain.serverMainClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  LogErr(Format('客户(%s)出现错误，错误码：%d。', [Socket.RemoteAddress, ErrorCode]));
end;

procedure TFormMain.serverMainClientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
  try
    case TMClientSocket(Socket).RecvBufProc of
      1:
        begin
          LogErr(Format('客户(%s)数据包大小将超出缓冲区，连接关闭。', [Socket.RemoteAddress]));
          Socket.Close;
        end;
    end;
  except
    on e: Exception do
      LogErr(Format('接收消息处理错误：%s', [e.Message]));
  end;
end;

procedure TFormMain.serverMainGetSocket(Sender: TObject; Socket: NativeInt; var ClientSocket: TServerClientWinSocket);
begin
  ClientSocket := TMClientSocket.Create(Socket, TServerWinSocket(Sender));
end;

procedure TFormMain.serverMainListen(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log('服务开始运行...');
end;

procedure TFormMain.TimerSecondTimer(Sender: TObject);
begin
  var uPacketByteSec: LongWord := 0;  // 当前每秒收到数据量
  GridClientInfo.RowCount := serverMain.Socket.ActiveConnections + 5;
  for var i := 1 to GridClientInfo.RowCount - 1 do begin
    for var j := 0 to GridClientInfo.ColCount - 1 do begin
      GridClientInfo.Cells[j, i] := '';
    end;
  end;
  for var i := 0 to serverMain.Socket.ActiveConnections - 1 do begin
    with serverMain.Socket.Connections[i] as TMClientSocket do begin
      uPacketByteSec := PacketByteTotal - PacketByteTotalLastSec;
      if uPacketByteSec > PacketByteSecMax then
        PacketByteSecMax := uPacketByteSec;
      GridClientInfo.Cells[0, i + 1] := RemoteAddress;
      GridClientInfo.Cells[1, i + 1] := FormatByteSize(PacketByteTotal);
      GridClientInfo.Cells[2, i + 1] := UIntToStr(PacketTotal);
      GridClientInfo.Cells[3, i + 1] := FormatByteSize(uPacketByteSec);
      GridClientInfo.Cells[4, i + 1] := FormatByteSize(PacketByteSecMax);
      GridClientInfo.Cells[5, i + 1] := '0';
      PacketByteTotalLastSec := PacketByteTotal;
    end;
  end;
end;

end.

