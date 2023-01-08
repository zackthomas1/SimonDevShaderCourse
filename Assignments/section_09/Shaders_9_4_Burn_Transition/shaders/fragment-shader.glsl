
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;
uniform sampler2D dogTexture; 
uniform sampler2D plantsTexture;

vec3 BLACK_COLOUR = vec3(0.0);
vec3 ORANGE_COLOUR = vec3(0.77f, 0.38f, 0.07f);
vec3 REDORANGE_COLOUR = vec3(0.91f, 0.27f, 0.07f);
vec3 YELLOWORANGE_COLOUR = vec3(0.85f, 0.65f, 0.1f);

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

float sdfCircle(vec2 pixelCoords, float radius){
  return length(pixelCoords) - radius;
}

void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  vec3 colour = vec3(0.0);

  float noiseSample = fbm(vec3(pixelCoords, 0.0) * 0.005, 4,0.5,2.0);
  noiseSample += fbm(vec3(pixelCoords, 0.0) * 0.05, 4,0.5,2.0) * 0.5;
  noiseSample += fbm(vec3(pixelCoords, 0.0) * 0.125, 4,0.5,2.0) * 0.25;

  float radius = smoothstep(0.00, 15.0, time) * (70.0 + length(resolution) * 0.5);
  float circleSDF = sdfCircle(pixelCoords + 50.0 * noiseSample, radius);
  float circleAlpha = 1.0 - smoothstep(0.0,1.0,circleSDF);

  vec2 distortion = noiseSample / resolution;
  vec2 uvDistortion = 20.0 * distortion * smoothstep(80.0,20.0, circleSDF);

  vec3 dogSample = texture2D(dogTexture, vUvs + uvDistortion).xyz;
  vec3 plantSample = texture2D(plantsTexture, vUvs).xyz;
  colour = dogSample;

  float burnAlpha = exp(-circleSDF * circleSDF * 0.0005);
  colour = mix(colour, BLACK_COLOUR, burnAlpha);

  float fireAlpha = 1.0 - smoothstep(0.0,10.0,(circleSDF ) * 0.5 * pow(noiseSample,2.25));
  fireAlpha = pow(fireAlpha, 2.0);
  colour = mix(colour, ORANGE_COLOUR, fireAlpha);

  colour = mix(colour, plantSample,  circleAlpha);

  vec3 glow_colour = mix(REDORANGE_COLOUR, YELLOWORANGE_COLOUR, noiseSample);
  float glowAmount = smoothstep(0.0, 32.0, abs(circleSDF));
  glowAmount = 1.0 - pow(glowAmount, 0.125); 
  colour += glowAmount * glow_colour;

  gl_FragColor = vec4(colour, 1.0);
}