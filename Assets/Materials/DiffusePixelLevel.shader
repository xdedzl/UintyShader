Shader "Unity Shaders Book/Chapter6/DiffusePixelLevel"{
	Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }//定义LightMode可以得到Unity内置光照变量

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

		fixed4 _Diffuse;//与属性对应

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
		//把顶点坐标从模型空间转换到裁剪空间中
		o.pos = UnityObjectToClipPos(v.vertex);
		//转换法线方向从模型空间到世界空间
		fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
		
		return o; 
	}

	fixed4 frag(v2f i) : SV_Target{
		//获得区域光
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		//获得世界空间法线方向
		fixed3 worldNormal = normalize(i.worldNormal);
		//获得世界空间光线方向
		fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
		//计算漫反射
		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

		fixed3 color = ambient + diffuse;  

		return fixed4(color, 1.0);
	}

		ENDCG
	}
	}
		Fallback "Diffuse"
}