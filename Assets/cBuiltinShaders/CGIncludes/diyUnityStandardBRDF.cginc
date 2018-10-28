#ifndef DIY_UNITY_STANDARD_BRDF_INCLUDED
#define DIY_UNITY_STANDARD_BRDF_INCLUDED

#include "UnityStandardBRDF.cginc"

#if !defined (cUNITY_BRDF_PBS)
    #define cUNITY_BRDF_PBS BRDF3_Unity_PBS
#endif

// 在这里建立BRDF 计算库
#define diy_BRDF_PBS BRDF3_Unity_PBS

#endif // DIY_UNITY_STANDARD_BRDF_INCLUDED
