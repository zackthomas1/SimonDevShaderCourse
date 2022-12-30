
varying vec2 vUvs;

uniform sampler2D diffuse1; 
uniform float time;

vec3 red = vec3(1.0,0.0,0.0);
vec3 green = vec3(0.0,1.0,0.0);
vec3 blue = vec3(0.0,0.0,1.0);
vec3 white = vec3(1.0,1.0,1.0);
vec3 black = vec3(0.0,0.0,0.0);

float inverseLerp(float v, float minValue, float maxValue){  
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax){
  float t = inverseLerp(v,inMin, inMax); 
  return mix(outMin, outMax, t);
}

void main() {
  vec3 colour = vec3(0.0);

  // Example 1 
  // float t = remap(sin(time), -1.0, 1.0, 0.0, 1.0);
  // colour = mix(red, green, t);

  // Example 2
  // float t = sin(vUvs.y * 100.00); 
  // colour = vec3(t);

  // Example 3
  // float t1 = sin(vUvs.x * 100.00); 
  // float t2 = sin(vUvs.y * 100.00); 
  // colour = vec3(max(t1, t2));

  // Homework - Section 1: Recreate television scanline effect 
  float t1 = remap(sin((vUvs.y * 50.00) - (2.0 * time)),-1.0,1.0,0.7,1.0); 
  float t2 = remap(sin((vUvs.y * 400.00) + (10.0 * time)),-1.0,1.0,0.9,1.0);

  colour = texture2D(diffuse1, vUvs).xyz * t1 * t2;

  // Homework Solution: 
  // float t1 = remap(sin(vUvs.y * 400.0 + time * 10.0), -1.0, 1.0, 0.9, 1.0); 
  // float t2 = remap(sin(vUvs.y * 50.0 - time * 2.0), -1.0, 1.0, 0.9, 1.0);

  // colour = texture2D(diffuse1, vUvs).xyz * t1 *t2; 

  gl_FragColor = vec4(colour, 1.0);
}