//From:  https://www.alanzucconi.com/2015/07/08/screen-shaders-and-postprocessing-effects-in-unity3d/
Shader "UnityShaderPool/Templates/basePostprocess" {
	Properties{
		//when using Graphics.Blit(source, destination, material) source is feed into _MainTex
		_MainTex("Base (RGB)", 2D) = "white" {}
	_bwBlend("Black & White blend", Range(0, 1)) = 0
	}
		SubShader{
		Pass{
		CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag

#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
	uniform float _bwBlend;

	float4 frag(v2f_img i) : COLOR{
		float4 c = tex2D(_MainTex, i.uv);

		float lum = c.r*.3 + c.g*.59 + c.b*.11;
		float3 bw = float3(lum, lum, lum);

		float4 result = c;
		result.rgb = lerp(c.rgb, bw, _bwBlend);
		return result;
	}
		ENDCG
	}
	}
}

/*
//From: shader effect cook book Chapter8
Shader "Custom/basePostprocess" {
Properties{
_MainTex("Base (RGB)", 2D) = "white" {}
_Color("Color", Color) = (1,1,1,1)
_bwBlend("Black & White blend", Range(0, 1)) = 0
}
SubShader{
Pass{
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
fixed _bwBlend;

//v2f_img is unity defined v2f of screen for postprocess
fixed4 frag(v2f_img i) : COLOR
{
fixed4 renderTex = tex2D(_MainTex, i.uv);

float luminosity = 0.299 * renderTex.r + 0.587 * renderTex.g + 0.114 * renderTex.b;
fixed4 finalColor = lerp(renderTex, luminosity, _bwBlend);
return finalColor;
}

ENDCG
}

}
FallBack "Diffuse"
}
*/