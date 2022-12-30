uniform vec2 u_resolution;
uniform float u_time;

varying vec2 v_Uvs;

vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);

float linearInterpolation(float x, float min, float max){
  return (x - min) / (max - min);
}

float remap(float x, float inMin, float inMax, float outMin, float outMax){
  float t = linearInterpolation(x, inMin, inMax); 
  return mix(outMin, outMax, t);
}

// Plot a line on y using a value between 0.0 - 1.0
float plot(vec2 st, float pct){
  return smoothstep(pct - 0.005, pct, st.y) - 
          smoothstep(pct, pct + 0.005, st.y);

}

void main() {
  vec3 colour = vec3(0.0);

  vec2 st = gl_FragCoord.xy / u_resolution;

  float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);
  colour = vec3(y);

  // Plot a line 
  float pct = plot(st, y); 
  colour = (1.0 - pct) * colour + pct * vec3(0.0,1.0,0.0);

  gl_FragColor = vec4(colour, 1.0);
}