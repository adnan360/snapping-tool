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
      textures : array[0..1] of IBGLTexture;
      vertexArray: TBGLCustomArray;
      elements: TBGLElementArray;
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
  with BGLContext.Canvas.Lighting do
  begin
    ActiveShader := data.shader;
    data.textures[0].Bind(0);
    data.textures[1].Bind(1);
    data.shader.Vertices := data.vertexArray;
    data.shader.Draw(data.elements, opTriangleStrip);
    ActiveShader := nil;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  data.shader.FadeFactor := TrackBar1.Position / 100;
  BGLVirtualScreen1.Invalidate;
end;

const
  g_vertex_buffer_data: array[0..3] of TPointF = (
              (x:-1.0; y:-1.0),
              (x:1.0;  y:-1.0),
              (x:-1.0; y: 1.0),
              (x:1.0;  y: 1.0));

procedure TForm1.BGLVirtualScreen1LoadTextures(Sender: TObject;
  BGLContext: TBGLContext);
begin
  with data do
  begin
    shader := TMyShader.Create(BGLContext.Canvas);
    textures[0] := BGLTexture('picture1.jpg', 256,256);
    textures[1] := BGLTexture('picture2.jpg', 256,256);
    shader.Textures[0] := 0;
    shader.Textures[1] := 1;
    vertexArray := TBGLArray.Create(@g_vertex_buffer_data[0],
                        length(g_vertex_buffer_data),
                        sizeof(TPointF));
    elements := TBGLElementArray.Create([0, 1, 2, 3]);
  end;
end;

procedure TForm1.BGLVirtualScreen1UnloadTextures(Sender: TObject;
  BGLContext: TBGLContext);
begin
  with data do
  begin
    textures[0] := nil;
    textures[1] := nil;
    vertexArray.Free;
    elements.Free;
    shader.Free;
  end;
end;

end.

