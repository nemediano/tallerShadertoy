vec3 backGroundColor(vec2 coords) {
    return mix(Olive, LightSkyBlue, coords.y+0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 coord = getWorldCoordinates(fragCoord, iResolution);


    vec3 color = backGroundColor(coord.xy);

    float disCircle = sdfCircle(coord.xy);
    float disSquare = sdfSquare(coord.xy);

    color = mix(Maroon, color, step(0.0, disSquare));
    color = mix(Crimson, color, step(0.0, disCircle));

    fragColor = vec4(color,1.0);
}
