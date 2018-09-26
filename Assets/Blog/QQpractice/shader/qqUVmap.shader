Shader "UnityShaderPool/QQpractice/qqUVmap"
{
	Properties
	{
		_MainTex("Texture",2D) = "black" {}
		_Color("Diffuse", Color) = (1,1,1,1)
		_Ambient("Ambient", float) = 0.1
		_Switch("tex&anim&proj", Range(0.0,1.0)) = 0
		_UVspeed("UVspeed", float) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{

			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform fixed4 _LightColor0;
			uniform fixed4 _Color;
			uniform fixed _Ambient;
			uniform sampler2D _MainTex;
			uniform fixed _Switch;
			uniform fixed _UVspeed;

			//unity defined for tiling and offset: _TextureName_ST
			uniform fixed4 _MainTex_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 tex : TEXCOORD0;
				float4 pos : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = mul(unity_ObjectToWorld, v.vertex);
				o.tex = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//UnityObjectToClipPos和ComputeScreenPos 有什么区别?
				fixed4 clipPos = UnityObjectToClipPos(i.pos);
				fixed4 screenUV = ComputeScreenPos(clipPos);

				//function for sampling texture
				fixed4 tex;
				
				if (_Switch <= 0.25)
					tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				else if (_Switch>0.3&&_Switch<0.5)
					tex = tex2D(_MainTex, i.pos.xz * _MainTex_ST.xy + _UVspeed * _Time.x + _MainTex_ST.zw);
				else if (_Switch>0.5&&_Switch<0.75)
					tex = tex2D(_MainTex, i.pos.xz * _MainTex_ST.xy + _MainTex_ST.zw);
				else
					tex = tex2D(_MainTex, screenUV.xy/screenUV.w);

				return tex;
			}
		ENDCG
		}
	}
}
