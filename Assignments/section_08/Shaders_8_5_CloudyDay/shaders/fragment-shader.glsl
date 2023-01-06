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

float sdfMoon(vec2 pixelCoord){
  float moonCutOut = sdfCircle(pixelCoord + vec2(50.0,0.0), 80.0);
  float moon = sdfCircle(pixelCoord, 80.0);
  moon = opSubtraction(moonCutOut, moon);

  return moon;
}

float sdfStar5(vec2 p, float r, float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

float hash(vec2 seed){
  float t = dot(seed, vec2(36.3214, 73.4561)); 
  return sin(t * 160.0);
}

float saturate(float t){
  return clamp(t,0.0,1.0);
}

float easeOutBounce(float t){
  float n1 = 7.5625; 
  float d1 = 2.75; 

  if(t < 1.0 / d1){
    return n1 * t * t; 
  }else if(t < 2.0 / d1){
    t -= 1.5 / d1;
    return n1 * t * t + 0.75;
  }else if(t < 2.5 / d1){
    t -= 2.25 / d1;
    return n1 * t * t + 0.9375;
  }else{
    t -= 2.625 / d1;
    return n1 * t * t + 0.984375;
  }
}

float easeInSine(float t){
  return 1.0 - cos((t * M_PI) / 2.0);
}
float easeOutSine(float t){
  return sin((t * M_PI) / 2.0);
}

float easeInOutSine(float t){
  return -(cos(M_PI * t) - 1.0) / 2.0;
}

float easeInQuart(float t){
  return pow(t, 4.0);
}

float easeOutQuart(float t){
  return 1.0 - pow(1.0 - t, 4.0);
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
    vec2 sunMiddayOffset = vec2(0.0, resolution.y*0.25);
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
  if(dayTime > 0.35){
    vec2 moonEveningPos = vec2(-(resolution.x * 0.5) - 250.0, -(resolution.y*0.25));
    vec2 moonMidnightPos = vec2(0.0, resolution.y*0.25);
    vec2 moonMorningPos = vec2((resolution.x * 0.5) + 250.0, -(resolution.y*0.25));
    vec2 moonOffset = mix(moonEveningPos, moonMidnightPos, smoothstep(0.4,0.8, dayTime));
    moonOffset = mix(moonOffset, moonMorningPos, smoothstep(0.8,1.1, dayTime));
   
    vec2 moonPos = pixelCoords - (resolution * 0.5);  
    moonPos = moonPos - moonOffset;
    moonPos = rotate2D(M_PI * -0.2) * moonPos;

    float moonShadow = sdfMoon(moonPos - vec2(15.0,-10.0));
    colour = mix(black,colour,smoothstep(-30.0,10.0,moonShadow));
    
    float moon = sdfMoon(moonPos);
    colour = mix(white,colour,smoothstep(-2.0,4.0,moon));

    float moonGlow = sdfMoon(moonPos);
    colour += 0.4 * mix(vec3(1.0), vec3(0.0), smoothstep(-5.0, 15.0, moonGlow));
  }

  // stars 
  const float NUM_STARS = 16.0; 
  for(float i = 0.0; i < NUM_STARS; i += 1.0){
    float hashSample = hash(vec2(i * 124.15)) * 0.5 + 0.5;
    float t = saturate(inverseLerp(mod(time, dayLength), dayLength * 0.65, dayLength * 0.65 + 1.35));

    float size = mix(2.5,0.5,hashSample);
    vec2 starOffset = vec2(i*100.0, 0.0) + 150.0 * hash(vec2(i));
    starOffset += mix(vec2(0.0,resolution.y * 0.7),vec2(0.0,300.0), easeOutBounce(t));

    vec2 starPos = pixelCoords - starOffset;
    starPos.x = mod(starPos.x, resolution.x);
    starPos = starPos - (resolution * 0.5);
    starPos = rotate2D(M_PI * 0.5 * hashSample) * starPos;
    starPos *= size;

    float star = sdfStar5(starPos, 10.0, 2.0);
    vec3 starColour = mix(vec3(0.70,0.75,0.9),black,smoothstep(0.0,1.0,star));
    starColour += 0.4 * mix(vec3(1.0), vec3(0.0), smoothstep(-5.0, 5.0, star));
    
    t = saturate(inverseLerp(mod(time, dayLength), dayLength * 0.9, dayLength * 0.9 + 2.0));
    colour += starColour * (1.0 - t);
    // colour += starColour;
  }

  // clouds 
  const float NUM_CLOUDS = 8.0;
  for(float i = 0.0; i < NUM_CLOUDS; i += 1.0){
    // set cloud transform
    float size = mix(2.0, 1.0, (i / NUM_CLOUDS)) + 0.5 * hash(vec2(i));
    float speed = size * 0.25;
    vec2 offset = vec2((200.0) * i, (250.0));
    offset = offset * hash(vec2(i)) + (vec2(100.0,0.0) * time * speed);
    
    vec2 pos = pixelCoords - offset;
    pos = mod(pos, resolution);
    pos = pos - resolution * 0.5;
    
    // draw clouds 
    float cloudShadow = sdfCloud(pos * size + vec2(25.0)) - 40.0;
    colour = mix(colour, black, 0.5 * smoothstep(0.0,-100.0,cloudShadow));
    
    float cloud = sdfCloud(pos * size);
    vec3 cloudColour = vec3(1.0);
    cloudColour = mix(vec3(0.60,0.65,0.8),
                      mix(vec3(0.85,0.90,0.94), 
                          mix(vec3(1.0, 1.0, 1.0),
                              mix(vec3(0.82,0.71,0.65),
                                  vec3(0.60,0.65,0.8),
                                  smoothstep(0.75, 1.0, easeOutSine(dayTime))
                                  ),
                              smoothstep(0.5, 0.75, easeOutSine(dayTime))
                            ),
                            smoothstep(0.25, 0.5, easeOutSine(dayTime))
                        ),
                      smoothstep(0.0, 0.25, easeOutSine(dayTime))
                  );
    colour = mix(cloudColour, colour, smoothstep(0.0,6.0,cloud));
  }

  gl_FragColor = vec4(colour, 1.0);
}