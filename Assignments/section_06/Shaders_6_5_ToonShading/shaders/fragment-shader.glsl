varying vec3 vNormal;
varying vec3 vPosition;

uniform samplerCube specMap;

vec3 linearTosRGB(vec3 colour){
  vec3 value1 = colour * 12.92; 
  vec3 value2 = 1.055 * pow(colour.rgb, vec3(1.0 / 2.4)) - vec3(0.055); 

  return mix(value1, value2, step(0.0031308, colour.rgb));
}

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

void main() {

  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);
  vec3 albedoColour = vec3(0.6f); 

  // Ambient Lighting 
  vec3 ambientLighting = vec3(0.15);

  // Hemi Lighting
  vec3 skyColour = vec3(0.49f, 0.73f, 0.93f); 
  vec3 groundColour = vec3(0.23f, 0.15f, 0.02f);
  float hemiMix = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  // hemiMix = smoothstep(0.5, 0.52, hemiMix);
  vec3 hemiLighting = mix(groundColour, skyColour, hemiMix);

  // Diffuse Lighting
  vec3 lightDir = normalize(vec3(1.0,1.0,1.0));
  vec3 lightColour = vec3(0.95f, 0.95f, 0.83f);
  float dotProduct = max(0.0, dot(lightDir, normal));
  
  // dotProduct = smoothstep(0.5, 0.52, dotProduct);
  // dotProduct = dotProduct <= 0.45 ? 0.0 : dotProduct >= 0.65 ? 1.0 : 0.5; // Homework section 5 - three toned toon shading 
  dotProduct = mix(0.5, 1.0, step(0.65, dotProduct)) * step(0.5,dotProduct); // Homework section 5 - solution

  vec3 diffuseLighting = lightColour * dotProduct;

  // Phong specular 
  vec3 reflectionDir = normalize(reflect(-lightDir, normal)); 
  float phongValue = pow(max(0.0, dot(viewDir, reflectionDir)), 64.0);

  // Homework section 3 - blinn-phong specular
  vec3 halfAngle = normalize(lightDir + viewDir);
  float blinnValue = pow(max(0.0, dot(normal, halfAngle)),64.0); 

  // IBL specular 
  vec3 iblCoord = normalize(reflect(-viewDir, normal));
  vec3 iblSample = textureCube(specMap, iblCoord).xyz; 

  // Fresnel 
  float F0 = .8;
  float fresnelValue = (F0 + (1.0 - F0)) * pow(1.0 - dot(viewDir, normal),2.0);
  fresnelValue *= smoothstep(0.7, 0.72, fresnelValue);

  vec3 specular = vec3(blinnValue);
  specular = smoothstep(0.5,0.52,specular);
  // specular += iblSample * fresnelValue * 0.5;
  // specular = specular * fresnelValue;

  // output 
  vec3 lighting = (ambientLighting * 0.0) + (hemiLighting * 1.0 * (fresnelValue + 0.2)) + (diffuseLighting * 0.8);
  vec3 colour = (albedoColour * lighting) + specular;
  colour = linearTosRGB(colour);

  gl_FragColor = vec4(colour, 1.0);
}