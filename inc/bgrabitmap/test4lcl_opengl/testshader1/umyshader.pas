unit UMyShader;

{$mode objfpc}{$H+}

interface

uses
  Classes, FileUtil, SysUtils,
  BGRAOpenGL3D, BGRAOpenGL;

type

  { TMyShader }

  TMyShader = class(TBGLShader3D)
  private
    procedure SetFadeFactor(AValue: single);
    procedure SetTextureByIndex(AIndex: integer; AValue: integer);
  protected
    FFadeFactorUniform: TUniformVariableSingle;
    FTexturesUniform: array[0..0] of TUniformVariableInteger;
    procedure StartUse; override;
  public
    constructor Create(ACanvas: TBGLCustomCanvas);
    property FadeFactor: single write SetFadeFactor;
    property Textures[AIndex: integer]: integer write SetTextureByIndex;
  end;

implementation

{ TMyShader }

procedure TMyShader.SetFadeFactor(AValue: single);
begin
  FFadeFactorUniform.Value  := AValue;
end;

procedure TMyShader.SetTextureByIndex(AIndex: integer; AValue: integer);
begin
  if (AIndex >= 0) and (AIndex <= high(FTexturesUniform)) then
    FTexturesUniform[AIndex].Value := AValue;
end;

constructor TMyShader.Create(ACanvas: TBGLCustomCanvas);
begin
  inherited Create(ACanvas, ReadFileToString('mix.vertex.glsl'),
                            ReadFileToString('mix.fragment.glsl'));
  FFadeFactorUniform := UniformSingle['fade_factor'];
  FTexturesUniform[0] :=  UniformInteger['textures[0]'];
end;

procedure TMyShader.StartUse;
begin
  inherited StartUse;
  FFadeFactorUniform.Update;
  FTexturesUniform[0].Update;
end;

end.

