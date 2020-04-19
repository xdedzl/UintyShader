// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/AnimTestShader" {
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_F("F",Range(1,30)) = 10
		_A("A",Range(0,0.1)) = 0.01
		_R("R",Range(0,1)) = 0
	}
		SubShader
		{
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float _F;//控制速度 
				float _A;//控制幅度
				float _R;//控制半径 

				struct v2f {
					float4 pos:POSITION;
					float2 uv:TEXCOORD0;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord.xy;
					return o;
				}

				fixed4 frag(v2f v) : COLOR
				{
					// 移动效果
					v.uv.x +=_Time.xy;
				
					// 上下位置波动
					v.pos.y += 100 * sin(_Time.y);

					//点击波纹效果
					float2 uv = v.uv;
					float2 po = float2(0.5,0.5);
					float dis = distance(uv,po);//距离中心点位置
					float scale = 0;
					if (dis < _R)
					{
						_A *= saturate(1 - dis / _R);
						scale = _A * sin(-dis * 3.14*_F + _Time.y);
						uv = uv + uv * scale;
					}
					fixed4 col = tex2D(_MainTex, uv) + fixed4(1,1,1,1)*saturate(scale) * 100;
					return col;
				}
			ENDCG
			}
		}
}