//vert frag deferred: http://kylehalladay.com/blog/tutorial/2015/01/03/Deferred-Pixel-Shaders.html
//surface deferred: http://kylehalladay.com/blog/tutorial/2014/04/05/Writing-Shaders-For-Deferred-Lighting-Unity.html

Shader "UnityShaderPool/Templates/baseDeferred"
{
	Properties{
		_MainTex("Base (RGB)", 2D) = "white"{}
	_SpecColor("Specular Color", Color) = (0.5,0.5,0.5,1)
		_Shininess("Shininess", Range(0.01,1)) = 0.078125
	}
		SubShader{
		//Draw Data Into the G Buffer: PrePassBase
		Pass{
		Tags{ "LightMode" = "PrePassBase" }
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag		
		uniform float _Shininess;

	struct vIN
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};
	struct vOUT
	{
		float4 pos : SV_POSITION;
		float3 wNorm : TEXCOORD0;
	};
	vOUT vert(vIN v)
	{
		vOUT o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.wNorm = mul((float3x3)unity_ObjectToWorld, v.normal);
		return o;
	}

	float4 frag(vOUT i) : COLOR
	{
		float3 norm = (i.wNorm * 0.5) + 0.5;
		return float4(norm, _Shininess);
	}
		ENDCG
	}

		//Getting Data Out of Light Buffer
		Pass{
		Tags{ "LightMode" = "PrePassFinal" }
		ZWrite off
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

		sampler2D _MainTex;
	uniform float4 _SpecColor;
	uniform sampler2D _LightBuffer;

	struct vIN
	{
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct vOUT
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 uvProj : TEXCOORD1;
	};

	vOUT vert(vIN v)
	{
		vOUT o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float4 posHalf = o.pos * 0.5;
		posHalf.y *= _ProjectionParams.x;

		o.uvProj.xy = posHalf.xy + float2(posHalf.w, posHalf.w);
		o.uvProj.zw = o.pos.zw;
		o.uv = v.texcoord;

		return o;
	}

	float4 frag(vOUT i) : COLOR
	{
		float4 light = tex2Dproj(_LightBuffer, i.uvProj);
		float4 logLight = -(log2(max(light, float4(0.001,0.001,0.001,0.001))));
		float4 texCol = tex2D(_MainTex, i.uv);
		return float4((texCol.xyz * light.xyz) + float3(_SpecColor.xyz) * light.w, texCol.w);
	}

		ENDCG
	}

		//shadow caster pass
		Pass{

	}
	}
}