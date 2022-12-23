
varying vec2 vUvs;

uniform vec2 resolution;

vec3 red = vec3(1.0, 0.0, 0.0);
vec3 blue = vec3(0.0, 0.0, 1.0);
vec3 white = vec3(1.0, 1.0, 1.0);
vec3 black = vec3(0.0, 0.0, 0.0);
vec3 yellow = vec3(1.0, 1.0, 0.0);

void main() {
  vec3 colour = vec3(0.0);

  // simple step, mix, and smoothstep examples
  // colour = vec3(vUvs.x);
  // colour = vec3(step(0.25,vUvs.x));
  // colour = vec3(mix(red,blue,vUvs.x));
  // colour = mix(red, blue, smoothstep(0.0, 1.0, vUvs.x));

  float line1 = smoothstep(0.0, 0.005, abs(vUvs.y - 0.33));
  float line2 = smoothstep(0.0, 0.005, abs(vUvs.y - 0.66));

  float stepLine = smoothstep(0.0, 0.005, abs(vUvs.y - mix(0.67, 0.99, step(0.5, vUvs.x))));
  float linearLine = smoothstep(0.0, 0.005, abs(vUvs.y - mix(0.33, 0.66, vUvs.x)));
  float smoothstepLine = smoothstep(0.0, 0.005, abs(vUvs.y - mix(0.0, 0.33, smoothstep(0.0, 1.0, vUvs.x))));

  if(vUvs.y > 0.66){
    colour = mix(red, blue, step(0.5, vUvs.x)); 
  }else if(vUvs.y > 0.33 && vUvs.y <= 0.66){
    colour = mix(red, blue, vUvs.x); 
  }else{
    colour = mix(red, blue, smoothstep(0.0, 1.0, vUvs.x));
  }

  colour = mix(black, colour, line1);
  colour = mix(black, colour, line2);

  colour = mix(white, colour, stepLine);
  colour = mix(white, colour, linearLine);
  colour = mix(white, colour, smoothstepLine);


  gl_FragColor = vec4(colour, 1.0);
}
