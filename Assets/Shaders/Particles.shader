// 模型粒子化效果
Shader "Custom/Particles"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Speed("Speed", Float) = 10
		_AccelerationValue("AccelerationValue", Float) = 10
        _ContinueTime("Current Time",Int) = 2
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass{
            Tags { "RenderType"="Opaque" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            sampler2D _MainTex;
            float _Speed;
            float _AccelerationValue;
            float _ContinueTime;
            fixed4 _Color;

            struct a2v{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2g vert(a2v v){
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                return o;
            }

            // 定义输出顶点的最大数量
            [maxvertexcount(1)]
            void geom(triangle v2g IN[3], inout PointStream<g2f> pointStream){
                g2f o;
                float3 v1 = IN[1].vertex - IN[0].vertex;
                float3 v2 = IN[2].vertex - IN[0].vertex;

                float3 normal = normalize(cross(v1,v2));
                float3 tempPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;

                float realTime = _Time.y % _ContinueTime;
                float a = _AccelerationValue + 
                tempPos += normal * (_Speed * realTime + 0.5 * _AccelerationValue * pow(realTime, 2));

                o.vertex = UnityObjectToClipPos(tempPos);

                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                pointStream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
