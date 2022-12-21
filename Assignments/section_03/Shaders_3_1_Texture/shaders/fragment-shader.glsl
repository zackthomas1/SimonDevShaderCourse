varying vec2 v_UV;

uniform sampler2D diffuse; 
uniform sampler2D overlay; 
uniform vec4 tint;

void main(void) {

  vec4 diffuseSample = texture2D(diffuse, v_UV); 
  vec4 diffuseFlippedSample = texture2D(diffuse, vec2(v_UV.x, 1.0 - v_UV.y));
  vec4 overlaySample = texture2D(overlay, v_UV);

  // gl_FragColor = overlaySample.w * overlaySample + (1.0 - overlaySample.w) * diffuseSample;
  gl_FragColor = mix(diffuseSample, overlaySample, overlaySample.w);
}