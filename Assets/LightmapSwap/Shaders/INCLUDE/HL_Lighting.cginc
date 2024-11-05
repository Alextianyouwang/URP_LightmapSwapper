#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

void FastSSS_float(float3 ViewDir, float3 LightDir, float3 WorldNormal,float3 LightColor, float Flood, float Power, out float3 sss)
{
    const float3 LAddN = LightDir + WorldNormal;
    sss = saturate(pow(dot (-LAddN , -LAddN * Flood + ViewDir), Power))  * LightColor;
    
}

void AdditionalLightFastSSS_float (float3 WorldPos,float3 ViewDir,float3 WorldNormal,float Flood, float Power, out float3 sss)
{
    sss = 0;
    for (int i = 0; i < GetAdditionalLightsCount(); ++i)
    {
        const Light light = GetAdditionalLight(i, WorldPos);
        float3 result;
        FastSSS_float(ViewDir,light.direction,WorldNormal,light.color,Flood,Power, result);
        sss += result * light.distanceAttenuation;
    }
    
}
void CalculateMainLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out half DistanceAtten, out half ShadowAtten) {
#ifdef SHADERGRAPH_PREVIEW
    Direction = half3(0.5, 0.5, 0);
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
#if SHADOWS_SCREEN
    half4 clipPos = TransformWorldToHClip(WorldPos);
    half4 shadowCoord = ComputeScreenPos(clipPos);
#else
    half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif
    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void AddAdditionalLights_float(float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView,
    float MainDiffuse, float MainSpecular, float SpecularIntensity, float3 MainColor,
    out float Diffuse, out float Specular, out float3 Color) {
    Diffuse = MainDiffuse;
    Specular = MainSpecular;
    Color = MainColor * (MainDiffuse + MainSpecular);
    #if SHADOWS_SCREEN
    half4 clipPos = TransformWorldToHClip(WorldPos);
    half4 shadowCoord = ComputeScreenPos(clipPos);
    #else
    half4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
    #endif
#ifndef SHADERGRAPH_PREVIEW
    int pixelLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < pixelLightCount; ++i) {
        Light light = GetAdditionalLight(i, WorldPosition,shadowCoord);
        half atten = light.distanceAttenuation * light.shadowAttenuation;
        half thisDiffuse = LightingLambert(1, light.direction, WorldNormal) * atten;
        half thisSpecular = LightingSpecular(1, light.direction, WorldNormal, WorldView, 1, Smoothness) * thisDiffuse * SpecularIntensity;
        Diffuse += thisDiffuse;
        Specular += thisSpecular;
        Color += light.color * (thisDiffuse + thisSpecular);
    }
#endif
    
}

#endif
