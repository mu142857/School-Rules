shader_type canvas_item;

// ============ 基础参数 ============
uniform vec3 color : source_color = vec3(0.7, 0.65, 1.0);
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 0.4;

// ============ 形态参数 ============
uniform float cloud_scale : hint_range(1.0, 20.0) = 6.0;
uniform float softness : hint_range(0.0, 1.0) = 0.6;
uniform int OCTAVES = 5;

// ============ 动态参数 ============
uniform float speed : hint_range(0.0, 2.0) = 0.5;  // 范围和默认值增大
uniform float drift_x : hint_range(-2.0, 2.0) = 0.4;  // 范围增大
uniform float drift_y : hint_range(-2.0, 2.0) = -0.2;
uniform float swirl_amount : hint_range(0.0, 2.0) = 1.2;
uniform float morph_speed : hint_range(0.0, 2.0) = 0.6;  // 范围和默认值增大

float rand(vec2 coord) {
    return fract(sin(dot(coord, vec2(56.0, 78.0)) * 1000.0) * 1000.0);
}

float noise(vec2 coord) {
    vec2 i = floor(coord);
    vec2 f = fract(coord);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    vec2 cubic = f * f * (3.0 - 2.0 * f);
    return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord) {
    float value = 0.0;
    float scale = 0.5;
    float total = 0.0;
    for (int i = 0; i < OCTAVES; i++) {
        value += noise(coord) * scale;
        total += scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value / total;
}

void fragment() {
    vec2 coord = UV * cloud_scale;
    
    // ============ 时间变量，不再重复乘 speed ============
    float t = TIME * speed;
    float t_morph = TIME * morph_speed;
    
    // ============ 多层飘动 ============
    // 整体方向性飘动（直接用 t，不再乘 speed）
    vec2 drift = vec2(drift_x, drift_y) * t;
    
    // 第一层：慢速大范围扭曲
    vec2 warp1 = vec2(
        fbm(coord * 0.5 + t_morph * 0.7 + vec2(0.0, 0.0)),
        fbm(coord * 0.5 + t_morph * 0.5 + vec2(5.2, 1.3))
    ) * swirl_amount;
    
    // 第二层：中速旋涡（加入时间）
    vec2 warp2 = vec2(
        fbm(coord + warp1 + vec2(1.7, 9.2) + t * 0.3),
        fbm(coord + warp1 + vec2(8.3, 2.8) + t * 0.4)
    ) * swirl_amount * 0.5;
    
    // 第三层：快速细节波动
    vec2 warp3 = vec2(
        fbm(coord * 2.0 + t * 1.2),
        fbm(coord * 2.0 + t * 0.9 + vec2(3.1, 7.4))
    ) * 0.4;
    
    // 合并所有层
    float cloud = fbm(coord + warp1 + warp2 + warp3 + drift);
    
    // ============ 柔和处理 ============
    cloud = smoothstep(0.2 - softness * 0.2, 0.7 + softness * 0.3, cloud);
    
    // 密度变化也加入时间
    float density_variation = fbm(coord * 0.3 + t_morph * 0.3);
    cloud *= 0.7 + density_variation * 0.5;
    
    // ============ 最终透明度 ============
    float final_alpha = cloud * alpha_multiplier;
    
    COLOR = vec4(color, final_alpha);
}