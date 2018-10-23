##Custome BuiltinShader Unity2018.2.5f1
###Structure

```C++ 
cStandard.shader
    // ------------------------------------------------------------------
    // 简化向前渲染
    cUnityStandardCoreForward.cginc
        "cUnityStandardCoreForwardSimple.cginc"
            //cUnityStandardCore.cginc
        //cUnityStandardCore.cginc
    // ------------------------------------------------------------------
    // 阴影
    cUnityStandardShadow.cginc
    // ------------------------------------------------------------------
    // 测试
    cUnityStandardMeta.cginc
        //cUnityCG.cginc
        //cUnityStandardInput.cginc
        "cUnityMetaPass.cginc"
        //cUnityStandardCore.cginc
    // ------------------------------------------------------------------
    // 渲染核心
    "cUnityStandardCore.cginc"
        "cUnityCG.cginc"
            //cUnityShaderVariables.cginc
            cUnityShaderUtilities.cginc
            cUnityInstancing.cginc
        "cUnityShaderVariables.cginc"
            cHLSLSupport.cginc
        cUnityStandardConfig.cginc
        cUnityStandardInput.cginc
            //cUnityCG.cginc
            //cUnityStandardConfig.cginc
            cUnityStandardUtils.cginc
        "cUnityPBSLighting.cginc"
                //cUnityShaderVariables.cginc
                //cUnityStandardConfig.cginc
                "cUnityLightingCommon.cginc"
                //cUnityGBuffer.cginc
                "cUnityGlobalIllumination.cginc"
        cUnityStandardUtils.cginc
            //cUnityCG.cginc
            //cUnityStandardConfig.cginc
        cUnityGBuffer.cginc
        "cUnityStandardBRDF.cginc"
            //cUnityCG.cginc
            //cUnityStandardConfig.cginc
            //cUnityLightingCommon.cginc
        cAutoLight.cginc
            //cHLSLSupport.cginc
            cUnityShadowLibrary.cginc
``` 

###Shader
#####cStandard.shader
```C++  
Shader "cStandard"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }

        // ------------------------------------------------------------------
        // Forward Pass
        Pass{
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "../CGIncludes/cUnityStandardCoreForward.cginc"
        }
        Pass{
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "../CGIncludes/cUnityStandardCoreForward.cginc"
        }
        Pass{
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            #include "../CGIncludes/cUnityStandardShadow.cginc"
        }

        // ------------------------------------------------------------------
        // Deferred Pass 
        Pass{
            Name "DEFERRED"
            Tags { "LightMode" = "Deferred" }
            #pragma vertex vertDeferred
            #pragma fragment fragDeferred
            #include "../CGIncludes/cUnityStandardCore.cginc"
        }

        // ------------------------------------------------------------------
        // Meta 
        Pass{
            Name "META"
            Tags { "LightMode" = "Meta" }
            #pragma vertex vert_meta
            #pragma fragment frag_meta
            #include "../CGIncludes/cUnityStandardMeta.cginc"  
        }
    }
    FallBack "VertexLit"
    CustomEditor "cStandardShaderGUI"
}
```

###Cginc
#####cUnityStandardCore.cginc
```C++
// ------------------------------------------------------------------
//Normalize
    'NormalizePerVertexNormal'
    'NormalizePerPixelNormal'
//Get Light
    'MainLight'
    'AdditiveLight'
    'DummyLight'
    'ZeroIndirect'

// ------------------------------------------------------------------
// 参数设定
//Common fragment setup
    'float3 PerPixelWorldNormal'
    '#define FRAGMENT_SETUP FragmentSetup'
    '#define UNITY_SETUP_BRDF_INPUT SpecularSetup'
    'struct FragmentCommonData'
    FragmentCommonData SpecularSetup
    FragmentCommonData RoughnessSetup
    FragmentCommonData MetallicSetup
    'FragmentCommonData FragmentSetup'
        UNITY_SETUP_BRDF_INPUT
        PerPixelWorldNormal
        NormalizePerPixelNormal
    'UnityGI FragmentGI'
        UnityGlobalIllumination

// ------------------------------------------------------------------
// 向前渲染
//Forward Vertex Output
    'half4 OutputForward'
    'half4 VertexGIForward'
//Base forward pass
    'struct VertexOutputForwardBase'
    'VertexOutputForwardBase vertForwardBase'
        UNITY_INITIALIZE_OUTPUT
        VertexGIForward
    'half4 fragForwardBaseInternal'
        FRAGMENT_SETUP
        Occlusion
        FragmentGI
        UNITY_BRDF_PBS
        Emission
        UNITY_APPLY_FOG
        OutputForward
//Additive forward pass
    'struct VertexOutputForwardAdd'
    'VertexOutputForwardAdd vertForwardAdd'
    'half4 fragForwardAddInternal'
        FRAGMENT_SETUP_FWDADD
        AdditiveLight
        UNITY_BRDF_PBS
        UNITY_APPLY_FOG_COLOR
        OutputForward
        
// ------------------------------------------------------------------
// 延迟渲染
//Deferred pass
    'struct VertexOutputDeferred'
    'VertexOutputDeferred vertDeferred'
    'void fragDeferred'
        FRAGMENT_SETUP
        Occlusion
        FragmentGI
        UNITY_BRDF_PBS
        UnityStandardDataToGbuffer
        UnityGetRawBakedOcclusions
```

##TIPS
**引用cginc**
<pre>
MainFolder  
    FolderA  
        custom.cginc  
    FolderB  
        standard.shader

standard.shader  
#include "../FolderA/custom.cginc"
</pre>
* cUnityStandardCore.cginc  
* cUnityPBSLighting.cginc
* cUnityStandardBRDF.cginc  