unit frmeditorunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ComCtrls, ExtCtrls,
  //
  BGRABitmap, BGRABitmapTypes,
  Clipbrd;

const
  //ExtraSpace = 40;
  ExtraSpaceX = 380;
  ExtraSpaceY = 380;

type

  { TfrmEditor }

  TfrmEditor = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mnuExit: TMenuItem;
    mnuAbout: TMenuItem;
    mnuNew: TMenuItem;
    mnuCopy: TMenuItem;
    mnuSave: TMenuItem;
    SaveDialog1: TSaveDialog;
    ScrollBox1: TScrollBox;
    shpTextarea: TShape;
    ToolBar1: TToolBar;
    btnNew: TToolButton;
    btnSave: TToolButton;
    btnCopy: TToolButton;
    btnRect: TToolButton;
    ToolButton4: TToolButton;
    btnPen: TToolButton;
    btnHighlighter: TToolButton;
    btnEraser: TToolButton;
    btnText: TToolButton;
    procedure btnCopyClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Paint(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure PaintImage;
    procedure DrawPen(X, Y: Integer; Closed: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
    procedure ExpandFinalCrop;
  public
    { public declarations }
  end;

var
  frmEditor: TfrmEditor;

  Image:TBGRABitmap;
  Drawings:TBGRABitmap;
  DrawingsCache:TBGRABitmap;

  //MouseIsDown:Boolean;
  mouseDrawing: boolean;
  mouseOrigin: TPoint;
  mouseDownOrigin: TPoint;

  finalCrop: TRect;
  textArea: TRect;

implementation

uses
  frmcontrolunit, frmsnapunit, frmaboutunit;

{$R *.lfm}

{ TfrmEditor }

procedure TfrmEditor.FormShow(Sender: TObject);
begin

  Image.SetSize(bmpCropped.Width+(ExtraSpaceX*2),bmpCropped.Height+(ExtraSpaceY*2));
  Image.FillRect(0,0,image.Width,image.Height,clWhite);
  bmpCropped.Draw(Image.Canvas,ExtraSpaceX,ExtraSpaceY);

  finalCrop := Rect(ExtraSpaceX,ExtraSpaceY,bmpCropped.Width+ExtraSpaceX,bmpCropped.Height+ExtraSpaceY);

  Drawings.SetSize(image.Width,image.Height);

  Image1.Width:=bmpCropped.Width+(ExtraSpaceX*2);
  Image1.Height:=bmpCropped.Height+(ExtraSpaceY*2);

  FormResize(Sender);

  Image1.Canvas.Brush.Color:=clwhite;
  Image1.Canvas.FillRect(0,0,Image1.ClientWidth,Image1.ClientHeight);

  PaintImage;

  // copy captured image to clipboard
  mnuCopyClick(Sender);

end;

procedure TfrmEditor.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if Button = mbLeft then begin

    mouseDrawing := True;
    mouseOrigin := Point(X,Y);
    mouseDownOrigin := Point(X,Y);

    Drawings.Draw(DrawingsCache.Canvas,0,0,false);

    if btnText.Down then begin
      shpTextarea.Show;
      shpTextarea.SetBounds(image1.Left + X, image1.Top + Y, 1, 1);
      textArea.Left:=X;
      textArea.Top:=Y;
    end else begin
      DrawPen(X,Y,True);
    end;

  end;

end;

procedure TfrmEditor.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

  if mouseDrawing then begin

    if btnText.Down then begin
      shpTextarea.Width:=image1.Left + X - shpTextarea.Left;
      shpTextarea.Height:=image1.Top + Y - shpTextarea.Top;
    end else begin
      DrawPen(X,Y,False);
    end;

  end;

end;

procedure TfrmEditor.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  c: TBGRAPixel;
  mytext: String;
begin

  if btnText.Down then begin

    textArea.Right:=X;
    textArea.Bottom:=Y;
    shpTextarea.Hide;

    mytext := InputBox('Text','Text to enter:','This is some text');

    c := ColorToBGRA(ColorToRGB(clRed));

    Drawings.FontHeight := 26;
    Drawings.FontAntialias := true;
    Drawings.FontStyle := [fsBold];
    Drawings.TextRect(
                   textArea,
                   mytext,
                   taCenter,tlCenter,c
                   );

    ExpandFinalCrop;
  end;

  mouseDrawing:=False;

  PaintImage;
  // Copy to clipboard automatically after a change
  mnuCopyClick(Sender);
end;

procedure TfrmEditor.ExpandFinalCrop;
begin

  if not PtInRect(mouseOrigin, finalCrop) then begin
      if mouseOrigin.x < finalCrop.Left then
        finalCrop.Left:=mouseOrigin.x;

      if mouseOrigin.y < finalCrop.Top then
        finalCrop.Top:=mouseOrigin.y;

      if mouseOrigin.x > finalCrop.Right then
        finalCrop.Right:=mouseOrigin.x;

      if mouseOrigin.y > finalCrop.Bottom then
        finalCrop.Bottom:=mouseOrigin.y;
  end;

  if btnText.Down then begin
      if textArea.Left < finalCrop.Left then
        finalCrop.Left:=textArea.Left;

      if textArea.Top < finalCrop.Top then
        finalCrop.Top:=textArea.Top;

      if textArea.Right > finalCrop.Right then
        finalCrop.Right:=textArea.Right;

      if textArea.Bottom > finalCrop.Bottom then
        finalCrop.Bottom:=textArea.Bottom;
  end;

end;

procedure TfrmEditor.PaintImage;
begin
  if image <> nil then image.Draw(Image1.Canvas,0,0,True);
  if Drawings <> nil then Drawings.Draw(Image1.Canvas,0,0,False);
  if DrawingsCache <> nil then DrawingsCache.Draw(Image1.Canvas,0,0,False);
end;

procedure TfrmEditor.DrawPen(X, Y: Integer; Closed: Boolean);
const
  brushRadius = 5;
  myalpha = 200; //255
begin
  if btnPen.Down then
    Drawings.DrawLineAntialias(
               X,Y,mouseOrigin.X,mouseOrigin.Y,BGRA(255,0,0,myalpha),brushRadius,Closed
    );

  if btnHighlighter.Down then
    Drawings.DrawLineAntialias(
               X,Y,mouseOrigin.X,mouseOrigin.Y,BGRA(255,240,0,128),20,Closed
    );

  if btnEraser.Down then
    Drawings.EraseLineAntialias(
               X,Y,mouseOrigin.X,mouseOrigin.Y,255,20,Closed
    );

  if btnRect.Down then begin
    Drawings.Rectangle(
             0,0,drawings.Width,drawings.Height,BGRAPixelTransparent,BGRAPixelTransparent,dmset
    );
    DrawingsCache.FillRect(0,0,500,500,clRed);
    DrawingsCache.Draw(Drawings.Canvas, 0, 0, false);
    Drawings.RectangleAntialias(
               X, Y, mouseDownOrigin.x, mouseDownOrigin.y,
               bgra(255,0,0,255), 5, BGRAPixelTransparent
    );
  end;


  mouseOrigin := Point(X,Y);
  ExpandFinalCrop;

  PaintImage;
  Image1.Refresh;
end;

procedure TfrmEditor.FormDestroy(Sender: TObject);
begin
  Image.Free;
  Drawings.Free;
  DrawingsCache.Free;
end;

procedure TfrmEditor.btnSaveClick(Sender: TObject);
begin
  mnuSaveClick(Sender);
end;

procedure TfrmEditor.btnCopyClick(Sender: TObject);
begin
  mnuCopyClick(Sender);
end;

procedure TfrmEditor.btnNewClick(Sender: TObject);
begin
  mnuNewClick(Sender);
end;

procedure TfrmEditor.Image1Paint(Sender: TObject);
begin
  PaintImage;
end;

procedure TfrmEditor.mnuAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TfrmEditor.mnuCopyClick(Sender: TObject);
var
  bmp: TBGRABitmap;
begin
  try
    bmp:=TBGRABitmap.Create(
                           finalCrop.Right - finalCrop.Left,
                           finalCrop.Bottom - finalCrop.Top
                           );
    Image.DrawPart(finalCrop, bmp.Canvas,0,0,true);
    Drawings.DrawPart(finalCrop, bmp.Canvas,0,0,false);

    Clipboard.Clear;
    Clipboard.Assign(bmp.Bitmap);
  finally
    bmp.Free;
  end;
end;

procedure TfrmEditor.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEditor.mnuNewClick(Sender: TObject);
begin
  Hide;
  Sleep(500);
  frmSnapControl.CaptureSnap;
end;

procedure TfrmEditor.mnuSaveClick(Sender: TObject);
var
  bmp: TBGRABitmap;
begin

  if SaveDialog1.Execute then begin

    try
      bmp:=TBGRABitmap.Create(
                             finalCrop.Right - finalCrop.Left,
                             finalCrop.Bottom - finalCrop.Top
                             );
      Image.DrawPart(finalCrop, bmp.Canvas,0,0,true);
      Drawings.DrawPart(finalCrop, bmp.Canvas,0,0,false);
      bmp.SaveToFile(SaveDialog1.FileName);
    finally
      bmp.Free;
    end;

  end;

end;

procedure TfrmEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmSnapControl.Close;
  frmSnap.Close;
  //
  Application.Terminate;
end;

procedure TfrmEditor.FormCreate(Sender: TObject);
begin
  if Image = nil then
    Image:=TBGRABitmap.Create;

  if Drawings = nil then
    Drawings:=TBGRABitmap.Create;

  if DrawingsCache = nil then
    DrawingsCache:=TBGRABitmap.Create;
end;

procedure TfrmEditor.FormResize(Sender: TObject);
begin
  Image1.Left := (ScrollBox1.Width-Image1.Width) div 2;
  Image1.Top := (ScrollBox1.Height-Image1.Height) div 2;
end;


end.

