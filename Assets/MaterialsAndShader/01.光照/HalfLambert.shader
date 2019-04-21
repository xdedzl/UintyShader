// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// 半兰伯特光照模型 C_diffuse = (C_light * m_diffuse) （α（n*l）+ β） 绝大多数情况下α和β都为0.5
//                  入射光线的颜色和强度 * 材质漫反射系数 * （α * （表面法线 * 光源方向） + β）

Shader "Unity Shaders Book/Chapter 6/HalfLambert"{
	Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

	SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }// 定义LightMode可以得到Unity内置光照变量

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;// 与属性对应

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				// 把顶点坐标从模型空间转换到裁剪空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				// 转换法线方向从模型空间到世界空间
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				// 获得场景光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 转换法线方向从模型空间到世界空间
				fixed3 worldNormal = normalize(i.worldNormal);
				// 获得世界空间的光方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				// 计算漫反射(saturate函数是把参数截取到[0,1])
				fixed halfLambert = dot(worldNormal, worldLightDir) * 0.6 + 0.4;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				fixed3 color = ambient + diffuse;

				return fixed4(color, 1.0);
			}

			ENDCG
		}	
	}
	FallBack "Diffuse"
}