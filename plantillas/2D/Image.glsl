/* Put the logic for the background here */
vec3 backGroundColor(vec2 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}

/* Draw main scene */
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 
    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = backGroundColor(coord.xy);
    
    mat3 M = mat3(1.0);
    
    // Calculate the distance of each shape using M
    M = translate(vec2(0.25, 0.0)) * rotate(radians(45.0)) * scale(vec2(0.2));
    float distShape1 = sdfSquare(coord, M);
    
    M = translate(vec2(-0.25, 0.0)) * scale(vec2(0.2));
    float distShape2 = sdfCircle(coord, M);

    // Draw each shape in a certain color using his distance
    // Remember these use painter's algorithm for the order
    color = mix(OrangeRed, color, step(0.0, distShape1));
    color = mix(Teal, color, step(0.0, distShape2));

    fragColor = vec4(color,1.0);
}

