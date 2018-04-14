Shader "Mya/WrapMode"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[KeywordEnum(Default , Center)]_TransFormPoint("TransForm Point" , Float) = 0
		_Angle("Angle" , float)	 = 0
		[KeywordEnum(Default , Clamp, Repeat , Mirror )]_WrapMode ("wrapMode", Float) = 0
		[Toggle] _Horizontal("Horizontal", Float) = 1
		[Toggle] _Vertical("Horizontal", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _TRANSFORMPOINT_DEFAULT _TRANSFORMPOINT_CENTER
			#pragma shader_feature _WRAPMODE_DEFAULT _WRAPMODE_CLAMP _WRAPMODE_REPEAT _WRAPMODE_MIRROR
			#pragma shader_feature __ _HORIZONTAL_ON
			#pragma shader_feature __ _VERTICAL_ON
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
			};

			struct v2f
			{
				float2 uv		: TEXCOORD0;
				float4 pos		: SV_POSITION;
			};

			sampler2D	_MainTex;
			float4		_MainTex_ST;
			float		_Angle;


			float2 TransFormUV(float2 uv,float angle , float4 uvST)
			{
				float2 outUV;
				float s = sin(angle/57.2958);
				float c = cos(angle/57.2958);
				outUV = uv * uvST.xy + uvST.zw;
				#if _TRANSFORMPOINT_DEFAULT
					outUV = float2(outUV.x * c - outUV.y * s, outUV.x * s + outUV.y * c);
				#elif _TRANSFORMPOINT_CENTER 
					outUV = outUV - uvST.xy * 0.5;
					outUV = float2(outUV.x * c - outUV.y * s, outUV.x * s + outUV.y * c);
					outUV = outUV + float2(0.5f, 0.5f);
				#endif


				return outUV;
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TransFormUV(v.uv,_Angle,_MainTex_ST);
				return o;
			}
			

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				#if _WRAPMODE_CLAMP
					uv = frac(i.uv);
					#if _HORIZONTAL_ON
					   uv.x = saturate(i.uv.x); 
					#endif
					#if	_VERTICAL_ON
					   uv.y = saturate(i.uv.y);
					#endif

				#elif _WRAPMODE_REPEAT
					uv = saturate(i.uv);
					#if _HORIZONTAL_ON
					   uv.x = frac(i.uv.x); 
					#endif
					#if	_VERTICAL_ON
					   uv.y = frac(i.uv.y);
					#endif

				#elif _WRAPMODE_MIRROR
					uv = saturate(i.uv);
					#if _HORIZONTAL_ON
					   uv.x = abs(i.uv.x); 
					#endif
					#if	_VERTICAL_ON
					   uv.y = abs(i.uv.y);
					#endif
				#endif


				fixed4 col = tex2D(_MainTex, uv);

				return col;
			}
			ENDCG
		}
	}
}
