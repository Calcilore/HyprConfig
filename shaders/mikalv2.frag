// #version 450

// layout(location = 0) in vec2 qt_TexCoord0;
// layout(location = 0) out vec4 fragColor;

// layout(std140, binding = 0) uniform buf {
//     mat4 qt_Matrix;
//     float qt_Opacity;
//     float iTime;
//     float iTimeDelta;
//     float iFrameRate;
//     float iSampleRate;
//     int iFrame;
//     vec4 iDate;
//     vec4 iMouse;
//     vec3 iResolution;
//     float iChannelTime[4];
//     vec3 iChannelResolution[4];
// } ubuf;

// layout(binding = 1) uniform sampler2D iChannel0;
// layout(binding = 1) uniform sampler2D iChannel1;
// layout(binding = 1) uniform sampler2D iChannel2;
// layout(binding = 1) uniform sampler2D iChannel3;

// vec2 fragCoord = vec2(qt_TexCoord0.x, 1.0 - qt_TexCoord0.y) * ubuf.iResolution.xy;

// #version 450

//layout(location = 0) in vec2 qt_TexCoord0;
//layout(location = 0) out vec4 fragColor;

//layout(std140, binding = 0) uniform buf {
//     mat4 qt_Matrix;
//     float qt_Opacity;
//     float ubuf.iTime;
//     float ubuf.iTimeDelta;
//     float ubuf.iFrameRate;
//     float ubuf.iSampleRate;
//     int ubuf.iFrame;
//     vec4 ubuf.iDate;
//     vec4 ubuf.iMouse;
//     vec3 ubuf.iResolution;
//     float ubuf.iChannelTime[4];
//     vec3 ubuf.iChannelResolution[4];
// } ubuf;
//
// layout(binding = 1) uniform sampler2D iChannel0;
// layout(binding = 1) uniform sampler2D iChannel1;
// layout(binding = 1) uniform sampler2D iChannel2;
// layout(binding = 1) uniform sampler2D iChannel3;
//
// vec2 fragCoord = vec2(qt_TexCoord0.x, 1.0 - qt_TexCoord0.y) * ubuf.ubuf.iResolution.xy;
//
// #version 450
//
// layout(location = 0) in vec2 qt_TexCoord0;
// layout(location = 0) out vec4 fragColor;
//
// layout(std140, binding = 0) uniform buf {
//     mat4 qt_Matrix;
//     float qt_Opacity;
//     float ubuf.ubuf.iTime;
//     float ubuf.ubuf.iTimeDelta;
//     float ubuf.ubuf.iFrameRate;
//     float ubuf.ubuf.iSampleRate;
//     int ubuf.ubuf.iFrame;
//     vec4 ubuf.ubuf.iDate;
//     vec4 ubuf.ubuf.iMouse;
//     vec3 ubuf.ubuf.iResolution;
//     float ubuf.ubuf.iChannelTime[4];
//     vec3 ubuf.ubuf.iChannelResolution[4];
// } ubuf;
//
// layout(binding = 1) uniform sampler2D iChannel0;
// layout(binding = 1) uniform sampler2D iChannel1;
// layout(binding = 1) uniform sampler2D iChannel2;
// layout(binding = 1) uniform sampler2D iChannel3;
//
// vec2 fragCoord = vec2(qt_TexCoord0.x, 1.0 - qt_TexCoord0.y) * ubuf.ubuf.ubuf.iResolution.xy;
//
// layout(location = 0) in vec2 qt_TexCoord0;
// layout(location = 0) out vec4 fragColor;
//
// layout(std140, binding = 0) uniform buf {
//     mat4 qt_Matrix;
//     float qt_Opacity;
//     float ubuf.ubuf.ubuf.iTime;
//     float ubuf.ubuf.ubuf.iTimeDelta;
//     float ubuf.ubuf.ubuf.iFrameRate;
//     float ubuf.ubuf.ubuf.iSampleRate;
//     int ubuf.ubuf.ubuf.iFrame;
//     vec4 ubuf.ubuf.ubuf.iDate;
//     vec4 ubuf.ubuf.ubuf.iMouse;
//     vec3 ubuf.ubuf.ubuf.iResolution;
//     float ubuf.ubuf.ubuf.iChannelTime[4];
//     vec3 ubuf.ubuf.ubuf.iChannelResolution[4];
// } ubuf;
//
// layout(binding = 1) uniform sampler2D iChannel0;
// layout(binding = 1) uniform sampler2D iChannel1;
// layout(binding = 1) uniform sampler2D iChannel2;
// layout(binding = 1) uniform sampler2D iChannel3;
//
// vec2 fragCoord = vec2(qt_TexCoord0.x, 1.0 - qt_TexCoord0.y) * iResolution.xy;

// funny math adam gave me, i have no clue what it does, its an easing.
float easeOutExpo(float x) {
    if (x == 1.0) {
        return 1.0;
    }
    return 1.0 - pow(2.0, -10.0 * x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalized pixel coordinates (from -0.5 to 0.5)

    vec2 uv = (fragCoord - iResolution.xy / 2.0)/iResolution.y;

    // stuff adam made about time, idk how it works gl future me.

    float time = mod(iTime * 2.0, 6.0);
    if (time > 1.0) {
        time = 2.0 - time;
    }

    // maxing out the time to 0.0? still confused.

    time = max(time, 0.0);

    // making COLOURS!!!!

    vec3 col = vec3(uv.x + 0.5, 0.5, uv.y + 0.5);

    // Pythagarym therom thingy
    // vDistance is a^2 and b^2
    // the center is the center and dis is c^2
    // now do thingy.

    vec2 center = vec2(0.0, 0.0);
    vec2 vDistance = center - uv;

    float dis = sqrt(vDistance.x*vDistance.x + vDistance.y*vDistance.y);

    // making the circles size in if.
    // creating and excluding diamond pattern from circle in else if.
    // change || to != to make checker board.

    if (dis < 0.20) {
        col = 1.5 * col;
    } else if ((int(fragCoord.x + fragCoord.y) % 32 < 16 || int(fragCoord.x - fragCoord.y - iTime * 32.0) % 32 < 16)) {
        col *= 0.6;
    }

    // outline of circle, its cool.

    if (dis < 0.205 && dis > 0.2) {
        col *= 0.1;
    }


    // face in circle!

    // eyeballs position, the mix is a lerp so it moves over time, adam helped me with it.

    bool leftEyeCheck = uv.x < -0.04 && uv.x > -0.08;
    bool rightEyeCheck = uv.x > 0.04 && uv.x < 0.08;
    bool heightOfEye = uv.y > 0.01 && uv.y < mix(0.125, 0.01, easeOutExpo(time));

    // eyeballs getting created.

    if ((leftEyeCheck || rightEyeCheck) && heightOfEye) {
        col *= 0.1;
    }

    // mouth.

    if (dis < 0.14 && dis > 0.12 && uv.y < -0.04) {
        col *= 0.1;
    }

    //colour printing.

    //this is vinette effect, just removing colour over distance.
    col *= max(1.1 - dis, 0.0);

    fragColor = vec4(col, 1.0);
}
