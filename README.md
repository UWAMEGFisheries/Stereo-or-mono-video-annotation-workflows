# Stereo-or-mono-video-annotation-workflows
Workflows including example R scripts for stereo or mono video surveys of fish. With an applied example using the EventMeasure software from www.seagis.com.au

<HR>
</HR>

<b>Table of contents</b>

[Introduction](#introduction)<br></br>
[Standard Operating Procedures](#method)<br></br>
[EventMeasure example](#eventmeasure-example)<br></br>
[Example data and R scripts](#r-example)<br></br>
[Bibliography](#bibliography)

#<a name="introduction"></a>Introduction

This repository is a work in progress.

Currently it only provides Example data and R scripts.

These R scripts are included in a published paper<sup>1</sup>, please cite if you use it.
Please refer to this GitHub repository for updated versions of the workflow and scripts.

<HR>
</HR>

To simplify the annotation process and still represent multiple scales of habitat in horizontaly facing imagery, we have gridded the images in 5 x 4 cells.

Protocol: each of the cells is annotated for dominant Benthic Composition, Field of View and Relief.

![alt text](https://cloud.githubusercontent.com/assets/14978794/18273176/b00f08fe-746e-11e6-82f2-ab29094f7403.JPG "TransectMeasure (seagis.com.au)")
<small>Screen capture from TransectMeasure (seagis.com.au) </small>

![alt text](https://cloud.githubusercontent.com/assets/14978794/18273210/d338f7e0-746e-11e6-929e-085d3f9f6c09.JPG "Application of annotation approach to characterise benthic composition and benthic complexity from horizontally facing remote video or from diver swum transects. Screen capture from TransectMeasure (seagis.com.au)")
<small>Screen capture from TransectMeasure (seagis.com.au) </small>
 
<HR>
</HR>

#<a name="method"></a>Method

The annotation schema is made up of nested Benthic Composition classes taken from the CATAMI schema and a Field of View and Relief class that are useful for characterising horizonatlly facing imagery.
BROAD>MORPHOLOGY>TYPE/FieldOfView/Relief

For detailed information on the particular taxanomic levels within the BROAD>MORPHOLOGY>TYPE classifications provided in this annotation schema, please consult the CATAMI visual guide within this repository.


To the BROAD class, we have added additional levels of "Open Water", to calculate the % of benthos within each image, and "Unknown", to account for the frequent issues of limited visibility typical for forward facing imagery.


The FieldOfView class allows the qualification of the image quality within each cell and the "Limited" level is used where benthos or substrate obscurs the cell within ~1m of the camera (typically the length of the diode arm of baited stereo-video systems)

Definition of FoV options:

<b>Facing Down:</b> No open water visible.

<b>Facing Up:</b> No substrate visible.

<b>Limited:</b> BRUV visibly landed on its side or the FoV is obstructed by benthos or substrate within 1m of camera (length of diode arm).

<b>Open:</b> BRUV landed upright and level on the substrate and there is an adequate amount of habitat available for classification.


The Relief class uses a 0-5 quatification of relief <sup>2</sup> and includes and "Unknown" level to account for cells with limited visibility.

<i>When the “BROAD” is “Open Water”, “Relief” should be classified as “Unknown”.</i>

“Relief” type is representative of complexity or the height and angle of substrate. Distinct categories have been adapted from Wilson et al. (2006):

<b>0.</b>	Flat substrate, sandy, rubble with few features. ~0 substrate slope.

<b>1.</b>	Some relief features amongst mostly flat substrate/sand/rubble. <45 degree substrate slope.

<b>2.</b>	Mostly relief features amongst some flat substrate or rubble. ~45 substrate slope.

<b>3.</b>	Good relief structure with some overhangs. >45 substrate slope.

<b>4.</b>	High structural complexity, fissures and caves. Vertical wall. ~90 substrate slope.

<b>5.</b>	Exceptional structural complexity, numerous large holes and caves. Vertical wall. ~90 substrate slope.


<HR>
</HR>

#<a name="recommended-approaches"></a>Recommended approaches

<b>Standard (rapid) assessment</b> of Benthic Composition, Field of View and Relief we recommend using ONLY the:
BROAD/FieldOfView/Relief classes. 
An experienced analyst would be able to annotate this schema to over 200 images a day.
<br></br>
OR
<br></br>
<b>Detailed assessment</b> of Benthic Composition (where coral bleaching or macroalgae compostion was of interest), Field of View and Relief we recommend using all the classes in the schema:
BROAD>MORPHOLOGY>TYPE/FieldOfView/Relief classes. 
An experienced analyst would be able to annotate this schema to over 120 images a day.

<HR>
</HR>

#<a name="transectmeasure-example"></a>TransectMeasure example

The annotation schema has been applied using the TransectMeasure software from www.seagis.com.au and the  <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/TransectMeasure_Schema_AttributeFile_160705.txt">attribute text file</a> for uploading the schema to TransectMeasure is provided in this repository.


For more information please see the  <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/StandardOperatingProcedure_TransectMeasure.md">Standard Operating Procedure for TransectMeasure</a>. 

#<a name="r-example"></a>Example data and R scripts

Also provided is an <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/x_1_RWorkflow.md"> R workflow example, including script, example habitat annotation data and outputs</a>. 

<HR>
</HR>

#<a name="bibliography"></a>Bibliography

1. Hill, N., Althaus, F., Rees, T., et al., 2014. CATAMI Classification Scheme for Scoring Marine Biota and Substrata in Underwater Imagery Version 1.4: December 2014
<br></br>
2. Wilson, S. K., N. A. J. Graham, and N. V. C. Polunin. 2006. “Appraisal of Visual Assessments of Habitat Complexity and Benthic Composition on Coral Reefs.” Marine Biology 151 (3). Springer-Verlag: 1069–76.
<br></br>
3. McLean, Dianne L., Tim J. Langlois, Stephen J. Newman, Thomas H. Holmes, Matthew J. Birt, Katrina R. Bornt, Todd Bond, et al. 2016. “Distribution, Abundance, Diversity and Habitat Associations of Fishes across a Bioregion Experiencing Rapid Coastal Development.” Estuarine, Coastal and Shelf Science 178 (September): 36–47.
<br></br>
4. Collins, Danielle, Tim J. Langlois, Todd Bond, Thomas H. Holmes, Euan S. Harvey, Rebecca Fisher Dianne L. McLean. In press. “A novel stereo-video method to investigate fish-habitat relationships.” Methods in Ecology and Evolution.
<br></br>
5. Katherine Bennett, Tim Langlois , George Shedrawi , Shaun Wilson, Dianne McLean. In press. “Can Diver Operated Stereo-Video Surveys for Fish Be Used to Collect Meaningful Data on Benthic Coral Reef Communities?” Limnology and Oceanography, Methods / ASLO.
