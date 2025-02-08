void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // UV coordinates
    vec2 uv = fragCoord/iResolution.xy;
    
    // Wave function
    const float PI = 3.141516;
    vec2 frequency = 8.0 * vec2(PI);
    vec2 waves = sin(frequency * uv);

    // Decide color
    vec2 cells = step(0.0, waves); //Cells have a 0.0 or 1.0 value
    vec3 black = vec3(0.0);
    vec3 white = vec3(1.0);
    //vec3 col = mix(black, white, cells.x);
    vec3 col = white;
    if (cells.x + cells.y == 1.0) {
        col = black;
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}
