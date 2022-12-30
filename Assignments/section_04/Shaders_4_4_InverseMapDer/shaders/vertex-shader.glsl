
varying vec2 vUvs;

varying vec4 localSpacePosition;
varying vec4 worldSpacePosition; 

void main() {	
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  
  localSpacePosition = vec4(position, 1.0);
  worldSpacePosition = modelViewMatrix * vec4(position, 1.0);

  vUvs = uv;
}