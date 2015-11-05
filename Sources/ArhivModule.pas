unit ArhivModule;

interface
uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Types,
  SyncObjs,
  Winapi.Windows,
  Winapi.Messages,
  ZipForge,
  GlobsAndConst;

//��������������� ������ ���������� ���������� ��������� SendMessage
//��� �������� � ������� ����� �������� ����� �������� ���������� ����������
//����������������, ��� ������� ������������ Application.ProgressMessage;
//��� �����, ���� ���������� �� ����������� ����� ������ SendMessage � Synhronize

type
  TThreadCreateArchiv = class(TThread)
  private
    FHandle: HWND;
    FArhivPath,
    FAppPath: string;
  protected
    procedure Execute; override;
  public
    constructor Create(AHandle: HWND; const AArhivPath, AAppPath: string;
      ACreateSuspended: Boolean);
  end;

  TThreadRestoreArchiv = class(TThread)
  private
    FHandle: HWND;
    FArhivPath,
    FAppPath,
    FArhivName: string;

  protected
    procedure Execute; override;
  public
    constructor Create(AHandle: HWND; const AArhivPath, AAppPath, AArhivName: string;
      ACreateSuspended: Boolean);
  end;

  TBaseAppArhiv = class(TObject)
  private
    FAppPath,
    FArhivPath: string;
    FArhFiles: TStringDynArray;

    FCreateArh: TThreadCreateArchiv;
    FCreateArhHandle: THandle;

    FRestoreArh: TThreadRestoreArchiv;
    FRestoreArhHandle: THandle;

    procedure ThreadTerminate(ASender: TObject);
    function GetInProgress(AIndex: Integer): Boolean;
  public
    constructor Create(const AAppPath, AArhivPath: string);
    destructor Destroy; override;
    procedure Update();
    function GetArhivTime(const AArhivName: string): TDateTime;
    procedure DeleteArhiv(const AArhivName: string);
    procedure RestoreArhiv(AHandle: HWND; const AArhivName: string);
    procedure CreateNewArhiv(AHandle: HWND);
    property ArhivPath: string read FArhivPath;
    property ArhFiles: TStringDynArray read FArhFiles;
    property CreateArhInProgress: Boolean Index 0 read GetInProgress;
    property RestoreArhInProgress: Boolean Index 1 read GetInProgress;
    property CreateArhHandle: THandle read FCreateArhHandle;
    property RestoreArhHandle: THandle read FRestoreArhHandle;
  end;

  procedure CopyAppTo(const ASourceDir, ADestDir: string);

implementation

uses  Tools, fUpdate, Forms;


procedure CopyAppTo(const ASourceDir, ADestDir: string);
var i: Integer;
begin
  for i:= Low(�_APPSTRUCT) to High(�_APPSTRUCT) do
  begin
    if �_APPSTRUCT[i].EType = 0 then //����� ������ ����������
    begin
      if TFile.Exists(ASourceDir + �_APPSTRUCT[i].EName) then
      begin
        //��������� ������������ ����� ������ ���� Dirname\Filename.ext
        ForceDirectories(ExtractFileDir(ADestDir + �_APPSTRUCT[i].EName));
        TFile.Copy(ASourceDir + �_APPSTRUCT[i].EName,
          ADestDir + �_APPSTRUCT[i].EName, True);
      end;
    end;

    if �_APPSTRUCT[i].EType = 1 then //����� ������ ����������
    begin
      if TDirectory.Exists(ASourceDir + �_APPSTRUCT[i].EName) then
      begin
        TDirectory.Copy(ASourceDir + �_APPSTRUCT[i].EName,
          ADestDir + �_APPSTRUCT[i].EName);
      end;
    end;
  end;
end;

{ TBaseAppArhiv }

