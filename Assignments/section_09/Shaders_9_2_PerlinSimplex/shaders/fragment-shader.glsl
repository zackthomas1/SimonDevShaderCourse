
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

// fractional browniam motion
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

// fractional browniam motion
float ridgedFBM(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 1.0;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    noiseValue = abs(noiseValue);
    noiseValue = 1.0 - noiseValue;

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;
  total *= total;

  return total;
}

// fractional browniam motion
float turblanceFBM(vec3 p, int octaves, float persistence, float lacunarity) {
  float amplitude = 1.0;
  float frequency = 1.0;
  float total = 0.0;
  float normalization = 0.0;

  for (int i = 0; i < octaves; ++i) {
    float noiseValue = noise(p * frequency);
    noiseValue = abs(noiseValue);

    total += noiseValue * amplitude;
    normalization += amplitude;
    amplitude *= persistence;
    frequency *= lacunarity;
  }

  total /= normalization;

  return total;
}

float cellular(vec3 coords){
  vec2 gridBasePosition = floor(coords.xy);
  vec2 gridCoordOffset = fract(coords.xy); 

  float closest = 1.0; 
  for(float y = -2.0; y <= 2.0; y += 1.0){
    for(float x = -2.0; x <= 2.0; x += 1.0){
      vec2 neighbourCellPosition = vec2(x,y); 
      vec2 cellWorldPosition = gridBasePosition + neighbourCellPosition;
      vec2 cellOffset = vec2(
        noise(vec3(cellWorldPosition, coords.z) + vec3(243.432, 324.235, 0.0)),
        noise(vec3(cellWorldPosition, coords.z))
      );
      float distToNeighbour = length(neighbourCellPosition + cellOffset - gridCoordOffset); 
      closest = min(closest, distToNeighbour);
    }
  }
  return closest;
}

float stepped(float noiseSample){
  float steppedSample = floor(noiseSample * 10.0) / 10.0; 
  float remainder = fract(noiseSample * 10.0); 
  steppedSample = (steppedSample - remainder) * 0.5 + 0.5; 
  return steppedSample;
}

float domainWarpingFBM(vec3 coords){
  vec3 offset = vec3(
    fbm(coords, 4, 0.5, 2.0),
    fbm(coords + vec3(43.235,23.112,0.0),4,0.5,2.0),0.0
  );
  float noiseSample = fbm(coords + offset, 1, 0.5, 2.0);

  vec3 offset2 = vec3(
      fbm(coords + 4.0 * offset + vec3(5.325, 1.421, 3.235), 4, 0.5, 2.0),
      fbm(coords + 4.0 * offset + vec3(4.32,0.532,6.324),4,0.5,2.0),0.0
  );
  noiseSample = fbm(coords + 4.0 * offset2, 1, 0.5, 2.0);

  vec3 offset3 = vec3(
      fbm(coords + 8.0 * offset + vec3(7.653, 6.41, 2.35), 4, 0.5, 2.0),
      fbm(coords + 8.0 * offset + vec3(7.561,5.32,6.324),4,0.5,2.0),0.0
  );
  noiseSample = fbm(coords + 8.0 * offset3, 1, 0.5, 2.0);

  return noiseSample;
}
void main() {
  vec2 pixelCoords = (vUvs - 0.5) * resolution;
  vec3 colour = vec3(0.0);

  vec3 coords = vec3(vUvs * 10.0, time * 0.2); 
  float noiseSample = 0.0; 

  // noiseSample = remap(noise(coords), -1.0, 1.0, 0.0, 1.0);
  // noiseSample = remap(fbm(coords, 8 ,0.5,2.0), -1.0, 1.0, 0.0, 1.0);
  // noiseSample = ridgedFBM(coords, 4, 0.5, 2.0);
  noiseSample = turblanceFBM(coords, 4, 0.05, 2.0);
  // noiseSample = cellular(coords);
  // noiseSample = 1.0 - cellular(coords);
  // noiseSample = remap(domainWarpingFBM(coords), -1.0, 1.0, 0.0, 1.0);
  // noiseSample = stepped(noiseSample);

  colour = vec3(noiseSample);

  vec3 pixel = vec3(1.0 / (2.0 *  resolution), 0.0);

  float s1 = turblanceFBM(coords + pixel.xzz,4,0.5,2.0);
  float s2 = turblanceFBM(coords - pixel.xzz,4,0.5,2.0);
  float s3 = turblanceFBM(coords + pixel.zyz,4,0.5,2.0);
  float s4 = turblanceFBM(coords - pixel.zyz,4,0.5,2.0);

  vec3 normal = normalize(vec3(s1 - s2, s3 - s4, 0.001));
  colour = normal;

  // hemi lighting 
  vec3 skyColour =  vec3(0.51f, 0.57f, 0.95f);
  vec3 groundColour = vec3(0.27f, 0.21f, 0.09f);

  vec3 hemiLight = mix(skyColour, groundColour, remap(normal.y, -1.0, 1.0, 0.0, 1.0)); 

  // diffuse lighting 
  vec3 lightDir = normalize(vec3(1.0,1.0,1.0));
  vec3 lightColour = vec3(0.96f, 0.92f, 0.79f);
  float dotproductDiffuse = max(0.0, dot(lightDir, normal));
  vec3 diffuseLighting = lightColour * dotproductDiffuse;

  // specular 
  vec3 viewDir = normalize(vec3(0.0,0.0,1.0));
  vec3 reflectDir = normalize(reflect(-lightDir, normal));
  float phongValue = max(0.0, dot(viewDir, reflectDir));
  phongValue = pow(phongValue, 64.0);
  vec3 specular = vec3(phongValue);

  vec3 baseColour1 = vec3(0.34f, 0.4f, 0.51f);
  vec3 baseColour2 = vec3(0.33f, 0.77f, 0.85f);
  vec3 diffuseColour = mix(baseColour1, baseColour2, noiseSample);
  vec3 lighting = (0.5 * hemiLight) + (0.5 * diffuseLighting);
  colour = diffuseColour * lighting + specular;

  gl_FragColor = vec4(colour, 1.0);
}




