Shader "UnityShaderPool/QQpractice/qqBlinnPhong"
{
	Properties
	{
		_Color("Diffuse", Color) = (1,1,1,1)
		//Question: Why I can't use fixed here?
		_Ambient("Ambient", float) = 0.1
		_SpecGloss("SpecGloss", float) = 50
		_SpecPower("SpecPower", float) = 1
		_Switch("Phong&BlinPhong", Range(0.0,1.0)) = 0
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			//Question: Why _WorldSpaceLightPos0 will be incorrect without LightMode tag?
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _LightColor0;
			uniform fixed4 _Color;
			uniform fixed _Ambient;
			uniform fixed _SpecGloss;
			uniform fixed _SpecPower;
			uniform fixed _Switch;

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed3 normal : TEXCOORD0;
				fixed3 pos : TEXCOORD1;
				fixed3 lightDir : TEXCOORD2;
				fixed3 viewDir : TEXCOORD3;
				//Question: is it appropriate to use so many texcoord?
				fixed3 worldNormal : TEXCOORD4;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.pos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//Question: Do i really need the normalize function?
				o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.pos);
				//Question: will normal here be interpolated?
				//o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, o.normal));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 col;
				fixed3 lightDir = i.lightDir;
				fixed3 viewDir = i.viewDir;

				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));
				//Question: Is there a way better to replace if else?
				if (_Switch < 0.5) {

					fixed3 diffuse = dot(worldNormal, lightDir);
					fixed3 reflect = normalize((2.0*i.normal * diffuse) - lightDir);
					fixed3 specular = pow(saturate(dot(reflect, viewDir)), _SpecGloss);
					col = _Color * (diffuse*_LightColor0 + _Ambient) + _SpecPower * specular * _LightColor0;
				}
				else {
					fixed3 diffuse = dot(worldNormal, lightDir);
					//Question: how to increase the specular accuracy?
					fixed3 halfvector = normalize(viewDir + lightDir);
					fixed3 specular = pow(saturate(dot(halfvector, worldNormal)), _SpecGloss);
					col = _Color * (diffuse*_LightColor0 + _Ambient) + _SpecPower * specular * _LightColor0;
				}

				return fixed4(col, 1.0);
			}
		ENDCG
		}
	}
}
