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
    function GetVertices: TBGLCustomArray;
    procedure SetFadeFactor(AValue: single);
    procedure SetTextureByIndex(AIndex: integer; AValue: integer);
    procedure SetVertices(AValue: TBGLCustomArray);
  protected
    FPositionAttribute: TAttributeVariable;
    FFadeFactorUniform: TUniformVariableSingle;
    FTexturesUniform: array[0..1] of TUniformVariableInteger;
    procedure StartUse; override;
  public
    procedure Draw(AElements: TBGLElementArray; APrimitive: TOpenGLPrimitive);
    constructor Create(ACanvas: TBGLCustomCanvas);
    property FadeFactor: single write SetFadeFactor;
    property Textures[AIndex: integer]: integer write SetTextureByIndex;
    property Vertices: TBGLCustomArray read GetVertices write SetVertices;
  end;

implementation

{ TMyShader }

function TMyShader.GetVertices: TBGLCustomArray;
begin
  result := FPositionAttribute.Source;
end;

procedure TMyShader.SetFadeFactor(AValue: single);
begin
  FFadeFactorUniform.Value  := AValue;
end;

procedure TMyShader.SetTextureByIndex(AIndex: integer; AValue: integer);
begin
  if (AIndex >= 0) and (AIndex <= high(FTexturesUniform)) then
    FTexturesUniform[AIndex].Value := AValue;
end;

procedure TMyShader.SetVertices(AValue: TBGLCustomArray);
begin
  FPositionAttribute.Source := AValue;
end;

constructor TMyShader.Create(ACanvas: TBGLCustomCanvas);
begin
  inherited Create(ACanvas, ReadFileToString('mix.vertex.glsl'),
                            ReadFileToString('mix.fragment.glsl'));
  FPositionAttribute := AttributePointF['position'];
  FFadeFactorUniform := UniformSingle['fade_factor'];
  FTexturesUniform[0] :=  UniformInteger['textures[0]'];
  FTexturesUniform[1] :=  UniformInteger['textures[1]'];
end;

procedure TMyShader.StartUse;
begin
  inherited StartUse;
  FFadeFactorUniform.Update;
  FTexturesUniform[0].Update;
  FTexturesUniform[1].Update;
end;

procedure TMyShader.Draw(AElements: TBGLElementArray;
  APrimitive: TOpenGLPrimitive);
begin
  AElements.Draw(FCanvas, APrimitive, [FPositionAttribute]);
end;

end.

