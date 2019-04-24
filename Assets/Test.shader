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

			}
		}
			//最后，我们为该Shader设置了合适的Fallback；
				FallBack "Specular"
}