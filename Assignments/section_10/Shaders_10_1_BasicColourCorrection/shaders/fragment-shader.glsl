
varying vec2 vUvs;
uniform vec2 resolution;
uniform float time;
uniform sampler2D diffuse1;
uniform sampler2D diffuse2;
uniform sampler2D vignette;


float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 saturate(vec3 x) {
  return clamp(x, vec3(0.0), vec3(1.0));
}

float saturate(float x) {
  return clamp(x, 0.0, 1.0);
}

float ColourDistance(vec3 c1, vec3 c2) {
  float rm = (c1.x + c2.x) * 0.5 * 256.0;
  vec3 d = (c1 - c2) * 256.0;

  float r = (2.0 + rm / 256.0) * d.x * d.x;
  float g = 4.0 * d.y * d.y;
  float b = (2.0 + (255.0 - rm) / 256.0) * d.z * d.z;
  return sqrt(r + g + b) / 256.0;
}

void main() {
  vec2 coords = fract(vUvs * vec2(2.0, 1.0));
  coords.x = remap(coords.x, 0.0, 1.0, 0.25, 0.75);
  vec3 colour = texture2D(diffuse2, coords).xyz;

  if (vUvs.x > 0.5) {
    // Tinting
    vec3 tintColour = vec3(1.0, 0.5, 0.5);
    // colour *= tintColour;

    // Brightness
    float brightnessAmount = 0.1;
    // colour += brightnessAmount;

    // Saturation
    float luminance = dot(colour, vec3(0.2126, 0.7152, 0.0722));
    float saturationAmount = 1.0;
    // colour = mix(vec3(luminance), colour, saturationAmount);

    // Contrast
    float contrastAmount = 1.0;
    float midpoint = 0.5;
    // colour = saturate((colour - midpoint) * contrastAmount + midpoint);
    // colour = smoothstep(vec3(0.0), vec3(1.0), colour);
    vec3 sg = sign(colour - midpoint);
    // colour = sg * pow(
    //     abs(colour - midpoint) * 2.0,
    //     vec3(1.0 / contrastAmount)) * 0.5 + midpoint;

    // The Matrix
    // colour = pow(colour, vec3(1.5, 0.8, 1.5));

    // Colour Boost
    vec3 refColour = vec3(0.72, 0.25, 0.25);
    // float colourWeight = 1.0 - distance(colour, refColour);
    // colourWeight = smoothstep(0.45, 1.0, colourWeight);
    float colourWeight = dot(normalize(colour), normalize(refColour));
    colourWeight = pow(colourWeight, 32.0);
    // colour = mix(vec3(luminance), colour, colourWeight);

    vec2 vignetteCoords = fract(vUvs * vec2(2.0, 1.0));
    // vec3 vignetteAmount = texture2D(vignette, vignetteCoords).xyz;

    float v1 = smoothstep(0.5, 0.2, abs(vignetteCoords.x - 0.5));
    float v2 = smoothstep(0.5, 0.2, abs(vignetteCoords.y - 0.5));
    float vignetteAmount = v1 * v2;
    vignetteAmount = pow(vignetteAmount, 0.25);
    vignetteAmount = remap(vignetteAmount, 0.0, 1.0, 0.5, 1.0);

    // colour *= vignetteAmount;

    // Pixelation
    vec2 dims = vec2(128.0, 128.0);
    vec2 texUV = floor(coords * dims) / dims;
    vec3 pixelated = texture2D(diffuse2, texUV).xyz;
    // colour = pixelated;

    // Ripples
    vec2 pushedCoords = coords;
    float pushedSign = sign(pushedCoords.y - 0.5);
    pushedCoords.y = pushedSign * pow(
        abs(pushedCoords.y - 0.5) * 2.0,
        0.7) * 0.5 + 0.5;
    // colour = texture2D(diffuse2, pushedCoords).xyz;

    float distToCenter = length(coords - 0.5);
    float d = sin(distToCenter * 50.0 - time * 2.0);
    vec2 dir = normalize(coords - 0.5);
    vec2 rippleCoords = coords + d * dir * 0.05;
    colour = texture2D(diffuse2, rippleCoords).xyz;
  }

  gl_FragColor = vec4(colour, 1.0);
}




