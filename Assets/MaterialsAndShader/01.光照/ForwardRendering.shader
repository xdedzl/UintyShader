Shader "Unity Shaders Book/Chapter 9/Forward Rendering"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        pass{
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // 保证光照衰减等光照变量可以被正确赋值
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v{
                float3 normal : NORMAL
                float4 vertex : POSITION
            };

            struct v2f{
                float4 pos : SV_POSITION
                fixed3 worldNormal : TEXCOORD0
                fixed3 worldPos : TEXCOORD1
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
            }


            fixed4 frag(v2f i){
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse - _LightColor0.rgb * _Diffuse.rgb
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}