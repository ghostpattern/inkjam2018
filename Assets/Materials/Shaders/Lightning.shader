// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Lightning"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0,0,0,0)
		_MainTex("MainTex", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Progression("Progression", Range( 0 , 1)) = 0
		_MainLightningIntensity("Main Lightning Intensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform float _Progression;
		uniform float _MainLightningIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_18_0 = saturate( pow( (1.0 + (_Progression - 0.5) * (0.0 - 1.0) / (1.0 - 0.5)) , 10.0 ) );
			float temp_output_19_0 = ( 1.0 - temp_output_18_0 );
			o.Emission = ( _Color + ( _Color * ( temp_output_19_0 * _MainLightningIntensity ) ) ).rgb;
			o.Alpha = 1;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
			float temp_output_49_0 = (0.0 + (_Progression - 0.0) * (1.0 - 0.0) / (0.6 - 0.0));
			float lerpResult42 = lerp( -0.25 , 0.5 , temp_output_49_0);
			float lerpResult41 = lerp( 0.0 , 0.75 , temp_output_49_0);
			clip( ( ( ( ( saturate( ( ( 1.0 - tex2DNode5.r ) - (1.0 + (_Progression - 0.0) * (0.0 - 1.0) / (0.5 - 0.0)) ) ) * temp_output_18_0 ) + ( tex2DNode5.g * temp_output_19_0 * _MainLightningIntensity ) ) * ( saturate( ( saturate( (0.0 + (tex2DNode5.r - lerpResult42) * (1.0 - 0.0) / (lerpResult41 - lerpResult42)) ) + tex2DNode5.g ) ) * tex2DNode5.b ) ) * (1.0 + (_Progression - 0.8) * (0.0 - 1.0) / (1.0 - 0.8)) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
2716;143;2234;1176;3043.467;864.4203;2.576949;True;True
Node;AmplifyShaderEditor.RangedFloatNode;6;-1844.847,461.7031;Float;False;Property;_Progression;Progression;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1529.531,-388.2472;Float;False;1650.919;424.8987;Fade Out Tendrils;8;51;52;47;48;43;42;41;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;49;-1435.765,-270.9336;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.6;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1128.977,131.7093;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;ec808d915764d3f46956c2800f8e494b;ec808d915764d3f46956c2800f8e494b;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;32;-863.558,670.8328;Float;False;1542.242;433.4122;Main Lightning;8;29;30;21;19;28;18;17;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-907.0278,135.5292;Float;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;17;-786.3881,743.0173;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-1201.233,-219.5865;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;42;-1201.234,-338.2473;Float;False;3;0;FLOAT;-0.25;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-462.1261,95.93375;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;43;-922.129,-289.1214;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-802.7164,320.5672;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;34;-490.9587,821.0887;Float;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;18;-202.3,759.6998;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-652.3497,-202.7507;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-285.8511,131.9741;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-419.9731,-127.6102;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;20.69999,839.6998;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;-130.6334,130.8292;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2.414798,998.4313;Float;False;Property;_MainLightningIntensity;Main Lightning Intensity;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;85.77539,187.1037;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;221.7001,753.6998;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;37;-861.4121,1164.047;Float;False;1551.427;247.6029;Main Fade;2;36;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;52;-243.5715,-134.645;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-49.84893,-133.1772;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;355.8375,407.2789;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;23;410.4901,300.4952;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;322.5852,956.8317;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;36;-844.0467,1207.46;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;584.0624,165.3252;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;35;494.5067,1211.801;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;516.2841,739.7311;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;917.9845,94.93204;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;1071.895,206.077;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;1652.978,-13.41484;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Lightning;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;49;0;6;0
WireConnection;5;0;4;0
WireConnection;17;0;6;0
WireConnection;41;2;49;0
WireConnection;42;2;49;0
WireConnection;15;0;5;1
WireConnection;43;0;5;1
WireConnection;43;1;42;0
WireConnection;43;2;41;0
WireConnection;33;0;6;0
WireConnection;34;0;17;0
WireConnection;18;0;34;0
WireConnection;48;0;43;0
WireConnection;9;0;15;0
WireConnection;9;1;33;0
WireConnection;47;0;48;0
WireConnection;47;1;5;2
WireConnection;19;0;18;0
WireConnection;39;0;9;0
WireConnection;22;0;39;0
WireConnection;22;1;18;0
WireConnection;21;0;5;2
WireConnection;21;1;19;0
WireConnection;21;2;28;0
WireConnection;52;0;47;0
WireConnection;51;0;52;0
WireConnection;51;1;5;3
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;30;0;19;0
WireConnection;30;1;28;0
WireConnection;36;0;6;0
WireConnection;14;0;23;0
WireConnection;14;1;51;0
WireConnection;35;0;36;0
WireConnection;29;0;3;0
WireConnection;29;1;30;0
WireConnection;31;0;3;0
WireConnection;31;1;29;0
WireConnection;38;0;14;0
WireConnection;38;1;35;0
WireConnection;2;2;31;0
WireConnection;2;10;38;0
ASEEND*/
//CHKSM=B44D7980A24970E8D4D9439D1345184CB092CB08