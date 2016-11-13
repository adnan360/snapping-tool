varying vec2 texcoord;

void main()
{
    gl_Position = gl_ProjectionMatrix * gl_Vertex;
    texcoord = vec2(gl_MultiTexCoord0);
}
