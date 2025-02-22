struct Material {
  vec3 Ka;
  vec3 Kd;
  vec3 Ks;
  float alpha;
};

struct Ray {
  vec3 origin;
  vec3 direction;
};

struct ScenePoint {
  float dist;
  vec3 color;
};

struct Camera {
  vec3 position;
  vec3 target;
};


mat3 camRotation(Camera cam) {

    vec3 camDir = normalize(cam.target - cam.position);
    vec3 camRight = normalize(cross(vec3(0, 1, 0), camDir));
    vec3 camUp = normalize(cross(camDir, camRight));

    return mat3(-camRight, camUp, -camDir);
}

// Get world coordinates from the traditional inputs to the shader
vec3 getWorldCoordinates(vec2 fragCoord, vec3 iResolution) {

    float aspectRatio = iResolution.x / iResolution.y;

    vec2 scaleFactor =
        iResolution.x > iResolution.y ? vec2(aspectRatio, 1.0) : vec2(1.0, aspectRatio);

    vec2 world = scaleFactor * (2.0 * (fragCoord/iResolution.xy) - vec2(1.0));

    return vec3(world, 1.0);
}

float sdSphere(vec3 position, vec3 shpereCenter, float radius) {
    return length(position - shpereCenter) - radius;
}

float sdBox(vec3 position, vec3 boxCenter, vec3 boxSizes) {
  vec3 q = abs(position - boxCenter) - boxSizes;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdFloor(vec3 position, float floorHeight) {
    return position.y - floorHeight;
}

vec3 getCheckboardPattern(vec2 coords, vec3 colorEven, vec3 colorOdd) {
    float alpha = mod(floor(coords.x) + floor(coords.y), 2.0);
    return mix(colorEven, colorOdd, alpha);
}

Material getCheckboardPattern(vec2 coords, Material matEven, Material matOdd) {
    float selector = mod(floor(coords.x) + floor(coords.y), 2.0);
    Material m;

    m.Ka = mix(matEven.Ka, matOdd.Ka, selector);
    m.Kd = mix(matEven.Kd, matOdd.Kd, selector);
    m.Ks = mix(matEven.Ks, matOdd.Ks, selector);
    m.alpha = mix(matEven.alpha, matOdd.alpha, selector);

    return m;
}

mat4 rotate(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(
    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0
  );
}

mat4 translate(vec3 offset) {
    mat4 T = mat4(1.0);

    T[3] = vec4(offset, 1.0);

    return T;
}

mat4 scale(vec3 scaleFactors) {
    mat4 S = mat4(1.0);

    S[0][0] = scaleFactors.x;
    S[1][1] = scaleFactors.y;
    S[2][2] = scaleFactors.z;

    return S;
}

//Math constants
const float Pi  = 3.141592653;
const float Tau = 6.283185307;

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
const vec3 Crimson       = vec3(0.86, 0.08,  0.24);
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
const vec3 LightSkyBlue  = vec3(0.53, 0.81, 0.98);
const vec3 LightSeaGreen = vec3(0.13, 0.70, 0.67);
const vec3 LimeGreen     = vec3(0.2,  0.8,  0.2);
const vec3 LawnGreen     = vec3(0.49, 0.99, 0.0);
const vec3 Ivory         = vec3(1.0,  1.0,  0.94);
const vec3 Plum          = vec3(0.87, 0.63,  0.87);
const vec3 Bisque        = vec3(1.0,  0.89,  0.77);
const vec3 DarkSeaGreen  = vec3(0.56, 0.74,  0.56);
const vec3 WhiteSmoke    = vec3(0.96, 0.96,  0.96);

//Material constants
const float sha = 128.0;//They calculate the shininess factor different in the equation, I need to adjust
const Material EMERALD = Material(vec3(0.0215, 0.1745, 0.0215), vec3(0.07568, 0.61424, 0.07568), vec3(0.633, 0.727811, 0.633), sha * 0.6);
const Material JADE = Material(vec3(0.135, 0.2225, 0.1575), vec3(0.54, 0.89, 0.63), vec3(0.316228, 0.316228, 0.316228), sha * 0.1);
const Material OBSIDIAN = Material(vec3(0.05375, 0.05, 0.06625), vec3(0.18275, 0.17, 0.22525), vec3(0.332741, 0.328634, 0.346435), sha * 0.3);
const Material PEARL = Material(vec3(0.25, 0.20725, 0.20725), vec3(1.0, 0.829, 0.829), vec3(0.296648, 0.296648, 0.296648), sha * 0.088f);
const Material RUBY = Material(vec3(0.1745, 0.01175, 0.01175), vec3(0.61424, 0.04136, 0.04136), vec3(0.727811, 0.626959, 0.626959), sha * 0.6);
const Material TURQUOISE = Material(vec3(0.1, 0.18725, 0.1745), vec3(0.396, 0.74151, 0.69102), vec3(0.297254, 0.30829, 0.306678), sha * 0.1f);

const Material BRASS = Material(vec3(0.329412, 0.223529, 0.027451), vec3(0.780392, 0.568627, 0.113725), vec3(0.992157, 0.941176, 0.807843), sha * 0.21794872);
const Material BRONZE = Material(vec3(0.2125, 0.1275, 0.054), vec3(0.714, 0.4284, 0.18144), vec3(0.393548, 0.271906, 0.166721), sha * 0.2);
const Material CHROME = Material(vec3(0.25, 0.25, 0.25), vec3(0.4, 0.4, 0.4), vec3(0.774597, 0.774597, 0.774597), sha * 0.6);
const Material COPPER = Material(vec3(0.19125, 0.0735, 0.0225), vec3(0.7038, 0.27048, 0.0828), vec3(0.256777, 0.137622, 0.086014), sha * 0.1);
const Material GOLD = Material(vec3(0.24725, 0.1995, 0.0745), vec3(0.75164, 0.60648, 0.22648), vec3(0.628281, 0.555802, 0.366065), sha * 0.4);
const Material SILVER = Material(vec3(0.19225, 0.19225, 0.19225), vec3(0.50754, 0.50754, 0.50754), vec3(0.508273, 0.508273, 0.508273), sha * 0.4);

const Material BLACK_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.01, 0.01, 0.01), vec3(0.50, 0.50, 0.50), sha * 0.25);
const Material CYAN_PLASTIC = Material(vec3(0.0, 0.1, 0.06), vec3(0.0, 0.50980392, 0.50980392), vec3(0.50196078, 0.50196078, 0.50196078), sha * 0.25);
const Material GREEN_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.1, 0.35, 0.1), vec3(0.45, 0.55, 0.45), sha * 0.25);
const Material RED_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.5, 0.0, 0.0), vec3(0.7, 0.6, 0.6), sha * 0.25);
const Material WHITE_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.55, 0.55, 0.55), vec3(0.70, 0.70, 0.70), sha * 0.25);
const Material YELLOW_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.5, 0.5, 0.0), vec3(0.60, 0.60, 0.50), sha * 0.25);

const Material BLACK_RUBBER = Material(vec3(0.02, 0.02, 0.02), vec3(0.01, 0.01, 0.01), vec3(0.4, 0.4, 0.4), sha * 0.078125);
const Material CYAN_RUBBER = Material(vec3(0.0, 0.05, 0.05), vec3(0.4, 0.5, 0.5), vec3(0.04, 0.7, 0.7), sha * 0.078125);
const Material GREEN_RUBBER = Material(vec3(0.0, 0.05, 0.0), vec3(0.4, 0.5, 0.4), vec3(0.04, 0.7, 0.04), sha * 0.078125);
const Material RED_RUBBER = Material(vec3(0.05, 0.0, 0.0), vec3(0.5, 0.4, 0.4), vec3(0.7, 0.04, 0.04), sha * 0.078125);
const Material WHITE_RUBBER = Material(vec3(0.05, 0.05, 0.05), vec3(0.5, 0.5, 0.5), vec3(0.7, 0.7, 0.7), sha * 0.078125);
const Material YELLOW_RUBBER = Material(vec3(0.05, 0.05, 0.0), vec3(0.5, 0.5, 0.4), vec3(0.7, 0.7, 0.04), sha * 0.078125);
