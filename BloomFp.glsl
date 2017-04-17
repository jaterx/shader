//this shader will enable grayscale image and also provide bloom visual effects by grayscale dilation
//an empty material file is least needed
//this is a fragment shader, combined vertex shader is needed
//geometry shader is not needed
//tested with OGRE3D 1.9
//GLSL Code

//Written by Jater (Ruohao) Xu, 2016

#version 400

// Passed from the vertex shader
in vec2 uv;

// Passed from outside
uniform float time;
uniform sampler2D diffuse_map;

void main()
{
  
  //STEP1: INITIALIZATION

  //variables that retrieve r,g,b value from the original texture
  float gr = 0;
  float gg = 0;
  float gb = 0;

  //variables that retrieve the grayscale value from the original texture
  float correctedR = 0;
  float	correctedG = 0;
  float	correctedB = 0;

  //extract the corrected RGB variable from grayscale value
  float bloomR = 0;
  float bloomG = 0;
  float bloomB = 0;

  //intialize the variable for storing the corrected grayscale values
  vec4 correctedPixel = vec4(0.0,0.0,0.0,1.0); //use this line to see grayscale convertion at this point

  //intialize texture position
  vec2 posss = uv;

  //intialize Texture Snapshot Recorder(I called it) that will take 25 snapshots for the textures with different dilated positions
  vec4 pixelSampler[9+16]; //sample through 5x5 nearby grids

  //intialize Texture Position Recorder(I called it) that will hold 25 dilated positions from recorded texture snapshots
  vec2 multiSampler[9+16]; //record adjancent pixel positions, with 2 layers of surrounding, center:0, layer1: 1-8, layer2: 9-24

  //set the 1st position of the Position Recorder to its original texture without dilation
  multiSampler[0] = posss; //Center

  //layer1
  multiSampler[1] = vec2(posss.x + 0.01, posss.y); //Dilate West
  multiSampler[2] = vec2(posss.x - 0.01, posss.y); //Dilate East
  multiSampler[3] = vec2(posss.x, posss.y + 0.01); //Dilate North
  multiSampler[4] = vec2(posss.x, posss.y - 0.01); //Dilate South
  multiSampler[5] = vec2(posss.x + 0.01, posss.y + 0.01); //Dilate NorthWest
  multiSampler[6] = vec2(posss.x - 0.01, posss.y + 0.01); //Dilate NorthEast
  multiSampler[7] = vec2(posss.x + 0.01, posss.y - 0.01); //Dilate SouthWest
  multiSampler[8] = vec2(posss.x - 0.01, posss.y - 0.01); //Dilate SouthEast

  //layer2
  //row1
  multiSampler[9] = vec2(posss.x - 0.02, posss.y - 0.02);
  multiSampler[10] = vec2(posss.x - 0.01, posss.y - 0.02);
  multiSampler[11] = vec2(posss.x, posss.y - 0.02);
  multiSampler[12] = vec2(posss.x + 0.01, posss.y - 0.02);
  multiSampler[13] = vec2(posss.x + 0.02, posss.y - 0.02);

  //row2
  multiSampler[14] = vec2(posss.x - 0.02, posss.y - 0.01);
  multiSampler[15] = vec2(posss.x + 0.02, posss.y - 0.01);

  //row3
  multiSampler[16] = vec2(posss.x - 0.02, posss.y);
  multiSampler[17] = vec2(posss.x + 0.02, posss.y);

  //row4
  multiSampler[18] = vec2(posss.x - 0.02, posss.y + 0.01);
  multiSampler[19] = vec2(posss.x + 0.02, posss.y + 0.01);

  //row5
  multiSampler[20] = vec2(posss.x - 0.02, posss.y + 0.02);
  multiSampler[21] = vec2(posss.x - 0.01, posss.y + 0.02);
  multiSampler[22] = vec2(posss.x, posss.y + 0.02);
  multiSampler[23] = vec2(posss.x + 0.01, posss.y + 0.02);
  multiSampler[24] = vec2(posss.x + 0.02, posss.y + 0.02);

  //intialize Texture Snapshot Mixer(I called it) that will mix 25 snapshots after dilation
  vec4 finalShowcase[25]; //output texture overlay layers with bloom effect
  
  //STEP2: GRAYSCALE DILATION

  //Now we start the dilation according to its grayscale
  //Dilate layer 1 first, with bloom effect (dimmer than center)
  for (int i=0; i<9; i++){
    
	//exract data in the Snapshot recorder
	pixelSampler[i] = texture(diffuse_map, multiSampler[i]);

	//get rgb value from the texture
	gr = pixelSampler[i].r;
	gg = pixelSampler[i].g;
	gb = pixelSampler[i].b;

	//grayscale convertion
	if (gr==1.0 && gg==1.0 && gb==1.0 ){ //get original white area
		//convert white area to black
		correctedR = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		correctedG = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		correctedB = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		//flip the grayscale value and extract background without actual mesh
		bloomR = 1.0-correctedR;
		bloomG = 1.0-correctedG;
		bloomB = 1.0-correctedB;
	}
	else{ //get mesh area
	    //convert the mesh area to according grayscale value
		correctedR = 0.0;
		correctedG = 0.0;
		correctedB = 0.0;
		//adjust bloom brightness
		bloomR = 0.6;
		bloomG = 0.6;
		bloomB = 0.6;
	}

	//push the bloom data(with color and position) and snapshot data to the Snapshot Mixer
	finalShowcase[i] = vec4(bloomR, bloomG, bloomB, 1.0);

  }

  //Dilate layer 2 next, with bloom effect (dimmer than layer1 than center)
  for (int i=9; i<25; i++){
    
	//extract data in the Snapshot recorder
	pixelSampler[i] = texture(diffuse_map, multiSampler[i]);

	//get rgb value from the texture
	gr = pixelSampler[i].r;
	gg = pixelSampler[i].g;
	gb = pixelSampler[i].b;

	//grayscale convertion
	if (gr==1.0 && gg==1.0 && gb==1.0 ){ //get original white area
		//convert white area to black
		correctedR = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		correctedG = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		correctedB = 1.0; //remain white at this time, turn to black via 1-correctX later on for deleting the unwanted background
		//flip the grayscale value and extract background without actual mesh
		bloomR = 1.0-correctedR;
		bloomG = 1.0-correctedG;
		bloomB = 1.0-correctedB;
	}
	else{ //get mesh area
		//convert the mesh area to according grayscale value
		correctedR = 0.0;
		correctedG = 0.0;
		correctedB = 0.0;
		//adjust bloom brightness
		bloomR = 0.3;
		bloomG = 0.3;
		bloomB = 0.3;
	}
	
	//push the bloom data(with color and position) and snapshot data to the Snapshot Mixer
	finalShowcase[i] = vec4(bloomR, bloomG, bloomB, 1.0);

  }

  //STEP3: FINAL MIXING

  //Mix all the data in the Snapshot Mixer again to get the final blooming effect
  gl_FragColor = finalShowcase[0] + finalShowcase[1] + finalShowcase[2] + finalShowcase[3] + finalShowcase[4] + finalShowcase[5] + finalShowcase[6] + finalShowcase[7] + finalShowcase[8] + finalShowcase[9] + finalShowcase[10] + finalShowcase[11] + finalShowcase[12] + finalShowcase[13] + finalShowcase[14] + finalShowcase[15] + finalShowcase[16] + finalShowcase[17] + finalShowcase[18] + finalShowcase[19] + finalShowcase[20] + finalShowcase[21] + finalShowcase[22] + finalShowcase[23] + finalShowcase[24];
  
}
