//Unity Toon Shader
//nobuyuki@unity3d.com
//toshiyuki@unity3d.com (Intengrated) 

Shader "Toon" {
    Properties {
        [HideInInspector] _BaseMap ("BaseMap", 2D) = "white" {}
    } 

    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    ENDHLSL

    // *************************** //
    // ****** HDRP Subshader ***** //
    // *************************** //
    SubShader
    {
        PackageRequirements
        {
           "com.unity.render-pipelines.high-definition": "10.5.0"
        }    
        // This tags allow to use the shader replacement features
        Tags{ "RenderPipeline"="HDRenderPipeline" }


        Pass
        {

            Name "ForwardOnly"
            Tags { "LightMode" = "ForwardOnly" } 

            ZWrite[_ZWriteMode]
            Cull[_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil {

                Ref[_StencilNo]

                Comp[_StencilComp]
                Pass[_StencilOpPass]
                Fail[_StencilOpFail]

            }



            HLSLPROGRAM
            #include "./UtsHDRP.hlsl"
//            #pragma multi_compile _ UTS_DEBUG_SHADOWMAP_BINALIZATION
            #pragma multi_compile _ DEBUG_DISPLAY
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // Setup DECALS_OFF so the shader stripper can remove variants
            #pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
            #pragma multi_compile SCREEN_SPACE_SHADOWS_OFF SCREEN_SPACE_SHADOWS_ON
            // Supported shadow modes per light type
            #pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
            #define LIGHTLOOP_DISABLE_TILE_AND_CLUSTER
//	    #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST
            #define SHADERPASS SHADERPASS_FORWARD
            // In case of opaque we don't want to perform the alpha test, it is done in depth prepass and we use depth equal for ztest (setup from UI)
            // Don't do it with debug display mode as it is possible there is no depth prepass in this case
            #if !defined(_SURFACE_TYPE_TRANSPARENT) && !defined(DEBUG_DISPLAY)
                #define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
            #endif
            #pragma shader_feature _ _SHADINGGRADEMAP
            // used in ShadingGradeMap
            #pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
            #pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON
            // used in Shadow calculation 
            #pragma shader_feature _ UTS_USE_RAYTRACING_SHADOW
            // used in DoubleShadeWithFeather
            #pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE
            // controlling mask rendering
            #pragma shader_feature _ _IS_CLIPPING_MATTE
            #pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

        #ifdef DEBUG_DISPLAY
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
        #endif

            // The light loop (or lighting architecture) is in charge to:
            // - Define light list
            // - Define the light loop
            // - Setup the constant/data
            // - Do the reflection hierarchy
            // - Provide sampling function for shadowmap, ies, cookie and reflection (depends on the specific use with the light loops like index array or atlas or single and texture format (cubemap/latlong))

            #define HAS_LIGHTLOOP

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"


            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
            #include "../../HDRP/Shaders/UtsLightLoop.hlsl"
            #include "../../HDRP/Shaders/ShaderPassForwardUTS.hlsl"

            #pragma vertex Vert
            #pragma fragment Frag

            ENDHLSL
        }

    }
    // *************************** //
    // ****** URP Subshader  ***** //
    // *************************** //
    SubShader 
    {
        PackageRequirements
        {
             "com.unity.render-pipelines.universal": "10.5.0"
        }    
        Tags {
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

//ToonCoreStart
        Pass {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}
            ZWrite[_ZWriteMode]
            Cull[_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil {

                Ref[_StencilNo]

                Comp[_StencilComp]
                Pass[_StencilOpPass]
                Fail[_StencilOpFail]

            }

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex vert
            #pragma fragment frag


            // -------------------------------------
            // Material Keywords
            // -------------------------------------
            // Material Keywords
//            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #pragma multi_compile   _IS_PASS_FWDBASE
            #pragma multi_compile   _ENVIRONMENTREFLECTIONS_OFF
            // DoubleShadeWithFeather and ShadingGradeMap use different fragment shader.  
            #pragma shader_feature _ _SHADINGGRADEMAP


            // used in ShadingGradeMap
            #pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
            #pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON

            // used in Shadow calculation 
            #pragma shader_feature _ UTS_USE_RAYTRACING_SHADOW
            // used in DoubleShadeWithFeather
            #pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE

            #pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../../UniversalRP/Shaders/UniversalToonInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"
            #include "../../UniversalRP/Shaders/UniversalToonHead.hlsl"
            #include "../../UniversalRP/Shaders/UniversalToonBody.hlsl"

            ENDHLSL
            
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_CullMode]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "../../UniversalRP/Shaders/UniversalToonInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_CullMode]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "../../UniversalRP/Shaders/UniversalToonInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"
#if (VERSION_GREATER_EQUAL(10, 0))
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "../../UniversalRP/Shaders/UniversalToonInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthNormalsPass.hlsl"
#endif
            ENDHLSL
        }

//ToonCoreEnd
    }

    // ***************************** //
    // ****** Legacy Subshader ***** //
    // ***************************** //

    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull[_SRPDefaultUnlitColMode]
            ColorMask[_SPRDefaultUnlitColorMask]
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                Ref[_StencilNo]
                Comp[_StencilComp]
                Pass[_StencilOpPass]
                Fail[_StencilOpFail]

            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            //#pragma fragmentoption ARB_precision_hint_fastest
            //#pragma multi_compile_shadowcaster
            //#pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal vulkan xboxone ps4 switch
            #pragma target 3.0
            //V.2.0.4
            #pragma multi_compile _IS_OUTLINE_CLIPPING_NO 
            #pragma multi_compile _OUTLINE_NML _OUTLINE_POS
            // Unity Toon Shader 0.5.0
            #pragma multi_compile _ _DISABLE_OUTLINE
            //The outline process goes to UTS_Outline.cginc.
            #include "../../Legacy/Shaders/UCTS_Outline.cginc"
            ENDCG
        }
//ToonCoreStart
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite[_ZWriteMode]
            Cull[_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil {

                Ref[_StencilNo]

                Comp[_StencilComp]
                Pass[_StencilOpPass]
                Fail[_StencilOpFail]

            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal vulkan xboxone ps4 switch
            #pragma target 3.0
            // DoubleShadeWithFeather and ShadingGradeMap use different fragment shader.  
            #pragma shader_feature _ _SHADINGGRADEMAP
            // used in ShadingGradeMap
            #pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
            #pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON
            // used in DoubleShadeWithFeather
            #pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE
            #pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION
            #pragma multi_compile _IS_PASS_FWDBASE

            //
            #pragma shader_feature UTS_USE_RAYTRACING_SHADOW
#if defined(_SHADINGGRADEMAP)

#include "../../Legacy/Shaders/UCTS_ShadingGradeMap.cginc"


#else //#if defined(_SHADINGGRADEMAP)

#include "../../Legacy/Shaders/UCTS_DoubleShadeWithFeather.cginc"


#endif //#if defined(_SHADINGGRADEMAP)

            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }

            Blend One One
            Cull[_CullMode]
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            //for Unity2018.x
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal vulkan xboxone ps4 switch
            #pragma target 3.0
            // DoubleShadeWithFeather and ShadingGradeMap use different fragment shader.  
            #pragma shader_feature _ _SHADINGGRADEMAP
            // used in ShadingGradeMap
            #pragma shader_feature _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
            #pragma shader_feature _IS_ANGELRING_OFF _IS_ANGELRING_ON
            // used in DoubleShadeWithFeather
            #pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE
            #pragma shader_feature _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION
            //v.2.0.4

            #pragma multi_compile _IS_PASS_FWDDELTA
            #pragma shader_feature UTS_USE_RAYTRACING_SHADOW

#if defined(_SHADINGGRADEMAP)

#include "../../Legacy/Shaders/UCTS_ShadingGradeMap.cginc"


#else //#if defined(_SHADINGGRADEMAP)

#include "../../Legacy/Shaders/UCTS_DoubleShadeWithFeather.cginc"


#endif //#if defined(_SHADINGGRADEMAP)

            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal vulkan xboxone ps4 switch
            #pragma shader_feature _ _SYNTHESIZED_TEXTURE
            #pragma target 3.0
            //v.2.0.4
            #pragma shader_feature _IS_CLIPPING_OFF _IS_CLIPPING_MODE _IS_CLIPPING_TRANSMODE
            #include "../../Legacy/Shaders/UCTS_ShadowCaster.cginc"
            ENDCG
        }
//ToonCoreEnd
    }
    FallBack "Legacy Shaders/VertexLit"
    CustomEditor "UnityEditor.Rendering.Builtin.Toon.UTS2GUI"
}
