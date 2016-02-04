


// -------------------- VARIABLES -------------------------------


float4x4 ViewProjMatrix : VIEWPROJECTION;
float4x4 WorldMatrix : WORLD;
float3 CameraPosition : POSITION  <string Object = "Camera";>;
// Obtain coordinates from Target Object
//float TargetPos2 : CONTROLOBJECT <string name = "Target.x";>;
//float TargetPos2 : CONTROLOBJECT <string name = "Surface.x";>;
// Get Si of Object
float Scale : CONTROLOBJECT <string name = "Line.x"; string item = "Si";>;
// Get Tr of Object
float Alpha : CONTROLOBJECT <string name = "Line.x"; string item = "Tr";>;
float time : TIME;

// Create Multiple Raindrops
int CloneNum = 10;
int index;


// ------------------- TEXTURES -----------------------

// Import texture
texture Line_Tex <
   string ResourceName = "Tex.png";
>;
sampler LineTexSampler = sampler_state {

   Texture = (Line_Tex);
   // Wrap
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   // Filter
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = NONE;
};

struct VS_OUTPUT {

    float4 Pos : POSITION; 
    float2 Tex : TEXCOORD1; 
};



// --------------- MAIN FUNCTIONS -------------------


// Vertex Shader
VS_OUTPUT Line_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0) {

	VS_OUTPUT Out = (VS_OUTPUT)0;

	// Make the raindrop be able to move around by the bones in MMD
	//float3 TargetPos = TargetPos2;
	float3 TargetPos = (0, 0, index);

	// Output pos
    float4 LastPos = 1;
	// World 0 pos


	float3 ZeroPos = WorldMatrix[3].xyz;
	//float3 ZeroPos = TargetPos2;
	// Pos of the raindrop
	// ZeroPos = Starting Point, TargetPos = End Point
	// Lerp = linear line
    float3 NowPos = lerp(TargetPos, ZeroPos, Pos.z);
	// Save NowPos to Output
    LastPos.xyz = NowPos;
    
    
	// ---- Billboard calculations ---

	// Obtain vector from current position to position with z+0.01
    float3 NextPos = lerp(TargetPos, ZeroPos, Pos.z+0.01);
	float3 FrontVec = normalize(NextPos - NowPos);
	// Obtain vector from Camera to Current Position
    float3 EyeVec = normalize(CameraPosition - NowPos);
	// Obtain Side vector by cross product
    float3 SideVec = cross(FrontVec,EyeVec) * Scale * 0.1;
    
    //現在処理している頂点を左右に割り振る
    //全ての頂点のX座標は0.5もしくは-0.5 - because of the current model Line.x
    if(Pos.x > 0)
    {
    	LastPos.xyz += SideVec;
    }else{
    	LastPos.xyz += -SideVec;
    }
    
    
    // カメラ視点ビュー射影変換
    Out.Pos = mul( LastPos, ViewProjMatrix );
    
    // Apply time lag to texture
    Tex.y -= time/4; 
    Out.Tex = Tex;
    
    return Out;
}


// Pixel Shader
float4 Line_PS( VS_OUTPUT IN ) : COLOR0 {
	
	// Obtain colour from texture
	float4 Colour = tex2D(LineTexSampler,IN.Tex);
    return Colour;
}


// Technique
technique MainTec < string MMDPass = "object"; 
  //  string Script = 
		//"LoopByCount=CloneNum;"
  //      "LoopGetIndex=index;"
	 //   "Pass=DrawObject;"
  //      "LoopEnd=;"
  //  ;
> {
    pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		CULLMODE = NONE;
		ALPHABLENDENABLE = TRUE;
		SRCBLEND=SRCALPHA;
		DESTBLEND=ONE;

        VertexShader = compile vs_3_0 Line_VS();
        PixelShader  = compile ps_3_0 Line_PS();
    }
}