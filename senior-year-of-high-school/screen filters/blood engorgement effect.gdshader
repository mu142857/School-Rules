shader_type canvas_item;

// ============ 基础参数 ============
uniform float intensity : hint_range(0.0, 1.0) = 0.15;  // 整体强度（已降低）
uniform vec3 blood_color : source_color = vec3(0.6, 0.02, 0.05);  // 血丝颜色
uniform float speed : hint_range(0.0, 1.0) = 0.45;  // 蠕动速度
uniform float vein_scale : hint_range(1.0, 20.0) = 8.0;  // 血丝密度
uniform float vein_sharpness : hint_range(1.0, 5.0) = 2.5;  // 血丝锐利度

// ============ 心跳参数 ============
uniform float heartbeat_rate : hint_range(0.3, 2.0) = 1.6;  // 心跳频率
uniform float heartbeat_strength : hint_range(0.0, 1.0) = 1.5;  // 脉动强度

// ============ 边缘扩张参数 ============
uniform float edge_start : hint_range(0.0, 0.5) = 0.1;  // 血丝起始位置
uniform float edge_softness : hint_range(1.0, 3.0) = 1.5;  // 边缘柔和度
uniform float expand_amount : hint_range(0.0, 0.5) = 0.15;  // 心跳扩张程度

// ============ 透明度参数 ============
uniform float alpha_boost : hint_range(1.0, 3.0) = 1.2;  // 透明度增强（已降低）
uniform float alpha_min : hint_range(0.0, 0.5) = 0.0;  // 最低透明度

// ============ 动态效果参数 ============
uniform float zoom_strength : hint_range(0.0, 0.08) = 0.07;  // 心跳缩放强度（已增大）
uniform float distort_strength : hint_range(0.0, 0.03) = 0.01;  // 边缘扭曲强度
uniform float chromatic_strength : hint_range(0.0, 0.02) = 0.005;  // 色差强度
uniform float vignette_strength : hint_range(0.0, 0.5) = 0.2;  // 边缘变暗程度

// 屏幕纹理
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 coord) {
    return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
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

float fbm(vec2 coord, int octaves) {
    float value = 0.0;
    float scale = 0.5;
    for(int i = 0; i < octaves; i++) {
        value += noise(coord) * scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value;
}

// 心跳波形
float heartbeat(float time) {
    float t = fract(time * heartbeat_rate);
    float beat1 = exp(-pow((t - 0.1) * 12.0, 2.0));
    float beat2 = exp(-pow((t - 0.25) * 12.0, 2.0)) * 0.5;
    return beat1 + beat2;
}

// 生成血丝纹理
float veins(vec2 uv, float time) {
    vec2 coord = uv * vein_scale;
    vec2 warp1 = vec2(
        fbm(coord + vec2(0.0, 0.0) + time * 0.7, 4),
        fbm(coord + vec2(5.2, 1.3) + time * 0.5, 4)
    );
    vec2 warp2 = vec2(
        fbm(coord + warp1 * 2.5 + vec2(1.7, 9.2) + time * 0.3, 4),
        fbm(coord + warp1 * 2.5 + vec2(8.3, 2.8) + time * 0.4, 4)
    );
    float vein = fbm(coord + warp2 * 2.0, 5);
    vein = pow(vein, vein_sharpness);
    vein = smoothstep(0.05, 0.4, vein);
    return vein;
}

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center) * 2.0;
    
    // 获取心跳值
    float beat = heartbeat(TIME);
    float beat_scaled = beat * heartbeat_strength * intensity;
    
    // ============ 屏幕缩放效果 ============
    // 心跳时画面先放大再缩回
    // zoom < 1 时画面放大，zoom > 1 时画面缩小
    vec2 zoom_uv = UV;
    float zoom = 1.0 - beat_scaled * zoom_strength;  // 改成减法，心跳时放大
    zoom_uv = center + (UV - center) * zoom;
    
    // ============ 边缘扭曲效果 ============
    vec2 distort_uv = zoom_uv;
    vec2 distort_offset = vec2(
        fbm(UV * 8.0 + vec2(TIME * 0.3, 0.0), 3) - 0.5,
        fbm(UV * 8.0 + vec2(0.0, TIME * 0.3), 3) - 0.5
    );
    float distort_mask = smoothstep(0.2, 0.8, dist);
    distort_uv += distort_offset * distort_strength * distort_mask * (1.0 + beat_scaled * 3.0);
    
    // ============ 色差效果 ============
    float chromatic = chromatic_strength * beat_scaled * dist;
    vec2 dir = normalize(UV - center);
    
    float r = texture(screen_texture, distort_uv + dir * chromatic).r;
    float g = texture(screen_texture, distort_uv).g;
    float b = texture(screen_texture, distort_uv - dir * chromatic).b;
    vec3 screen_color = vec3(r, g, b);
    
    // ============ 暗角效果 ============
    float vignette = 1.0 - dist * vignette_strength * (1.0 + beat_scaled * 2.0);
    vignette = clamp(vignette, 0.5, 1.0);
    screen_color *= vignette;
    
    // ============ 血丝层 ============
    float edge_expand = beat_scaled * expand_amount;
    float edge_mask = smoothstep(edge_start - edge_expand, 1.0, dist);
    edge_mask = pow(edge_mask, edge_softness);
    
    float vein = veins(UV, TIME * speed);
    
    // 心跳时血丝变化大幅降低（从0.8改成0.15）
    float beat_intensity = 1.0 + beat_scaled * 0.4;
    
    float alpha = vein * edge_mask * intensity * beat_intensity * alpha_boost;
    alpha = max(alpha, alpha_min * edge_mask * intensity);
    alpha = clamp(alpha, 0.0, 1.0);
    
    // 心跳时颜色变化大幅降低（从0.4改成0.08）
    vec3 vein_color = blood_color * (1.0 + beat * 0.3);
    
    // ============ 混合输出 ============
    vec3 final_color = mix(screen_color, vein_color, alpha);
    
    COLOR = vec4(final_color, 1.0);
}