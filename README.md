# How to trace axons using imageJ, automatically (nearly)  

[![hackmd-github-sync-badge](https://hackmd.io/1hzLYJ3HSny6CH9mzOxWVg/badge)](https://hackmd.io/1hzLYJ3HSny6CH9mzOxWVg)


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




```javascript=
imageJ code here 
```

