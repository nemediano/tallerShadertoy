// Material for Phong shading
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

// Point in the scene for Raymarching
// We should put any information need to idenify and reconstruct a point that hist the scene
struct ScenePoint {
  float dist;
  vec3 color;
  Material mat;
};

// Camera's pose
struct Camera {
  vec3 position;
  vec3 target;
};

// Camera rotation from the postions and target paramters
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


// Signed distance fields (sdf) of some shapes
float sdSphere(vec3 position, vec3 shpereCenter, float radius) {
    return length(position - shpereCenter) - radius;
}

float sdSphere(vec3 position, mat4 T) {
    vec3 tPos = (inverse(T) * vec4(position, 1.0)).xyz;
    return sdSphere(tPos, vec3(0.0), 1.0);
}

float sdBox(vec3 position, vec3 boxCenter, vec3 boxSizes) {
  vec3 q = abs(position - boxCenter) - boxSizes;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdBox(vec3 position, mat4 T) {
  vec3 tPos = (inverse(T) * vec4(position, 1.0)).xyz;
  return sdBox(tPos, vec3(0.0), vec3(1.0));
}

float sdTorus(vec3 position, float majorRadious, float minorRadious, mat4 T) {
  vec3 tPos = (inverse(T) * vec4(position, 1.0)).xyz;
  vec2 q = vec2(length(tPos.xz) - majorRadious, tPos.y);
  return length(q) - minorRadious;
}

float sdCylinder(vec3 position, float height, float radious, mat4 T) {
  vec3 tPos = (inverse(T) * vec4(position, 1.0)).xyz;
  vec2 d = abs(vec2(length(tPos.xz), tPos.y)) - vec2(radious, height);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Note that angle is the angle that makes the cone with an horizontal plane
// or the complement of the actual cone angle
float sdCone(vec3 position, float angle, float height, mat4 T) {
  
  vec3 tPos = (inverse(T) * vec4(position, 1.0)).xyz;
  vec2 c = vec2(sin(angle), cos(angle));
  float q = length(tPos.xz);
  return max(dot(c.xy, vec2(q, tPos.y)),-height - tPos.y);
}

float sdFloor(vec3 position, float floorHeight) {
    return position.y - floorHeight;
}

// Boolean operations between shapes by sdfs
float opUnion(float lhsd, float rhsd) {
    return min(lhsd, rhsd);
}

float opSubtraction(float lhsd, float rhsd) {
    return max(-lhsd, rhsd);
}

float opIntersection(float lhsd, float rhsd) {
    return max(lhsd, rhsd);
}

float opXor(float lhsd, float rhsd) {
    return max(min(lhsd, rhsd), -max(lhsd, rhsd));
}

// Smooth boolean operations between shapes by sdfs
// The smooth factor its in the same units as the sdfs
float opSmoothUnion(float lhsd, float rhsd, float smoothFactor) {
    float h = clamp(0.5 + 0.5 * (rhsd - lhsd) / smoothFactor, 0.0, 1.0);
    return mix(rhsd, lhsd, h) - smoothFactor * h * (1.0 - h);
}

float opSmoothSubtraction(float lhsd, float rhsd, float smoothFactor) {
    float h = clamp(0.5 - 0.5 * (rhsd + lhsd) / smoothFactor, 0.0, 1.0);
    return mix(rhsd, -lhsd, h) + smoothFactor * h * (1.0 - h);
}

float opSmoothIntersection(float lhsd, float rhsd, float smoothFactor) {
    float h = clamp(0.5 - 0.5 * (rhsd - lhsd) / smoothFactor, 0.0, 1.0);
    return mix(rhsd, lhsd, h) + smoothFactor * h * (1.0 - h);
}

// Select between two colors based on the coordinates of a plane
vec3 getCheckboardPattern(vec2 coords, vec3 colorEven, vec3 colorOdd) {
    float alpha = mod(floor(coords.x) + floor(coords.y), 2.0);
    return mix(colorEven, colorOdd, alpha);
}

// Select between two Materials based on the coordinates of a plane
Material getCheckboardPattern(vec2 coords, Material matEven, Material matOdd) {
    float selector = mod(floor(coords.x) + floor(coords.y), 2.0);
    Material m;
    
    m.Ka = mix(matEven.Ka, matOdd.Ka, selector);
    m.Kd = mix(matEven.Kd, matOdd.Kd, selector);
    m.Ks = mix(matEven.Ks, matOdd.Ks, selector);
    m.alpha = mix(matEven.alpha, matOdd.alpha, selector);
    
    return m;
}


// Affine transformation matrices
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

// Shading algorthims
vec3 lambertShading(vec3 point, vec3 lightPos, vec3 normal, vec3 color) {

    vec3 lightDirection = normalize(lightPos - point);

    float Kd = max(dot(normal, lightDirection), 0.0);

    return Kd * color;
}

vec3 blinPhongShading(vec3 point, vec3 eye, vec3 lightPos, vec3 normal, Material mat) {

  vec3 v = normalize(eye - point);
  vec3 l = normalize(lightPos - point);
  vec3 n = normalize(normal);
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


// Post processing effects
vec3 gammaCorrection(vec3 color, float gamma) {
    return pow(color, vec3(1.0 / gamma));
}

vec3 toneMapping(vec3 color) {
	return color / (color + vec3(1.0));
}


// Math constants
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
const Material EMERALD = Material(vec3(0.0215, 0.1745, 0.0215), vec3(0.07568, 0.61424, 0.07568), vec3(0.633, 0.727811, 0.633), 76.8);
const Material JADE = Material(vec3(0.135, 0.2225, 0.1575), vec3(0.54, 0.89, 0.63), vec3(0.316228, 0.316228, 0.316228), 12.8);
const Material OBSIDIAN = Material(vec3(0.05375, 0.05, 0.06625), vec3(0.18275, 0.17, 0.22525), vec3(0.332741, 0.328634, 0.346435), 38.4);
const Material PEARL = Material(vec3(0.25, 0.20725, 0.20725), vec3(1.0, 0.829, 0.829), vec3(0.296648, 0.296648, 0.296648), 11.264);
const Material RUBY = Material(vec3(0.1745, 0.01175, 0.01175), vec3(0.61424, 0.04136, 0.04136), vec3(0.727811, 0.626959, 0.626959), 76.8);
const Material TURQUOISE = Material(vec3(0.1, 0.18725, 0.1745), vec3(0.396, 0.74151, 0.69102), vec3(0.297254, 0.30829, 0.306678), 12.8);

const Material BRASS = Material(vec3(0.329412, 0.223529, 0.027451), vec3(0.780392, 0.568627, 0.113725), vec3(0.992157, 0.941176, 0.807843), 27.89743616);
const Material BRONZE = Material(vec3(0.2125, 0.1275, 0.054), vec3(0.714, 0.4284, 0.18144), vec3(0.393548, 0.271906, 0.166721), 25.6);
const Material CHROME = Material(vec3(0.25, 0.25, 0.25), vec3(0.4, 0.4, 0.4), vec3(0.774597, 0.774597, 0.774597), 76.8);
const Material COPPER = Material(vec3(0.19125, 0.0735, 0.0225), vec3(0.7038, 0.27048, 0.0828), vec3(0.256777, 0.137622, 0.086014), 12.8);
const Material GOLD = Material(vec3(0.24725, 0.1995, 0.0745), vec3(0.75164, 0.60648, 0.22648), vec3(0.628281, 0.555802, 0.366065), 51.2);
const Material SILVER = Material(vec3(0.19225, 0.19225, 0.19225), vec3(0.50754, 0.50754, 0.50754), vec3(0.508273, 0.508273, 0.508273), 51.2);

const Material BLACK_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.01, 0.01, 0.01), vec3(0.50, 0.50, 0.50), 32.0);
const Material CYAN_PLASTIC = Material(vec3(0.0, 0.1, 0.06), vec3(0.0, 0.50980392, 0.50980392), vec3(0.50196078, 0.50196078, 0.50196078), 32.0);
const Material GREEN_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.1, 0.35, 0.1), vec3(0.45, 0.55, 0.45), 32.0);
const Material RED_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.5, 0.0, 0.0), vec3(0.7, 0.6, 0.6), 32.0);
const Material WHITE_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.55, 0.55, 0.55), vec3(0.70, 0.70, 0.70), 32.0);
const Material YELLOW_PLASTIC = Material(vec3(0.0, 0.0, 0.0), vec3(0.5, 0.5, 0.0), vec3(0.60, 0.60, 0.50), 32.0);

const Material BLACK_RUBBER = Material(vec3(0.02, 0.02, 0.02), vec3(0.01, 0.01, 0.01), vec3(0.4, 0.4, 0.4), 10.0);
const Material CYAN_RUBBER = Material(vec3(0.0, 0.05, 0.05), vec3(0.4, 0.5, 0.5), vec3(0.04, 0.7, 0.7), 10.0);
const Material GREEN_RUBBER = Material(vec3(0.0, 0.05, 0.0), vec3(0.4, 0.5, 0.4), vec3(0.04, 0.7, 0.04), 10.0);
const Material RED_RUBBER = Material(vec3(0.05, 0.0, 0.0), vec3(0.5, 0.4, 0.4), vec3(0.7, 0.04, 0.04), 10.0);
const Material WHITE_RUBBER = Material(vec3(0.05, 0.05, 0.05), vec3(0.5, 0.5, 0.5), vec3(0.7, 0.7, 0.7), 10.0);
const Material YELLOW_RUBBER = Material(vec3(0.05, 0.05, 0.0), vec3(0.5, 0.5, 0.4), vec3(0.7, 0.7, 0.04), 10.0);

