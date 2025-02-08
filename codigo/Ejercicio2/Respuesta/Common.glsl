// Get world coordinates from the traditional inputs to the shader
vec3 getWorldCoordinates(vec2 fragCoord, vec3 iResolution) {

    float aspectRatio = iResolution.x / iResolution.y;

    vec2 scaleFactor =
        iResolution.x > iResolution.y ? vec2(aspectRatio, 1.0) : vec2(1.0, 1.0 / aspectRatio);

    vec2 world = scaleFactor * (2.0 * (fragCoord/iResolution.xy) - vec2(1.0));

    return vec3(world, 1.0);
}

//Signed distance funcitons

float sdfCircle(vec2 fragCoord) {
    return dot(fragCoord, fragCoord) - 1.0;
}

float sdfSquare(vec2 fragCoord) {
    return max(abs(fragCoord.x), abs(fragCoord.y)) - 1.0;
}

// Color constants
const vec3 White         = vec3(1.0,  1.0,  1.0);
const vec3 Silver        = vec3(0.75, 0.75, 0.75);
const vec3 Gray          = vec3(0.5,  0.5,  0.5);
const vec3 Black         = vec3(0.0,  0.0,  0.0);
const vec3 Red           = vec3(1.0,  0.0,  0.0);
const vec3 Maroon        = vec3(0.5,  0.0,  0.0);
const vec3 Yellow        = vec3(1.0,  1.0,  0.0);
const vec3 Olive         = vec3(0.5,  0.5,  0.0);
const vec3 Lime          = vec3(0.0,  1.0,  0.0);
const vec3 Green         = vec3(0.0,  0.5,  0.0);
const vec3 Aqua          = vec3(0.0,  1.0,  1.0);
const vec3 Cyan          = Aqua;
const vec3 Teal          = vec3(0.0,  0.5,  0.5);
const vec3 Blue          = vec3(0.0,  0.0,  1.0);
const vec3 Navy          = vec3(0.0,  0.0,  0.5);
const vec3 Fuchsia       = vec3(1.0,  0.0,  1.0);
const vec3 Magenta       = Fuchsia;
const vec3 Purple        = vec3(0.5,  0.0,  0.5);
const vec3 Pink          = vec3(1.0,  0.75, 0.8);
const vec3 HotPink       = vec3(1.0,  0.41, 0.71);
const vec3 Crimson       = vec3(0.86, 0.8,  0.24);
const vec3 Salmon        = vec3(0.98, 0.5,  0.45);
const vec3 OrangeRed     = vec3(1.0,  0.27, 0.0);
const vec3 Orange        = vec3(1.0,  0.65, 0.0);
const vec3 Coral         = vec3(1.0,  0.5,  0.31);
const vec3 Gold          = vec3(1.0,  0.84, 0.0);
const vec3 Khaki         = vec3(0.94, 0.9,  0.55);
const vec3 Sienna        = vec3(0.63, 0.32, 0.18);
const vec3 Chocolate     = vec3(0.82, 0.41, 0.12);
const vec3 Peru          = vec3(0.80, 0.52, 0.25);
const vec3 DarkViolet    = vec3(0.58, 0.0,  0.83);
const vec3 Indigo        = vec3(0.29, 0.0,  0.51);
const vec3 DeepSkyBlue   = vec3(0.0,  0.75, 1.0);
const vec3 LightSkyBlue  = vec3(0.53, 0.81, 0.1);
const vec3 LightSeaGreen = vec3(0.13, 0.70, 0.67);
const vec3 LimeGreen     = vec3(0.2,  0.8,  0.2);
const vec3 LawnGreen     = vec3(0.49, 0.99, 0.0);
const vec3 Ivory         = vec3(1.0,  1.0,  0.94);
