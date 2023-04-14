unit uNet;

interface

uses
  System.Win.ScktComp, Winapi.WinSock, System.SysUtils;

const
  /// <remarks> 数据传输缓冲大小 </remarks>
  DATA_BUF_SIZE = 1024 * 2;

type
  TMClientSocket = class(TServerClientWinSocket)
    /// <remarks> 当前数据包大小 </remarks>
    m_PacketSize: Integer;
    /// <remarks> 当前获得数据包大小的长度(等于4时完整获得) </remarks>
    m_PacketSizeLen: Byte;
    /// <remarks> 接收数据包缓冲区 </remarks>
    m_PacketBuf: array[0..DATA_BUF_SIZE - 1] of Byte;
    /// <remarks> 已接收数据大小 </remarks>
    m_PacketBufSize: Word;
  private
  public
    constructor Create(socket: TSocket; ServerWinSocket: TServerWinSocket);
    destructor Destroy; override;
    /// <remarks> 接收数据处理 </remarks>
    function RecvBufProc: Byte;
    /// <remarks> 完整消息到达 </remarks>
    procedure ProcessPacket;
  end;

implementation

uses
  uLog;

constructor TMClientSocket.Create(Socket: TSocket; ServerWinSocket: TServerWinSocket);
begin
  inherited;
end;

destructor TMClientSocket.Destroy;
begin
  inherited;
end;

function TMClientSocket.RecvBufProc: Byte;
var
  RecvBuffer: array[0..DATA_BUF_SIZE - 1] of Byte;
  RecvLen: Integer;   // 接受数据长度
  copyNum: Word;
  RecvLenTmp: Word;
begin
  // 数据格式：4字节长度 + data
  Result := 0;
  FillChar(RecvBuffer, SizeOf(RecvBuffer), 0);
  RecvLen := ReceiveBuf(RecvBuffer, SizeOf(RecvBuffer));
  if RecvLen <= 0 then
    Exit;
  var RecvBufPos: Word := 0;   // 当前读取位置
  var PacketSizeLen: Byte := SizeOf(m_PacketSize);
  while RecvBufPos < RecvLen do begin
    // 未获得完整4字节长度时拷贝长度
    if m_PacketSizeLen < PacketSizeLen then begin
      RecvLenTmp := RecvLen - RecvBufPos;
      if m_PacketSizeLen + RecvLenTmp <= PacketSizeLen then begin
        copyNum := RecvLenTmp;
      end
      else begin
        // RecvLen过大的情况下仅拷贝缺失数据
        copyNum := PacketSizeLen - m_PacketSizeLen;
      end;
      // 获得4字节实际数据包长度
      Move(RecvBuffer[RecvBufPos], PByte(@m_PacketSize)[m_PacketSizeLen], copyNum);
      Inc(m_PacketSizeLen, copyNum);
      Inc(RecvBufPos, copyNum);
    end;
    if (m_PacketSizeLen <> PacketSizeLen) or (m_PacketSize = 0) or (RecvBufPos = RecvLen) then
      Exit;
    if m_PacketSize > DATA_BUF_SIZE then begin
      Result := 1;
      Exit;
    end;
    if m_PacketBufSize < m_PacketSize then begin
      RecvLenTmp := RecvLen - RecvBufPos;
      if m_PacketBufSize + RecvLenTmp <= m_PacketSize then begin
        copyNum := RecvLenTmp;
      end
      else begin
        // RecvLen过大的情况下仅拷贝缺失数据
        copyNum := m_PacketSize - m_PacketBufSize;
      end;
      Move(RecvBuffer[RecvBufPos], m_PacketBuf[m_PacketBufSize], copyNum);
      Inc(m_PacketBufSize, copyNum);
      Inc(RecvBufPos, copyNum);
    end;
    if m_PacketBufSize = m_PacketSize then begin
      ProcessPacket;
      m_PacketSize := 0;
      m_PacketSizeLen := 0;
      m_PacketBufSize := 0;
      FillChar(m_PacketBuf, SizeOf(m_PacketBuf), 0);
    end;
  end;
end;

procedure TMClientSocket.ProcessPacket;
begin
  var tbytes: tbytes;
  SetLength(tbytes, m_PacketSize);
  Move(m_PacketBuf[0], tbytes[0], m_PacketSize);
  Log(Format('收到数据：%s', [TEncoding.UTF8.GetString(tbytes)]));
end;

end.

