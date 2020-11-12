# How to trace axons using imageJ, automatically (nearly) 

[![hackmd-github-sync-badge](https://hackmd.io/1hzLYJ3HSny6CH9mzOxWVg/badge)](https://hackmd.io/1hzLYJ3HSny6CH9mzOxWVg)

---

If you are reading this on github, I recommend you open it [here](https://hackmd.io/@samuelorion/H1ro8MoKw) on hackMD (the markdown does not render in the same way). 

---

> [name=Samuel Burke 2020-11-12 ]
## Table of Contents

[TOC]

### Aim 

Take images of labelled axons, automatically segment the axons.  

### Overview  

Using images of TH+ DA neurons, we will segment the axons, quantify the total length of neurites, and normalize this on an estimate of the number of cells in the image.

If you so wish, you can count neurons manually. But, this is ineffective when we are trying to do experiments in 96 well plates*  

*or on samples where the replicates is high enough that we can actually detect changes (see my previous power analysis for required replicates in our system link).  

### Instructions 

- This document is the continuation of [this document](https://udemontreal.sharepoint.com/:w:/r/sites/Gr-LaboTrudeau2/_layouts/15/Doc.aspx?sourcedoc=%7B0BDE5351-CB80-4243-A3E5-6134666C45C5%7D&file=Document.docx&action=default&mobileredirect=true).
- Make sure you have the [Fiji distribution of imageJ installed](https://imagej.net/Fiji).

### What we are trying to do 

Turn this ... 

![](https://i.imgur.com/CyYJVJ9.jpg)

Into this ... 

![](https://i.imgur.com/HILnpjJ.png)

And then, segment cell bodies ...

![](https://i.imgur.com/6hgaRaC.png)

To normalize the data, and plot

![](https://i.imgur.com/o0WDj8e.png)

:::info
I reccomend using [RStudio](https://rstudio.com/).

However, here, we will just have the ouput as the total number of pixels of the segmentation (ie TH+ neurite length)
:::


**Data**

Download and unzip the [data](https://udemontreal.sharepoint.com/sites/Gr-LaboTrudeau2/Shared%20Documents/Forms/AllItems.aspx?csf=1&web=1&e=b203BP&cid=60f440f3%2D0561%2D4de1%2Db97f%2Dbb1c4a1982bc&FolderCTID=0x012000FBF258D21CD3FF46B1E21489D30FD838&viewid=055d6acf%2Dcb3c%2D4814%2D8785%2D27989f87f108&id=%2Fsites%2FGr%2DLaboTrudeau2%2FShared%20Documents%2FLab%20Books%2FSamuel%20Burke%2FShared%5FData). 

The folder is called: "TraceAxons_workshop"

It contains three images.

![](https://i.imgur.com/2LXxY8D.png)


**ImageJ**

Open ImageJ / Fiji, create a new script, and selcet IJ1 Macro language 

![](https://i.imgur.com/k0gVy8U.png)




:::success
If you know very little about scripts in ImageJ, I encourage you to consult these two resources: 

[Introduction | Analyzing fluorescence microscopy images with ImageJ](https://petebankhead.gitbooks.io/imagej-intro/content/)

[Macro Programming in ImageJ](https://imagej.nih.gov/ij/docs/macro_reference_guide.pdf)

:::

The ImageJ script can be found [here on github](https://github.com/samuelorion/imageJ_axon_tracing_workshop/blob/main/TraceAxons_worksho.ijm)

#### How does this work? Step by step... 

Declare a path to the folder containging your images.

 
```javascript=
input = "/Users/SamuelOrion/Downloads/TraceAxons_workshop";
list = getFileList(input);
Array.show(list);
```

We create a list of files which can be found in the folder, and can now be indexed. 

>Value  
>B1.tif  
>C1.tif  
>C2.tif  

We will use this list to work our way though the images. 


:::info
Look what happens when we use the print function.
:::

```javascript=
print(list[0]);
```
> B1.tif

We create a for loop that creates a path to each image in the folder, than we can then use to open each file. 

```javascript=
for (i = 0; i < list.length; i++){
		path = list[i];
		file = input + path;
```
:::info
you can replace 'list.length' with a an integer, such that you choose how many images you open (ie put 1 there, and it will only open the first image in 'list')
:::
To set up our analysis (and for opening images that are not .tif (ie. .nd files)), we will use biofromats to open the image.

We can also crop on import, such that we can opn a selection of the images we want to analyze. 


```javascript=
start_x = 2000;
start_y = 2000;
width = 3000;
height = 3000;
		
run("Bio-Formats", "open=file autoscale color_mode=Default crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT x_coordinate_1=start_x y_coordinate_1=start_y width_1=width height_1=height");
		
raw = getTitle(); 
title = replace(raw, ".tif", "");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
```

:::warning
start_ -> the top left hand cornder position of your crop  

width and height -> the size of your crop   

We also create to variable 'raw' and 'title'. This is the name of the raw (unmodified image), and 'title' the name of the image without the file extension. 
:::

Once you understand these steps, you can comment out commands that you deem not necessary. ie 

```javascript=
print(list[0]);
```

Is not necessary, but good to show what is going on. 

Remember, when writing a script, write all these extra pieces such that you can really follow what you are telling the computer to do. 

### Image processing
:::warning
Note that the current image in selection is 'raw', so no need to select it. 
::: 

```javascript=
run("Enhance Contrast", "saturated=0.35");
setMinAndMax(0, 750); // just for viz
run("Duplicate...", " "); 
gaussian = getTitle();

gauss_sigma = 20; // can be modified 
run("Gaussian Blur...", "sigma=gauss_sigma"); 
```

