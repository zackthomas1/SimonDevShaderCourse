

varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;	
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}