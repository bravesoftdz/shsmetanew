unit SSR;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fFrameSSR, Tools;

type
  TfSSR = class(TSmForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FrameSSR: TFrameSSR;
    SSRID: Integer;
    BtnCaption: string;
  public
    constructor Create(const ID: Integer; const ToolBtnCaption: string); reintroduce;
  end;

var
  fSSR: TfSSR;

implementation

{$R *.dfm}

uses Main;

constructor TfSSR.Create(const ID: Integer; const ToolBtnCaption: string);
begin
  SSRID := ID;
  BtnCaption := ToolBtnCaption;
  inherited Create(Application);
  Caption := ToolBtnCaption;
end;

procedure TfSSR.FormActivate(Sender: TObject);
begin
  // ���� ������ ������� Ctrl � �������� �����, �� ������
  // �������������� � ��������� ���� ����� �� �������� ����
  FormMain.CascadeForActiveWindow;
  // ������ ������� ������ �������� ����� (�� ������� ����� �����)
  FormMain.SelectButtonActiveWindow(BtnCaption);
end;

procedure TfSSR.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfSSR.FormCreate(Sender: TObject);
begin
  FrameSSR := TFrameSSR.Create(Self);
  FrameSSR.Parent := Self;
  FrameSSR.Align := alClient;
  FrameSSR.PanelMenu.Visible := False;
  FrameSSR.ComboBox.ItemIndex := SSRID - 1;
  with FrameSSR do
    case SSRID of
      1:
        lbPrikazRef.Caption := '��� 8.01.103 - 2012';
      2:
        lbPrikazRef.Caption := '��� 8.01.102 - 2012';
    else
      lbPrikazRef.Caption := '';
    end;

  if (SSRID >= 3) and (SSRID <= 5) then
    FrameSSR.ReceivingAll2
  else
    FrameSSR.ReceivingAll;
  FrameSSR.Visible := True;
  FormMain.CreateButtonOpenWindow(BtnCaption, BtnCaption, Self, 1);
  inherited;
end;

procedure TfSSR.FormDestroy(Sender: TObject);
begin
  // ������� ������ �� ����� ���� (�� ������� ����� �����)
  FormMain.DeleteButtonCloseWindow(BtnCaption);
  fSSR := nil;
end;

end.
