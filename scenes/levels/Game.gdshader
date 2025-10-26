shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float blur_radius = 224.0;

// pakai hint_screen_texture agar kompatibel di Godot 4.5+
uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
    vec4 sum = vec4(0.0);
    float count = 0.0;

    for (float x = -blur_radius; x <= blur_radius; x++) {
        for (float y = -blur_radius; y <= blur_radius; y++) {
            sum += texture(screen_tex, SCREEN_UV + vec2(x, y) * 0.002);
            count += 1.0;
        }
    }

    COLOR = sum / count;
}
