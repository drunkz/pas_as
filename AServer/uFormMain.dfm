object FormMain: TFormMain
  Left = 817
  Top = 471
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #39564#35777#26381#21153
  ClientHeight = 438
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
  object GridClientInfo: TStringGrid
    Left = 8
    Top = 271
    Width = 612
    Height = 154
    TabStop = False
    ColCount = 6
    DefaultColWidth = 100
    DefaultColAlignment = taCenter
    DefaultRowHeight = 16
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goFixedRowDefAlign]
    TabOrder = 1
    ColWidths = (
      85
      100
      100
      100
      100
      100)
  end
  object dbConn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'JournalMode=Off'
      'Synchronous=Full')
    Left = 29
    Top = 368
  end
  object dbQuery: TFDQuery
    Connection = dbConn
    Left = 93
    Top = 368
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
    Left = 157
    Top = 368
  end
  object MenuMain: TMainMenu
    Left = 229
    Top = 368
    object MenuItemControl: TMenuItem
      Caption = #25511#21046'(&C)'
      object MenuItemReloadBlackList: TMenuItem
        Caption = #37325#36733#40657#21517#21333#21015#34920'(&B)'
        OnClick = MenuItemReloadBlackListClick
      end
    end
    object MenuItemView: TMenuItem
      Caption = #26597#30475'(&V)'
      object MenuItemViewConnNum: TMenuItem
        Caption = #24635#36830#25509#25968#37327'(&C)'
        OnClick = MenuItemViewConnNumClick
      end
    end
  end
  object TimerSecond: TTimer
    OnTimer = TimerSecondTimer
    Left = 301
    Top = 368
  end
end
