shader_type canvas_item;
render_mode unshaded;

uniform float blackout_alpha : hint_range(0.0, 1.0) = 0.0;
uniform vec2 light_uv = vec2(0.5, 0.5);
uniform float light_radius : hint_range(0.0, 1.0) = 0.7;
uniform float light_direction = 1.0;
uniform float aspect = 1.777;
uniform bool light_on = false;

void fragment() {
	float a = blackout_alpha;

	if (light_on && a > 0.001) {
		vec2 delta = UV - light_uv;
		delta.x *= aspect;
		float dist = length(delta);

		if (dist < light_radius && dist > 0.001) {
			vec2 dir = vec2(light_direction, 0.0);
			float cos_val = dot(normalize(delta), dir);
			float cone_cos = 0.7; // cos(45°) - flashlight half angle

			float angle_reveal = smoothstep(cone_cos * 0.8, cone_cos, cos_val);
			float dist_reveal = 1.0 - smoothstep(light_radius * 0.4, light_radius, dist);
			a = a * (1.0 - angle_reveal * dist_reveal);
		}
	}

	COLOR = vec4(0.0, 0.0, 0.0, a);
}
