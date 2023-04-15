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
  Vcl.Menus;

type
  TFormMain = class(TForm)
    dbConn: TFDConnection;
    dbQuery: TFDQuery;
    mmoLog: TMemo;
    btn1: TButton;
    serverMain: TServerSocket;
    lblConnNum: TLabel;
    MenuMain: TMainMenu;
    MenuItemControl: TMenuItem;
    MenuItemReloadBlackList: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
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
  private
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  Global, uLog, Common, uNet;

procedure TFormMain.btn1Click(Sender: TObject);
begin
  //LogErr(Format('连接数: %d', [serverMain.Socket.ActiveConnections]));
  for var i := 0 to serverMain.Socket.ActiveConnections - 1 do begin
    with serverMain.Socket.Connections[i] as TMClientSocket do
      Log(Format('收到数据包总数：%u', [PacketCount]));
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // dkz：检测IP、Mac地址
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

procedure TFormMain.serverMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  var IPAddress := Socket.RemoteAddress;
  Log(Format('客户(%s)建立连接。', [IPAddress]));
  if BlackList.IndexOf(IPAddress) >= 0 then begin
    Socket.Close;
    Log(Format('客户(%s)位于黑名单中，拒绝连接。', [IPAddress]));
    Exit;
  end;
  if (IPAddress <> '127.0.0.1') and not IPAddress.StartsWith('192.168.') then begin
    for var i := 0 to serverMain.Socket.ActiveConnections - 1 do begin
      if serverMain.Socket.Connections[i].RemoteAddress = IPAddress then begin
        Socket.Close;
        Log(Format('客户(%s)已有连接，本次拒绝。', [IPAddress]));
        Exit;
      end;
    end;
  end;
  lblConnNum.Caption := Format('连接数: %d', [serverMain.Socket.ActiveConnections]);
  lblConnNum.Tag := serverMain.Socket.ActiveConnections;
end;

procedure TFormMain.serverMainClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log(Format('客户(%s)断开连接。', [Socket.RemoteAddress]));
  lblConnNum.Tag := lblConnNum.Tag - 1;
  lblConnNum.Caption := Format('连接数: %d', [lblConnNum.Tag]);
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

end.

