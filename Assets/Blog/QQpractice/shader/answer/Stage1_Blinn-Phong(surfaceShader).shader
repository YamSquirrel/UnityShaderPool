Shader "Mya/Blinn-Phong(surfaceShader)" {
 Properties 
    {
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(0,1)) = 1
    }
    
    SubShader 
    {
        Tags {"Queue" = "Geometry"  "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf MyBlinnPhong
        

        sampler2D _MainTex;
        float4 _SpecularColor;
        float4 _MainTint;
        float _Gloss , _Specular;
        
        inline fixed4 LightingMyBlinnPhong (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            fixed4 c;
			//漫反射光照计算
            float diff =max (0,  dot(s.Normal, lightDir));

			//下面两行是为Phong光照模型高光算法
            //float3 reflectionVector = normalize((2.0 * s.Normal * diff) - lightDir);
			//float spec = pow(max(0,dot(reflectionVector, viewDir)), _SpecPower);

			//以下为Blinn-Phong光照模型高光算法
            fixed3 halfDir = normalize(lightDir + viewDir);  
			fixed3 NormalDir = normalize(s.Normal);
			float spec = pow(max(0,dot(halfDir, NormalDir)),  s.Gloss*128.0);

			//高光颜色
            float3 finalSpec = _SpecularColor.rgb * spec;
            
            c.rgb = (s.Albedo * _LightColor0.rgb * diff) + (_LightColor0.rgb * finalSpec);

			//加上阴影的影响
			c.rgb *=atten;

            c.a = 1.0;

            return c;
        }

        struct Input 
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o) 
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
            o.Albedo = c.rgb;
			o.Gloss = _Gloss;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}