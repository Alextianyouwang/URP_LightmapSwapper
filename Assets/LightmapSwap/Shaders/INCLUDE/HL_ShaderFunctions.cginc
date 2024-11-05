#ifndef SHADER_FUNCTIONS_INCLUDED
#define SHADER_FUNCTIONS_INCLUDED

inline float Dither8x8Bayer( int x, int y )
{
    const float dither[ 64 ] = {
        1, 49, 13, 61,  4, 52, 16, 64,
       33, 17, 45, 29, 36, 20, 48, 32,
        9, 57,  5, 53, 12, 60,  8, 56,
       41, 25, 37, 21, 44, 28, 40, 24,
        3, 51, 15, 63,  2, 50, 14, 62,
       35, 19, 47, 31, 34, 18, 46, 30,
       11, 59,  7, 55, 10, 58,  6, 54,
       43, 27, 39, 23, 42, 26, 38, 22};
    int r = y * 8 + x;
    return dither[r] / 64; 
}
void DitherFade_float (float2 uv, out float value)
{
    value = Dither8x8Bayer( fmod(uv.x, 8), fmod(uv.y, 8) );
}

void ApplyTangentNormalToWorld_float(float3 normal, float3 tangent, float3 bitangent, float3 normalTS, out float3 result)
{
    normalTS = normalTS.xzy;

    result = normalize( float3 (normalTS.x * tangent + normalTS.y * normal + normalTS.z * bitangent));
    
}
#endif
