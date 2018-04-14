// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Mya/Stage2/screenPosUV(VSshader)"
{
	Properties
	{
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Tilling("Tilling" , Range(0,10)) = 1
	}
	SubShader
	{
        Tags {"Queue" = "Geometry"  "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 screenPos: TEXCOORD1;
				
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

        	float4 _MainTint;
        	float  _Tilling;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.screenPos.xy/i.screenPos.w *  _Tilling);
				return col;
			}
			ENDCG
		}
	}
}
