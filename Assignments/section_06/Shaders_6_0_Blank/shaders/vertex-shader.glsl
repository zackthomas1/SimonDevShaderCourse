

varying vec3 vNormal;
varying vec3 vPosition;

void main() {	
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}