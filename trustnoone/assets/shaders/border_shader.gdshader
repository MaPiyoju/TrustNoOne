shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV;

	float edge_x = min(uv.x, 1.0 - uv.x);
	float edge_y = min(uv.y, 1.0 - uv.y);

	float edge = min(edge_x, edge_y);

	float border = 1.0 - smoothstep(0.0, 0.20, edge);

	COLOR = vec4(
		1.0,
		0.0,
		0.0,
		border * intensity
	);
}