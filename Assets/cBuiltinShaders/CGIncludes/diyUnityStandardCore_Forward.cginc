// 拷贝diyUnityStandardCore_Forward.cginc并重命名 shader的Base && Add通道引用
// 可以把diy_ 替换为其它名字如 skin_
// 主要修改的地方：
// 1.贴图输入 diy_BRDF_Setup() && diy_FragmentSetup()
//   shader修改#define cUNITY_SETUP_BRDF_INPUT
// 2.光照计算 diyUnityStandardBRDF.cginc BRDF 
//   shader修改#define cUNITY_BRDF_PBS
// 3.顶点计算 struct diy_VertexOutputForwardBase && diy_vertForwardBase()
//   shader修改 #pragma vertex
// 4.像素计算 diy_fragForwardBaseInternal() && diy_fragForwardAddInternal()
//   shader修改 #pragma fragment

#ifndef DIY_UNITY_STANDARD_CORE_INCLUDED
#define DIY_UNITY_STANDARD_CORE_INCLUDED
#include "UnityStandardCore.cginc"

// -------------------------------<0>-----------------------------------
#include "diyUnityStandardBRDF.cginc"

// -------------------------------<1>-----------------------------------
// FRAGMENT SETUP

// Common Fragment Setup
#ifndef cUNITY_SETUP_BRDF_INPUT
    #define cUNITY_SETUP_BRDF_INPUT diy_BRDF_Setup
#endif

inline FragmentCommonData diy_BRDF_Setup (float4 i_tex)
{
    // need change for texture input optimize
    half2 metallicGloss = MetallicGloss(i_tex.xy);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic (Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// DIY Fragment Setup
struct diy_FragmentCommonData
{
    FragmentCommonData fragDataCommon;
};

inline diy_FragmentCommonData diy_FragmentSetup (inout float4 i_tex, float3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld)
{
    i_tex = Parallax(i_tex, i_viewDirForParallax);

    half alpha = Alpha(i_tex.xy);
    #if defined(_ALPHATEST_ON)
        clip (alpha - _Cutoff);
    #endif

    FragmentCommonData o = cUNITY_SETUP_BRDF_INPUT (i_tex);
    o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld);
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
    o.posWorld = i_posWorld;
    o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, o.alpha);

    diy_FragmentCommonData diy_o;
    diy_o.fragDataCommon = o;
    //diy_o.other_paramaters = ....

    return diy_o;
}

// --------------------------------<2-1>----------------------------------
// BASE PASS

// DIY vertex output
struct diy_VertexOutputForwardBase
{
    VertexOutputForwardBase vertOutCommon;
};

// DIY vertex shader    
diy_VertexOutputForwardBase diy_vertForwardBase (VertexInput v)
{
    VertexOutputForwardBase o = vertForwardBase(v);
    diy_VertexOutputForwardBase diy_o;
    diy_o.vertOutCommon = o;
    return diy_o;
}

// DIY fragment shader
#define diy_FRAGMENT_SETUP(x) diy_FragmentCommonData x = \
    diy_FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

half4 diy_fragForwardBaseInternal (diy_VertexOutputForwardBase diy_i) : SV_Target
{
    VertexOutputForwardBase i = diy_i.vertOutCommon;
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    diy_FRAGMENT_SETUP(diy_s)
    FragmentCommonData s = diy_s.fragDataCommon;

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    UnityLight mainLight = MainLight ();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

    half occlusion = Occlusion(i.tex.xy);
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

    half4 c = cUNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    c.rgb += Emission(i.tex.xy);

    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG(_unity_fogCoord, c.rgb);
    return OutputForward (c, s.alpha);
}

// --------------------------------<2-2>----------------------------------
// ADDITIVE PASS

struct diy_VertexOutputForwardAdd
{
    VertexOutputForwardAdd vertOutCommon;
};

// VS Shader 
diy_VertexOutputForwardAdd diy_vertForwardAdd (VertexInput v)
{
    VertexOutputForwardAdd o = vertForwardAdd(v);
    diy_VertexOutputForwardAdd diy_o;
    diy_o.vertOutCommon = o;
    return diy_o;
}

// PS Shader
#define diy_FRAGMENT_SETUP_FWDADD(x) diy_FragmentCommonData x = \
    diy_FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i));

half4 diy_fragForwardAddInternal (diy_VertexOutputForwardAdd diy_i) : SV_Target
{
    VertexOutputForwardAdd i = diy_i.vertOutCommon;
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    diy_FRAGMENT_SETUP_FWDADD(diy_s)
    FragmentCommonData s = diy_s.fragDataCommon;

    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
    UnityLight light = AdditiveLight (IN_LIGHTDIR_FWDADD(i), atten);
    UnityIndirect noIndirect = ZeroIndirect ();

    half4 c = cUNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);

    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG_COLOR(_unity_fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
    return OutputForward (c, s.alpha);
}




#endif // DIY_UNITY_STANDARD_CORE_INCLUDED
