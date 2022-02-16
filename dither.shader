Shader "Dither"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Specular ("Smoothness", Range(0,1)) = 0.5
       
		_MinDistance("Min Fade Distance", Float) = 0
		_MaxDistance("Max Fade Distance", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
		
        #pragma surface surf BlinnPhong fullforwardshadows vertex:vert

        #pragma target 4.0

        sampler2D _MainTex;//
		half _Specular;
		fixed4 _Color;
		float _MinDistance;
		float _MaxDistance;

        struct Input
        {
			float2 uv_MainTex;
			float4 position;
			float4 screenposition;
			float4 color;
        };

        UNITY_INSTANCING_BUFFER_START(Props)

        UNITY_INSTANCING_BUFFER_END(Props)

		void Dither(float2 pos, float alpha,float relDist)
		{
			pos *= _ScreenParams.xy;

			float dith[16] =
			{
				0.07,
				0.92,
				0.15,
				0.81,
				0.06,
				0.11,
				0.45,
				0.84,
				0.11,
				0.33,
				0.54,
				0.94,
				0.01,
				0.24,
				0.44,
				0.84
			};

			relDist = relDist - _MinDistance;
			relDist = relDist / (_MaxDistance - _MinDistance);
			int i = (int(pos.x) % 4) * 4 + int(pos.y) % 4;
			clip(relDist - dith[i]);
		}

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.position = UnityObjectToClipPos(v.vertex);
			o.screenposition = ComputeScreenPos(o.position);
		}

        void surf (Input IN, inout SurfaceOutput o)
        {
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Specular = _Specular;
			Dither(IN.screenposition.xy / IN.screenposition.w, col.a, IN.screenposition.w);
			o.Albedo = col;
			o.Alpha = IN.color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
