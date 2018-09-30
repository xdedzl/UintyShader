// C_specular = (C_light * m_specualr) * （max(0, v*r)的m_gloss次方）
//      入射光的颜色和强度 * 材质的高光反射系数     v：视角方向   r:反射方向 = l - 2(n*l)*n    n:表面法线  l:光源方向

Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {

	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

		SubShader{
			Pass{

				Tags{ "LightMode" = "ForwardBAse" }
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				fixed _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 color : COLOR;
				};
		
				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));	// 计算漫反射系数
					fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));							// 计算发射方向
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
					o.color = ambient + diffuse + specular;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					return fixed4(i.color, 1.0);
				}
			ENDCG
			}
		}
		Fallback "Specular"
}
