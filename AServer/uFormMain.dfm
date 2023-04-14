object FormMain: TFormMain
  Left = 817
  Top = 471
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #39564#35777#26381#21153
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  Menu = MenuMain
  Position = poDesktopCenter
  OnCreate = FormCreate
  TextHeight = 12
  object lblConnNum: TLabel
    Left = 8
    Top = 288
    Width = 54
    Height = 12
    Caption = #36830#25509#25968': 0'
  end
  object mmoLog: TMemo
    Left = 8
    Top = 8
    Width = 612
    Height = 257
    TabStop = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btn1: TButton
    Left = 296
    Top = 376
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 1
    OnClick = btn1Click
  end
  object dbConn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'JournalMode=Off'
      'Synchronous=Full')
    Left = 8
    Top = 384
  end
  object dbQuery: TFDQuery
    Connection = dbConn
    Left = 64
    Top = 384
  end
  object serverMain: TServerSocket
    Active = False
    Port = 8081
    ServerType = stNonBlocking
    OnListen = serverMainListen
    OnGetSocket = serverMainGetSocket
    OnClientConnect = serverMainClientConnect
    OnClientDisconnect = serverMainClientDisconnect
    OnClientRead = serverMainClientRead
    OnClientError = serverMainClientError
    Left = 136
    Top = 384
  end
  object MenuMain: TMainMenu
    Left = 200
    Top = 384
    object MenuItemControl: TMenuItem
      Caption = #25511#21046'(&C)'
      object MenuItemReloadBlackList: TMenuItem
        Caption = #37325#36733#40657#21517#21333#21015#34920'(&B)'
        OnClick = MenuItemReloadBlackListClick
      end
    end
  end
end
