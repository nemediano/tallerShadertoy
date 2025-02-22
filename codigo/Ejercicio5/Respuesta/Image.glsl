vec3 calculateBackground(vec3 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}


const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

//Light parameters
const vec3 lightPos = vec3(2, 2, 4);

ScenePoint sdScene(vec3 position) {
    ScenePoint closestShape;

    closestShape.dist = sdFloor(position, -1.0);
    closestShape.color = getCheckboardPattern(position.xz, vec3(1.0), vec3(1.4));
    closestShape.mat = getCheckboardPattern(position.xz, OBSIDIAN, PEARL);

    float testDistance = sdBox(position, vec3(1.5, 0.0, 0.0), vec3(1.0));
    if (testDistance < closestShape.dist) {
       closestShape.dist = testDistance;
       closestShape.color = DarkSeaGreen;
       closestShape.mat = EMERALD;
    }


    testDistance = sdSphere(position, vec3(-1.5, 0.0, 0.0), 1.0);
    if (testDistance < closestShape.dist) {
       closestShape.dist = testDistance;
       closestShape.color = Crimson;
       closestShape.mat = RUBY;
    }

    return closestShape;
}

vec3 calcNormal(vec3 p) {
  const float e = 0.0005; // Epsilon
  return normalize(vec3(
    sdScene(vec3(p.x + e, p.y, p.z)).dist - sdScene(vec3(p.x - e, p.y, p.z)).dist,
    sdScene(vec3(p.x, p.y + e, p.z)).dist - sdScene(vec3(p.x, p.y - e, p.z)).dist,
    sdScene(vec3(p.x, p.y, p.z + e)).dist - sdScene(vec3(p.x, p.y, p.z - e)).dist
  ));
}


ScenePoint rayMarch(Ray ray, float start, float end) {
  float depth = start;
  ScenePoint currentPoint;

  for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
    vec3 position = ray.origin + depth * ray.direction;
    currentPoint = sdScene(position);
    depth += currentPoint.dist;
    if (currentPoint.dist < PRECISION || depth > end) break;
  }

  currentPoint.dist = depth;
  return currentPoint;
}

vec3 shading(vec3 point, vec3 color) {
    vec3 normal = calcNormal(point);
    vec3 lightDirection = normalize(lightPos - point);

    float Kd = clamp(dot(normal, lightDirection), 0.0, 1.0);

    return Kd * color;
}

vec3 BlinPhongShading(vec3 point, vec3 eye, vec3 lightPos, Material mat) {

  vec3 v = normalize(eye - point);
  vec3 l = normalize(lightPos - point);
  vec3 n = calcNormal(point);
  vec3 h = normalize(l + v);

  // Light properties
  vec3 La = vec3(1.0);
  vec3 Ls = vec3(1.0);
  vec3 Ld = vec3(1.0);

  //Phong's shading
  vec3 ambient = mat.Ka * La;
  vec3 diffuse = mat.Kd * Ld * max(dot(n, l), 0.0);
  //Well, technically it is Blin - Phong
  vec3 specular = mat.Ks * Ls * pow(max(dot(n, h), 0.0), mat.alpha);

  return vec3(ambient + specular + diffuse);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = calculateBackground(coord);

    float rps = 1.0 / 16.0;

    //float camMoveAngle = iTime * Tau * rps;
    float camMoveAngle = (1.0 / 4.0) * Tau;
    float camMoveRadious = 4.0;
    float camHeight = 0.5;

    vec2 camCoords = camMoveRadious * vec2(cos(camMoveAngle), sin(camMoveAngle));

    Camera cam;
    cam.position = vec3(camCoords.x, camHeight, camCoords.y);
    cam.target = vec3(0.0);

    Ray ray;
    ray.origin = cam.position;
    ray.direction = camRotation(cam) * normalize(vec3(coord.xy, -1.0));

    ScenePoint sceneHit = rayMarch(ray, MIN_DIST, MAX_DIST);

    if (sceneHit.dist < MAX_DIST) {
        vec3 surfacePoint = ray.origin + ray.direction * sceneHit.dist;
        // color = shading(surfacePoint, sceneHit.color);
        color = BlinPhongShading(surfacePoint, cam.position, lightPos, sceneHit.mat);
    }

    fragColor = vec4(color,1.0);
}
