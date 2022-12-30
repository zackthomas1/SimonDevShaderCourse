
varying vec2 vUvs;

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

// Homework section2 - Implement clamp using min/max 
float clampMinMax(float x, float minvalue, float maxvalue)
{  
  // Alternative implementation using tertiary conditional statements instead of glsl min/max functions
  // float result = result < minvalue? minvalue : result;
  // result = result > maxvalue? maxvalue : result;
 
  float result = min(x, maxvalue);
  result = max(result, minvalue); 

  // Given Soloution 
  // result = max(min(x,maxvalue), minvalue);

  return result;
}

float saturation(float a){
  return clamp(a, 0.0, 1.0);
}

void main() {
  vec3 colour = vec3(0.0);

  float line1 = smoothstep(0.0,0.005, abs(vUvs.y - 0.5));

  float value01 = vUvs.x;
  float value02 = clamp(vUvs.x, 0.25, 0.75);
  // float value02 = saturation(vUvs.x);

  float smoothstepLine = smoothstep(0.0,0.005,abs(vUvs.y - mix(0.5,1.0,smoothstep(0.0,1.0, value01))));
  float linearLine = smoothstep(0.0, 0.005, abs(vUvs.y - mix(0.0, 0.5, value02)));

  if(vUvs.y > 0.5){
    colour= mix(red, blue, smoothstep(0.0,1.0, value01)); 
  }else{
    colour = mix(red, blue, value02);
  }

  colour = mix(black, colour, line1);
  colour = mix(white, colour, smoothstepLine);
  colour = mix(white, colour, linearLine);

  // Final output
  gl_FragColor = vec4(colour, 1.0);
}
