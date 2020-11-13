// This script is associated with the tutorial on how to trace axons which can be found here https://hackmd.io/@samuelorion/H1ro8MoKw

// when running, set batch mode hide, but if you want to see process 
// comment out
	
//	setBatchMode("hide");

close("*");


input = "/Users/SamuelOrion/Downloads/TraceAxons_workshop/";
	
list = getFileList(input);

// FOR TUTORIAL: -- these can be removed / added - for explanation purposes. 
// FOR TUTORIAL: Array.show(list);

// FOR TUTORIAL: print(list[0]);


for (i = 0; i < list.length; i++){  

// FOR TUTORIAL: for (i = 0; i < 3; i++){	

	path = list[i];
	file = input + path;

// ####################################################
// OPEN IMAGES  
// to crop on open (or opening non-TIFF files), use 
// bio formats (and you can specify dims for crop on import)
// ####################################################	

	start_x = 2000;
	start_y = 2000;
	width = 3000;
	height = 3000;
	
	run("Bio-Formats", "open=file autoscale color_mode=Default crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT x_coordinate_1=start_x y_coordinate_1=start_y width_1=width height_1=height");
	
	raw = getTitle(); 
	title = replace(raw, ".tif", "");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); 

// ####################################################
// PROCESS IMAGES  // PRE-PROCSSING OF RAW IMAGE
// ####################################################

	run("Enhance Contrast", "saturated=0.35");
	setMinAndMax(0, 750); // just for viz
	run("Duplicate...", " "); 
	gaussian = getTitle();
	
	gauss_sigma = 20; // can be modified 
	run("Gaussian Blur...", "sigma=gauss_sigma"); 
		
// ####################################################
// Original image (raw) - Gaussinan to clean and normalize images 
// ####################################################	
	
	imageCalculator("Subtract create", raw, gaussian);
	setOption("ScaleConversions", true);
	run("Enhance Contrast", "saturated=0.35");
	
	raw_sub_gaussian = getTitle();
	
// ####################################################
// Threshold to binarise for skeletonization, choice of automatic threshold 
// or using set might be interesting -- TBD 
// ####################################################	
	
	selectWindow(raw_sub_gaussian);
	setAutoThreshold("Huang dark no-reset");
	//run("Threshold...");
		
	setThreshold(300, 65535);

	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	}

//	Tile to make this all more visible 
	
	run("Tile");
