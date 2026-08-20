// go to line 234 to change the number (iTime means time in seconds)
// and go to line 235 to change the base you count in
// you can only go up to base 10, later bases work but the digits
// will be blank because i only have 0-9
// 
// if you want to make new digits just add a new function next
// to the others, then build the digit using the three 
// shape check funcitons:
//
// line(PASS_POS, offset_point_a, offset_point_b, PASS_SCALE)
//     creates a line from point A to point B
// 
// cir(PASS_POS, offset, radius, PASS_SCALE)
//     creates a hollow circle from the center point (offset)
//     and with a radius of radius
// 
// arc(PASS_POS, offset, radius, start, end, PASS_SCALE)
//     creates an arc from the center point (offset)
//     with radius of radius and starting from start and going
//     to end, start and end are in radians
//     (0 being no rotation, TAU being 1 rotation)
//     and rotation must not be negative

const float PI = 3.1415926535897932384626433832795;
const float TAU = PI*2.0;

vec2 uv;

// |------------------|
// |       Util       |
// |------------------|

float logx(float x, float n) {
    float logBaseX = log2(x);
    return log2(n) / logBaseX;
}

vec2 angleRadToPoint(float angle, float radius) {
    return vec2(radius*sin(PI-angle), radius*cos(PI-angle));
}

bool isInAngle(float start, float end, float angle) {
    if (start < end) { // normal
        return angle < start || angle > end;
    }
    
    // passes through 0 point, invert?
    return angle < start && angle > end;
}

// |----------------------|
// |  Distance Functions  |
// |----------------------|

float distanceSquared(vec2 a, vec2 b) {
    vec2 disVec = a-b;
    return disVec.x*disVec.x + disVec.y*disVec.y;
}

// i don't understand this code
float distanceToLineSqr(vec2 a, vec2 b, vec2 pos) {
    float lengthSqr = distanceSquared(a, b);
    
    // if a and b are the same
    if (lengthSqr == 0.0) return distance(a, pos);
    
    // (i didn't write this comment)
    // Consider the line extending the segment, parameterized as a + t (b - a).
    // We find projection of point p onto the line. 
    // It falls where t = [(pos-a) . (b-a)] / |b-a|^2
    // We clamp t from [0,1] to handle points outside the segment ab.
    float t = clamp(dot(pos - a, b - a) / lengthSqr, 0.0, 1.0);
    vec2 projection = a + t * (b - a);  // Projection falls on the segment
    return distanceSquared(pos, projection);
}

float distanceToCircle(vec2 center, float radius, vec2 pos) {
    float dis = distance(center, pos);
    return abs(dis-radius);
}

// i do understand this code
float distanceToArc(vec2 center, float radius, float start, float end, vec2 pos) {
    // get angle to point from center
    vec2 sub = pos - center;
    float angle = PI-atan(sub.x, sub.y); // 0-TAU clockwise
    
    // if outside of arc bounds, get distance from closest end
    // this gives the arc rounded edges
    if (isInAngle(start, end, angle)) {
        vec2 startPos = center + angleRadToPoint(start, radius);
        vec2 endPos = center + angleRadToPoint(end, radius);
    
        float dis = min(distanceSquared(startPos, pos),
            distanceSquared(endPos, pos));
        return sqrt(dis);
    }
    
    // this is the actual arc
    return distanceToCircle(center, radius, pos);
}

// |-----------------------|
// |  Inside Shape Checks  |
// |-----------------------|

bool line(vec2 origin, vec2 a, vec2 b, float scale) {
    return distanceToLineSqr(origin+a*scale, origin+b*scale, uv) 
        < pow(0.01*scale, 2.0);
}

bool cir(vec2 origin, vec2 center, float radius, float scale) {
    return distanceToCircle(origin+center*scale, radius*scale, uv) < 0.01*scale;
}

bool arc(vec2 origin, vec2 center, float radius, float start, float end, float scale) {
    return distanceToArc(origin+center*scale, radius*scale, start, end, uv) < 0.01*scale;
}

// |---------------------------------------------------|
// |  The digits, made up of lines, circles, and arcs  |
// |---------------------------------------------------|

bool zero(vec2 pos, float scale) {
    const float offsetF = 0.05;
    const vec2 offset = vec2(0.0, offsetF);
    
    // top arc, bottom arc, left wall, right wall
    return arc(pos, -offset, 0.05, TAU*0.75, TAU*0.25, scale) ||
        arc(pos, +offset, 0.05, TAU*0.25, TAU*0.75, scale) ||
        line(pos, vec2(-offsetF, -offsetF), vec2(-offsetF, offsetF), scale) ||
        line(pos, vec2(offsetF, -offsetF), vec2(offsetF, offsetF), scale);
}

bool one(vec2 pos, float scale) {
    const vec2 offset = vec2(0.0, 0.1);
    const vec2 topTip = (-offset)+vec2(-0.05, 0.05);
    const vec2 bottom = vec2(0.05, 0.0);
    
    // stick, top bit, base
    return line(pos, -offset, offset, scale) ||
        line(pos, -offset, topTip, scale) ||
        line(pos, offset-bottom, offset+bottom, scale);
}

