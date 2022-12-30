
varying vec2 vUvs;

uniform sampler2D texture01;
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

  // Homework Section 1 - Change shader to have 3 sections(step, mix, and smoothstep)
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


  // Homework Section 1 - Run a texture through smoothstep
  vec4 textureSmoothStepUVsSample = texture2D(texture01, smoothstep(0.0,1.0,vUvs));  
  vec3 textureSmoothStepUVsColour = vec3(textureSmoothStepUVsSample); 

  vec4 textureSample = texture2D(texture01, vUvs); 
  vec3 textureSampleColour = vec3(textureSample);

  // Changing the edge values appears to have the effect of chaning the white and black points of the image
  float edge0 = 0.0, edge1 = 1.0;
  vec3 textureSmoothStepRGBColour = vec3( smoothstep(edge0, edge1, textureSample.r), 
                                          smoothstep(edge0, edge1, textureSample.g), 
                                          smoothstep(edge0, edge1, textureSample.b));

  float stepValue = 0.35;
  vec3 textureStepRGBColour = vec3( step(stepValue, textureSample.r),
                                    step(stepValue, textureSample.g),
                                step(stepValue, textureSample.b));

  // final output
  gl_FragColor = vec4(colour, 1.0);
}
