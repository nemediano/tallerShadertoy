void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Some useful constants
    const float PI = 3.141516;
    const vec3 BLACK = vec3(0.0);
    const vec3 WHITE = vec3(1.0);
    
    // UV coordinates
    vec2 uv = fragCoord/iResolution.xy;
      
    /* One way of doing it */
    // Wave function
    vec2 frequency = PI * vec2(8.0);
    vec2 waves = sin(frequency * uv);
    // Decide color
    vec2 cells = step(0.0, waves); //Cells have a 0.0 or 1.0 value
    float selector = mod(cells.x + cells.y, 2.0);
    vec3 col = mix(BLACK, WHITE, selector);
    
    /* Another way of doing it */
    // vec2 frequency = vec2(8.0);
    // uv *= frequency;
    // float selector = mod(floor(uv.x) + floor(uv.y), 2.0);
    // vec3 col = mix(BLACK, WHITE, selector);

    // Output to screen
    fragColor = vec4(col,1.0);
}
