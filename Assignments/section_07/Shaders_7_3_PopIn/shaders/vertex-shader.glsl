#define M_PI 3.1415926535897932384626433832795

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

float easeInOutSine(float t){
  return -(cos(M_PI * t) - 1.0) / 2.0;
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

  mat4 transformationMatrix = mat4(1.0);

  float t = easeOutBounce(clamp((time - 1.0) * 0.5,0.0,1.0));
  transformationMatrix *= scale(vec3(t));

  float theta = remap(easeInOutSine(mod( time * 0.5, 1.0)),0.0,1.0,0.0,2.0 * M_PI);
  transformationMatrix *= rotate(theta, vec3(0.0,1.0,0.0));

  t = easeOutBounce(clamp((time - 1.0) * 0.5,0.0,1.0));
  transformationMatrix *= translate(vec3(0.0,t-1.0,0.0));

  gl_Position = projectionMatrix * modelViewMatrix * transformationMatrix * vec4(localSpacePosition, 1.0);
  vNormal = (modelMatrix * transformationMatrix * vec4(normal, 0.0)).xyz;
  vPosition = (modelMatrix * vec4(localSpacePosition, 1.0)).xyz;
}