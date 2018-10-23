// 参考Unity Standard Shader
// 暂时不考虑以下情况：
//		灯光贴图、灯光探针、反射探针
//		ForwardAdd、Deferred、Meta

Shader "Move/PBR_Base_Core"
{
	Properties
	{
		_Color("颜色", Color) = (1,1,1,1)
        _MainTex("漫反射纹理(RGB)透明通道(A)", 2D) = "white" {}

        _Roughness ("粗糙度",Float) = 1
        _RoughnessMap("粗糙度贴图", 2D) = "white" {}
        _Metallic ("金属度",Float) = 1
        _MetallicMap("金属度贴图", 2D) = "white" {}

        _BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Float) = 1.0
        
        [Toggle(ENABLE_PARALLAX)] _EnableParallax("是否使用视差效果?",Float) = 0
        _HeightScale ("视差缩放", Range (0.005, 0.08)) = 0.02
		_HeightMap ("视差图", 2D) = "black" {}

        _OcclusionStrength("AO 强度", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("AO 贴图", 2D) = "white" {}

		_EnvMap("环境贴图",Cube) = "_Skybox"{}
        _EnvColor ("环境颜色",Color) = (1,1,1,0.5) 
        _EnvScale ("环境强度",Float) = 1.0

        _Cutoff("Alpha 剔除",Range(0,1)) = 0.5

       	[Enum(Off,0,On,1)] _ZWrite ("是否写入深度:",Float) = 1
       	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试模式:",Float) = 4
       	[Enum(UnityEngine.Rendering.CullMode)] _Cull("裁剪模式:",Float) = 2
       	[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src 混合模式:",Float) = 1
       	[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst 混合模式:",Float) = 0

       	[Toggle(ENABLE_EMISSION)] _EnableEmission("是否使用自发光?",Float) = 0
        _EmissionColor("自发光颜色", Color) = (0,0,0)
        _EmissionIntensity ("自发光强度",Float) = 1
        _EmissionMap("自发光贴图", 2D) = "white" {}

        [Toggle(ENABLE_ADVANCED_EMISSION)] _EnableAdvancedEmission("是否启用高级自发光效果?",Float) = 0
        
        _MaskU("U方向遮罩色阶参数:iMin(x)iMax(y)oMin(z)oMax(w)",Vector) = (0,1,0,1)
		_MaskV("V方向遮罩色阶参数:iMin(x)iMax(y)oMin(z)oMax(w)",Vector) = (0,1,0,1)

		_UVAnimScale ("UV动画摆动幅度",Float) = 1
		_UVAnimSpeed ("UV动画速度",Float) = 1

        _Cos_Ux("UCos_x:振幅(x)周期(y)速度(z)相位(w)",Vector) = (0,1,0,0)
        _Cos_Uy("UCos_y:振幅(x)周期(y)速度(z)相位(w)",Vector) = (0,1,0,0)
        _Cos_Vy("VCos_y:振幅(x)周期(y)速度(z)相位(w)",Vector) = (0,1,0,0)
        _Cos_Vx("VCos_x:振幅(x)周期(y)速度(z)相位(w)",Vector) = (0,1,0,0)

        _Color1 ("自发光颜色1",Color) = (1,1,1,1)
        _ValueSlider1 ("自发光颜色1的范围",Range(-1,1)) = 0
        
        _Color2 ("自发光颜色2",Color) = (1,1,1,1)
        _ValueSlider2 ("自发光颜色2的范围",Range(-1,1)) = 0
        
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }



		Pass
		{
			Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Cull]

            CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase
			
			#pragma shader_feature ENABLE_PARALLAX
			#pragma shader_feature ENABLE_EMISSION
			#pragma shader_feature ENABLE_ADVANCED_EMISSION
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			// #include "UnityStandardBRDF.cginc"
			// #include "UnityLightingCommon.cginc"

			#ifdef UNITY_COLORSPACE_GAMMA 
				#define unity_ColorSpaceGrey fixed4(0.5, 0.5, 0.5, 0.5)
				#define unity_ColorSpaceDouble fixed4(2.0, 2.0, 2.0, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
				#define unity_ColorSpaceLuminance half4(0.22, 0.707, 0.071, 0.0) // Legacy: alpha is set to 0.0 to specify gamma mode 
			#else // Linear values 
				#define unity_ColorSpaceGrey fixed4(0.214041144, 0.214041144, 0.214041144, 0.5)
				#define unity_ColorSpaceDouble fixed4(4.59479380, 4.59479380, 4.59479380, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%) 
				#define unity_ColorSpaceLuminance half4(0.0396819152, 0.458021790, 0.00609653955, 1.0) // Legacy: alpha is set to 1.0 to specify linear mode
			#endif

			#define UNITY_SPECCUBE_LOD_STEPS (6)
			
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				half4 tangent : TANGENT;
				half3 normal : NORMAL;
			};

			struct v2f_forwardbase
			{
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float3 eyeVec : TEXCOORD1;
				float4 tangentToWorld_tangentView[3] : TEXCOORD2;
				half4 ambient : TEXCOORD5;
				UNITY_SHADOW_COORDS(6)
				float3 worldPos : TEXCOORD7;
			};

			fixed4 _Color; 
			fixed4 _LightColor0;
			sampler2D _MainTex; float4 _MainTex_ST;			
			sampler2D _OcclusionMap; half _OcclusionStrength;
			sampler2D _HeightMap; half _HeightScale;
			sampler2D _RoughnessMap; half _Roughness;
			sampler2D _MetallicMap; half _Metallic;
			sampler2D _BumpMap; half _BumpScale;
			samplerCUBE _EnvMap; half4 _EnvColor; half _EnvScale;
			half _Cutoff;

			sampler2D _EmissionMap; half4 _EmissionColor; half _EmissionIntensity; 
			// UV Anim
			half4 _MaskU,_MaskV;
			half4 _Cos_Ux,_Cos_Uy,_Cos_Vy,_Cos_Vx;
			float4 _EmissionMap_ST;
			float _ValueSlider1, _ValueSlider2;
			fixed4 _Color1,_Color2;
			float _UVAnimScale,_UVAnimSpeed;

			inline half Remap(float Val,float iMin,float iMax,float oMin,float oMax)
			{
				return (oMin + ((Val - iMin) * (oMax - oMin))/(iMax - iMin));
			}

			inline half3 Remap(float3 Val,float iMin,float iMax,float oMin,float oMax)
			{
				return (oMin + ((Val - iMin) * (oMax - oMin))/(iMax - iMin));
			}

			half3 AdvancedEmission(float2 i_tex)
			{
				float timeGO = _Time.y*_UVAnimSpeed;
				float2 uv = i_tex.xy * _EmissionMap_ST.xy + _EmissionMap_ST.zw;

				float mask = saturate(Remap(uv.x,_MaskU.x,_MaskU.y,_MaskU.z,_MaskU.w)) * saturate(Remap(uv.y,_MaskV.x,_MaskV.y,_MaskV.z,_MaskV.w));

                float uOffset = _Cos_Ux.x * cos(uv.x * _Cos_Ux.y + timeGO * _Cos_Ux.z+ _Cos_Ux.w) ;
                uOffset += _Cos_Uy.x * cos(uv.y * _Cos_Uy.y + timeGO * _Cos_Uy.z+ _Cos_Uy.w) ;
                
                float vOffset = _Cos_Vy.x * cos(uv.y * _Cos_Vy.y + timeGO * _Cos_Vy.z+ _Cos_Vy.w) ;
                vOffset += _Cos_Vx.x * cos(uv.x * _Cos_Vx.y + timeGO * _Cos_Vx.z+ _Cos_Vx.w) ;

				uv += float2(uOffset,vOffset)*mask*_UVAnimScale;
				half3 col = tex2D(_EmissionMap,uv).rgb;
				half texVal = saturate(dot(col.rgb,float3(0.3,0.59,0.11)));

				col = saturate(texVal + _ValueSlider1) * _Color1;
				col +=  lerp(col,_Color2,saturate(texVal + _ValueSlider2) );
				col *=  _EmissionColor.rgb *_EmissionIntensity;
				return col;
			}

			v2f_forwardbase vert (appdata v)
			{
				v2f_forwardbase o = (v2f_forwardbase)0;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = TRANSFORM_TEX(v.uv0, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.eyeVec = normalize( o.worldPos.xyz - _WorldSpaceCameraPos);
				

				half3 normalWorld = UnityObjectToWorldNormal(v.normal);
				half3 tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
				half3 binormalWorld = cross(normalWorld,tangentWorld) * v.tangent.w;

				o.tangentToWorld_tangentView[0].xyz = tangentWorld;
				o.tangentToWorld_tangentView[1].xyz = binormalWorld;
				o.tangentToWorld_tangentView[2].xyz = normalWorld;

				float3x3 rotation = float3x3(tangentWorld,binormalWorld,normalWorld);
				half3 viewDirForParallax = mul (rotation, UnityWorldSpaceViewDir(o.worldPos));
				
				o.tangentToWorld_tangentView[0].w = viewDirForParallax.x;
				o.tangentToWorld_tangentView[1].w = viewDirForParallax.y;
				o.tangentToWorld_tangentView[2].w = viewDirForParallax.z;
				
				o.ambient.rgb = Shade4PointLights (
	                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
	                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
	                unity_4LightAtten0, o.worldPos, normalWorld);

				o.ambient.rgb += UNITY_LIGHTMODEL_AMBIENT.rgb;
				UNITY_TRANSFER_SHADOW(o, v.uv1);
				return o;
			}
			
			struct FragmentData
			{
				 half3 diffColor,specColor;
				 half oneMinusReflectivity,roughness;
				 float3 normalWorld,eyeVec,posWorld;
				 half alpha;
			}; 


			FragmentData FragmentSetup(inout float2 i_tex,float3 i_eyeVec,half3 i_viewDirForParallax ,float4 tangentToWorld[3],float3 i_posWorld)
			{
				FragmentData s = (FragmentData)0;

				#ifdef ENABLE_PARALLAX// Parallax
					float2 offset = ParallaxOffset(tex2D(_HeightMap,i_tex.xy).g,_HeightScale,i_viewDirForParallax);
					i_tex += offset.xy;
				#endif
				// Normal
				half3 normalTangent = UnpackNormal(tex2D(_BumpMap,i_tex.xy));
				normalTangent = lerp(float3(0,0,1),normalTangent,_BumpScale);
				s.normalWorld = normalize(tangentToWorld[0].xyz * normalTangent.x + tangentToWorld[1].xyz * normalTangent.y + tangentToWorld[2].xyz * normalTangent.z);

				fixed4 mainTex = tex2D(_MainTex,i_tex.xy);
				s.diffColor = _Color.rgb * mainTex.rgb;
				s.alpha = mainTex.a;

				half metallic = tex2D(_MetallicMap,i_tex.xy).r * _Metallic;
				half roughness = tex2D(_RoughnessMap,i_tex.xy).r * _Roughness;

				s.specColor = lerp(unity_ColorSpaceDielectricSpec.rgb ,s.diffColor,metallic);
				s.oneMinusReflectivity = (1-metallic) * unity_ColorSpaceDielectricSpec.a;

				s.diffColor *= s.oneMinusReflectivity;
				s.roughness = roughness;
				s.eyeVec = normalize(i_eyeVec);

				return s;

			}

			struct GI
			{
				half3 color;
				half3 dir;

				half3 indirectDiffuse;
				half3 indirectSpecular;
			}; 

			GI FragmentGI(FragmentData s,half occlusion,half4 i_ambient,half atten,half3 lightColor,half3 worldSpaceLightDir)
			{
				GI gi = (GI)0;
				gi.color = lightColor * atten;
				gi.dir = worldSpaceLightDir;

				// SH完全逐顶点计算,只是在这里做Gamma矫正
				gi.indirectDiffuse = i_ambient; 
				#ifdef UNITY_COLORSPACE_GAMMA
					gi.indirectDiffuse = LinearToGammaSpace(gi.indirectDiffuse);
				#endif
				gi.indirectDiffuse *= occlusion;
				
				/// EnvCol
				float3 reflUVW = reflect(s.eyeVec,s.normalWorld);
				half perceptualRoughness = s.roughness;
				perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);
				half mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = texCUBElod(_EnvMap,half4(reflUVW,mip)) * _EnvColor * _EnvScale;

			
    			half3 envCol = DecodeHDR(rgbm,unity_SpecCube0_HDR);

				gi.indirectSpecular = envCol * occlusion;
				return gi;
			}

			inline half Pow5 (half x)
			{
			    return x*x * x*x * x;
			}

			// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
			half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
			{
			    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
			    // Two schlick fresnel term
			    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
			    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

			    return lightScatter * viewScatter;
			}

			inline float GGXTerm (float NdotH, float roughness)
			{
			    float a2 = roughness * roughness;
			    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
			    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
			                                            // therefore epsilon is smaller than what can be represented by half
			}
			
			inline half SmithJointGGXVisibilityTerm (half NdotL, half NdotV, half roughness)
			{
				half a = roughness;
			    half lambdaV = NdotL * (NdotV * (1 - a) + a);
			    half lambdaL = NdotV * (NdotL * (1 - a) + a);

			    return 0.5f / (lambdaV + lambdaL + 1e-5f);
			}

			inline half3 FresnelTerm (half3 F0, half cosA)
			{
			    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
			    return F0 + (1-F0) * t;
			}

			inline half3 FresnelLerp (half3 F0, half3 F90, half cosA)
			{
			    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
			    return lerp (F0, F90, t);
			}
			
		

			inline half3 RemapLerp(half3 F0,half3 F90,half val)
			{
				half t = saturate(Remap(val,0.95,1,0,1));
				return lerp (0, F0 ,t) ;
			}

			// Diffuse:Disney
			// Specular: 基于Torrance-Sparrow micro-facet 光照模型
			// 		NDF: GGX ; V项: Smith; Fresnel: Schlick的近似
			//   BRDF = kD / pi + kS * (D * V * F) / 4
			//   I = BRDF * NdotL
			// HACK: 这里没有给漫反射项除 pi，并且给高光项乘pi。
			// 原因是：防止在引擎中的结果和传统的相比太暗；SH和非重要的灯光也得除pi;
			half4 BRDF_PBS(FragmentData s,GI gi)
			{
				float perceptualRoughness = s.roughness;
				float roughness = perceptualRoughness * perceptualRoughness;

				float3 lightDir = gi.dir;
				float3 viewDir = -s.eyeVec;
				float3 normal = s.normalWorld;
				float3 halfDir = normalize (lightDir + viewDir);

				half nv = saturate(dot(normal,viewDir));
				half nl = saturate(dot(normal,lightDir));
				float nh = saturate(dot(normal, halfDir));
				half lv = saturate(dot(lightDir, viewDir));
    			half lh = saturate(dot(lightDir, halfDir));

    			// DiffuseTerm
    			half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    			// SpecularTerm: GGX
    			roughness = max(roughness,0.002);
    			half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    			float D = GGXTerm (nh, roughness);

    			half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later
    			#ifdef UNITY_COLORSPACE_GAMMA
        			specularTerm = sqrt(max(1e-4h, specularTerm));
				#endif
        		
        		specularTerm = max(0, specularTerm * nl);

			    half surfaceReduction;
				#ifdef UNITY_COLORSPACE_GAMMA
			        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
				#else
			        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
				#endif

			    half grazingTerm = saturate(1-perceptualRoughness + (1-s.oneMinusReflectivity));

			    // HACK: 环境光太暗，所以默认乘4；加强金属光感
			    half3 color =   s.diffColor * (gi.indirectDiffuse + gi.color * diffuseTerm) 
                    + specularTerm * gi.color * FresnelTerm (s.specColor, lh) 
                    + surfaceReduction * gi.indirectSpecular * FresnelLerp (s.specColor, grazingTerm, nv) * 4 + surfaceReduction * RemapLerp(s.specColor,grazingTerm,nh);

                return half4(color,1);
			}

			

			fixed4 frag (v2f_forwardbase i) : SV_Target
			{
				FragmentData s = FragmentSetup(i.tex,i.eyeVec,
					half3(i.tangentToWorld_tangentView[0].w,i.tangentToWorld_tangentView[1].w,i.tangentToWorld_tangentView[2].w),
					i.tangentToWorld_tangentView,i.worldPos);
				
				UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld); 

				half occlusion = lerp(1,tex2D(_OcclusionMap,i.tex.xy).g,_OcclusionStrength);

				GI gi = FragmentGI(s,occlusion,i.ambient,atten,_LightColor0.rgb,_WorldSpaceLightPos0.xyz);

				half4 col = BRDF_PBS(s,gi);
				
				/*
				UnityLight mainLight;
				mainLight.color = gi.color;
				mainLight.dir = gi.dir;

				UnityIndirect idirect;
				idirect.diffuse = gi.indirectDiffuse;
				idirect.specular = gi.indirectSpecular;


				half4 col = BRDF3_Unity_PBS (s.diffColor,s.specColor,s.oneMinusReflectivity,1-s.roughness,s.normalWorld,-s.eyeVec,mainLight,idirect);
				*/

				#ifdef ENABLE_EMISSION
					#ifdef ENABLE_ADVANCED_EMISSION
						col.rgb += AdvancedEmission(i.tex.xy);
						//return AdvancedEmission(i.tex.xy).xyzx;
					#else
						col.rgb += tex2D(_EmissionMap,i.tex.xy).rgb * _EmissionColor.rgb * _EmissionIntensity;
					#endif
				#endif

				col.a = s.alpha;
				clip(col.a - _Cutoff);
				return col;
			}
			ENDCG
		}
      

	}

	Fallback "Diffuse"
}
