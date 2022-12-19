

void main()
{
    vec3 red = vec3(1.0, 0.0, 0.0);

    vec3 color01 = vec3(0.0, 1.0, 0.0); //0x00FF00 (Green)
    vec3 color02 = vec3(0.5, 0.5, 0.5); // 0x808080 (Light Gray)
    vec3 color03 = vec3(0.8, 0.8, 1.0); // 0xC0C0FF (Blue-ish)


    gl_FragColor = vec4(color03, 1.0); //rgba
}