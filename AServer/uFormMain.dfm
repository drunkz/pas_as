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
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 12
  object dbConn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'JournalMode=Off'
      'Synchronous=Full')
    Left = 24
    Top = 384
  end
end
