shader_type canvas_item;

// Mode: 1 = Overdrive (Gold-Orange), 2 = Fusion (Violet-Platinum)
uniform int aura_mode = 1;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a < 0.1) {
		COLOR = vec4(0.0);
	} else {
		vec3 c0 = (aura_mode == 1) ? vec3(0.96, 0.48, 0.08) : vec3(0.62, 0.26, 0.95);
		vec3 c1 = (aura_mode == 1) ? vec3(1.00, 0.74, 0.20) : vec3(0.80, 0.52, 1.00);
		vec3 c2 = (aura_mode == 1) ? vec3(1.00, 0.90, 0.48) : vec3(0.92, 0.80, 1.00);
		vec3 c3 = (aura_mode == 1) ? vec3(1.00, 0.98, 0.88) : vec3(1.00, 0.98, 1.00);

		if (c.r > 0.95) {
			COLOR = vec4(c3, c.a);
		} else if (c.r > 0.80) {
			COLOR = vec4(c2, c.a);
		} else if (c.r > 0.55) {
			COLOR = vec4(c1, c.a);
		} else {
			COLOR = vec4(c0, c.a);
		}
	}
}
