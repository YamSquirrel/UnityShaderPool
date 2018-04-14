Shader "UnityShaderPool/Templates/baseFrag"
{
	Properties
	{
		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess("Shininess", Float) = 10
		_MainTex("Diffuse Texture", 2D) = "white" {}
	}
		SubShader
	{
		////////////////////////////////////Subshader Tags//////////////////////////////////////////
		//Documentation https://docs.unity3d.com/Manual/SL-SubShaderTags.html
		//Queue: 
		//Background(1000) Geometry(2000 default) AlphaTest(2400) 
		//Transparent(3000 no depth) Overlay(4000 postprocess)
		//RenderType: 
		//opaque transparent TransparentCutout Skybox shaders
		//https://blog.csdn.net/mobilebbki399/article/details/50512059
		//https://blog.csdn.net/nnsword/article/details/17840439
		////////////////////////////////////////////////////////////////////////////////////////////
		Tags{ "Queue" = "Geometry+1" "RenderType" = "opaque" }
		//////////////////////////////////////////LOD///////////////////////////////////////////////
		//https://docs.unity3d.com/Manual/SL-ShaderLOD.html
		//VertexLit kind of shaders = 100; Decal, Reflective VertexLit = 150; Diffuse = 200
		//Bumped, Specular = 300; Bumped Specular = 400; Parallax Specular = 600
		//Unity use Shader.maximumLOD to select the subshader to use
		////////////////////////////////////////////////////////////////////////////////////////////
		LOD 300

		Pass
	{
		///////////////////////////////////////Pass Tags////////////////////////////////////////////
		//Documentation https://docs.unity3d.com/Manual/SL-PassTags.html
		//LightMode:
		//Always ForwardBase ForwardAdd Deferred ShadowCaster MotionVectors
		////////////////////////////////////////////////////////////////////////////////////////////
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		/////////////////////////////////////Compilation Target/////////////////////////////////////
		//https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
		//#pragma geometry need target 4.0 tessellation(#pragma hull or #pragma domain)  need target 4.6
		//default target 2.5 DX9 target 3.0 DX11 target 4.0
		////////////////////////////////////////////////////////////////////////////////////////////
#pragma target 3.0

		//user defined variables
		uniform float4 _Color;
	uniform float4 _SpecColor;
	uniform float _Shininess;
	uniform sampler2D _MainTex;

	//unity defined variables;
	uniform float4 _LightColor0;

	///////////////////////////////////////semantics////////////////////////////////////////////
	//VertexInput:
	//TEXCOORD0 (float2 texcoord) POSITION (float4) NORMAL (float3) TANGENT (float4) COLOR(fixed4)
	//VertexOutput:
	//SV_POSITION (float4 裁剪空间顶点坐标) COLOR0 COLOR1(float4 第一组第二组颜色) TEXCOORD0-7 (纹理坐标)
	//SV_Target(Render to Target)
	//TEXCOORD POSITION在输入Fragment时候都被interpolate过了
	////////////////////////////////////////////////////////////////////////////////////////////

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

	vertexOutput vert(vertexInput v) {
		vertexOutput o;

		/////////////////////////////////UnityShaderVariables///////////////////////////////////////
		// https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
		//UNITY_MATRIX_MVP model*view*projection; UNITY_MATRIX_M model; UNITY_MATRIX_V view; UNITY_MATRIX_P projection;
		//unity_ObjectToWorld model; unity_WorldToObject InverseWorld;
		//_WorldSpaceCameraPos; _ProjectionParams; unity_CameraProjection;
		//_LightColor0; _WorldSpaceLightPos0; _LightMatrix0; unity_LightColor; unity_WorldToShadow;
		////////////////////////////////////////////////////////////////////////////////////////////

		o.pos = UnityObjectToClipPos(v.vertex);
		o.tex = v.texcoord;
		o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

		return o;
	}

	fixed4 frag(vertexOutput i) : COLOR
	{

		//vectors
		float3 normalDirection = i.normalDir;
		float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
		float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

		//Sample texture
		float4 tex = tex2D(_MainTex, i.tex.xy);

		//lighting
		float3 diffuseReflection = _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
		float3 specularReflection = _LightColor0.xyz * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

		//Output
		float4 dif = float4 (diffuseReflection, 1.0);
		float4 spec = float4 (specularReflection, 1.0);
		float4 col = _Color * tex * (dif + UNITY_LIGHTMODEL_AMBIENT) + spec;
		return col;
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}