vec3 backGroundColor(vec2 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = backGroundColor(coord.xy);

    mat3 M = mat3(1.0);

    // Moving Boxes
    float rvps = 1.0 / 8.0;
    M = translate(vec2(0.0, 0.8)) * scale(vec2(0.4, 0.075));
    float disLine1 = sdfSquare(inverse(M) * coord);
    M = translate(vec2(0.0, -0.8)) * scale(vec2(0.4, 0.075));
    float disLine2 = sdfSquare(inverse(M) * coord);

    // Moving Circles
    M = rotate(iTime * Tau * rvps) * translate(vec2(0.8, 0.0)) * scale(vec2(0.2));
    float disCircle1 = sdfCircle(inverse(M) * coord);
    M = rotate((iTime * Tau * rvps) + Tau / 2.0) * translate(vec2(0.8, 0.0)) * scale(vec2(0.2));
    float disCircle2 = sdfCircle(inverse(M) * coord);

    // Star
    // Big points
    M = scale(vec2(0.1, 0.4)) * rotate(Tau / 8.0);
    float disSquare1 = sdfSquare(inverse(M) * coord);
    M = scale(vec2(0.4, 0.1)) * rotate(Tau / 8.0);
    float disSquare2 = sdfSquare(inverse(M) * coord);
    // Small point
    M = rotate(Tau / 8.0) * scale(vec2(0.075, 0.3)) * rotate(Tau / 8.0);
    float disSquare3 = sdfSquare(inverse(M) * coord);
    M = rotate(Tau / 8.0) * scale(vec2(0.3, 0.075)) * rotate(Tau / 8.0);
    float disSquare4 = sdfSquare(inverse(M) * coord);
    // Center
    M = scale(vec2(0.112));
    float disCenter = sdfCircle(inverse(M) * coord);


    // Draw secene
    // Center star
    color = mix(Green, color, step(0.0, disSquare1));
    color = mix(Green, color, step(0.0, disSquare2));
    color = mix(Lime, color, step(0.0, disSquare3));
    color = mix(Lime, color, step(0.0, disSquare4));
    color = mix(Gold, color, step(0.0, disCenter));
    // Moving boxes
    color = mix(Purple, color, step(0.0, disLine1));
    color = mix(Purple, color, step(0.0, disLine2));
    // Moving cirlces
    color = mix(OrangeRed, color, step(0.0, disCircle1));
    color = mix(OrangeRed, color, step(0.0, disCircle2));


    fragColor = vec4(color,1.0);
}

