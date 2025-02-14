vec3 calculateBackground(vec3 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}


const vec3 camPos = vec3(0.0, 0.0, 2.0);
const int MAX_MARCHING_STEPS = 32;
const float MIN_DIST = 0.0;
const float MAX_DIST = 10.0;
const float PRECISION = 0.001;

//Light parameters
const vec3 lightPos = vec3(2, 2, 4);

float sdScene(vec3 position) {
    return sdSphere(position, vec3(0.0, 0.0, -2.0), 1.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = calculateBackground(coord);

    // Output to screen
    fragColor = vec4(color,1.0);
}
