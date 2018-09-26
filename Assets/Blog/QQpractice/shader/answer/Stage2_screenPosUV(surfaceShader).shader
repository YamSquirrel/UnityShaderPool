Shader "Mya/Stage2/screenPosUV(surfaceShader)" {
 Properties 
    {
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Tilling("Tilling" , Range(0,10)) = 1
    }
    
    SubShader 
    {
        Tags {"Queue" = "Geometry"  "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert
        

        sampler2D _MainTex;
        float4 _SpecularColor;
        float4 _MainTint;
        float  _Tilling;

        struct Input 
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        void surf (Input IN, inout SurfaceOutput o) 
        {
            half4 c = tex2D (_MainTex, IN.screenPos.xy/IN.screenPos.w * _Tilling) * _MainTint;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}