
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vColour;

uniform float time;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

mat4 translate(vec3 trans){
  return mat4(
    1.0,0.0,0.0,0.0,
    0.0,1.0,0.0,0.0,
    0.0,0.0,1.0,0.0,
    trans.x,trans.y,trans.z,1.0
  );
}

mat4 rotate(float theta, vec3 axis){
  axis = normalize(axis);
  float cosTheta = cos(theta); 
  float sinTheta = sin(theta);
  return mat4(
    cosTheta + axis.x * axis.x * (1.0 - cosTheta),          axis.x * axis.y * (1.0 - cosTheta) - axis.z * sinTheta,  axis.x * axis.z * (1.0 - cosTheta) + axis.y * sinTheta, 0.0,
    axis.y * axis.x * (1.0 - cosTheta) + axis.z * sinTheta, cosTheta + axis.y * axis.y * (1.0 - cosTheta),           axis.y * axis.z * (1.0 - cosTheta) - axis.x * sinTheta, 0.0,
    axis.z * axis.x * (1.0 - cosTheta) - axis.y * sinTheta, axis.z * axis.y * (1.0 - cosTheta) + axis.x * sinTheta, cosTheta + axis.z * axis.z * (1.0 - cosTheta),        0.0,
   0.0,                                                    0.0,                                                    0.0,                                                  1.0
   );
}

mat4 scale(vec3 scalar){
  return mat4(
    scalar.x,0.0,0.0,0.0,
    0.0,scalar.y,0.0,0.0,
    0.0,0.0,scalar.z,0.0,
    0.0,0.0,0.0,1.0
    );
}

void main() {	
  vec3 localSpacePosition = position;

  float t1 = sin(localSpacePosition.x * 10.0 + (2.0 * time));
  t1 = remap(t1,-1.0,1.0,0.0,0.5); 
  // localSpacePosition += normal * t1;

  float t2 = sin(localSpacePosition.y * 20.0 + (2.0 * time));
  t2 = remap(t2,-1.0,1.0,0.0,0.5); 
  // localSpacePosition += normal * t2;

  float t3 = sin(localSpacePosition.z * 10.0 + (2.0 * time)); 
  t3 = remap(t3,-1.0,1.0,0.0,0.5);
  // localSpacePosition += normal * t3;

  mat4 transformationMatrix = mat4(1.0); 
  transformationMatrix *= translate(t1 * normal);
  transformationMatrix *= translate(t2 * normal);
  transformationMatrix *= translate(t3 * normal);

  vColour = mix(
      vec3(0.0,0.0,0.5),
      vec3(0.1,0.5,0.8),
      smoothstep(0.0,0.5,(t1 + t2 + t3) / 3.0)
    );


  gl_Position = projectionMatrix * modelViewMatrix * transformationMatrix * vec4(localSpacePosition, 1.0);
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}