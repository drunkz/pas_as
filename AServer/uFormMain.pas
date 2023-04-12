unit uFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.DApt;

type
  TFormMain = class(TForm)
    dbConn: TFDConnection;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  common;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // 验证服务绑定IP、绑定MAC地址
  // 检测数据库是否存在，不存在则创建
  dbConn.Params.Database := DB_FILE_NAME;
  //if FileExists(DB_FILE_NAME) then
  dbConn.Open;
  var qry := TFDQuery.Create(nil);
  try
    qry.Connection := dbConn;
      // 创建表
    qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS customers (id INTEGER PRIMARY KEY, name TEXT, email TEXT)';
    qry.ExecSQL;
      // 插入数据
    qry.SQL.Text := 'INSERT INTO customers (name, email) VALUES (:name, :email)';
    qry.Params.ParamByName('name').AsString := 'John';
    qry.Params.ParamByName('email').AsString := 'john@example.com';
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  dbConn.Close;
end;

end.

