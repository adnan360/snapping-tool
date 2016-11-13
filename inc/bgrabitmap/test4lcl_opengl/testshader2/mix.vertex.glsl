attribute vec2 position;

varying vec2 texcoord;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
    texcoord = vec2(0.5 + position[0]*0.5, 0.5 - position[1]*0.5);
}
