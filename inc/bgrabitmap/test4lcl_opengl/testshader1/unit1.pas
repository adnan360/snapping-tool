unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, BGLVirtualScreen, BGRAOpenGL,
  UMyShader, BGRABitmapTypes;

type
  { TForm1 }

  TForm1 = class(TForm)
    BGLVirtualScreen1: TBGLVirtualScreen;
    Label1: TLabel;
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    procedure BGLVirtualScreen1LoadTextures(Sender: TObject;
      {%H-}BGLContext: TBGLContext);
    procedure BGLVirtualScreen1Redraw(Sender: TObject; {%H-}BGLContext: TBGLContext);
    procedure BGLVirtualScreen1UnloadTextures(Sender: TObject;
      {%H-}BGLContext: TBGLContext);
    procedure TrackBar1Change(Sender: TObject);
  private
    data: record
      textures : array[0..0] of IBGLTexture;
      shader: TMyShader;
    end;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BGLVirtualScreen1Redraw(Sender: TObject;
  BGLContext: TBGLContext);
begin
  with BGLContext.Canvas do
  begin
    Lighting.ActiveShader := data.shader;
    data.textures[0].StretchDraw(0,0,Width,Height);
    Lighting.ActiveShader := nil;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  data.shader.FadeFactor := TrackBar1.Position / 100;
  BGLVirtualScreen1.Invalidate;
end;

procedure TForm1.BGLVirtualScreen1LoadTextures(Sender: TObject;
  BGLContext: TBGLContext);
begin
  with data do
  begin
    shader := TMyShader.Create(BGLContext.Canvas);
    textures[0] := BGLTexture('picture1.jpg', 256,256);
    shader.Textures[0] := 0;
  end;
end;

procedure TForm1.BGLVirtualScreen1UnloadTextures(Sender: TObject;
  BGLContext: TBGLContext);
begin
  with data do
  begin
    textures[0] := nil;
    shader.Free;
  end;
end;

end.

