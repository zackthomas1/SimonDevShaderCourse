varying vec2 v_UV; 

uniform sampler2D diffuse; 
uniform sampler2D overlay; 
uniform vec4 tint;

void main(void) {
  vec2 scaledUV = v_UV / 10.0;

  gl_FragColor = texture2D(diffuse, scaledUV);
}