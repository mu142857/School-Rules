shader_type canvas_item;

uniform float brightness : hint_range(-1.0, 1.0) = 0.10; // 亮度微调
uniform float contrast : hint_range(0.0, 3.0) = 0.70;   // 对比度（1.0是原始，小于1.0降低对比度）
uniform float saturation : hint_range(0.0, 2.0) = 1.0; // 饱和度

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec3 color = tex.rgb;

    // 调整对比度 (以0.5为中心缩放)
    color = (color - 0.5) * contrast + 0.5;

    // 调整亮度
    color += brightness;

    // 调整饱和度
    float grey = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(grey), color, saturation);

    COLOR = vec4(color, tex.a);
}