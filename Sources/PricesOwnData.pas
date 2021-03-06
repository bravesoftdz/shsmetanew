unit PricesOwnData;

interface

uses
  Windows,
  Messages,
  Classes,
  Controls,
  Forms,
  Buttons,
  ExtCtrls,
  System.SysUtils,
  fFramePriceTransportations,
  fFramePriceDumps, fFrameSmeta, Tools;

type
  TFormPricesOwnData = class(TSmForm)

    PanelPrices: TPanel;
    SpeedButtonPriceMaterials: TSpeedButton;
    SpeedButtonPriceMechanizms: TSpeedButton;
    SpeedButtonPriceTransportation: TSpeedButton;
    SpeedButtonPriceDumps: TSpeedButton;

    constructor Create(AOwner: TComponent; const vDataBase: Char; const vPriceColumn: Boolean); reintroduce;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure HideAllFrames;

    procedure SpeedButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    const CaptionButton = '���� �� ������. ������';
    const HintButton = '���� ���� �� ����������� ������';
  private
    procedure WMSysCommand(var Msg: TMessage); message WM_SYSCOMMAND;

  public
   { FramePriceMaterials: TFramePriceMaterial;
    FramePriceMechanizms: TFramePriceMechanizm;}
    FramePriceTransportations: TFramePriceTransportations;
    FramePriceDumps: TFramePriceDumps;

  end;

var
  FormPricesOwnData: TFormPricesOwnData;

implementation

uses Main, Waiting;

{$R *.dfm}

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormPricesOwnData.WMSysCommand(var Msg: TMessage);
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
    ShowWindow(FormPricesOwnData.Handle, SW_HIDE); // �������� ������ �������� �����
    FormMain.PanelCover.Visible := False;
  end
  else
    inherited;
end;

// ---------------------------------------------------------------------------------------------------------------------

constructor TFormPricesOwnData.Create(AOwner: TComponent; const vDataBase: Char; const vPriceColumn: Boolean);
begin
  inherited Create(AOwner);

  // ----------------------------------------

  FormMain.PanelCover.Visible := True; // ���������� ������ �� ������� �����

  // ----------------------------------------

  // ��������� �������� � ��������� �����

  ClientWidth := FormMain.ClientWidth;
  ClientHeight := FormMain.ClientHeight;
  Top := (GetSystemMetrics(SM_CYFRAME) + GetSystemMetrics(SM_CYCAPTION)) * -1;
  Left := GetSystemMetrics(SM_CXFRAME) * -1;

  WindowState := wsMaximized;
  Caption := FormNamePricesOwnData;

  // ----------------------------------------
   {
  FramePriceMaterials := TFramePriceMaterial.Create(Self, vDataBase, vPriceColumn, False, False);
  FramePriceMaterials.Parent := Self;
  FramePriceMaterials.align := alClient;
  FramePriceMaterials.Visible := True;
  SpeedButtonPriceMaterials.Tag := Integer(FramePriceMaterials);

  FramePriceMechanizms := TFramePriceMechanizm.Create(Self, vDataBase, vPriceColumn, False);
  FramePriceMechanizms.Parent := Self;
  FramePriceMechanizms.align := alClient;
  FramePriceMechanizms.Visible := False;
  SpeedButtonPriceMechanizms.Tag := Integer(FramePriceMechanizms); }

  FramePriceTransportations := TFramePriceTransportations.Create(Self, Date);
  FramePriceTransportations.Parent := Self;
  FramePriceTransportations.align := alClient;
  FramePriceTransportations.Visible := False;
  SpeedButtonPriceTransportation.Tag := Integer(FramePriceTransportations);

  FramePriceDumps := TFramePriceDumps.Create(Self, Date);
  FramePriceDumps.Parent := Self;
  FramePriceDumps.align := alClient;
  FramePriceDumps.Visible := False;
  SpeedButtonPriceDumps.Tag := Integer(FramePriceDumps);

  SpeedButtonClick(SpeedButtonPriceMaterials);
  {FramePriceMaterials.Visible := True;  }

  FormMain.PanelCover.Visible := False;

  // ----------------------------------------

  FormMain.CreateButtonOpenWindow(CaptionButton, HintButton, Self);
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormPricesOwnData.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFormPricesOwnData.FormCreate(Sender: TObject);
begin
  inherited;
  //
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormPricesOwnData.FormActivate(Sender: TObject);
begin
  // ���� ������ ������� Ctrl � �������� �����, �� ������ �������������� � ��������� ���� ����� �� �������� ����
  FormMain.CascadeForActiveWindow;

  // ������ ������� ������ �������� ����� (�� ������� ����� �����)
  FormMain.SelectButtonActiveWindow(CaptionButton);
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormPricesOwnData.FormDestroy(Sender: TObject);
begin
  FormPricesOwnData := nil;

  // ������� ������ �� ����� ���� (�� ������� ����� �����)
  FormMain.DeleteButtonCloseWindow(CaptionButton);
end;

// ---------------------------------------------------------------------------------------------------------------------

procedure TFormPricesOwnData.HideAllFrames;
begin
 { FramePriceMaterials.Visible := False;
  FramePriceMechanizms.Visible := False;      }
  FramePriceTransportations.Visible := False;
  FramePriceDumps.Visible := False;
end;

procedure TFormPricesOwnData.SpeedButtonClick(Sender: TObject);
begin
  HideAllFrames;

  if not Assigned(TSmetaFrame((Sender as TComponent).Tag)) then exit;


  with TSmetaFrame((Sender as TComponent).Tag) do
  begin
    if not Loaded then
    begin
      FormWaiting.Show;
      Application.ProcessMessages;
      try
        ReceivingAll;
      finally
        FormWaiting.Close;
      end;
    end
    else
        CheckCurPeriod;

    if (Self as TControl).Visible then
    begin
      Visible := True;
      SetFocus;
    end;
  end;
end;

end.
