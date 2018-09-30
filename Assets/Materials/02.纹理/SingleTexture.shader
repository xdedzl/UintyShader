// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Single Texture"{

	Properties{
		_Color("Color Tint", Color)
		_MainTex("Main Tex", 2D)
		_Specular("Specular",Color)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

		SubShader{
			Pass{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Specular;
				float4 _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2c v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.wroldNormal = UnityObjectToWorldNormal(v.normal);
					o.wroldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					o.uv = v.texcoord.xy * _MainTex.ST.xy + _MainTex.ST.zw;
					return o;
				}

				fixed4 frag

			ENDCG
		}
	}
}