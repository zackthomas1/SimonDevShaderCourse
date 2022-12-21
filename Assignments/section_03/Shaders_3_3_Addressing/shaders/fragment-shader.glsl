varying vec2 v_UV; 

uniform sampler2D diffuse; 
uniform sampler2D overlay; 
uniform vec4 tint;

void main(void) {
  vec2 scaledUV = vec2(-2.0, -2.0) * v_UV;

  gl_FragColor = texture2D(diffuse, scaledUV);
}