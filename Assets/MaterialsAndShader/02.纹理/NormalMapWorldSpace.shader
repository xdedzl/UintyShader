// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 法线分量 [-1,1],像素分量 [0,1] 映射关系 pixel = (normal + 1) / 2

// 凹凸映射，世界空间
Shader "Unity Shaders Book/Chapter 7/Noraml Map World Space"{

	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}  // bump对应模型自带的法线信息
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader{
		Pass{
			// 光照模式
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			// 纹理名_ST声明某个纹理的属性，.xy是缩放.zw是偏移
			float4 _MainTex_ST;
			sampler2D _BumpMap;  // 凸起
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			 
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				// 需要w分量来决定切线空间中的第三个坐标轴————副切线的方向性？？？ 
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
                // xyz存储切线空间到世界空间的转换矩阵，w分量存储世界空间下的顶点位置
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
			};

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); 

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;  // o.uv.xy存储_MainTex的纹理坐标
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;  // o.uv.zw存储_BumpMap的纹理坐标

                float3 wroldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 =float4(worldTangent.x,worldBinormal.x,worldNormal.x,wroldPos.x);
                o.TtoW1 =float4(worldTangent.y,worldBinormal.y,worldNormal.y,wroldPos.y);
                o.TtoW2 =float4(worldTangent.z,worldBinormal.z,worldNormal.z,wroldPos.z);

                return o;
            } 

			fixed4 frag(v2f i) : SV_Target {
                
                // get the position in world space
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                
                // Compute the light and view dir in world space
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
 
				fixed4 bump = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;
				tangentNormal = UnpackNormal(bump);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				float3x3 t2wMatrix = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
				tangentNormal = normalize(half3(mul(t2wMatrix, tangentNormal)));
 
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, lightDir));
 
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
 
				return fixed4(ambient + diffuse + specular, 1.0);
            }

			ENDCG
		}
	}
	Fallback "Specular"
}