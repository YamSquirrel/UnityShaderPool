##Custome BuiltinShader Unity2018.2.5f1
###File Structure
#####cStandard.shader
```C++ 
// ------------------------------------------------------------------
// 简化向前渲染
#include "cUnityStandardCoreForward.cginc"
    'cUnityStandardCoreForwardSimple.cginc'
        //cUnityStandardCore.cginc
    //cUnityStandardCore.cginc
// ------------------------------------------------------------------
// 阴影
cUnityStandardShadow.cginc
// ------------------------------------------------------------------
// 测试
#include "cUnityStandardMeta.cginc"
    //cUnityCG.cginc
    //cUnityStandardInput.cginc
    'cUnityMetaPass.cginc'
    //cUnityStandardCore.cginc
// ------------------------------------------------------------------
// 渲染核心
#include "cUnityStandardCore.cginc"
    'cUnityCG.cginc'
        //cUnityShaderVariables.cginc
        cUnityShaderUtilities.cginc
        cUnityInstancing.cginc
    'cUnityShaderVariables.cginc'
        cHLSLSupport.cginc
    cUnityStandardConfig.cginc
    cUnityStandardInput.cginc
        //cUnityCG.cginc
        //cUnityStandardConfig.cginc
        cUnityStandardUtils.cginc
    'cUnityPBSLighting.cginc'
            //cUnityShaderVariables.cginc
            //cUnityStandardConfig.cginc
            'cUnityLightingCommon.cginc'
            //cUnityGBuffer.cginc
            'cUnityGlobalIllumination.cginc'
                'cUnityImageBasedLighting.cginc'
                    //cUnityCG.cginc
                    //cUnityStandardConfig.cginc
                    'cUnityStandardBRDF.cginc'
                        //cUnityCG.cginc
                        //cUnityStandardConfig.cginc
                        //cUnityLightingCommon.cginc
                //cUnityStandardUtils.cginc
                //cUnityShadowLibrary.cginc
    cUnityStandardUtils.cginc
        //cUnityCG.cginc
        //cUnityStandardConfig.cginc
    cUnityGBuffer.cginc
    //cUnityStandardBRDF.cginc
    cAutoLight.cginc
        //cHLSLSupport.cginc
        cUnityShadowLibrary.cginc
// 如果是自定义shader
#include "diyUnityStandardCore.cginc"
    cUnityStandardCore.cginc
    'diyustomUnityStandardInput.cginc'
        cUnityStandardInput.cginc
    'diyUnityPBSLighting.cginc'
        cUnityPBSLighting.cginc
        'diyUnityGlobalIllumination.cginc'
            cUnityGlobalIllumination.cginc
            'diyUnityImageBasedLighting.cginc'
                cUnityImageBasedLighting.cginc
                'diyUnityStandardBRDF.cginc'
                    cUnityStandardBRDF.cginc

    
// ------------------------------------------------------------------
// Deferred Calculation
Internal-DeferredReflections.shader
Internal-DeferredShading.shader
Internal-PrePassLighting.shader
``` 

    diyUNITY_BRDF_PBS                       //diyUnityPBSLighting.cginc
        diyBRDF1_Unity_PBS()                             //diyUnityStandardBRDF.cginc
