// #version 330 core
// go to line 221 to change the base of the clock
// you can only go up to base 10, later bases work but the digits
// will be blank because there are only characters for 0-9
// 
// go to line 324 and 330 to change the colors
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
//
// afterwards, just add it to the switch statement near the bottom


in vec2 texcoord;

out vec4 color;

uniform vec2 u_resolution;
uniform float u_time;

const float PI = 3.1415926535897932384626433832795;
const float TAU = PI*2.0;

vec2 uv = vec2(0.0);

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

float distanceToLineSqr(vec2 a, vec2 b, vec2 pos) {
    float lengthSqr = distanceSquared(a, b);
    
    // if a and b are the same
    if (lengthSqr == 0.0) return distance(a, pos);

    float t = clamp(dot(pos - a, b - a) / lengthSqr, 0.0, 1.0);
    vec2 projection = a + t * (b - a);  // Projection falls on the segment
    return distanceSquared(pos, projection);
}

float distanceToCircle(vec2 center, float radius, vec2 pos) {
    float dis = distance(center, pos);
    return abs(dis-radius);
}

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
    return line(pos, -offset, offset, scale);// ||
        //line(pos, -offset, topTip, scale) ||
        //line(pos, offset-bottom, offset+bottom, scale);
}

bool two(vec2 pos, float scale) {
    return line(pos, vec2(-0.05, 0.0), vec2(0.05, 0.0), scale);

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

vec3 col = vec3(1.0); // used for debugging
const float COLON_THICKNESS = 0.015;

int balancedTernaryDigit(float number, int digit) {
    // Find the highest required digit.
    int highestDigit = int(ceil(log(abs(number) * 2.0 + 1.0) / log(3.0))) - 1;

    // We need to process all digits from highestDigit down to `digit`.
    float remaining = number;

    for (int i = highestDigit; i >= digit; i--) {
        float place = pow(3.0, float(i));

        // Find the nearest balanced-ternary digit.
        float value = remaining / place;
        int d;

        if (value >= 0.5) {
            if (value > 1.5) {
                d = -1;
            } else {
                d = 1;
            }
        } else if (value <= -0.5) {
            if (value < -1.5) {
                d = 1;
            } else {
                d = -1;
            }
        } else {
            d = 0;
        }

        // Subtract the value represented by this digit.
        remaining -= float(d) * place;

        // We use 2 to represent -1.
        if (i == digit) {
            return d == -1 ? 2 : d;
        }
    }

    return 0;
}

bool doNumbers(vec2 uv) {
    float width = iResolution.x/iResolution.y;

    // float base = float(abs((int(iDate.w)) / 60 / 60) % 9 + 2);
    float base = 3.0;
    
    int digitsMiSe = max(1, int(ceil(logx(base, 2.0 * 60.0 + 1.0))));
    // int digitsHo = max(1, int(ceil(logx(base, 2.0 * 24.0 + 1.0))));;
    int digitsHo = digitsMiSe;

    float numbersWidth = float(digitsMiSe * 3) * 0.245 + 0.05 * 2.0 + 0.5;

    float scale = min(width / numbersWidth, 2.0);
    float digitWidth = 0.245 * scale;
    float padding = 0.05 * scale;

    float halfMinuteWidth = float(digitsMiSe) * digitWidth * 0.5;
    float hourWidth = float(digitsHo) * digitWidth;

    // hours, minutes, seconds
    float[] numbers = float[](floor(iDate.w / 60.0 / 60.0), mod(floor(iDate.w / 60.0), 60.0), mod(floor(iDate.w), 60.0));
    float[] numberPositions = float[](-halfMinuteWidth - hourWidth - padding, -halfMinuteWidth, halfMinuteWidth + padding);
    
    int digits = digitsMiSe;
    float number;
    float startPos;

    // which number to render
    {
        if (uv.x < -halfMinuteWidth) { // Hours
            // Hours Colon
            if (uv.x > -halfMinuteWidth - padding) {
                vec2 localUv = vec2(uv.x - (-halfMinuteWidth - padding) - padding / 2.0, uv.y);
                return distance(localUv, vec2(0.0, 0.05 * scale)) < COLON_THICKNESS * scale || distance(localUv, vec2(0.0, -0.05 * scale)) < COLON_THICKNESS * scale;
            }

            col = vec3(1.0, 0.0, 0.0);
            // OOB
            if (uv.x < -halfMinuteWidth - hourWidth - padding) {
                return false;
            }

            number = numbers[0];
            startPos = numberPositions[0];
            digits = digitsHo;
        } else if (uv.x <= halfMinuteWidth) { // Minutes
            col = vec3(0.0, 1.0, 0.0);
            number = numbers[1];
            startPos = numberPositions[1];
        } else { // Seconds
            // Seconds Colon
            if (uv.x < halfMinuteWidth + padding) {
                vec2 localUv = vec2(uv.x - (halfMinuteWidth + padding) + padding / 2.0, uv.y);
                return distance(localUv, vec2(0.0, 0.05 * scale)) < COLON_THICKNESS * scale || distance(localUv, vec2(0.0, -0.05 * scale)) < COLON_THICKNESS * scale;
            }

            col = vec3(0.0, 0.0, 1.0);
            // OOB
            if (uv.x > halfMinuteWidth * 3.0 + padding) {
                return false;
            }

            number = numbers[2];
            startPos = numberPositions[2];
        }
    }

    int digitIndex = digits-1 - int((uv.x-startPos)/digitWidth);

    // the value of the digit being rendered
    // decimal digits dont round down properly
    // so i add 0.0001 to them, it fixes the rounding issues
    //float digitF = number / pow(base, float(digitIndex));
    //int digit = int(digitIndex < 0 ? (digitF+0.0001) : digitF);
    //digit = digit % int(base);
    int digit = balancedTernaryDigit(number, digitIndex);
    
    // draw the digit
    vec2 drawPos = vec2(digitWidth*(float(digits-digitIndex)-0.5) + startPos, 0.0);
    // float scale = min(digitWidth*4.0, 4.0);
    
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

    return on;
}

void mainImage(out vec4 color, in vec2 fragCoord) {
    // pixel coordinates: -0.5y is top +0.5 is bottom
    // if square: 0.0x is left, +1.0x is right
    // if not square right of screen is determined by aspect
    // ratio, but y stays the same.
    uv = (fragCoord - iResolution.xy / 2.0)/iResolution.y;
    uv.y = -uv.y; // make +y down
    // uv = ((texcoord / iResolution.xy) + vec2(0.0, -0.5)) * vec2(1.0, -1.0);
    
    // default background color
    vec3 col1 = vec3(0.1);
    
    bool on = doNumbers(uv);
    
    if (on) {
        // number color
        col1 = vec3(1.0);
    }
    
    color = vec4(col1, 1.0);
}

