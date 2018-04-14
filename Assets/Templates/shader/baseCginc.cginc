/////////////////////////////////cginc//////////////////////////////////////////
//cginc must be created as txt first Not cs file. then rename as .cginc
//https://forum.unity.com/threads/include-custom-cginc-files.94518/
////////////////////////////////////////////////////////////////////////////////
struct vertexInput
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
};

struct vertexOutput
{
    float4 pos : SV_POSITION;
    float4 tex : TEXCOORD0;
    float4 posWorld : TEXCOORD1;
    float3 normalDir : TEXCOORD2;
};

/////////////////////////////////inline/////////////////////////////////////////
//Inline function Is copied to the reference place rather than create a call
//Shot and important function could be created as inline to speed up calculation
///////////////////////////////////////////////////////////////////////////////
inline float3 diffuse(fixed4 _LightColor0, float3 normalDirection, float3 lightDirection){
    return _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
}

inline float3 specular(fixed4 _LightColor0, float3 normalDirection, float3 lightDirection, float3 viewDirection, float _Shininess){
    return _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
}