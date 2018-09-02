// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LightningAbove"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0
		[HDR]_Color("Color", Color) = (2,2,2,1)
		_OffsetSpeed("OffsetSpeed", Range( 0 , 10)) = 1
		_Progression("Progression", Range( 0 , 1)) = 0
		_MainLightningBrightness("Main Lightning Brightness", Range( 1 , 50)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _OffsetSpeed;
		uniform float4 _Color;
		uniform float _MainLightningBrightness;
		uniform float _Progression;
		uniform float _Cutoff = 0;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult13 = (float4(_Time.y , _Time.y , _Time.y , 0.0));
			float4 temp_output_11_0 = ( float4( ase_worldPos , 0.0 ) + ( appendResult13 * _OffsetSpeed ) );
			float simplePerlin2D3 = snoise( temp_output_11_0.xy );
			float4 break15 = temp_output_11_0;
			float4 appendResult7 = (float4(break15.x , break15.y , 0.0 , 0.0));
			float simplePerlin2D6 = snoise( appendResult7.xy );
			float4 appendResult8 = (float4(simplePerlin2D3 , 0.0 , simplePerlin2D6 , 0.0));
			v.vertex.xyz += ( appendResult8 * 0.1 ).xyz;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 lerpResult28 = lerp( _Color , ( _Color * _MainLightningBrightness ) , saturate( (0.0 + (_Progression - 0.6) * (1.0 - 0.0) / (0.7 - 0.6)) ));
			o.Emission = lerpResult28.rgb;
			o.Alpha = 1;
			float4 ditherCustomScreenPos37 = float4( i.uv_texcoord, 0.0 , 0.0 );
			float2 clipScreen37 = ditherCustomScreenPos37.xy * _ScreenParams.xy;
			float dither37 = Dither4x4Bayer( fmod(clipScreen37.x, 4), fmod(clipScreen37.y, 4) );
			dither37 = step( dither37, min( (1.0 + (_Progression - 0.9) * (-0.1 - 1.0) / (1.0 - 0.9)) , 1.0 ) );
			clip( ( ( ( ( 1.0 - i.uv_texcoord.x ) - 1.0 ) + saturate( (0.0 + (_Progression - 0.0) * (1.0 - 0.0) / (0.6 - 0.0)) ) ) * ( dither37 - 0.01 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
2699;128;2234;1200;1499.948;737.84;1;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1902,600;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1564,447;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1648,687;Float;False;Property;_OffsetSpeed;OffsetSpeed;2;0;Create;True;0;0;False;0;1;6.46;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-1568,98;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1409,566;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1237,309;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1001.084,-263.4331;Float;False;Property;_Progression;Progression;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;15;-1188,490;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TexCoordVertexDataNode;21;-897.5417,-568.8843;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;34;-502.1802,-852.3865;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-464.7061,-576.598;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;40;-266.9485,-797.8396;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;31;-581.309,-481.6493;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.6;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-933,318;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-816.1852,136.3508;Float;False;Property;_MainLightningBrightness;Main Lightning Brightness;4;0;Create;True;0;0;False;0;1;10;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;6;-758,369;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;33;-314.7869,-459.9941;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;3;-766,271;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;37;-80.89165,-899.0911;Float;False;0;True;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-743,-69;Float;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;False;0;2,2,2,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;23;-589.6402,-315.0712;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;0.7;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-263.1487,-561.6058;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-321.4518,-355.0493;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-356.433,96.37256;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-26.60974,-464.9915;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;138.0515,-757.8396;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-581.2912,587.3369;Float;False;Constant;_Offset;Offset;1;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-331,230;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;28;-68.2558,-93.52449;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;116.5091,-265.108;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-279,478;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;318.1609,-78.29089;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;LightningAbove;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;19;0
WireConnection;13;1;19;0
WireConnection;13;2;19;0
WireConnection;17;0;13;0
WireConnection;17;1;18;0
WireConnection;11;0;5;0
WireConnection;11;1;17;0
WireConnection;15;0;11;0
WireConnection;34;0;22;0
WireConnection;29;0;21;1
WireConnection;40;0;34;0
WireConnection;31;0;22;0
WireConnection;7;0;15;0
WireConnection;7;1;15;1
WireConnection;6;0;7;0
WireConnection;33;0;31;0
WireConnection;3;0;11;0
WireConnection;37;0;40;0
WireConnection;37;2;21;0
WireConnection;23;0;22;0
WireConnection;30;0;29;0
WireConnection;24;0;23;0
WireConnection;26;0;1;0
WireConnection;26;1;25;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;41;0;37;0
WireConnection;8;0;3;0
WireConnection;8;2;6;0
WireConnection;28;0;1;0
WireConnection;28;1;26;0
WireConnection;28;2;24;0
WireConnection;36;0;32;0
WireConnection;36;1;41;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;0;2;28;0
WireConnection;0;10;36;0
WireConnection;0;11;9;0
ASEEND*/
//CHKSM=355885C21028EB85F17CB371DD7A1D85587DEEA2