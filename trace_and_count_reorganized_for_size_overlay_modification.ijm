// ####################################################

// rejigged to reduce computational demands ... 

// ####################################################
// GET RID OF STUFF THAT IS ALREADY OPEN - NOT NECESSARY
// but useful  
// ####################################################
	
	close("*");

	//when running, set batch mode hide, but if you want to see process 
	//comment out
	
	setBatchMode("hide");
	
	time_start = getTime();
	
// ####################################################

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

	// Set-up 

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

// DECLARE YOUR INPUT (/AN DOR OUTPUT) FOLDER
// "list" is the files within the input folder, in an array – 
// these can be called using list[x], where x is a number 
// from 0 to the length of the list

// NOTE

// input folder is the 'master' folder. 
// within it, you have a direcotry called "_images", which contains
// the files to be analysed, and analysis etc., are not within it, 
// but in the 'master' folder. 

// ####################################################
	
	// chose your directory 
	//dir = getDirectory("Choose a Directory ");
	//input = dir; 
	

	// OR 
	
	// declare your directory 
	input = "/Volumes/labo_trudeau_4TB/Scan lamelles NRXN/TIFF";
	
	input_images = input + "/_images/"; 
	list = getFileList(input_images);

// ####################################################
// CREATE FOLDERS for putting stuff in (ie images and data) 
// ####################################################

	new_directory_overlay = input+"/overlay";
	File.makeDirectory(new_directory_overlay);

	new_directory_analysis = input+"/analysis";
	File.makeDirectory(new_directory_analysis);	

// ####################################################
// FOR, IMAGE - DO  
// ####################################################

	for (i = 0; i < list.length; i++){
	
	//OR	

	//for (i = 5; i < 9; i++){	
	
	path = list[i];
	file = input_images+path;
	
// ####################################################
// OPEN IMAGES  
// to crop on open (or opening non-TIFF files), use 
// bio formats (and you can specify dims for crop on import)
// ####################################################

	open(file);    

	//or 
	
	// dimensions for crop on import (note, you can change 
	// this to just be the whole image
	start_x = 5000;
	start_y = 5000;
	width = 6000;
	height = 6000;
	
	//*run("Bio-Formats", "open=file autoscale color_mode=Default crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT x_coordinate_1=start_x y_coordinate_1=start_y width_1=width height_1=height");
	
	raw = getTitle(); 
	title = replace(raw, ".tif", "");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); 
	

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~



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

//  ************** close gaussian and raw (memory ...)  
	
	
	selectWindow(gaussian); close(); 
	selectWindow(raw); close();

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

	// Counting 

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


// ####################################################
// Counting neurons in images - take normalized image
// and do count 
// ####################################################	

	selectWindow(raw_sub_gaussian);
	run("Duplicate...", " "); 
	segmentation_count = getTitle();
	
	run("Gaussian Blur...", "sigma=10");
	run("Enhance Contrast", "saturated=0.35"); setMinAndMax(0, 20);
	
	setAutoThreshold("Otsu dark");
	//run("Threshold...");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	segmented_count = getTitle();
	
	run("Set Measurements...", "  redirect=None decimal=1");
	run("Analyze Particles...", "size=15.00-1000.00 summarize");

// ####################################################	
// save count segmentation for looking at after
// ####################################################	

	selectWindow(segmentation_count);
	name = new_directory_overlay + "/" + title + "_overlay_count"; 
	saveAs("TIFF", name);
	close();
		
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

	// Tracing 

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


// ####################################################
// Threshold to binarise for skeletonization, choice of automatic threshold 
// or using set might be interesting -- TBD 
// ####################################################	
	
	selectWindow(raw_sub_gaussian);
	setAutoThreshold("Huang dark no-reset");
	//run("Threshold...");
		
	setThreshold(65, 65535);

	setOption("BlackBackground", true);
	run("Convert to Mask");
	
//	// ####################################################
//	//	DESPECKLE  
//	// ####################################################	

			
			for (j = 0; j < 10; j++){ 
				run("Despeckle");
				}

