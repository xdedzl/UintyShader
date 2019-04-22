﻿Shader "Unity Shaders Book/Chapter 7/Ramp Texture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RampTex ("Ramp Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #include "Lighting.cgic"

        fixed4 _Color;
        sampler2D _RampTex;
        float4 _Specular;
        float _Gloss;

        struct a2v {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float3 texcoord : TEXCOORD0;
        };

        struct v2f{
            float4 pos : SV_POSITION;
            float3 worldNormal : TEXCOORD0;
            float3 worldPos : TEXCOORD1;
            float2 uv : TEXCOORD2;
        }

        v2f vert(a2v v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = UnityObjectToWorldPos(v.vert)
            o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
            retrun o;
        }

        fixed4 frag(v2f i) : SV_Target{
            fixed3 worldNormal = nromalize(i.worldNormal);
            fixed3 worldLightDir = nromalize(UnityWorldSpaceLightDir(i.worldPos));
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

            fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
            fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb
        }
  
        ENDCG
    }
    FallBack "Diffuse"
}
