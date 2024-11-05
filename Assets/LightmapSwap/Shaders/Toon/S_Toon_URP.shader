Shader "Custom/S_Toon_URP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness ("Smoothness",Range (0,1)) = 0.5
        _SpecularIntensity ("SpecularIntensity",Range (0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" }
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #include "HL_Toon.cginc"
            ENDHLSL
            
        }
          Pass {

            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define SHADOW_CASTER_PASS
            #include "HL_Toon.cginc"
            ENDHLSL
        }
        
        
    }
}
