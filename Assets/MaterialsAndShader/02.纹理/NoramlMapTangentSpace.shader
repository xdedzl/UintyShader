// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 法线分量 [-1,1],像素分量 [0,1] 映射关系 pixel = (normal + 1) / 2

// 凹凸映射，切线空间
Shader "Unity Shaders Book/Chapter 7/Noraml Map Tanegent Space"{

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
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); 

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;  // o.uv.xy存储_MainTex的纹理坐标
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;  // o.uv.zw存储_BumpMap的纹理坐标

                // Compute the binormal(次法线)
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                // Construct a matrix which transform vectors from object space to tangent space
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // Transform the light direction from object space to tangent space
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            } 

			 fixed4 frag(v2f i) : SV_Target {                
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                // Get the texel in the normal map在法线贴图中得到贴图
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;
                // If the texture is not marked as "Normal map"如果纹理没有被标记为“法线贴图”
				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
                // Or mark the texture as "Normal map", and use the built-in funciton
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

			ENDCG
		}
	}
	Fallback "Specular"
}