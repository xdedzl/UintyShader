Shader "Custom/UI/Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _XDistance ("XDistance", Range(-1,1)) = 1
        _YDistance ("YDistance", Range(-1,1)) = 1
        _Velocity ("Velocity", float) = 1
        _BarkgroundColor ("BarkgroundColor", Color) = (1,1,1,0)
        // _BarkgroundTex ("BarkgroundTex", 2D) = "white" {}
    }
    SubShader
    {
        Pass{
            Tags { "RenderType"="Opaque" }
            
			Blend SrcAlpha OneMinusSrcAlpha   // 设置混合模式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"


            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
			};

            struct v2f{
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD2;
            };

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float4 _Color;
            float _XDistance;
            float _YDistance;
            float _Velocity;
            float4 _BarkgroundColor;
            sampler2D _BarkgroundTex;

            float rand(float2 c){
                return frac(sin(dot(c.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

            v2f vert (a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex); 
                o.uv = TRANSFORM_TEX(i.texcoord,_MainTex);
                // o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i) : SV_TARGET{

                float2 uv = i.uv;
                float2 offset = sin(_Time.y * _Velocity) * sin(_Time.y * _Velocity) * float2(_XDistance, _YDistance); 
                float r = rand(uv); 
                uv -= r * offset;
                float4 c = tex2D(_MainTex,uv).rgba;

                float2 absOffset = abs(offset);
                float2 n = normalize(uv.xy - offset);
                float d = dot(offset, n);

                if (d < 0.0) {
                    return _BarkgroundColor * _Color; 
                }

                return c * _Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}