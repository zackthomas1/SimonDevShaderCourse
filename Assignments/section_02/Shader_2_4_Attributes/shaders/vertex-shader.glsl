attribute vec3 a_Color;

varying vec2 v_UV; 
varying vec3 v_AttributeColor; 

void main()
{
    v_UV = uv;
    v_AttributeColor = a_Color;

    vec4 localPosition = vec4(position, 1.0); 

    gl_Position =  projectionMatrix* modelViewMatrix * localPosition;
}