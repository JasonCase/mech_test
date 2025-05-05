shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 pres = vec2(320.,240.);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 psize = SCREEN_PIXEL_SIZE*(3.);
	vec2 center_uv = floor(uv / psize) * psize;

	COLOR = textureLod(screen_texture, center_uv, 0.0);
}