// 音符跳动

Shader "XDEDZL/Note Bounce"
{

	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
        _Intensity("Intensity",Float) = 1
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
			fixed4 _Specular;
			float _Gloss;
            float _Intensity;
			 
			struct a2v {
				float4 vertex : POSITION;
				float4 normal : NORMAL;
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
                //v.vertex += v.normal * 1;
                float offset = frac(sin(dot(v.vertex.xy + _Time.xy, (12.9898,78.233))) * 43758.5453) * _Intensity;
                v.vertex += v.normal * offset;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);  // 内置函数实现了上面注释的算法

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				// tex2D获取纹理对应坐标的纹素值
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;  // 环境光照
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir)); // 漫反射光照

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);  // 高光反射光照
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
	Fallback "Specular"
}
