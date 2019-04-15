// C_specular = (C_light * m_specualr) * （max(0, v*r)的m_gloss次方）
//      入射光的颜色和强度 * 材质的高光反射系数     v：视角方向   r:反射方向 = l - 2(n*l)*n    n:表面法线  l:光源方向

Shader "Unity Shaders Book/Chapter 6/Specular Pixel-Level" {

	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

		SubShader{
		Pass{
		Tags{"LightMode" = "ForwardBAse"}
		 
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

		fixed4 _Diffuse;
		fixed4 _Specular;
		float _Gloss;

	struct a2v {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXTCOORD0;
		float3 worldPos : TEXTCOORD1;
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = mul(v.normal, (float3x3)(unity_WorldToObject));
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target{

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 worldNormal = normalize(i.worldNormal);
		fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir)); // 计算漫反射系数

		fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal)); // 计算发射方向
		fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz); // 计算观察者方向
		fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

		return fixed4(ambient + diffuse + specular, 0.1);
	}
		ENDCG
	}
	}
		Fallback "Specular"
}
