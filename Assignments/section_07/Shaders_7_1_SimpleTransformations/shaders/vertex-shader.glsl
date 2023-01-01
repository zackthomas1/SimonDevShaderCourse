
varying vec3 vNormal;
varying vec3 vPosition;

uniform float time;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}


mat4 translation(float x, float y, float z){
  return mat4(
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    x, y, y, 1.0
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

mat4 scale(float x, float y, float z){
  return mat4(
    x, 0.0,0.0,0.0,
    0.0,y,0.0,0.0,
    0.0,0.0,z,0.0,
    0.0,0.0,0.0,1.0
    );
}

// Homework Section 2 - implement rotateX
mat3 rotateX(float radians){
  float sinTheta = sin(radians); 
  float cosTheta = cos(radians); 

  return mat3(
    1.0, 0.0,      0.0,
    0.0, cosTheta, -sinTheta, 
    0.0, sinTheta, cosTheta
  );
}

//simonDev rotationY function
mat3 rotateY(float radians){
  float sinTheta = sin(radians); 
  float cosTheta = cos(radians); 

  return mat3(
    cosTheta, 0.0, sinTheta,
    0.0,      1.0, 0.0,
    -sinTheta,0.0, cosTheta 
  );
}

// Homework Section 2 - implement rotateZ
mat3 rotateZ(float radians){
  float sinTheta = sin(radians); 
  float cosTheta = cos(radians); 

  return mat3(
    cosTheta,  -sinTheta, 0.0,
    sinTheta,   cosTheta, 0.0,
    0.0,       0.0,       1.0
  );
}

void main() {	
  vec3 localSpacePosition = position;
 
  // order of transformations matters. Composition of transforms (and matrix multiplication) non-communtive. translation-rotation-scale. Operations applied right-to-left 
  // localSpacePosition.xyz *= remap(sin(time), -1.0, 1.0, 0.5, 1.5); // demonstrates scaling along an axis
  // localSpacePosition = (rotationMatrix * vec4(localSpacePosition, 1.0)).xyz; // demonstrates rotation around axis
  // localSpacePosition = rotateZ(time) * localSpacePosition; // SimonDev rotationY function
  // localSpacePosition.x += 2.0 * sin(time); // demonstrates translation

  float scalar = remap(sin(time), -1.0, 1.0, 0.5, 1.5);
  mat4 transformationMatrix = mat4(1.0);
  transformationMatrix *= translation(sin(time), 0.0, 0.0); 
  transformationMatrix *= rotate(time,vec3(1.0,1.0,0.0));
  transformationMatrix *= scale(scalar,scalar,scalar);
  localSpacePosition = (transformationMatrix * vec4(localSpacePosition, 1.0)).xyz;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(localSpacePosition, 1.0);
  vNormal = (modelMatrix * transformationMatrix *vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}