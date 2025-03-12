// Affine transformation matrices
// Translation
mat3 translate(vec2 delta) {
    mat3 T = mat3(1.0);
    
    T[2] = vec3(delta, 1.0);

    return T;
}

// Scale matrix
mat3 scale(vec2 scaleFactors) {
    mat3 S = mat3(1.0);
    
    S[0][0] = scaleFactors.x;
    S[1][1] = scaleFactors.y;
    
    return S;
}

// Rotation matrix from angle (it rotates around the origin)
mat3 rotate(float angle) {
    mat3 R = mat3(1.0);
    
    float c = cos(angle);
    float s = sin(angle);
    
    R[0][0] = c;
    R[1][1] = c;
    R[0][1] = s;
    R[1][0] = -s;
    
    return R;
}

// Get world coordinates from the traditional inputs to the shader
vec3 getWorldCoordinates(vec2 fragCoord, vec3 iResolution) {
    
    float aspectRatio = iResolution.x / iResolution.y;
    
    vec2 scaleFactor = 
        iResolution.x > iResolution.y ? vec2(aspectRatio, 1.0) : vec2(1.0, 1.0 / aspectRatio);
        
    vec2 world = scaleFactor * (2.0 * (fragCoord/iResolution.xy) - vec2(1.0));
    
    return vec3(world, 1.0);
}

// Signed distance funcitons
// These are not necesarlly "real sdf's", they only garantee the sign
// They were adapted from these: https://iquilezles.org/articles/distfunctions2d/

float dot2 (vec2 x) {
	return dot(x, x);
}

float dot2 (vec3 x) {
	return dot(x, x);
}

// Circle that starts as radious 1 centerd at the origin
// And it is transformed by T, before return
float sdfCircle(vec3 fragCoord, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    return dot(point.xy, point.xy) - 1.0;
}

// Square that starts of side 2 centerd at the origin
// And it is transformed by T, before return
float sdfSquare(vec3 fragCoord, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    return max(abs(point.x), abs(point.y)) - 1.0;
}

// Trapezoid aligned with the y axis.
// It takes the height and the sizes of the two basis as paramters
// And it is transformed by T, before return
float sdTrapezoid(vec3 fragCoord, float topSide, float downSide, float height, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    vec2 k1 = vec2(topSide, height);
    vec2 k2 = vec2(topSide - downSide, 2.0 * height);
    point.x = abs(point.x);
    vec2 ca = vec2(point.x - min(point.x, (point.y < 0.0) ? downSide : topSide), abs(point.y) - height);
    vec2 cb = point - k1 + k2 * clamp(dot(k1 - point, k2) / dot2(k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot2(ca), dot2(cb)));
}

// EquilateralTriangle center at the origin with one side parallel to the x-axis
// And it is transformed by T, before return
float sdEquilateralTriangle(vec3 fragCoord, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    const float k = sqrt(3.0);
    point.x = abs(point.x) - 1.0;
    point.y = point.y + 1.0 / k;
    if (point.x + k * point.y > 0.0) {
	    point = vec2(point.x - k * point.y, -k * point.x - point.y) / 2.0;
    }
    point.x -= clamp(point.x, -2.0, 0.0);
    return -length(point) * sign(point.y);
}

// Isosceles center at the origin with one side parallel to the x-axis
// And it is transformed by T, before return
float sdTriangleIsosceles(vec3 fragCoord, vec2 q, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    point.x = abs(point.x);
    vec2 a = point - q * clamp(dot(point, q) / dot(q, q), 0.0, 1.0);
    vec2 b = point - q * vec2(clamp(point.x / q.x, 0.0, 1.0), 1.0);
    float s = -sign(q.y);
    vec2 d = min(vec2(dot(a, a), s * (point.x * q.y - point.y * q.x)),
                 vec2(dot(b, b), s * (point.y - q.y)));
    return -sqrt(d.x) * sign(d.y);
}


// Triangle whose vertex are p0, p1 and p2
// And it is transformed by T, before return
float sdTriangle(vec2 fragCoord, vec2 p0, vec2 p1, vec2 p2, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
    vec2 v0 = point - p0, v1 = point - p1, v2 = point - p2;
    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0 );
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0 );
    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
                     vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
                     vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
    return -sqrt(d.x) * sign(d.y);
}

