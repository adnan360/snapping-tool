unit frmcontrolunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  LCLIntf, LCLType, StdCtrls,
  BGRABitmap, BGRABitmapTypes;

type

  { TfrmSnapControl }

  TfrmSnapControl = class(TForm)
    ImageList1: TImageList;
    Label1: TLabel;
    ToolBar1: TToolBar;
    btnNew: TToolButton;
    btnCancel: TToolButton;
    ToolButton3: TToolButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure CaptureSnap;
  end;

var
  frmSnapControl: TfrmSnapControl;

  //bmpSnap: TBitmap;
  bmpSnap: TBGRABitmap;
  bmpSnapBlended: TBGRABitmap;
  bmpCropped: TBGRABitmap;

implementation

uses
  frmsnapunit;

{$R *.lfm}

{ TfrmSnapControl }

procedure TfrmSnapControl.FormCreate(Sender: TObject);
begin

end;

procedure TfrmSnapControl.btnNewClick(Sender: TObject);
begin
  CaptureSnap;
end;

procedure TfrmSnapControl.btnCancelClick(Sender: TObject);
begin
  frmSnap.Hide;
  btnCancel.Enabled:=False;
end;

procedure TfrmSnapControl.FormDestroy(Sender: TObject);
begin
  bmpSnap.Free;
  bmpSnapBlended.Free;
  bmpCropped.Free;
end;

procedure TfrmSnapControl.FormShow(Sender: TObject);
begin
  if frmSnap.Visible = False then
    CaptureSnap;
end;

procedure TfrmSnapControl.CaptureSnap();
var
  ScreenDC: HDC;
begin
  btnCancel.Enabled:=True;

  if Visible = True then begin
    Visible:=False;
    Sleep(500);
  end;

  if bmpSnap = nil then
    bmpSnap := TBGRABitmap.Create;

  if bmpSnapBlended = nil then
    bmpSnapBlended := TBGRABitmap.Create;

  if bmpCropped = nil then
    bmpCropped := TBGRABitmap.Create;

  ScreenDC := GetDC(0);
  //bmpSnap.LoadFromDevice(ScreenDC);
  bmpSnap.SetSize(Screen.Width,Screen.Height);
  bmpSnap.LoadFromDevice(ScreenDC);
  ReleaseDC(0, ScreenDC);

  //Create faded image
  bmpSnapBlended.SetSize(bmpSnap.Width,bmpSnap.Height);
  bmpSnapBlended.Assign(bmpSnap);
  bmpSnapBlended.FillRect(0,0,bmpSnapBlended.Width,bmpSnapBlended.Height,BGRA(255,255,255,128), dmDrawWithTransparency);

  with frmSnap do begin
      Show;
      SetBounds(0, 0, Screen.Width, Screen.Height);
      bmpSnapBlended.Draw(imgSnap.Canvas,0,0,true);
  end;

  Visible:=True;
  FormStyle:=fsStayOnTop;
end;

end.

