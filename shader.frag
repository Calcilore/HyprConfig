#version 320 es

precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // if (v_texcoord.x < 0.1) {
    //   pixColor *= 0.1;
    // }

    fragColor = pixColor * vec4(1.0);
}