// ####################################################
// TURNING SEGMENTATION INTO SKELETON
// ####################################################
		
	run("Skeletonize"); 
	segmented = getTitle();
		
// ####################################################
// Measure skeleton and save results for image 
// NB we need to delete the analysis images and results
// table once saved
// ####################################################

	//number of splits of the image
	divisions = 8;
	
	x_width = getWidth(); 
	y_height = getHeight();

	for (s = 0; s < divisions; s++){
		
		y_div_height = y_height / divisions;
		
		y_pos = y_div_height*s;
		
		
		selectWindow(segmented);
		//setTool("rectangle");
		makeRectangle(0, y_pos , x_width, y_div_height);
		run("Duplicate...", " ");
		to_delete_duplicate = getTitle();
			
		run("Analyze Skeleton (2D/3D)", "prune=none show display");
		selectWindow("Result-labeled-skeletons"); close();
		selectWindow("Results"); run("Close");
		selectWindow("Branch information");
		saveAs("Results", new_directory_analysis + "/" + title + "_" + s + "_Branch information.csv"); 
		run("Close");
		selectWindow("Tagged skeleton"); close();
		selectWindow(to_delete_duplicate); close();
	}

// ####################################################
// Save skeleton segmentation for looking at after 
// ####################################################
	selectWindow(segmented);
	run("Select None"); // there is rectangle left from previous step to remove 
	name = new_directory_overlay + "/" + title + "_overlay_trace"; 
	saveAs("TIFF", name);

// ####################################################
// USE HARD CLOSE WHEN RUNNING ON LARGE DATA SETS AS WILL 
// BLOCK UP COMPUTER 
// ####################################################
	
	close("*");
	
// ####################################################
// FOR LOOP ... CLOSE  
// ####################################################

	}

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

// Save count 
// Show overlay of segmentations   

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


// ####################################################
// Save count 
// ####################################################	
	
	selectWindow("Summary");
	saveAs("Results", input + "/Count.csv"); run("Close"); 

// ####################################################
// Show images -- nb this will not work when big data sets.  
// ####################################################	

	setBatchMode("exit and display");


		time_end = getTime();
		time_taken = (time_end - time_start)/ 60000; // in minutes
		print("time taken =" + time_taken + " minutes");



//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

// ------- END -------- 

//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~










// ####################################################
// ####################################################
// UNUSED BUT USEFUL 
// ####################################################

// ####################################################
// CREATE COMPOSITE TO SEE OUTCOME OF TRACING and count  
// ####################################################	
// Merge of raw, segmented_for_merge, and segmented_count
// ####################################################
	
//*	selectWindow(raw); run("8-bit"); // for merge, have to be same bit depth
	
//*	run("Merge Channels...", "c1=" + raw +  " c3=[" + segmented_count +"] c7=[" + segmented_for_merge + "] create");
//*	run("Enhance Contrast", "saturated=0.35");
//*	setMinAndMax(50, 800); 
//*	name = new_directory_overlay + "/" + title+"_overlay"; 
//*	saveAs("TIFF", name);
//*	close();

// ####################################################
// Save skeleton prior to analyze skeleton
// ####################################################

//*	name = new_directory_overlay + "/" + title + "_overlay_trace"; 
//*	saveAs("TIFF", name);

// ####################################################	
// ####################################################	
//*	selectWindow(segmentation_count);
//*	name = new_directory_overlay + "/" + title + "_overlay_count"; 
//*	saveAs("TIFF", name);
//*	close();

	//run("Tile");

// ####################################################
// OPION TO CLOSE IMAGES when doing optimization of algo
// ####################################################	

	//selectWindow(raw); close();  selectWindow(segmented); close(); 
	//selectWindow(raw_sub_gaussian); close(); selectWindow(gaussian); close();
// ####################################################
// FOR ... loop to test pre-processing 
// ####################################################

//		for (gaus=10; gaus<=30; gaus+=10){ 
