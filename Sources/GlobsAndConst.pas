unit GlobsAndConst;

interface
uses Winapi.Messages;

type
  TAppElement = record
    EName: string;
    EType: Byte;  //0 - ����, 1 - ����� (���������� �� �����������)
  end;

  //��������� ��� ������ � ������� ������
  TSmClipRec = record
    ObjID,
    SmID,
    DataID,
    DataType: Integer;
    RateType: Integer; //�������� ��� ������������(���� ��� ������ ��������� SubType �����)
  end;

  PSmClipRec = ^TSmClipRec;

const
//******************************************************************************
// ��������� ������ ����������
  //��������� ��� ��������� ����� �� ��� ������
  C_TMPDIR = 'Tmp\';
  //����� � �������
  C_ARHDIR = 'Arhiv\';
  //����� � ��������
  C_REPORTDIR = 'Reports\';
  //����� � ������
  C_LOGDIR = 'Logs\';
  //����� � ������������
  C_UPDATEDIR = 'Updates\';
  C_UPDMIRRORTMP = 'MirrorTmp\';
  //�������� ������� ��� ���������� ���������� (��������)
  C_UPDATERNAME = 'SmUpd.exe';

  arraymes: array[1..12, 1..2] of string =
    (('������',   '������'),
    ('�������',  '�������'),
    ('����',     '�����'),
    ('������',   '������'),
    ('���',      '���'),
    ('����',     '����'),
    ('����',     '����'),
    ('������',   '�������'),
    ('��������', '��������'),
    ('�������',  '�������'),
    ('������',   '������'),
    ('�������',  '�������'));

  //��� ������ ��� ������ ������
  C_SMETADATA = 'CF_SMETA';

  //��������� (���������� � ����� �������) ��� ET18, ET20
  C_ET18ITER = 2000000000;
  C_ET20ITER = 2000000001;

  //ID ����� ��� ������� GetNewID
  C_ID_OBJ     = 1;  //1 - ������
  C_ID_SM      = 2;  //2 - �����
  C_ID_SMRAT   = 3;  //3 - ����� ��������
  C_ID_SMMAT   = 4;  //4 - ����� ��������
  C_ID_SMMEC   = 5;  //5 - ����� ��������
  C_ID_SMDEV   = 6;  //6 - ����� ������������
  C_ID_SMDUM   = 7;  //7 - ����� ������
  C_ID_SMTR    = 8;  //8 - ����� ���������
  C_ID_DATA    = 9;  //9 - ����� data_row
  C_ID_SMCOEF  = 10; //10 - ����� calculation_coef
  //C_ID_ACT     = 11; //11 - ���  ------------��������
  C_ID_TRAVEL  = 12; //12 - ������ ���������������
  C_ID_TRWORK  = 13; //13 - ������ ���������� �����
  C_ID_WORKDEP = 14; //14 - ������ ��������� �������
  C_ID_SUPPAG  = 15; //15 - �������������� ����������
  C_ID_DOC     = 16; //16 - ��������� ����������

  CTabNameAndID: array [1..15, 0..1] of string =
    (('objcards', 'obj_id'),
    ('smetasourcedata', 'SM_ID'),
    ('card_rate', 'ID'),
    ('materialcard', 'ID'),
    ('mechanizmcard', 'ID'),
    ('devicescard', 'ID'),
    ('dumpcard', 'ID'),
    ('transpcard', 'ID'),
    ('data_row', 'ID'),
    ('calculation_coef', 'calculation_coef_id'),
    ('card_acts', 'ID'),
    ('travel', 'travel_id'),
    ('travel_work', 'travel_work_id'),
    ('worker_deartment', 'worker_department_id'),
    ('supp_agreement', 'supp_agreement_id'));

  �_MANIDDELIMETER = 1000000000; //����������� ID ��� ����������� ������ � ������������.

type
  TIDConvertArray = array [1..15, 0..1] of array of Integer;
//******************************************************************************

//******************************************************************************
// ��������� ����������� ��� ������ ������� ���������� �����������
const
//******************************************************************************
//  ��������� ����������� ��� ������ ������� ����������
  �_UPD_INI = 'Update.ini';
  //�������� ������� ����� ������� ���������� ����� �������
  C_GETVERSINTERVAL = 1200000;
  //��������� ���������� �������� ���� �� ���������� �������� ����������
  WM_SHOW_SPLASH = WM_USER + 1;
  //����� ������� ����������
  C_UPDATESERV = 'http://85.143.218.164:3113';
  //����� ����� ������������
  C_SUPPORTMAIL = 'd_grin@mail.ru';
  //��������� ����� �����������
  C_UPDATELOG = 'update.log';
  C_UPD_MIRRORNAME = 'AppVersion%0:d.zip';
  C_UPD_MIRRORMASK = 'AppVersion*.zip';
  C_UPD_MIRRORPAT1 = 'AppVersion';
  C_UPD_MIRRORPAT2 = '.zip';