// Heart like shape centered at the origin
// And it is transformed by T, before return
float sdHeart(vec2 fragCoord, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
    
    point.x = abs(point.x);

    if(point.y + point.x > 1.0) {
    	return sqrt(dot2(point - vec2(0.25, 0.75))) - sqrt(2.0) / 4.0;
    }
        
    return sqrt(min(dot2(point - vec2(0.00, 1.00)),
                    dot2(point - 0.5 * max(point.x + point.y, 0.0)))) * sign(point.x - point.y);
}

// Cross centered at the origin
// And it is transformed by T, before return
float sdCross(vec2 fragCoord, vec2 b, float r, mat3 T) {
	vec2 point = (inverse(T) * fragCoord).xy;
	
    point = abs(point); point = (point.y > point.x) ? point.yx : point.xy;
    vec2  q = point - b;
    float k = max(q.y, q.x);
    vec2  w = (k > 0.0) ? q : vec2(b.y - point.x, -k);
    return sign(k) * length(max(w, 0.0)) + r;
}

// Constructive Solid Geometry operations
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

//Math constants
const float Pi  = 3.141592653;
const float Tau = 6.283185307;

// Color constants
const vec3 White	     = vec3(1.0,  1.0,  1.0);
const vec3 Silver	     = vec3(0.75, 0.75, 0.75);
const vec3 Gray	         = vec3(0.5,  0.5,  0.5);
const vec3 Black	     = vec3(0.0,  0.0,  0.0);
const vec3 Red	         = vec3(1.0,  0.0,  0.0);
const vec3 Maroon	     = vec3(0.5,  0.0,  0.0);
const vec3 Yellow	     = vec3(1.0,  1.0,  0.0);
const vec3 Olive	     = vec3(0.5,  0.5,  0.0);
const vec3 Lime	         = vec3(0.0,  1.0,  0.0);
const vec3 Green	     = vec3(0.0,  0.5,  0.0);
const vec3 Aqua	         = vec3(0.0,  1.0,  1.0);
const vec3 Cyan          = Aqua;
const vec3 Teal	         = vec3(0.0,  0.5,  0.5);
const vec3 Blue	         = vec3(0.0,  0.0,  1.0);
const vec3 Navy	         = vec3(0.0,  0.0,  0.5);
const vec3 Fuchsia	     = vec3(1.0,  0.0,  1.0);
const vec3 Magenta       = Fuchsia;
const vec3 Purple	     = vec3(0.5,  0.0,  0.5);
const vec3 Pink	         = vec3(1.0,  0.75, 0.8);
const vec3 HotPink	     = vec3(1.0,  0.41, 0.71);
const vec3 Crimson	     = vec3(0.86, 0.8,  0.24);
const vec3 Salmon	     = vec3(0.98, 0.5,  0.45);
const vec3 OrangeRed     = vec3(1.0,  0.27, 0.0);
const vec3 Orange	     = vec3(1.0,  0.65, 0.0);
const vec3 Coral	     = vec3(1.0,  0.5,  0.31);
const vec3 Gold	         = vec3(1.0,  0.84, 0.0);
const vec3 Khaki	     = vec3(0.94, 0.9,  0.55);
const vec3 Sienna	     = vec3(0.63, 0.32, 0.18);
const vec3 Chocolate     = vec3(0.82, 0.41, 0.12);
const vec3 Peru	         = vec3(0.80, 0.52, 0.25);
const vec3 DarkViolet    = vec3(0.58, 0.0,  0.83);
const vec3 Indigo	     = vec3(0.29, 0.0,  0.51);
const vec3 DeepSkyBlue   = vec3(0.0,  0.75, 1.0);
const vec3 LightSkyBlue	 = vec3(0.53, 0.81, 0.98);
const vec3 LightSeaGreen = vec3(0.13, 0.70, 0.67);
const vec3 LimeGreen	 = vec3(0.2,  0.8,  0.2);
const vec3 LawnGreen	 = vec3(0.49, 0.99, 0.0);
const vec3 Ivory	     = vec3(1.0,  1.0,  0.94);
const vec3 Plum	         = vec3(0.87, 0.63,  0.87);
const vec3 Bisque	     = vec3(1.0,  0.89,  0.77);
const vec3 DarkSeaGreen	 = vec3(0.56, 0.74,  0.56);
const vec3 WhiteSmoke	 = vec3(0.96, 0.96,  0.96);

