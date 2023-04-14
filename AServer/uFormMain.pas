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
    procedure serverMainClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    /// <remarks> 菜单项_重载黑名单列表 </remarks>
    procedure MenuItemReloadBlackListClick(Sender: TObject);
  private
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  Global, uLog, Common;

procedure TFormMain.btn1Click(Sender: TObject);
begin
  Log('aaa');
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // dkz：检测IP、Mac地址
  dbConn.Params.Database := DB_FILE_NAME;
  try
    dbQuery.ExecSQL('create table if not exists Account (id integer primary key, uname text, pwd text, qq text, tel text, expiration integer, bindMac text)');
  except
    on e: Exception do begin
      Log(e.Message);
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
  Log(Format('客户(%s)请求连接中...', [IPAddress]));
  if BlackList.IndexOf(IPAddress) >= 0 then begin
    Socket.Close;
    Log(Format('客户(%s)位于黑名单中，拒绝连接。', [IPAddress]));
    Exit;
  end;
  for var i := 0 to serverMain.Socket.ActiveConnections - 1 do begin
    if serverMain.Socket.Connections[i].RemoteAddress = IPAddress then begin
      Socket.Close;
      Log(Format('客户(%s)已有连接，本次拒绝连接。', [IPAddress]));
      Exit;
    end;
  end;
  lblConnNum.Caption := Format('连接数: %d', [serverMain.Socket.ActiveConnections]);
end;

procedure TFormMain.serverMainListen(Sender: TObject; Socket: TCustomWinSocket);
begin
  Log('服务开始运行...');
end;

end.

