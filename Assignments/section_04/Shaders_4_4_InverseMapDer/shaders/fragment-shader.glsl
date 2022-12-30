
varying vec2 vUvs;

varying vec4 localSpacePosition;
varying vec4 worldSpacePosition; 

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

void main() {
  vec3 colour = vec3(0.0);

  vec3 lsPosition = vec3(localSpacePosition);
  vec3 lsNormal = normalize(cross(dFdx(lsPosition), dFdy(lsPosition)));

  vec3 wsPosition = vec3(worldSpacePosition);
  vec3 wsNormal = normalize(cross(dFdx(wsPosition), dFdy(wsPosition)));

  colour = wsNormal;

  gl_FragColor = vec4(colour, 1.0);
}
