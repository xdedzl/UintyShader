﻿Shader "Custom/Transfer"
{
    Properties
    {
		_Color("Main Tint", Color) = (1,1,1,1)
        _TopColor("Top Color",Color) = (1,1,1,1)
        _MainTex("Main Tex",2D) = "white"{}
        _WorldHeight("World Height", Float) = 0.5
    }
    SubShader
	{
		//    指定渲染队列             不受投影器影响              归入提前定义的组
		Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}

		Pass{
			Tags { "LightMode" = "ForwardBase"}
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
            fixed4 _TopColor;
            float _WorldHeight;
            sampler2D _MainTex;
            float4 _MainTex_ST;

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

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

                fixed3 albedo;
                float temp = i.worldPos.y > _WorldHeight * abs(_SinTime.w);
                if(temp > 0){
                    discard;
                }
                else if(temp = 0){
                    albedo = _TopColor.rgb * tex2D(_MainTex,i.uv).rgb;
                }
                else{
                    albedo = _Color.rgb * tex2D(_MainTex,i.uv).rgb;
                }

                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal, worldLightDir));
				return fixed4(ambient + diffuse,1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
