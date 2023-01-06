
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
//
// https://www.shadertoy.com/view/Xsl3Dl
vec3 hash( vec3 p ) // replace this by something better
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
            dot(p,vec3(269.5,183.3,246.1)),
            dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec3 p )
{
  vec3 i = floor( p );
  vec3 f = fract( p );
	
	vec3 u = f*f*(3.0-2.0*f);

  return mix( mix( mix( dot( hash( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                        dot( hash( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                        dot( hash( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
              mix( mix( dot( hash( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                        dot( hash( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                   mix( dot( hash( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                        dot( hash( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

float fbm(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 1.0;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;
  total = smoothstep(-1.0, 1.0, total);

  return total;
}

float easeOutQuad(float t){
  return 1.0 - (1.0 - t) * (1.0 - t);
}

vec3 GenerateSky(){
  vec3 colour1 = vec3(0.65f, 0.78f, 0.8f); 
  vec3 colour2 = vec3(0.24f, 0.27f, 0.45f); 

  return mix(colour1, colour2, smoothstep(0.74,1.05,vUvs.y));
}

float sdfMontains(vec2 pixelCoords){
  float amplitude = resolution.y * 0.04; 
  float frequency = resolution.x * 0.25;
  float shift = 0.0;
  float y = amplitude * sin(pixelCoords.x / frequency + shift);
  y += fbm(vec3(pixelCoords.x / frequency, 1.432, 3.643),8,0.5,2.0) * 256.0;
  return pixelCoords.y - y; 
}

vec3 DrawMoutains(vec3 background, vec3 colour, vec2 pixelCoords, float depth){
    vec3 fogColour = vec3(0.49f, 0.55f, 0.61f); 
    
    float fogFactor = smoothstep(0.0, 8000.0, depth) * 0.5;
    float heightFactor = smoothstep(-256.0, 512.0, pixelCoords.y);
    heightFactor *= heightFactor;
    fogFactor = mix(heightFactor,fogFactor,fogFactor);

    vec3 mountainColour = mix(colour, fogColour, fogFactor);
    
    float blurr = 1.0 + (smoothstep(0.0,6400.0,depth) * 96.0) + (smoothstep(200.0,-1400.0, depth) * 32.0);
    vec2 depthOffset = vec2((1.0 - smoothstep(0.0,8000.0,depth)) * 2048.0,0.0);
    return mix(mountainColour, background, smoothstep(0.0,blurr,sdfMontains(pixelCoords + depthOffset)));

}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  vec3 colour = vec3(0.0);

  colour = GenerateSky();
  
  vec2 timeOffset = vec2(time * 50.0, 0.0);
  vec3 moutainColour = vec3(0.6f);

  vec2 moutainCoords = vec2(pixelCoords - vec2(6400.0,400.0)) * 16.0 + timeOffset;
  colour = DrawMoutains(colour, moutainColour * 1.0, moutainCoords,6400.0);
  
  moutainCoords = (pixelCoords - vec2(3200.0,300.0)) * 4.0 + timeOffset;
  colour = DrawMoutains(colour, moutainColour * 0.9, moutainCoords,3200.0);

  moutainCoords = (pixelCoords - vec2(1600.0,200.0)) * 2.0 + timeOffset;
  colour = DrawMoutains(colour, moutainColour * 0.8, moutainCoords, 1600.0);

  moutainCoords = (pixelCoords - vec2(800.0,-50.0)) * 0.5 + timeOffset;
  colour = DrawMoutains(colour, moutainColour * 0.6, moutainCoords,200.0);

  moutainCoords = (pixelCoords - vec2(0.0,-400.0)) * 0.25 + timeOffset;
  colour = DrawMoutains(colour, moutainColour * 0.5, moutainCoords,0.0);


  gl_FragColor = vec4(colour, 1.0);
}




