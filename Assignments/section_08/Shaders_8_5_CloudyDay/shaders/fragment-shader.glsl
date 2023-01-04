#define M_PI 3.14159

varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);
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

vec3 drawBackground(float dayTime){
  vec3 morning = mix(
        vec3(0.54,0.48,0.84),
        vec3(0.24,0.31,0.64),
        smoothstep(0.0,1.0,pow(vUvs.x * vUvs.y,0.5))
    ); 

  vec3 midday = mix(
        vec3(0.3,0.6,0.85),
        vec3(0.36,0.46,0.82),
        smoothstep(0.0,1.0,pow(vUvs.x * vUvs.y,0.5))
    ); 

  vec3 evening = mix(
        vec3(0.82,0.51,0.25),
        vec3(0.36,0.46,0.82),
        smoothstep(0.0,1.0,pow((1.0 - vUvs.x) * vUvs.y,0.8))
    ); 

  vec3 night = mix(
        vec3(0.07,0.1,0.1),
        vec3(0.34,0.5,0.74),
        smoothstep(0.0,1.0,pow((1.0 - vUvs.x) * vUvs.y,1.1))
    ); 

  if(dayTime < 0.25){
    return mix(morning,midday,smoothstep(0.0, 0.25, dayTime));
  }else if(dayTime < 0.5){
    return mix(midday, evening, smoothstep(0.25, 0.50, dayTime));
  }else if(dayTime < 0.8){
    return mix(evening, night, smoothstep(0.50, 0.80, dayTime));
  }else{
    return mix(night, morning,smoothstep(0.8, 1.0, dayTime));
  }
}

vec3 drawVignette(){
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

float sdfCircle(vec2 pixelPosition, float radius){
  return length(pixelPosition) - radius;
}


float sdfLine(vec2 p, vec2 a, vec2 b){
  vec2 pa = p - a; 
  vec2 ba = b - a; 
  float h = clamp(dot(pa,ba) / dot(ba, ba), 0.0, 1.0); 

  return length(pa - ba * h);

}

float sdfBox(vec2 p, vec2 b){
  vec2 d = abs(p) - b; 
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

//https://iquilezles.org/articles/distfunctions2d/
float sdfHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

mat2 rotate2D(float theta){
  float sinTheta = sin(theta); 
  float cosTheta = cos(theta); 

  return mat2(cosTheta, -sinTheta, 
              sinTheta, cosTheta);
}

float opUnion(float d1, float d2){
  return min(d1, d2); 
}

float opIntersection(float d1, float d2){
  return max(d1, d2); 
}

// substract d1 from d2. (d2 - d1)
float opSubtraction(float d1, float d2){
  return max(-d1, d2);
}

float softMax(float a, float b, float k){
  return log(exp(k * a) + exp(k * b)) / k;
}

float softMin(float a, float b, float k){
  return -softMax(-a, -b, k);
}

float softMinValue(float a, float b, float k){
  float h = exp(-b * k) / (exp(-a * k) + exp(-b * k));
  // float h = remap(a - b, -1.0 / k, 1.0 / k, 0.0, 1.0);
  return h;
}

float sdfCloud(vec2 pixelCoord){
  float puff1 = sdfCircle(pixelCoord, 100.0); 
  float puff2 = sdfCircle(pixelCoord - vec2(100.0, -10.0), 75.0); 
  float puff3 = sdfCircle(pixelCoord + vec2(100.0, 10.0), 75.0); 

  return softMin(softMin(puff1, puff2, 0.15), puff3, 0.15);
}

float hash(vec2 seed){
  float t = dot(seed, vec2(36.3214, 73.4561)); 
  return sin(t * 160.0);
}

float saturate(float t){
  return clamp(0.0,1.0,t);
}

void main() {
  vec2 pixelCoords = (vUvs) * resolution;

  float dayLength = 20.0; 
  float dayTime = remap(mod(time, dayLength), 0.0, dayLength, 0.0, 1.0);

  // draw background
  vec3 colour = drawBackground(dayTime);

  // sun
  if(dayTime < 0.75){
    vec2 sunMorningOffset = vec2(-(resolution.x * 0.5) - 250.0, -(resolution.y*0.25));
    vec2 sunMiddayOffset = vec2(0.0, resolution.y*0.35);
    vec2 sunEveningOffset = vec2((resolution.x * 0.5) + 250.0, -(resolution.y*0.25));
    vec2 sunOffset = mix(sunMorningOffset, sunMiddayOffset, smoothstep(-0.1, 0.70/2.0,dayTime));
    sunOffset = mix(sunOffset, sunEveningOffset, smoothstep(0.70/2.0, 0.75, dayTime));
    vec2 sunPos = pixelCoords - sunOffset;
    sunPos = sunPos - resolution * 0.5; 

    float sun = sdfCircle(sunPos, 100.00);
    colour = mix(vec3(0.85,0.60,0.5), colour, smoothstep(-15.0,15.0,sun));

    float s = max(0.001, sun);
    float p = saturate(exp(-0.001 * s *s));
    colour += 0.5 * mix(vec3(0.0), vec3(0.95,0.65,0.47), p);
  }

  // moon
  // if(dayTime > 0.6){
    vec2 moonStart = vec2(-resolution.x * 0.55, resolution.y * 0.55);
    vec2 moonEnd = vec2(resolution.x * 0.42, resolution.y * 0.3);
    vec2 moonOffset = mix(moonStart, moonEnd, smoothstep(0.6,0.8, dayTime));
    moonOffset = mix(moonOffset, moonStart, smoothstep(0.8,1.0, dayTime));
   
    vec2 moonPos = pixelCoords - moonOffset;  
    moonPos = rotate2D(M_PI * -0.2) * moonPos;
    // moonPos = moonPos + (resolution * 0.5);

    float moonCutOut = sdfCircle(moonPos + vec2(40.0,0.0), 80.0);
    float moon = sdfCircle(moonPos, 100.0);
    moon = opSubtraction(moonCutOut, moon);
    colour = mix(white,colour,smoothstep(0.0,4.0,moon));

    float s = max(0.001, moon);
    float p = saturate(exp(-0.001 * s * s));
    colour += 0.5 * mix(vec3(0.0), vec3(0.85,0.75,0.6), p);
  // }

  const float NUM_CLOUDS = 8.0;
  for(float i = 0.0; i < NUM_CLOUDS; i += 1.0){
    // set cloud transform
    float size = mix(2.0, 1.0, (i / NUM_CLOUDS)) + 0.5 * hash(vec2(i));
    float speed = size * 0.25;
    vec2 offset = vec2((resolution.x * 0.2) * i, (resolution.x * 0.14) * hash(vec2(i))) + (vec2(100.0,0.0) * time * speed);
    vec2 pos = pixelCoords - offset;
    pos = mod(pos, resolution);
    pos = pos - resolution * 0.5;
    
    // draw clouds 
    float cloudShadow = sdfCloud(pos * size + vec2(25.0)) - 40.0;
    float cloud = sdfCloud(pos * size);
    colour = mix(colour, black, 0.5 * smoothstep(0.0,-100.0,cloudShadow));
    colour = mix(white, colour, smoothstep(0.0,6.0,cloud));
  }

  gl_FragColor = vec4(colour, 1.0);
}