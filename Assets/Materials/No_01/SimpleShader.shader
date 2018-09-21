Shader "Unity Shaders Book/Chapter 5/Simple Shader"{
	Properties{
		_Color("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}
		SubShader{
			Pass{
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				//在CG代码中，需要定义一个与属性名称和类型都匹配的变量
				fixed4 _Color;

			//使用一个结构体来定义定点着色器的输入
			struct a2v {
				//POSITION语义 ： 用模型空间的顶点坐标填充vertex变量
				float4 vertex : POSITION;
				//NORMAL语义 ： 用模型空间的法线方向填充normal变量
				float3 normal : NORMAL;
				//。。。		模型的第一套纹理坐标
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				//表示pos里面包含了顶点在裁剪空间中的位置空间
				float4 pos : SV_POSITION;
				//COLOR0用于存储颜色信息
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v) {
				//声明输出结构
				v2f o;
				//把顶点坐标从模型空间转换到裁剪空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				//v.normal包含了顶点的法线方向，其分量范围在[-1.0,1.0],下面代码把分量范围映射到了[0.0，1.0]，存储到o.color中传给片元着色器
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
				return o;
			} 

			fixed4 frag(v2f i) : SV_Target{ 
				fixed3 c = i.color;
				////将差值后的i.color显示到屏幕上
				//return fixed4(i.color,1.0);

				//使用_Color属性来控制输出颜色
				c *= _Color.rgb;
				return fixed4(c, 1.0);
			} 

			ENDCG
		}
	}
}