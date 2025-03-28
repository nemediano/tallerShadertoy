// Logic to get background color (anything that in NOT hit by a ray)
vec3 calculateBackground(vec3 coords) {
    float radio = 0.3 * length(coords);
    return mix(WhiteSmoke, LightSkyBlue, radio);
}

// Constant for Ray marching algorith
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;


// Helper function as an example to define composed shapes
float sdCompousedShape(vec3 position) {
    float dis;
    
    float sphereDis = sdSphere(position, vec3(0), 1.0);
    float boxDis = sdBox(position, vec3(0.5, 0.0, 0.0), vec3(0.8));
    dis = opSmoothSubtraction(sphereDis, boxDis, 0.15);
    
    return dis;
}

// Here you set up the scene using sdfs
ScenePoint sdScene(vec3 position) {
    ScenePoint closestShape;
    
    closestShape.dist = sdFloor(position, -1.0);
    closestShape.color = getCheckboardPattern(position.xz, vec3(1.0), vec3(1.4));
    closestShape.mat = getCheckboardPattern(position.xz, OBSIDIAN, PEARL);  

    float testDistance = sdCompousedShape(position);
    if (testDistance < closestShape.dist) {
       closestShape.dist = testDistance;
       closestShape.color = DarkSeaGreen;
       closestShape.mat = TURQUOISE;
    }
    
    return closestShape;
}

// Get the normal at a point of contact
vec3 calcNormal(vec3 p) {
  const float e = 0.0005; // Epsilon
  return normalize(vec3(
    sdScene(vec3(p.x + e, p.y, p.z)).dist - sdScene(vec3(p.x - e, p.y, p.z)).dist,
    sdScene(vec3(p.x, p.y + e, p.z)).dist - sdScene(vec3(p.x, p.y - e, p.z)).dist,
    sdScene(vec3(p.x, p.y, p.z + e)).dist - sdScene(vec3(p.x, p.y, p.z - e)).dist
  ));
}

// Get the normal at a point of contact. 
// Second method less precise but faster to evaluate
vec3 calcNormalV2(vec3 p) {
  const vec2 e = vec2(1.0, -1.0) * 0.0005; // Epsilon

  return normalize(
    e.xyy * sdScene(p + e.xyy).dist +
    e.yyx * sdScene(p + e.yyx).dist +
    e.yxy * sdScene(p + e.yxy).dist +
    e.xxx * sdScene(p + e.xxx).dist
  );
}

// Ray Marching algorithm
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

// Main function: execution start and ends here
void mainImage( out vec4 fragColor, in vec2 fragCoord) {

    vec3 coord = getWorldCoordinates(fragCoord, iResolution);
    vec3 color = calculateBackground(coord);
    
    // Camera position: we use cylindrical coordinates to define it
    float camMovementRadious = 3.0;
    float camHeight = 0.5;
    // Two modes static camera or moving camera
    bool camMove = true;
    float camFixAngle = (1.0 / 4.0) * Tau;
    float rps = 1.0 / 16.0; // revolutions per second i.e: rotation speed
    float camMoveAngle = iTime * Tau * rps;
    float camAngle = camMove ? camMoveAngle : camFixAngle;
    // coordinates in the circle
    vec2 camCoords = camMovementRadious * vec2(cos(camAngle), sin(camAngle));
    
    Camera cam;
    cam.position = vec3(camCoords.x, camHeight, camCoords.y);
    cam.target = vec3(0.0);

    Ray ray;
    ray.origin = cam.position;
    ray.direction = camRotation(cam) * normalize(vec3(coord.xy, -1.0));

    // Light is attach to the camera at a certain offset
    const vec3 lightOffset = vec3(1.0, 1.5, 1.0);
    vec3 lightPosition = (camRotation(cam) * lightOffset) + cam.position;

    ScenePoint sceneHit = rayMarch(ray, MIN_DIST, MAX_DIST);

    if (sceneHit.dist < MAX_DIST) {
        vec3 surfacePoint = ray.origin + ray.direction * sceneHit.dist;
        vec3 normal = calcNormalV2(surfacePoint);
        color = blinPhongShading(surfacePoint, cam.position, lightPosition, normal, sceneHit.mat);
    }

    fragColor = vec4(color,1.0);
}

