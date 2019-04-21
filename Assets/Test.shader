// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Test/Single Texture" {
	Properties{
		//为了使用纹理，在Properties语义块中添加一个纹理属性
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
			//上面的代码声明了一个名为_MainTex的纹理，2D是纹理属性的声明方式。
			//我们使用一个字符串后跟一个花括号作为它的初始值，“white”是内置
			//纹理的名字，也是一个全白的纹理。为了控制物体的整体色调，我们还声明了一个_Color属性。
	}
		SubShader{
			Pass {
			//光照模式：
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			//定义顶点着色器和片元着色器叫什么名字。
			#pragma vertex vert
			#pragma fragment frag
			//为了使用Unity内置的一些变量,我们需要包含了;
			#include "Lighting.cginc"

			//在CG代码中声明和上述属性类型相匹配的变量，以便和材质面板中的属性建立联系
			//与其他属性类型不同的是，我们还需要为纹理类型的属性声明一个float4类型的变量
			//_MainTex_ST。其中，_MainTex_ST的名字不是任意起的。在Unity中，我们需要使用
			//纹理名_ST的方式来声明某个纹理的属性。其中，ST是缩放（scale）和平移（translation）的
			//缩写。_MainTex_ST可以让我们得到该纹理的缩放和平移（偏移）值，_MainTex_ST存储的是缩放值，
			//_MainTex_ST.xy存储的是缩放值，而_MainTex_ST.zw存储的是偏移值。这些值可以在材质面板的属性纹理
			//中调节，
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			//在上面的代码中，我们首先在a2v结构体中使用TEXCOORD0语义块声明了一个新的变量texcoord，
			//这样Unity就会将模型的第一组纹理坐标存储到该变量中。然后，我们v2f结构体中添加了用于存储纹理坐标的变量uv，
			//以便子片元着色器中使用该坐标进行纹理采样。

			//然后，我们定义了顶点着色器：
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// Or just call the built-in function
//              o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			//在顶点着色器中，我们使用纹理的属性值_MainTex_ST来对顶点纹理做坐标进行变换，得到
			//最终的纹理坐标。计算过程是，首先使用缩放属性_MainTex_ST.xy对顶点纹理坐标进行缩放，
			//然后在使用偏移属性_MainTex_ST.zw对结果进行偏移。Unity提供了一个内置宏TRANSFORM_TEX
			//来帮我们计算上述过程。TRANSFORM_TEX是在UnityCG.cginc中定义的：
			//Transforms 2D UV by scale/bias property
			//#define TRANSFORM_TEX（tex，name） （tex.xy * name ## _ST.xy + name ## _ST.zw）
			//他接受两个参数，第一个参数是顶点纹理坐标，第二参数是纹理名，在它的实现中，将利用纹理名_ST的
			//方式来计算变换后的纹理坐标。

			//我们还需要实现片元着色器，并在计算漫反射时使用纹理中的纹素值：
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				// Use the texture to sample the diffuse color
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
				//上面的代码首先计算了世界空间下的法线方向和光照方向。然后，使用CG的tex2D
				//函数对纹理进行采样。它的第一参数是需要被采样的纹理，第二个参数是一个float2
				//类型的纹理坐标，它将返回计算得到的纹素值。我们使用采样结果和颜色属相_Color的
				//乘积来作为材质的反射率albedo，并把他和环境光照相乘得到环境部分。随后，我们使用albedo
				//来计算漫反射光照的结果，并和环境光照、高光反射光照想加后返回/
			ENDCG
			}
		}
			//最后，我们为该Shader设置了合适的Fallback；
				FallBack "Specular"
}
