
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

vec3 white = vec3(1.0);
vec3 gray = vec3(0.5);
vec3 black = vec3(0.0);

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  vec3 colour = vec3(0.0);

  // vignette 
  float x = remap(pixelCoords.x, -(resolution.x * 0.5), resolution.x * 0.5,-1.0,1.0);
  float y = remap(pixelCoords.y, -(resolution.y * 0.5), resolution.y * 0.5,-1.0,1.0);
  float t = 1.0 - (0.30 * ((x*x) + (y*y)));
  
  colour = mix(black, white, smoothstep(0.0,0.8,t));

  // Grid
  float xAxis = smoothstep(0.0,0.0025, abs(pixelCoords.y -(resolution.y * 0.5)));
  float yAxis = smoothstep(0.0,0.0025, abs(pixelCoords.x - (resolution.x * 0.5)));
  float xUnitMarks = smoothstep(0.0,0.0045, mod(abs(x),0.1));
  float yUnitMarks = smoothstep(0.0,0.0045, mod(abs(y),0.1));
  float xHalfUnitMarks = smoothstep(0.0,0.0025, mod(abs(x),0.05));
  float yHalfUnitMarks = smoothstep(0.0,0.0025, mod(abs(y),0.05));

  colour = mix(gray, colour, xHalfUnitMarks);
  colour = mix(gray, colour, yHalfUnitMarks);
  colour = mix(black, colour, xUnitMarks);
  colour = mix(black, colour, yUnitMarks);
  colour = mix(black, colour, xAxis);
  colour = mix(black, colour, yAxis);


  // colour = vec3(pixelCoords * 0.1, 0.0);

  gl_FragColor = vec4(colour, 1.0);
}