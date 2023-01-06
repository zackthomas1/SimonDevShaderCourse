
varying vec2 vUvs;

uniform vec2 resolution;
uniform float time;
uniform sampler2D diffuse; 
uniform vec4 tint;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

float Math_Random(vec2 p){
  p = 50.0 * fract( p * 0.3183099 + vec2(0.71,0.113));
  return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
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

vec4 bilinearFilterSample(sampler2D target, vec2 coords){
  vec2 texSize = vec2(2.0);
  vec2 pc = coords * texSize - 0.5;
  vec2 base = floor(pc) + 0.5;

  vec4 s1 = texture2D(target, (base + vec2(0.0,0.0)) / texSize);
  vec4 s2 = texture2D(target, (base + vec2(1.0,0.0)) / texSize);
  vec4 s3 = texture2D(target, (base + vec2(0.0,1.0)) / texSize);
  vec4 s4 = texture2D(target, (base + vec2(1.0,1.0)) / texSize);

  vec2 f = smoothstep(0.0,1.0,fract(pc));

  vec4 px1 = mix(s1, s2, f.x);
  vec4 px2 = mix(s3, s4, f.x);

  return mix(px1,px2, f.y);
}

vec4 valueNoise(vec2 coords){
  vec2 texSize = vec2(2.0);
  vec2 pc = coords * texSize;
  vec2 base = floor(pc);

  float s1 = Math_Random((base + vec2(0.0,0.0)) / texSize);
  float s2 = Math_Random((base + vec2(1.0,0.0)) / texSize);
  float s3 = Math_Random((base + vec2(0.0,1.0)) / texSize);
  float s4 = Math_Random((base + vec2(1.0,1.0)) / texSize);

  vec2 f = smoothstep(0.0,1.0,fract(pc));

  float px1 = mix(s1, s2, f.x);
  float px2 = mix(s3, s4, f.x);
  float result = mix(px1,px2, f.y);  
  return vec4(result);
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  vec3 colour = vec3(0.0);

  // colour = vec3(Math_Random(pixelCoords / 16.0));
  // colour = texture2D(diffuse, vUvs).xyz;
  // colour = bilinearFilterSample(diffuse, vUvs).xyz;
  colour = valueNoise(vUvs * 10.0).xyz;

  gl_FragColor = vec4(colour, 1.0);
}




