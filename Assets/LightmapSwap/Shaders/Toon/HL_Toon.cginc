#ifndef TOON_INCLUDE
#define TOON_INCLUDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../INCLUDE/HL_ShadowUtility.cginc"
#include "../INCLUDE/HL_Lighting.cginc"
struct VertexInput
{
    float3 positionOS: POSITION;
    float3 normalOS: NORMAL;
    float2 uv: TEXCOORD0;
};
struct  VertexOutput
{
    float4 positionCS: SV_POSITION;
    float2 uv: TEXCOORD0;
    float3 normalWS: TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    float3 viewDir : TEXCOORD3;
};
TEXTURE2D (_MainTex); SAMPLER(sampler_MainTex); float4 _MainTex_ST;
float _Smoothness,_SpecularIntensity;
VertexOutput vert (VertexInput i)
{
    VertexOutput o;
    o.positionWS = TransformObjectToWorld(i.positionOS);
    o.normalWS = TransformObjectToWorldNormal(i.normalOS);
    o.viewDir = normalize( _WorldSpaceCameraPos -o.positionWS);
    o.uv = TRANSFORM_TEX(i.uv,_MainTex);
    o.positionCS = CalculatePositionCSWithShadowCasterLogic(o.positionWS, o.normalWS);
    return o;
    
}
half4 frag(VertexOutput i) : SV_Target
{
    const float3 n = normalize(i.normalWS);
    const float3 p = i.positionWS;
    half3 ml_Color;
    float3 ml_Dir;
    half ml_dist_atten,ml_sha_atten;
    half comp_diffuse, comp_specular;
    half3 comp_color;
    CalculateMainLight_float(p, ml_Dir, ml_Color, ml_dist_atten, ml_sha_atten);
    half ml_diffuse =saturate(dot(n , ml_Dir))* ml_dist_atten * ml_sha_atten;
    half smoothness = exp2(_Smoothness * 10 + 1);
    half ml_specular = LightingSpecular(1, ml_Dir, n, i.viewDir, 1, smoothness) * ml_diffuse *_SpecularIntensity;
    AddAdditionalLights_float(smoothness, p, n, i.viewDir,
    ml_diffuse, ml_specular, _SpecularIntensity, ml_Color,
    comp_diffuse, comp_specular ,comp_color);
    half3 sh = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
#ifdef SHADOW_CASTER_PASS
    return 0;
#else
    return half4(comp_color + sh, 1);
    
#endif
}

#endif
