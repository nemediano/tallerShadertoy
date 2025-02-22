vec3 calculateBackground(vec3 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}


const vec3 camPos = vec3(0.0, 0.0, 2.0);
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

//Light parameters
const vec3 lightPos = vec3(2, 2, 4);

float sdScene(vec3 position) {
    return sdBox(position, vec3(-1.0, 0.0, 0.0), vec3(0.25, 0.5, 0.25));
}

vec3 calcNormal(vec3 p) {
  const float Epsilon = 0.0005; // epsilon
  return normalize(vec3(
    sdScene(vec3(p.x + Epsilon, p.y, p.z)) - sdScene(vec3(p.x - Epsilon, p.y, p.z)),
    sdScene(vec3(p.x, p.y + Epsilon, p.z)) - sdScene(vec3(p.x, p.y - Epsilon, p.z)),
    sdScene(vec3(p.x, p.y, p.z  + Epsilon)) - sdScene(vec3(p.x, p.y, p.z - Epsilon))
  ));
}


float rayMarch(Ray ray, float start, float end) {
  float depth = start;

  for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
    vec3 position = ray.origin + depth * ray.direction;
    float d = sdScene(position);
    depth += d;
    if (d < PRECISION || depth > end) break;
  }

  return depth;
}

vec3 shading(vec3 point, vec3 color) {
    vec3 normal = calcNormal(point);
    vec3 lightDirection = normalize(lightPos - point);

    float Kd = clamp(dot(normal, lightDirection), 0.0, 1.0);

    return Kd * color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = calculateBackground(coord);

    Ray r;
    r.origin = camPos;
    r.direction = //normalize(vec3(coord.xy, -1.0));
    normalize(vec3(coord.xy, 0.0) - camPos);
    float d = rayMarch(r, MIN_DIST, MAX_DIST);

    if (d < MAX_DIST) { // did ray hit something?
        vec3 p = r.origin + r.direction * d; // point on sphere we discovered from ray marching
        color = shading(p, Crimson);
    }

    // Output to screen
    fragColor = vec4(color,1.0);
}
