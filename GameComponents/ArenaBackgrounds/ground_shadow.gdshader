shader_type canvas_item;

uniform float animation_speed_x = 0.002;
uniform float animation_speed_y = 0.005;
uniform float perspective = .8;
uniform float intensity = 1;
uniform sampler2D noise_texture;

void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	
	float perspective_offset = UV.x;// * perspective;
	vec2 uv = vec2(perspective_offset + TIME * animation_speed_x, UV.y + TIME * animation_speed_y);
	vec4 noise_color = texture(noise_texture, uv);
	vec4 final_color = noise_color;
	float subtract = noise_color.r * intensity;
	final_color.rgb = vec3(
		abs(input_color.r - subtract),
		abs(input_color.g - subtract),
		abs(input_color.b - subtract)
	);
	final_color.a = input_color.a;
//	final_color.a = final_color.r;
	COLOR = final_color;
}
