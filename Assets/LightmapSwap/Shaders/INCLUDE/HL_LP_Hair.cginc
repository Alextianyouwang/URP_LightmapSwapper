#ifndef LOW_POLY_HAIR_INCLUDED
#define LOW_POLY_HAIR_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float StrandSpecular ( half3 T, half3 V, half3 L, half3 N, float shift, float exponent)
{
   const half3 biT = -cross( N, T);
   const half3 shiftBiT = normalize( biT  + shift * N);
   const half3 H = normalize ( L + V );
   const float dotTH = dot ( shiftBiT, H );
   const float sinTH = sqrt ( 1 - dotTH * dotTH);
   const float dirAtten = smoothstep( -1, 0, dotTH );
         return dirAtten * pow(sinTH, exponent);
}

void StrandSpecular_float (half3 T, half3 V, half3 L, half3 N, float shift, float exponent, out float spec)
{
    spec = StrandSpecular(T,V,L, N, shift, exponent);
}

struct HairSurfaceData
{
    float3 albedo;
    float3 specular;
    float3 specular2;
    float smoothness;
    float tanShift;
    float tanShift2;


    float3 positionWS;
    float3 tangentWS;
    float3 normalWS;
    float3 viewDir;
    
    float4 shadowCoord;
    
    float ambientOcclusion;
    float ambientOcclusionRimPower;
    float3 bakedGI;
    float4 shadowMask;
    float fogFactor;
    
};
float GetSmoothnessPower(float rawSmoothness) {
    return exp2(10 * rawSmoothness + 1);
}
float3 CustomGlobalIllumination(HairSurfaceData  d) {
    const float3 indirectDiffuse = d.albedo * d.bakedGI * d.ambientOcclusion;

    const float3 reflectVector = reflect(-d.viewDir, d.normalWS);
    const float fresnel = pow(1 - saturate(dot(d.viewDir, d.normalWS)),d.ambientOcclusionRimPower);
    const float3 indirectSpecular = GlossyEnvironmentReflection(reflectVector,
        RoughnessToPerceptualRoughness(1 - d.smoothness),
        d.ambientOcclusion) * fresnel;

    return indirectDiffuse + indirectSpecular;
}
float3 CustomLightHandling(HairSurfaceData d, Light light) {
    const float3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation);

    const float diffuse = saturate(dot(d.normalWS, light.direction));
    const float strandSpecular = StrandSpecular(
        d.tangentWS,d.viewDir,light.direction, d.normalWS,d.tanShift,GetSmoothnessPower(d.smoothness));
    const float strandSpecular2 = StrandSpecular(
       d.tangentWS,d.viewDir,light.direction, d.normalWS,d.tanShift2,GetSmoothnessPower(d.smoothness));

    float3 color = d.albedo * radiance * (diffuse + strandSpecular * diffuse* d.specular + strandSpecular2 * diffuse* d.specular2);
    return  color;
}
float3 CalculateCustomLighting(HairSurfaceData d) {


    Light mainLight = GetMainLight(d.shadowCoord, d.positionWS, d.shadowMask);
    MixRealtimeAndBakedGI(mainLight, d.normalWS, d.bakedGI);
    float3 color = CustomGlobalIllumination(d);
    color += CustomLightHandling(d, mainLight);

    const uint numAdditionalLights = GetAdditionalLightsCount();
    for (uint lightI = 0; lightI < numAdditionalLights; lightI++) {
        const Light l= GetAdditionalLight(lightI, d.positionWS, d.shadowCoord);
        color += CustomLightHandling(d, l);
    }
    color = MixFog(color, d.fogFactor);
    return color;
}
void LowPolyHair_float (float3 tangentWS, float3 normalWS, float3 viewDir,
   float3 posWS,float3 albedo, float3 specular, float3 specular2, float2 lightmapUV, float tanShift,float tanShift2,
   float smoothness, float ao, float ambientOcclusionRimPower,out float3 color)
{
    HairSurfaceData d = (HairSurfaceData)0;
    d.albedo = albedo;
    d.specular = specular;
    d.specular2 = specular2;
    d.smoothness = smoothness;
    d.tanShift = tanShift;
    d.tanShift2 = tanShift2;

    d.ambientOcclusionRimPower = ambientOcclusionRimPower;
    d.ambientOcclusion = ao;

    d.positionWS = posWS;
    d.normalWS = normalWS;
    d.tangentWS = tangentWS;
    d.viewDir = viewDir;

    float4 positionCS = TransformWorldToHClip(posWS);
    #if SHADOWS_SCREEN
    d.shadowCoord = ComputeScreenPos(positionCS);
    #else
    d.shadowCoord = TransformWorldToShadowCoord(posWS);
    #endif

    float2 lmUV;
    OUTPUT_LIGHTMAP_UV(lightmapUV, unity_LightmapST, lmUV);
    // Samples spherical harmonics, which encode light probe data
    float3 vertexSH;
    OUTPUT_SH(normalWS, vertexSH);
    // This function calculates the final baked lighting from light maps or probes
    d.bakedGI = SAMPLE_GI(lmUV, vertexSH, normalWS);
    // This function calculates the shadow mask if baked shadows are enabled
    d.shadowMask = SAMPLE_SHADOWMASK(lmUV);
    // This returns 0 if fog is turned off
    // It is not the same as the fog node in the shader graph
    d.fogFactor = ComputeFogFactor(positionCS.z);
    color = CalculateCustomLighting(d);
}
#endif