###Function Structure
```C++ 
// ------------------------------------------------------------------
// cStandard.shader : vertBase() fragBase()
// Internal-DeferredReflections.shader : vert() frag()
// Internal-DeferredShading.shader : CalculateLight()

// ------------------------------------------------------------------
//Forward Pass
//cUnityStandardCoreForward.cginc
vertBase() 
    //cUnityStandardCore.cginc
    vertForwardBase()                       

//cUnityStandardCoreForward.cginc
fragBase()  
    //cUnityStandardCore.cginc             
    fragForwardBaseInternal()
        //Material Setup FragmentCommonData s    
        FRAGMENT_SETUP s                   
            FragmentSetup()                 
                UNITY_SETUP_BRDF_INPUT      
                    SpecularSetup()         
                        SpecularGloss()                 //cUnityStandardInput.cginc
                        EnergyConservationBetweenDiffuseAndSpecular() //cUnityStandardUtils.cginc
                    RoughnessSetup()        
                        MetallicRough()                 //cUnityStandardInput.cginc
                        DiffuseAndSpecularFromMetallic()
                    MetallicSetup()         
                        MetallicGloss()                 //cUnityStandardInput.cginc
                        DiffuseAndSpecularFromMetallic()              //cUnityStandardUtils.cginc
                PerPixelWorldNormal()       
                NormalizePerPixelNormal()   
                PreMultiplyAlpha()                                    //cUnityStandardUtils.cginc
        Occlusion()                                     //cUnityStandardInput.cginc
        FragmentGI()                        
            UnityGlossyEnvironmentSetup()                             //cUnityImageBasedLighting.cginc
            UnityGlobalIllumination()                   //cUnityGlobalIllumination.cginc
                UnityGI_Base()                          //cUnityGlobalIllumination.cginc
                    UnitySampleBakedOcclusion()                       //cUnityShadowLibrary.cginc
                    UnityComputeShadowFadeDistance()                  //cUnityShadowLibrary.cginc    
                    UnityMixRealtimeAndBakedShadows()                 //cUnityShadowLibrary.cginc  
        //Lighting Setup
        UNITY_BRDF_PBS                     //cUnityPBSLighting.cginc
            BRDF3_Unity_PBS()                           //cUnityStandardBRDF.cginc
            BRDF2_Unity_PBS()                           //cUnityStandardBRDF.cginc
            BRDF1_Unity_PBS()                           //cUnityStandardBRDF.cginc
        Emission()                         //cUnityStandardInput.cginc
        UNITY_APPLY_FOG()                  //cUnityCG.cginc
        OutputForward()                    //cUnityStandardCore.cginc

// ------------------------------------------------------------------
// DIY Forward Pass
//diyUnityStandardCore.cginc
diyFragForwardBase()
    diyFRAGMENT_SETUP s                   
    diyFragmentSetup()                 
        diyUNITY_SETUP_BRDF_INPUT
            diySetup()
                diyGloss()                  //diyUnityStandardInput.cginc
    diyUNITY_BRDF_PBS                       //diyUnityPBSLighting.cginc
        diyBRDF1_Unity_PBS()                             //diyUnityStandardBRDF.cginc

// ------------------------------------------------------------------
//Deferred Pass
vertDeferred()                      //cUnityStandardCore.cginc
 
fragDeferred()                      //cUnityStandardCore.cginc
    //Material Setup FragmentCommonData s 
    FRAGMENT_SETUP s
    Occlusion()
    FragmentGI()
    //Lighting Setup & Write outEmission : SV_Target3 
    UNITY_BRDF_PBS
    //Material Write outGBuffer0 1 2 : SV_Target0 1 2
    UnityStandardData data;
    UnityStandardDataToGbuffer()

// ------------------------------------------------------------------
// Deferred Lighting
CalculateLight()
    UNITY_INITIALIZE_OUTPUT()
    UnityDeferredCalculateLightParams()
    UnityStandardDataFromGbuffer()
    UNITY_BRDF_PBS()

``` 








### Main Functions
```C++ 
inline FragmentCommonData FragmentSetup(){
    FragmentCommonData o = UNITY_SETUP_BRDF_INPUT (i_tex);
    o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld);
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
}

``` 

###Shader
#####cStandard.shader
```C++  
Shader "cStandard"
    SubShader
        Tags "RenderType"="Opaque" "PerformanceChecks"="False" 
        // ------------------------------------------------------------------
        // Forward Pass
        Pass
            Name "FORWARD"
            Tags  "LightMode" = "ForwardBase" 
            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "../CGIncludes/cUnityStandardCoreForward.cginc"
        
        Pass
            Name "FORWARD_DELTA"
            Tags  "LightMode" = "ForwardAdd" 
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "../CGIncludes/cUnityStandardCoreForward.cginc"
        
        Pass
            Name "ShadowCaster"
            Tags  "LightMode" = "ShadowCaster" 
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            #include "../CGIncludes/cUnityStandardShadow.cginc"
        
        // ------------------------------------------------------------------
        // Deferred Pass 
        Pass
            Name "DEFERRED"
            Tags  "LightMode" = "Deferred" 
            #pragma vertex vertDeferred
            #pragma fragment fragDeferred
            #include "../CGIncludes/cUnityStandardCore.cginc"

        // ------------------------------------------------------------------
        // Meta 
        Pass
            Name "META"
            Tags  "LightMode" = "Meta" 
            #pragma vertex vert_meta
            #pragma fragment frag_meta
            #include "../CGIncludes/cUnityStandardMeta.cginc"  
        
    FallBack "VertexLit"
    CustomEditor "cStandardShaderGUI"
```

