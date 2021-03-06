﻿// 基本光照模型 C_diffuse = (C_light * m_diffuse) max(0,n*l)
//                  入射光线的颜色和强度 * 材质漫反射系数 * （表面法线 * 光源方向）

// 逐顶点光照
Shader "Unity Shaders Book/Chapter 6/DiffuseVertexLevel"{
	Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }// 定义LightMode可以得到Unity内置光照变量 这一句可以注释掉

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION; // 顶点在裁剪空间中的位置空间
				fixed3 color : COLOR;
			};

			v2f vert(a2v v) {
				v2f o;
				// 把顶点坐标从模型空间转换到裁剪空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				// 获得场景光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 转换法线方向从模型空间到世界空间
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// 获得世界空间的光方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// 计算漫反射(saturate函数是把参数截取到[0,1])
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

				o.color = ambient + diffuse;
				return o;
			}

			fixed4 frag(v2f o) : SV_Target{
				return fixed4(o.color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}