constructor TBaseAppArhiv.Create(const AAppPath, AArhivPath: string);
begin
  if not TDirectory.Exists(AArhivPath) then
    TDirectory.CreateDirectory(AArhivPath);

  inherited Create;
  FAppPath := IncludeTrailingPathDelimiter(AAppPath);
  FArhivPath := IncludeTrailingPathDelimiter(AArhivPath);
  try
    if not TDirectory.Exists(FAppPath) then
      raise Exception.Create('���������� ''' + AAppPath + ''' �� ������.');
    Update();
  except
    on e: Exception do
    begin
      Destroy;
      raise e;
    end;
  end;
end;

destructor TBaseAppArhiv.Destroy;
begin
  //���� ��� ����������� ���������� �������
  if Assigned(FCreateArh) then
    while WaitForSingleObject(FCreateArhHandle, 1000) <> WAIT_OBJECT_0 do
      Application.ProcessMessages;

  if Assigned(FRestoreArh) then
    while WaitForSingleObject(FRestoreArhHandle, 1000) <> WAIT_OBJECT_0 do
      Application.ProcessMessages;

  inherited;
end;

procedure TBaseAppArhiv.ThreadTerminate(ASender: TObject);
begin
  if ASender = FCreateArh then
    FCreateArh := nil;
  if ASender = FRestoreArh then
    FRestoreArh := nil;
end;

function TBaseAppArhiv.GetInProgress(AIndex: Integer): Boolean;
begin
  case AIndex of
  0: Result := Assigned(FCreateArh);
  1: Result := Assigned(FRestoreArh);
  else Result := False;
  end;
end;

function TBaseAppArhiv.GetArhivTime(const AArhivName: string): TDateTime;
var TmpStr: string;
    TmpList: TStringList;
    y,m,d: Word;
begin
  TmpList := TStringList.Create;
  try
    TmpStr := ExtractFileName(AArhivName);
    TmpStr := StringReplace(TmpStr, '_arh.zip', '', [rfIgnoreCase]);
    TmpStr := StringReplace(TmpStr, '_', #13#10, [rfReplaceAll]);
    TmpList.Text := TmpStr;
    y := StrToInt(TmpList[0]);
    m := StrToInt(TmpList[1]);
    d := StrToInt(TmpList[2]);
    Result := EncodeDate(y, m, d);
    Result := Result + (StrToInt(TmpList[3]))/10000;
  finally
    FreeAndNil(TmpList);
  end;
end;

procedure TBaseAppArhiv.RestoreArhiv(AHandle: HWND; const AArhivName: string);
begin
  if not SameText(ExtractFilePath(AArhivName), FArhivPath) then
    raise Exception.Create('������������ ����� ''' + AArhivName +
      ''' �� ��������� � ������������� ������');

  FRestoreArh := TThreadRestoreArchiv.Create(AHandle, FArhivPath, FAppPath,
    AArhivName, True);
  FRestoreArh.OnTerminate := ThreadTerminate;
  FRestoreArh.FreeOnTerminate := True;
  FRestoreArh.Start;
  FRestoreArhHandle := FRestoreArh.Handle;
end;

procedure TBaseAppArhiv.DeleteArhiv(const AArhivName: string);
begin
  if not SameText(ExtractFilePath(AArhivName), FArhivPath) then
    raise Exception.Create('������������ ����� ''' + AArhivName +
      ''' �� ��������� � ������������� ������');
  TFile.Delete(AArhivName);
  Update();
end;

procedure TBaseAppArhiv.CreateNewArhiv(AHandle: HWND);
begin
  if Assigned(FCreateArh) then
    raise Exception.Create('�������� ������ ��� ��������.');

  FCreateArh := TThreadCreateArchiv.Create(AHandle, FArhivPath, FAppPath, True);
  FCreateArh.OnTerminate := ThreadTerminate;
  FCreateArh.FreeOnTerminate := True;
  FCreateArh.Start;
  FCreateArhHandle := FCreateArh.Handle;
end;

procedure TBaseAppArhiv.Update();
var i, j, k: Integer;
    TmpStr: string;
begin
  FArhFiles := TDirectory.GetFiles(FArhivPath, '*_arh.zip',
    TSearchOption.soTopDirectoryOnly);
  //��������� ������ �� ��������
  for i := Low(FArhFiles) to High(FArhFiles) do
  begin
    k := i;
    TmpStr := FArhFiles[i];
    for j := i + 1 to High(FArhFiles) do
      if (FArhFiles[j] > TmpStr) then
      begin
        k := j;
        TmpStr := FArhFiles[j];
      end;
    if k <> i then
    begin
      FArhFiles[k] := FArhFiles[i];
      FArhFiles[i] := TmpStr;
    end;
  end;
end;

{ TThreadCreateArchiv }

constructor TThreadCreateArchiv.Create(AHandle: HWND;
  const AArhivPath, AAppPath: string;
  ACreateSuspended: Boolean);
begin
  FHandle := AHandle;
  FArhivPath := AArhivPath;
  FAppPath := AAppPath;
  inherited Create(ACreateSuspended);
end;

procedure TThreadCreateArchiv.Execute;
var ZF: TZipForge;
    TmpCurPath: string;
    TmpWaitResult: DWord;
    y,m,d,t: Word;

    function FileSize(const aFilename: String): Int64;
    var info: TWin32FileAttributeData;
    begin
      result := -1;
      if not GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
        EXIT;
      result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
    end;
begin
  TmpCurPath := TDirectory.GetCurrentDirectory;
  ZF := TZipForge.Create(nil);
  try
    try
      SendMessage(FHandle, WM_ARCHIVEPROGRESS,
        WParam(PChar('�������� ����� ��')), 1);

      //�������������� �������� ����� ��� ����� ������ �����
      if TDirectory.Exists(FArhivPath + C_TMPDIR) then
        KillDir(FArhivPath + C_TMPDIR);

      //���� ���� ������� ���������
      if TFile.Exists(FArhivPath + C_DUMPNAME) then
        TFile.Delete(FArhivPath + C_DUMPNAME);

      if not TFile.Exists(FArhivPath + C_BASETODUMP) then
        raise Exception.Create('������ ''' + C_BASETODUMP + ''' �� ������!');

      //������ ������� ����������, ����� �� ��������� ���� ��� ���
      TDirectory.SetCurrentDirectory(FArhivPath);

      //������ �������� ������
      //� ��������� ������� �������� ������ �� ��� �� ��������������
      WinExecAndWait(C_BASETODUMP, nil, 0, TmpWaitResult);

      if (TmpWaitResult <> WAIT_OBJECT_0) or
        not TFile.Exists(FArhivPath + C_DUMPNAME) or
        (FileSize(FArhivPath + C_DUMPNAME) < 1024*1024*2) then //2�� ����� �������
        raise Exception.Create('�� ������� ������� ���� ���� ������!');

      //������� ����� ���� � ����� ���������� � ������
      TDirectory.CreateDirectory(FArhivPath + C_TMPDIR + C_ARHBASEDIR);
      TDirectory.CreateDirectory(FArhivPath + C_TMPDIR + C_ARHAPPDIR);

      SendMessage(FHandle, WM_ARCHIVEPROGRESS,
        WParam(PChar('����������� ��������� � �����')), 1);

      try
        //���������� ��������� ���� � �����
        TFile.Move(FArhivPath + C_DUMPNAME,
          FArhivPath + C_TMPDIR + C_ARHBASEDIR + C_DUMPNAME);
        //�������� � ����� ����������
        CopyAppTo(FAppPath, FArhivPath + C_TMPDIR + C_ARHAPPDIR);
      except
        on e: Exception do
          raise Exception.Create('������ �����������: ' + e.Message);
      end;

      try
        //����������� � ����� � ���������� ������
        DecodeDate(Date, y, m, d);
        t := Trunc(Time * 10000);
        ZF.FileName := FArhivPath + IntToStr(y) + '_' +
          copy(IntToStr(100 + m), 2, 2) +  '_' +
          copy(IntToStr(100 + d), 2, 2) + '_' +
          copy(IntToStr(10000 + t), 2, 4) + '_arh.zip';
        ZF.Options.CreateDirs := true;
        ZF.Options.OverwriteMode := omAlways;
        ZF.OpenArchive(fmCreate);
        ZF.BaseDir := FArhivPath + C_TMPDIR;
        ZF.AddFiles('*');
        ZF.CloseArchive;
      except
        on e: Exception do
          raise Exception.Create('������ ��������: ' + e.Message);
      end;
    except
      on e: Exception do
      begin
        e.Message := '� �������� �������� ������ �������� ����������:' +
          sLineBreak + e.Message;
        SendMessage(FHandle, WM_EXCEPTION, WParam(e), 0);
      end;
    end;
  finally
    FreeAndNil(ZF);
    TDirectory.SetCurrentDirectory(TmpCurPath);

    if TFile.Exists(FArhivPath + C_DUMPNAME) then
      TFile.Delete(FArhivPath + C_DUMPNAME);

    if TDirectory.Exists(FArhivPath + C_TMPDIR) then
      KillDir(FArhivPath + C_TMPDIR);

    SendMessage(FHandle, WM_ARCHIVEPROGRESS, 0, 2);
  end;
end;

{ TThreadRestoreArchiv }

constructor TThreadRestoreArchiv.Create(AHandle: HWND; const AArhivPath,
  AAppPath, AArhivName: string; ACreateSuspended: Boolean);
begin
  FHandle := AHandle;
  FArhivPath := AArhivPath;
  FAppPath := AAppPath;
  FArhivName := AArhivName;
  inherited Create(ACreateSuspended);
end;

procedure TThreadRestoreArchiv.Execute;
var ZF: TZipForge;
    TmpCurPath: string;
    TmpWaitResult: DWord;
begin
  TmpCurPath := TDirectory.GetCurrentDirectory;
  ZF := TZipForge.Create(nil);
  try
    try
      SendMessage(FHandle, WM_ARCHIVEPROGRESS,
        WParam(PChar('���������� ������')), 1);
      //�������������� �������� �����
      if TDirectory.Exists(FArhivPath + C_TMPDIR) then
        KillDir(FArhivPath + C_TMPDIR);
      TDirectory.CreateDirectory(FArhivPath + C_TMPDIR);

      //���� ���� ������� ���������
      if TFile.Exists(FArhivPath + C_DUMPNAME) then
        TFile.Delete(FArhivPath + C_DUMPNAME);

      //������ ������� ����������
      TDirectory.SetCurrentDirectory(FArhivPath);

      try
        ZF.BaseDir := FArhivPath + C_TMPDIR;
        ZF.Options.CreateDirs := true;
        ZF.Options.OverwriteMode := omAlways;

        ZF.FileName := FArhivName;
        ZF.OpenArchive;
        ZF.ExtractFiles('*');
        ZF.CloseArchive;

      except
        on e: Exception do
          raise Exception.Create('������ ����������: ' + e.Message);
      end;

      try
        //������������ ���� � ������� ����������
        if TFile.Exists(FArhivPath + C_TMPDIR + C_ARHBASEDIR + C_DUMPNAME) then
          TFile.Move(FArhivPath + C_TMPDIR + C_ARHBASEDIR + C_DUMPNAME,
            FArhivPath + C_DUMPNAME);
      except
        on e: Exception do
          raise Exception.Create('������ �����������: ' + e.Message);
      end;

      SendMessage(FHandle, WM_ARCHIVEPROGRESS,
        WParam(PChar('�������� ����� ��')), 1);

      if not TFile.Exists(FArhivPath + C_DUMPTOBASE) then
        raise Exception.Create('������ ''' + C_DUMPTOBASE + ''' �� ������!');

      //������ �������������� �� �����
      //�� ����� �� ��������� �����������!!!!!!!!!!!
      WinExecAndWait(C_DUMPTOBASE, nil, 0, TmpWaitResult);
      if (TmpWaitResult <> WAIT_OBJECT_0) then
        raise Exception.Create('�� ������� ������������ ���� �� �����!');

      //��������� �� ������ �������� (������ ������������ ��������)
      if TFile.Exists(G_UPDPATH + C_UPDATERNAME) then
      begin
        TFile.Copy(G_UPDPATH + C_UPDATERNAME,
          FAppPath + C_UPDATERNAME, True);
        TFile.Delete(G_UPDPATH + C_UPDATERNAME);
      end;

      G_STARTUPDATER := 2;
      G_UPDPATH := FArhivPath + C_TMPDIR + C_ARHAPPDIR;
      G_STARTAPP := True;

      SendMessage(FHandle, WM_ARCHIVEPROGRESS,
        WParam(PChar('��������� ����� ������������')), 0);
      sleep(2000);
      PostMessage(FHandle, WM_ARCHIVEPROGRESS, 0, 2);
    except
      on e: Exception do
      begin
        e.Message := '� �������� �������������� �� ������ �������� ����������:' +
          sLineBreak + e.Message;
        SendMessage(FHandle, WM_EXCEPTION, WParam(e), 0);
      end;
    end;
  finally
    FreeAndNil(ZF);

    TDirectory.SetCurrentDirectory(TmpCurPath);

    if TFile.Exists(FArhivPath + C_DUMPNAME) then
      TFile.Delete(FArhivPath + C_DUMPNAME);
  end;
end;

end.
