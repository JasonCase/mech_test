shader_type spatial;
render_mode blend_mix;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float mask = 1. - step(0.5, dist);
	vec3 col = vec3(0); // white outside, black inside
	ALBEDO = col;
	ALPHA = mask; // optional: make outside transparent
}
