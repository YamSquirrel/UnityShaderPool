// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Mya/Blinn-Phong(VFShader)"
{
	Properties
	{
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Geometry"  "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				half3 normal : TEXCOORD1;
				half3 viewDir : TEXCOORD2;
				half3 lightDir : TEXCOORD3;
				LIGHTING_COORDS(5,6)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

        	float4 _SpecularColor;
        	float4 _MainTint;
        	float _Gloss , _Specular;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);  
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));  
                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);  
				TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c;
				fixed4 tex = tex2D(_MainTex, i.uv);

				//漫反射光照计算
            	float diff =max (0,  dot(i.normal, i.lightDir));

				//下面两行是为Phong光照模型高光算法
            	//float3 reflectionVector = normalize((2.0 * i.normal * diff) - i.lightDir);
				//float spec = pow(max(0,dot(reflectionVector, i.viewDir)), _Specular*128.0)* _Gloss;

				//以下为Blinn-Phong光照模型高光算法
				fixed3 halfDir = normalize(i.lightDir + i.viewDir);  
				fixed3 NormalDir = normalize(i.normal);
				float spec = pow(max(0,dot(halfDir, NormalDir)),  _Gloss*128.0) ;

				//高光颜色
           		float3 finalSpec = _SpecularColor.rgb * spec;

				//环境光
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				//接受阴影
				float  atten = LIGHT_ATTENUATION(i);

				//接受阴影的支持写起来比较麻烦，新手可能也不太能理解，所以没写
				c.rgb = (tex* _LightColor0.rgb * diff + tex * ambient) + (_LightColor0.rgb * finalSpec);
				c.rgb *= atten;
				c.a = 1.0;
				return c;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
