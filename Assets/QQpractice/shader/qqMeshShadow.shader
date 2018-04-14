Shader "UnityShaderPool/QQpractice/qqMeshShadowTest"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_ShadowColor("ShadowColor", Color) = (0.2,0.2,0.2,1)
		_Ground("Ground height",float) = 0
		_shadowFalloff("Shadow Falloff",float) = 0.5
	}
	SubShader
	{
		//Question: Why I write these tags in Pass without error but won't work?
		//Question: what's the difference of RenderType and LightMode?
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//IMPORTANT! must be used with "LightMode" = "ForwardBase" or the render queue will be wrong
			#define UNITY_PASS_FORWARDBASE

			uniform float4 _ShadowColor;
			uniform float _Ground;
			uniform float _shadowFalloff;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float4 vertex = float4 (worldPos.xyz - (max(0,worldPos.y - _Ground) / lightDir.y) * lightDir.xyz,1);
				o.vertex = mul(UNITY_MATRIX_VP, vertex);

				//物体的中点是怎么通过unity_ObjectToWorld得到的？
				float3 center = float3(unity_ObjectToWorld[0].w, _Ground, unity_ObjectToWorld[2].w);
				float shadowDistance = distance(vertex.xyz, center);
				o.color = float4(_ShadowColor.xyz, 1 - saturate(shadowDistance*_shadowFalloff));
				//o.color = float4(_ShadowColor.xyz, 0);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return i.color;
			}
		ENDCG
		}

		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{ "Queue" = "Opaque" "LightMode" = "ForwardBase" }
			ZWrite on
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			uniform float4 _Color;
			struct appdata {
				float4 vertex : POSITION;
			};
			struct v2f {
				float4 vertex : SV_POSITION;
			};
			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			fixed4 frag(v2f i) : SV_Target{
				return _Color;
			}
		ENDCG
		}
	}
}