//******************************************************************************

  //����� ����� ������ ������
  C_ARHBASEDIR = 'Base\';
  C_ARHAPPDIR = 'App\';

  //������� ������ ������ � ����� � �������
  C_BASETODUMP = 'To_Dump_all_database.bat';
  C_DUMPTOBASE = 'From_Dump_all_database.bat';
  //��� ����� ������ ��������������� ����� ����������� � �������
  C_DUMPNAME = 'all_database.sql';

  //������ �������� ������ ���������� ������� �����
  //�������������� ��� ���������� �����������
  //����� ���������� � ���������� ������� ����������
  //������������� ������ ���� � ���� �������
  �_APPSTRUCT: array [0..11] of TAppElement =
    ((EName: 'smeta.exe'; EType: 0),
     (EName: 'smeta.ini'; EType: 0),
     (EName: �_UPD_INI; EType: 0),
     (EName: 'libmysql.dll'; EType: 0),
     (EName: C_UPDATERNAME; EType: 0),
     (EName: C_ARHDIR + '\' + C_BASETODUMP; EType: 0),
     (EName: C_ARHDIR + '\' + C_DUMPTOBASE; EType: 0),
     (EName: 'sql'; EType: 1),
     (EName: 'settings'; EType: 1),
     (EName: 'reports'; EType: 1),
     (EName: 'xls'; EType: 1),
     (EName: 'docs'; EType: 1));

  //���������� ���-�� �������
  C_ARHCOUNT = 5;
//******************************************************************************

//******************************************************************************
//  ��������� ���������� ����������
  C_UPD_UPDATE = '-u'; //����������
  C_UPD_RESTOR = '-r'; //�������������� �� ������
  C_UPD_PATH = '-path'; //���� � ����� � ������������ (������)
  C_UPD_VERS = '-v'; //����� ������ ���������
  C_UPD_START = '-s'; //���������� ��������� ����� ����� ��������� ���������
  C_UPD_APP = '-a'; //��� ������������ ����������
//******************************************************************************

//******************************************************************************
//  ����������� ���� � ���������� �������
  WM_EXCECUTE = WM_USER + 2;
  WM_EXCEPTION = WM_USER + 3;
  WM_SPRLOAD = WM_USER + 4;
  WM_PRICELOAD = WM_USER + 5;
  //���������� ���������� �������� ������
  WM_ARCHIVEPROGRESS = WM_USER + 6;
  WM_UPDATEFORMSTYLE = WM_USER + 7;
  //���������� ���� ����������
  WM_UPDATESTATE = WM_USER + 8;
  WM_UPDATEPROGRESS = WM_USER + 9;

//******************************************************************************

//******************************************************************************
//  ��������� ID ����������
  C_DOCID_MAIS450 = 7;
  C_DOCID_TRANSP_XLT = 8;
//******************************************************************************

var
//******************************************************************************
  //���������� ���������� �������������� ���������� ����������
  //���� ������������� ��������� �������� �� ���������� ���������
  // 1 - ����������, 2 - �������������� �� ��������� �����
  G_STARTUPDATER: Byte = 0;

  G_UPDPATH: string = ''; //���� � ����� � ������������ ��� ��������� ������ ����������
  G_NEWAPPVERS: Integer = 0; //����� ������ ����������
  G_STARTAPP: Boolean = False; //��������� ���������� ����� ����������

  G_CONNECTSTR: string = 'DriverID=MySQL' + sLineBreak +
                         'User_name=root' + sLineBreak +
                         'Password=serg' + sLineBreak +
                         'SERVER=xxx' + sLineBreak +
                         'DATABASE=smeta' + sLineBreak +
                         'CharacterSet=cp1251' + sLineBreak +
                         'TinyIntFormat=Integer';
//******************************************************************************

//******************************************************************************
  //������������ ��������� �������
  G_CALCMODE: Byte = 1;   //0 - ����� (������) ������� �������; 1 - ������ (�� ������), ��� � ������ ���������
  //������������ ������� ����������� ������
  G_SHOWMODE: Byte = 1;  //0 - � ����������� �� ���������� � �����������
  //��������� RegisterClipboardFormat()
  G_SMETADATA: Integer;
  //ID �������� ������������
  G_USER_ID: Integer = 0;
  //���������� ��� ������ �������� ������������
  G_CURYEAR,
  G_CURMONTH: Integer;
  //�������� ��� ����������� �� ��������� � ���������
  G_NDS: Double = 20;

implementation

end.
