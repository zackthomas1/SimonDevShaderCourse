varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUVs;


void main() {	
  vUVs = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vPosition = (modelMatrix * vec4(position,1.0)).xyz;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}