bool two(vec2 pos, float scale) {
    // very magic numbers
    const vec2 offset = vec2(-0.0028, -0.05);
    const float radius = 0.0535;

    // top bit, stick, base
    return arc(pos, offset, radius, TAU*0.83, TAU*0.35, scale) || 
        line(pos, offset+angleRadToPoint(TAU*0.35, radius), vec2(-0.05, 0.1), scale) ||
        line(pos, vec2(-0.05, 0.1), vec2(0.05, 0.1), scale);
}

bool three(vec2 pos, float scale) {
    const vec2 offsetT = vec2(0.0, -0.05);
    const vec2 offsetB = offsetT*vec2(1.0, -1.0);
    const float radius = 0.05;
    const float outAngle = 0.85;
    const float inAngle = 0.05;

    // top, bottom
    return arc(pos, offsetT, radius, TAU*outAngle, PI*(1.0-inAngle), scale) ||
        arc(pos, -offsetT, radius, PI*inAngle, PI+TAU*(1.0-outAngle), scale);
}

bool four(vec2 pos, float scale) {
    const vec2 offsetB = vec2(0.02, 0.1);
    const vec2 offsetT = vec2(offsetB.x, -offsetB.y);
    const vec2 leftPoint = vec2(-0.05, 0.05);
    const vec2 rightPoint = vec2(-leftPoint.x, leftPoint.y);
    
    // stick, topleft bit, bottom bit
    return line(pos, offsetB, offsetT, scale) ||
        line(pos, offsetT, leftPoint, scale) ||
        line(pos, leftPoint, rightPoint, scale);
}


// i should have used more constants
bool five(vec2 pos, float scale) {
    const float radius = 0.06;
    
    // top part, left part, arc
    return line(pos, vec2(0.05, -0.1), vec2(-0.05, -0.1), scale) ||
        line(pos, vec2(-0.05, -0.1), vec2(-0.05, -0.01), scale) ||
        arc(pos, vec2(-0.01, 0.04), radius, PI+TAU*(1.0-0.615), TAU*0.615, scale);
}

bool six(vec2 pos, float scale) {
    // top, stick, bottom
    return arc(pos, vec2(0.0, -0.05), 0.05, TAU*0.75, TAU*0.125, scale) ||
        line(pos, vec2(-0.05, -0.05), vec2(-0.05, 0.05), scale) ||
        cir(pos, -vec2(0.0, -0.05), 0.05, scale);
}

bool seven(vec2 pos, float scale) {
    // top, stick
    return line(pos, vec2(0.05, -0.1), vec2(-0.05, -0.1), scale) ||
        line(pos, vec2(0.05, -0.1), vec2(-0.05, 0.1), scale);
}

bool eight(vec2 pos, float scale) {
    return cir(pos, vec2(0.0, -0.05), 0.05, scale) ||
        cir(pos, vec2(0.0, 0.05), 0.05, scale);
}

bool nine(vec2 pos, float scale) {
    return arc(pos, vec2(0.0, 0.05), 0.05, TAU*0.25, TAU*(0.75-0.125), scale) ||
        line(pos, vec2(0.05, -0.05), vec2(0.05, 0.05), scale) ||
        cir(pos, -vec2(0.0, 0.05), 0.05, scale);
}

// |-----------------------------------------------------------|
// |  Here we calculate the digits and draw the correct digit  |
// |-----------------------------------------------------------|

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // pixel coordinates: -0.5y is top +0.5 is bottom
    // if square: 0.0x is left, +1.0x is right
    // if not square right of screen is determined by aspect
    // ratio, but y stays the same.
    uv = (fragCoord - iResolution.xy / 2.0)/iResolution.y;
    uv.y = -uv.y; // make +y down (my brain cant handle +y being up)
    float width = iResolution.x/iResolution.y;
    uv.x += width/2.0;
    
    // default background color
    vec3 col = vec3(0.1);
    
    // number to render
    float number = iTime;
    float base = 3.0;
    
    // how many digits are in this number
    int digits = int(logx(base, float(number)))+1;
    
    // which digit this pixel is rendering
    float digitSize = width/float(digits+2);
    int digitIndex = digits-1 - int(uv.x/digitSize);

    // the value of the digit being rendered
    // decimal digits dont round down properly
    // so i add 0.0001 to them, it fixes the rounding issues
    float digitF = number / pow(base, float(digitIndex));
    int digit = int(digitIndex < 0 ? (digitF+0.0001) : digitF);
    digit = digit % int(base);
    
    // draw the digit
    vec2 drawPos = vec2(digitSize*(float(digits-digitIndex)-0.5), 0.0);
    float scale = min(digitSize*4.0, 4.0);
    
    // decimal point
    if (digitIndex == 0 && distance(uv, drawPos+vec2(0.11, 0.1)*scale) < 0.0125*scale) {
        fragColor = vec4(1.0);
        return;
    }
    
    // draw the correct digit
    bool on = false;
    switch (digit) {
        case 0: on = zero(drawPos, scale); break;
        case 1: on = one(drawPos, scale); break;
        case 2: on = two(drawPos, scale); break;
        case 3: on = three(drawPos, scale); break;
        case 4: on = four(drawPos, scale); break;
        case 5: on = five(drawPos, scale); break;
        case 6: on = six(drawPos, scale); break;
        case 7: on = seven(drawPos, scale); break;
        case 8: on = eight(drawPos, scale); break;
        case 9: on = nine(drawPos, scale); break;
    }
    
    if (on) {
        col = vec3(1.0);
    }
    
    fragColor = vec4(col, 1.0);
}