###Cginc
#####cUnityStandardCore.cginc
```C++
// ------------------------------------------------------------------
// Normalize
    NormalizePerVertexNormal()
    NormalizePerPixelNormal()
// Get Light
    MainLight()
    AdditiveLight()
    DummyLight()
    ZeroIndirect()

// ------------------------------------------------------------------
// 参数设定
// Common fragment setup
    float3 PerPixelWorldNormal()
    #define FRAGMENT_SETUP
        FragmentSetup
    #define UNITY_SETUP_BRDF_INPUT
    struct FragmentCommonData;
    FragmentCommonData SpecularSetup()
    FragmentCommonData RoughnessSetup()
    FragmentCommonData MetallicSetup()
    // DIY FRAGMENT_SETUP
    FragmentCommonData FragmentSetup()
        UNITY_SETUP_BRDF_INPUT
        PerPixelWorldNormal
        NormalizePerPixelNormal
        PreMultiplyAlpha
    // DIY FragmentGI 
    UnityGI FragmentGI()
        UnityGlobalIllumination

// ------------------------------------------------------------------
// 向前渲染
// Forward Vertex Output
    half4 OutputForward()
    half4 VertexGIForward()
// Base forward pass
    struct VertexOutputForwardBase;
    VertexOutputForwardBase vertForwardBase()
        UNITY_INITIALIZE_OUTPUT
        VertexGIForward
    // DIY fragBase
    half4 fragForwardBaseInternal()
        FRAGMENT_SETUP
        Occlusion
        FragmentGI
        UNITY_BRDF_PBS
        Emission
        UNITY_APPLY_FOG
        OutputForward
// Additive forward pass
    struct VertexOutputForwardAdd;
    VertexOutputForwardAdd vertForwardAdd()
    half4 fragForwardAddInternal()
        FRAGMENT_SETUP_FWDADD
        AdditiveLight
        UNITY_BRDF_PBS
        UNITY_APPLY_FOG_COLOR
        OutputForward
        
// ------------------------------------------------------------------
// 延迟渲染
// Deferred pass
    struct VertexOutputDeferred;
    VertexOutputDeferred vertDeferred()
    void fragDeferred()
        FRAGMENT_SETUP
        Occlusion
        FragmentGI
        UNITY_BRDF_PBS
        UnityStandardDataToGbuffer
        UnityGetRawBakedOcclusions
```
#####cUnityStandardCoreForward.cginc
```C++
#include "cUnityStandardCore.cginc"
    VertexOutputForwardBase vertBase()
        vertForwardBase
    VertexOutputForwardAdd vertAdd()
        vertForwardAdd
    half4 fragBase()
        fragForwardBaseInternal
    half4 fragAdd() 
        fragForwardAddInternal
```

#####cUnityPBSLighting.cginc
```C++
//-------------------------------------------------------------------------------------
// DIY UNITY_BRDF_PBS 在cUnityStandardBRDF.cginc添加函数
// Default BRDF to use:
    #define UNITY_BRDF_PBS
        BRDF3_Unity_PBS
        BRDF2_Unity_PBS
        BRDF1_Unity_PBS
// little helpers for GI calculation
    half3 BRDF_Unity_Indirect()
    UNITY_GI()
        UnityGlobalIllumination

//-------------------------------------------------------------------------------------
// 供Surface shader调用的lighting函数
// 新建standard surface shader并 show compile code 可以看到这些函数被调用
// Metallic workflow
    struct SurfaceOutputStandard;
    half4 LightingStandard()
    half4 LightingStandard_Deferred()
    void LightingStandard_GI()
// Specular workflow
    struct SurfaceOutputStandardSpecular;
    half4 LightingStandardSpecular()
    half4 LightingStandardSpecular_Deferred()
    void LightingStandardSpecular_GI()
```

#####cUnityGlobalIllumination.cginc
```C++
    UnityGI UnityGI_Base()
    half3 UnityGI_IndirectSpecular()
    // DIY GI
    UnityGI UnityGlobalIllumination()
        UnityGI_Base
        UnityGI_IndirectSpecular
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