varying vec2 v_UV; 

void main(){

    vec3 horizontalGradient = vec3(v_UV.x); 
    vec3 inverseHorizontalGradient = vec3(1.0 - v_UV.x); 
    vec3 verticalGradient = vec3(v_UV.y);
    vec3 inverseVerticalGradient = vec3(1.0 - v_UV.y);

    vec3 uvGradient = vec3(v_UV, 0.0);

    gl_FragColor = vec4(v_UV.y,0.0, v_UV.x, 1.0); 
}