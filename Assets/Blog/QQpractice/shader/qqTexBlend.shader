Shader "UnityShaderPool/QQpractice/qqTexBlend"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_SecTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		//How to create 1.Alpha Test 2.Transparent ???
		Tags{ "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off
		LOD 100

		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SecTex;
			float4 _SecTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 topCol = tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 baseCol = tex2D(_SecTex, i.uv * _SecTex_ST.xy + _SecTex_ST.zw);
				fixed4 finalCol = (baseCol.xyz, baseCol.x);
				return finalCol;
			}
		ENDCG
		}
	}
}
