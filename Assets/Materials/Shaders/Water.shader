// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_Speed("Speed", Range( 0 , 10)) = 1
		_Offset("Offset", Range( 0 , 1)) = 0.1
		_Color("Color", Color) = (0.3773585,0.3773585,0.3773585,1)
		_Color1("Color 1", Color) = (0.3773585,0.3773585,0.3773585,1)
		_ColorHeight("Color Height", Range( 0 , 1)) = 0
		_Scale("Scale", Vector) = (1,1,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform sampler2D _Texture0;
		uniform float _Speed;
		uniform float2 _Scale;
		uniform float _Offset;
		uniform float4 _Color;
		uniform float4 _Color1;
		uniform float _ColorHeight;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_11_0 = ( _Time.y * _Speed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult31 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 temp_output_32_0 = ( appendResult31 * float4( _Scale, 0.0 , 0.0 ) );
			float2 panner7 = ( temp_output_11_0 * float2( 1,0.2 ) + temp_output_32_0.xy);
			float2 panner5 = ( temp_output_11_0 * float2( 0.5,0.7 ) + temp_output_32_0.xy);
			float2 temp_cast_4 = (( _Speed * _SinTime.w )).xx;
			float2 panner22 = ( _SinTime.w * temp_cast_4 + temp_output_32_0.xy);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _Texture0, float4( panner7, 0, 0.0) ).r + tex2Dlod( _Texture0, float4( panner5, 0, 0.0) ).r + tex2Dlod( _Texture0, float4( panner22, 0, 0.0) ).b ) * ase_vertexNormal * _Offset );
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 lerpResult25 = lerp( _Color , _Color1 , saturate( ( ase_worldPos.y / _ColorHeight ) ));
			o.Emission = lerpResult25.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
618;994;2234;1254;3179.401;563.7216;2.001561;True;True
Node;AmplifyShaderEditor.WorldPosInputsNode;24;-1350.562,-611.5397;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1075.428,-522.3602;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-1233,-103;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;33;-1533.647,-311.378;Float;False;Property;_Scale;Scale;6;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;10;-1397,264;Float;False;Property;_Speed;Speed;1;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;20;-1210.661,360.2315;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1036,-10;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1020.862,343.3315;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1332.647,-325.378;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-237.9928,-759.788;Float;False;Property;_ColorHeight;Color Height;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;22;-829.7621,365.4314;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,0.7;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1552,-69;Float;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;False;0;e43c2a70a4c8a5c4a86cdfa7a3720b5f;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;7;-790,-147;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;5;-783,188;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.5,0.7;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-494,-6;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;131.2724,-637.1987;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-489,-227;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;e43c2a70a4c8a5c4a86cdfa7a3720b5f;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-494.3617,192.5316;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-146.3769,-306.4784;Float;False;Property;_Color;Color;3;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;26;-119.8878,-127.4035;Float;False;Property;_Color1;Color 1;4;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-82.34753,56.65967;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;330.1072,-635.7034;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;16;-591.1483,424.4797;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-272.0881,563.3395;Float;False;Property;_Offset;Offset;2;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1.788622,347.0996;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;25;176.1222,-525.0735;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;394.5598,-144.66;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;0;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;24;1
WireConnection;31;1;24;3
WireConnection;11;0;8;0
WireConnection;11;1;10;0
WireConnection;23;0;10;0
WireConnection;23;1;20;4
WireConnection;32;0;31;0
WireConnection;32;1;33;0
WireConnection;22;0;32;0
WireConnection;22;2;23;0
WireConnection;22;1;20;4
WireConnection;7;0;32;0
WireConnection;7;1;11;0
WireConnection;5;0;32;0
WireConnection;5;1;11;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;30;0;24;2
WireConnection;30;1;27;0
WireConnection;6;0;3;0
WireConnection;6;1;7;0
WireConnection;21;0;3;0
WireConnection;21;1;22;0
WireConnection;13;0;6;1
WireConnection;13;1;4;1
WireConnection;13;2;21;3
WireConnection;29;0;30;0
WireConnection;14;0;13;0
WireConnection;14;1;16;0
WireConnection;14;2;17;0
WireConnection;25;0;18;0
WireConnection;25;1;26;0
WireConnection;25;2;29;0
WireConnection;2;2;25;0
WireConnection;2;11;14;0
ASEEND*/
//CHKSM=3FF8A1ABCF9EB484B98DD87371D9DFDAEB59CA3C