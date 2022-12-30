varying vec3 vNormal;
varying vec3 vPosition;

uniform samplerCube specMap;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 linearTosRGB(vec3 colour){
  vec3 value1 = colour * 12.92; 
  vec3 value2 = 1.055 * pow(colour.rgb, vec3(1.0 / 2.4)) - vec3(0.055); 

  return mix(value1, value2, step(0.0031308, colour.rgb));
}

void main() {
  vec3 baseColour = vec3(0.54f, 0.21f, 0.05f); 
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);
  
  // Ambient Lighting
  vec3 ambientLight = vec3(0.5);

  // Hemi Lighting
  vec3 skyColour = vec3(0.51f, 0.73f, 0.87f); 
  vec3 groundColour = vec3(0.17f, 0.15f, 0.04f);
  float hemiMix = remap(normal.y,-1.0,1.0,0.0,1.0);
  vec3 hemiLight = mix(groundColour, skyColour, hemiMix);

  //Diffuse Lighting
  vec3 lightDir = normalize(vec3(1.0,1.0,1.0)); 
  vec3 lightColour = vec3(0.9f, 0.9f, 0.8f); 
  float dotProduct = max(0.0, dot(lightDir, normal));
  vec3 diffuseLight = lightColour * dotProduct;

  // Phong (specular) Lighting
  vec3 reflectionDir = normalize(reflect(-lightDir,normal));
  float phongValue = max(0.0, dot(viewDir, reflectionDir));
  phongValue = pow(phongValue, 32.0); 
  vec3 specular = vec3(phongValue);

  // IBL specular
  vec3 iblCoord = normalize(reflect(-viewDir, normal));
  vec3 iblSample = textureCube(specMap, iblCoord).xyz;
  specular += iblSample * 0.5;

  // Fresnel 
  float F0 = .8;
  float fresnelValue = (F0 + (1.0 - F0)) * pow(1.0 - dot(viewDir, normal),2.0);
  specular = specular * fresnelValue; 

  // Final lighting mix
  vec3 lighting = ambientLight * 0.0 + hemiLight * 0.5 + diffuseLight * 0.5; 
  vec3 colour = baseColour * lighting + specular;
  colour = linearTosRGB(colour);


  gl_FragColor = vec4(colour, 1.0);
}