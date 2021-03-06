unit TariffsMechanism;

interface

uses
  Windows, Messages, Classes, Controls, Forms, ExtCtrls, AppEvnts, SysUtils, Tools;

type
  TFormTariffsMechanism = class(TSmForm)

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private const
    CaptionButton = '���� �� ���������';

  const
    HintButton = '���� ���� �� ���������';
  private
    procedure WMSysCommand(var Msg: TMessage); message WM_SYSCOMMAND;
  public
    //29.05.2015 FramePriceMechanizm: TFramePriceMechanizm;
  end;

var
  FormTariffsMechanism: TFormTariffsMechanism;

implementation

uses Main, Waiting;

{$R *.dfm}

procedure TFormTariffsMechanism.WMSysCommand(var Msg: TMessage);
begin
  // SC_MAXIMIZE - �������������� ����� �� ���� �����
  // SC_RESTORE - ������������ ����� � ����
  // SC_MINIMIZE - ������������ ����� � ��������� ������

  if (Msg.WParam = SC_MAXIMIZE) or (Msg.WParam = SC_RESTORE) then
  begin
    FormMain.PanelCover.Visible := True;
    inherited;
    FormMain.PanelCover.Visible := False;
  end
  else if Msg.WParam = SC_MINIMIZE then
  begin
    FormMain.PanelCover.Visible := True;
    inherited;
    ShowWindow(FormTariffsMechanism.Handle, SW_HIDE); // �������� ������ �������� �����
    FormMain.PanelCover.Visible := False;
  end
  else
    inherited;
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormTariffsMechanism.FormCreate(Sender: TObject);
begin
  // ��������� �������� � ��������� �����
  ClientWidth := FormMain.ClientWidth div 2;
  ClientHeight := FormMain.ClientHeight div 2;
  Top := 10; // (GetSystemMetrics(SM_CYFRAME) + GetSystemMetrics(SM_CYCAPTION)) * -1;
  Left := 10; // GetSystemMetrics(SM_CXFRAME) * -1;

  WindowState := wsMaximized;
  Caption := FormNamePriceMechanizms;

  // ----------------------------------------

  {29.05.2015 FramePriceMechanizm := TFramePriceMechanizm.Create(Self, 'g', True, True);
  FramePriceMechanizm.Parent := Self; }

  FormWaiting.Show;
  Application.ProcessMessages;

  {29.05.2015 FramePriceMechanizm.ReceivingAll; }

  FormWaiting.Close;
  FormMain.PanelCover.Visible := False;

  // ������ ������ �� ����� ���� (�� ������� ����� �����)
  FormMain.CreateButtonOpenWindow(CaptionButton, HintButton, Self, 1);
  inherited;
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormTariffsMechanism.FormActivate(Sender: TObject);
begin
  // ���� ������ ������� Ctrl � �������� �����, �� ������
  // �������������� � ��������� ���� ����� �� �������� ����
  FormMain.CascadeForActiveWindow;

  // ������ ������� ������ �������� ����� (�� ������� ����� �����)
  FormMain.SelectButtonActiveWindow(CaptionButton);
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormTariffsMechanism.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormTariffsMechanism.FormDestroy(Sender: TObject);
begin
  FormTariffsMechanism := nil;
  // ������� ������ �� ����� ���� (�� ������� ����� �����)
  FormMain.DeleteButtonCloseWindow(CaptionButton);
end;

end.
