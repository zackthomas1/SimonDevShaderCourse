
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 green = vec3(0.0, 1.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 BackgroundColour(){
  float distFromCenter = length(abs(vUvs - 0.5)); 

  float vignette = 1.0 - distFromCenter; 
  vignette = smoothstep(0.0, 0.7, vignette);
  vignette = remap(vignette,0.0, 1.0, 0.3, 1.0);

  return vec3(vignette);
}

vec3 drawGrid(vec3 colour, vec3 lineColour, float cellSpacing, float lineWidth){
  vec2 center = vUvs - 0.5;
  vec2 cells = abs(fract(center * resolution / cellSpacing) - 0.5); 
  float distToEdge = (0.5 - max(cells.x, cells.y)) * cellSpacing; 
  float lines = smoothstep(0.0, lineWidth, distToEdge); 

  colour = mix(lineColour, colour, lines);

  return colour; 
}

float sdfCircle(vec2 p, float r){
  return length(p) - r;
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;

  vec3 colour = BackgroundColour();
  colour = drawGrid(colour, vec3(0.5), 10.0, 1.0);
  colour = drawGrid(colour, vec3(0.0), 100.0, 2.0);

  float d = sdfCircle(pixelCoords, 100.0);

  gl_FragColor = vec4(colour, 1.0);
}