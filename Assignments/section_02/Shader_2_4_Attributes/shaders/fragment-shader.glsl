varying vec2 v_UV; 
varying vec3 v_AttributeColor;

void main(){
    gl_FragColor = vec4(v_AttributeColor, 1.0);
}