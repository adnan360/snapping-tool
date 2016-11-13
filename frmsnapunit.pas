unit frmsnapunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  BGRABitmap, BGRABitmapTypes;

type

  { TfrmSnap }

  TfrmSnap = class(TForm)
    imgSelect: TImage;
    imgSnap: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure imgSnapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgSnapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgSnapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSnap: TfrmSnap;

  //bmpSnapOriginal: TBGRABitmap;
  px, py, cx, cy: Integer;
  MouseIsDown: Boolean;

implementation

uses
  frmcontrolunit, frmeditorunit;

{$R *.lfm}

{ TfrmSnap }

procedure TfrmSnap.imgSnapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //MouseIsDown:=True;
  //imgSnapMouseMove(Sender, Shift, x, y);
  //cx:=X;
  //cy:=Y;
  MouseIsDown:=False;

  bmpCropped.SetSize(abs(cx-px), abs(cy-py));
  bmpSnap.DrawPart(
                   Rect(px, py, bmpSnap.Width+px, bmpSnap.Height+py),
                   bmpCropped.Canvas,
                   0, 0, true
                   );
  //bmpCropped.SetSize(bmpSnap.Width, bmpSnap.Height);
  //bmpSnap.Draw(bmpCropped.Canvas,0,0);

  Hide;
  frmSnapControl.Hide;
  frmEditor.Show;
  Close;
end;

procedure TfrmSnap.FormCreate(Sender: TObject);
begin
  imgSelect.SetBounds(0,0,Width,Height);
  Canvas.Pen.Color:=clRed;
end;

procedure TfrmSnap.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TfrmSnap.imgSnapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  px:=X;
  py:=Y;
  MouseIsDown:=True;
end;

procedure TfrmSnap.imgSnapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  getRect: TRect;
begin

  if MouseIsDown=True then begin

    //if not imgSelect.Visible then
    //  imgSelect.Visible := True;

    cx:=X;
    cy:=Y;

    getRect := Rect(px, py, X, Y);


    //imgSelect.SetBounds(px, py, X - px, Y - py);

    bmpSnapBlended.Draw(Canvas,0,0);
    Canvas.Rectangle(getRect.Left-1,getRect.Top-1,getRect.Right+1,getRect.Bottom+1);
    bmpSnap.DrawPart(Rect(px,py,x,y), Canvas, px, py, False);


  end;

end;

{ TfrmSnap }


end.

