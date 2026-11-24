shader_type canvas_item;

// Mode: 0 = Base (no recolor), 1 = Overdrive (Gold), 2 = Fusion (Violet-Platinum)
uniform int transform_mode = 0;
uniform float hair_uv_cutoff = 0.56;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a < 0.1 || transform_mode == 0) {
		COLOR = c;
	} else {
		float luma = (c.r + c.g + c.b) / 3.0;
		// Restrict hair recolor to upper head zone & preserve darkest eye/outline pixels (luma >= 0.10)
		bool is_hair_region = UV.y < hair_uv_cutoff;
		bool is_dark_navy_hair = (c.b - c.r >= 0.03) && luma >= 0.10 && luma < 0.36 && (c.g - c.r < 0.14);
		if (is_hair_region && is_dark_navy_hair) {
			float t = clamp((luma - 0.10) / 0.24, 0.0, 1.0);
			if (transform_mode == 1) {
				vec3 dark_gold = vec3(0.55, 0.24, 0.02);
				vec3 bright_gold = vec3(1.0, 0.88, 0.22);
				COLOR = vec4(mix(dark_gold, bright_gold, t), c.a);
			} else {
				vec3 dark_violet = vec3(0.32, 0.14, 0.52);
				vec3 bright_plat = vec3(0.92, 0.84, 1.0);
				COLOR = vec4(mix(dark_violet, bright_plat, t), c.a);
			}
		} else {
			COLOR = c;
		}
	}
}
