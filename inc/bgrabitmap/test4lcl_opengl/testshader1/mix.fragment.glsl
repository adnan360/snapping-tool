uniform float fade_factor;
uniform sampler2D textures[1];

varying vec2 texcoord;

void main()
{
    gl_FragColor = mix(
        texture2D(textures[0], texcoord),
        texture2D(textures[0], vec2(texcoord.x,1-texcoord.y)),
        fade_factor
    );
}
