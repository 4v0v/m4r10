vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coord)
{
    vec4 texture_color = Texel(texture, texture_coords);
    return texture_color * color;
}