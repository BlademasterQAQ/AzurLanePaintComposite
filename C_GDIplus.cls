VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CGDIp"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'// ����API //
Private Declare Function GdiplusStartup Lib "GdiPlus" (token As Long, inputbuf As GdiplusStartupInput, Optional ByVal outputbuf As Long = 0) As Long
Private Declare Function GdiplusShutdown Lib "GdiPlus" (ByVal token As Long) As Long
Private Declare Function GdipSaveImageToFile Lib "GdiPlus" (ByVal hImage As Long, ByVal sFilename As Long, clsidEncoder As Any, encoderParams As Any) As Long
Private Declare Function GdipGetImageEncodersSize Lib "GdiPlus" (numEncoders As Long, size As Long) As Long
Private Declare Function GdipGetImageEncoders Lib "GdiPlus" (ByVal numEncoders As Long, ByVal size As Long, encoders As Any) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private Declare Function lstrlenW Lib "kernel32" (ByVal psString As Any) As Long

'// �������� //
Private Type GdiplusStartupInput
   GdiplusVersion As Long
   DebugEventCallback As Long
   SuppressBackgroundThread As Long
   SuppressExternalCodecs As Long
End Type
Private Type Clsid
   Data1 As Long
   Data2 As Integer
   Data3 As Integer
   Data4(0 To 7) As Byte
End Type
Private Type ImageCodecInfo
    ClassID(0 To 3) As Long
    FormatID(0 To 3) As Long
    CodecName As Long
    DllName As Long
    FormatDescription As Long
    FilenameExtension As Long
    MimeType As Long
    flags As Long
    Version As Long
    SigCount As Long
    SigSize As Long
    SigPattern As Long
    SigMask As Long
End Type

'// ����� //
Private m_Token As Long
Private m_Graphics As Long

'// ����GDIplus
Public Function Startup()
  Dim uInput As GdiplusStartupInput
  uInput.GdiplusVersion = 1
  If GdiplusStartup(m_Token, uInput) = 0 Then
    Startup = True
  End If
End Function

'// ����
Public Sub Terminate()
  If m_Token Then Call GdiplusShutdown(m_Token)
End Sub

'// ����ͼƬ
Public Function LoadImage(ByRef Path As String) As Object
  Dim TempObj As New CGDIpImage
  Set LoadImage = TempObj.Load(Path)
  Set TempObj = Nothing
End Function

'// ��������
Public Function CreatGraphics(ByVal Width As Long, ByVal Height As Long) As Object
  Dim TempObj As New CGDIpGraphics
  Set CreatGraphics = TempObj.Create(Width, Height)
  Set TempObj = Nothing
End Function

'// ����ͼƬ.PNG
Public Function Save(ByVal Graphics As Object, ByVal FileName As String)
  Dim Clsid(3) As Long
  If Not GetEncoderClsID("Image/png", Clsid) = -1 Then
    Save = (GdipSaveImageToFile(Graphics.Bitmap, StrPtr(FileName), Clsid(0), ByVal 0) = 0) '����ΪPNG
  End If
End Function
Public Function GetEncoderClsID(strMimeType As String, ClassID() As Long) As Long
    Dim Num As Long
    Dim size As Long
    Dim I As Long
    Dim Info() As ImageCodecInfo
    Dim buffer() As Byte
    GetEncoderClsID = -1
    GdipGetImageEncodersSize Num, size '�õ�����������Ĵ�С
    If size <> 0 Then
        ReDim Info(1 To Num) As ImageCodecInfo '�����鶯̬�����ڴ�
        ReDim buffer(1 To size) As Byte
        GdipGetImageEncoders Num, size, buffer(1) '�õ�������ַ�����
        CopyMemory Info(1), buffer(1), (Len(Info(1)) * Num) '������ͷ
        For I = 1 To Num 'ѭ��������н���
            If (StrComp(PtrToStrW(Info(I).MimeType), strMimeType, vbTextCompare) = 0) Then '�����ָ��ת���ɿ��õ��ַ�
                CopyMemory ClassID(0), Info(I).ClassID(0), 16 '�������ID
                GetEncoderClsID = I '���سɹ�������ֵ
                Exit For
            End If
        Next
    End If
End Function
Public Function PtrToStrW(ByVal lpsz As Long) As String
    Dim Out As String
    Dim Length As Long
    Length = lstrlenW(lpsz)
    If Length > 0 Then
        Out = StrConv(String$(Length, vbNullChar), vbUnicode)
        CopyMemory ByVal Out, ByVal lpsz, Length * 2
        PtrToStrW = StrConv(Out, vbFromUnicode)
    End If
End Function