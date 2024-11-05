#ifndef EYE_INCLUDE
#define EYE_INCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


void EyeUV_float(float2 uv, float3 normalWS , float3 viewDir, float depth, float irisSize, out float2 eyeUV)
{
    const float2 originalEyeUV = abs(uv % 1.0);
    float dist = distance(originalEyeUV, 0.5);
    dist = saturate(1- dist * 1.9);
    eyeUV = (originalEyeUV - 0.5) * (3 - 4* irisSize ) + 0.5;
    float3 H = mul(unity_WorldToObject, normalize(-viewDir * 15 + normalWS));
    eyeUV += float3(H.y, H.x, H.z) * float3(-dist, -dist, 0) * depth;

}

void EyeColor_float( float2 uv, float pupilTex, float irisTex, float irisSize,
   float irisEdge, float irisShadowSize, float irisShadowEdge, float irisShadowMult,
   float3 irisColor, float3 shadowCol, float3 edgeCol, float3 pupilCol, out float3 color)
{
    const float2 originalEyeUV = abs(uv % 1.0);
    float dist = distance(uv, 0.5);
    dist = saturate(1- dist * 1.9);

    irisShadowSize += irisSize;
    const float irisShadow = smoothstep(irisShadowSize, irisShadowSize + irisShadowEdge,dist);
    const float irisShadow2 = clamp((1 - originalEyeUV.y) *  irisShadowMult, 0, 1.4);
    

    irisSize = 1- irisSize;
    const float iris = smoothstep( irisSize, irisSize + irisEdge,dist) * (1 - irisTex);

    const float pupil = pupilTex * iris;
    float3 c = (irisTex * irisColor * iris * pow(irisShadow2, 4) * irisShadow);
    float3 shadow = (1 - irisShadow2) * irisShadow * shadowCol * iris;			
    float3 edge = (1 - irisShadow) * edgeCol* iris;	
    color =  (c+ shadow + edge ) * (1.0 - pupil) + (pupil * pupilCol);
    color =  iris;
    
}
#endif
