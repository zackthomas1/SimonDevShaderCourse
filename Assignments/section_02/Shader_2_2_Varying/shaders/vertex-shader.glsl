varying vec2 v_UV; 

void main()
{
    vec4 localPosition = vec4(position, 1.0); 
    v_UV = uv;

    gl_Position =  projectionMatrix* modelViewMatrix * localPosition;
}