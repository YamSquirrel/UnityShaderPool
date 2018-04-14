Shader "Mya/Stage2/uvFlow(surfaceShader)" {
 Properties 
    {
        _MainTint ("Diffuse Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _FlowX("Flow for X" , float) = 0
        _FlowY("Flow for Y" , float) = 0
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
        float _FlowX , _FlowY;

        struct Input 
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 screenPos;
        };

        void surf (Input IN, inout SurfaceOutput o) 
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex + _Time.yy * float2(_FlowX,_FlowY)) * _MainTint;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}