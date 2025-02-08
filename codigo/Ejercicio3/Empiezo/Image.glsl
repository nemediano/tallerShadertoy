vec3 backGroundColor(vec2 coords) {
    return LightSkyBlue;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = backGroundColor(coord.xy);

    mat3 M = mat3(1.0);

    M = scale(vec2(0.2));
    float disCircle = sdfCircle(inverse(M) * coord);
    color = mix(Crimson, color, step(0.0, disCircle));

    fragColor = vec4(color,1.0);
}
