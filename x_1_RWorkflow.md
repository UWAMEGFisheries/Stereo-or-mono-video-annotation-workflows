# R workflow 
Example workflow using R to take standard MaxN and Length+3D point queries from EventMeasure from www.seagis.com.au.

Two sequential scripts are provided:
1. format and check species names and min and max lengths against a master list.
2. calculate biomass from lenght-weigth relationship and tidy data for analysis

These R script are included in a published paper<sup>1</sup>, please cite if you use it.
Please refer to this GitHub repository for updated versions of the R script.

<HR>
</HR>

<b>Table of contents</b>

[Example R script](#method)<br></br>
[Example data](#transectmeasure-example)<br></br>
[Example output data and plot](#output-example)<br></br>
[Folder structure](#introduction)<br></br>
[Bibliography](#bibliography)

<HR>
</HR>

#<a name="method"></a>Example R script

The example <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/x_ExampleR_1_HabitatAnnotation_Format.and.write.data_160919.R">R script</a> is designed to import and format the raw annotation output from TransectMeasure and calculate mean and sd rugosity and % habitat cover.

The script uses Data Wrangling grammar from the tidyr<sup>2</sup> and dplyr<sup>3</sup> packages and data piplines. These packages shoulod be cited if you use the script.
For more information on the grammar of tidyr and dplyr see the <a href="https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf">Data Wrangling cheat sheet</a>. 

<HR>
</HR>

#<a name="transectmeasure-example"></a>Example annotation data

An example of <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/x_ExampleData_BRUV_TM_HabitatAnnotation.txt">habitat annotation data</a> generated from the TransectMeasure software is provided that will run with the above script.

<HR>
</HR>

#<a name="output-example"></a>Example output data and plot

The <a href="https://github.com/TimLanglois/HabitatAnnotation/blob/master/x_Example_R_habitat.output.csv">output </a> and a simple plot of the habitat data expected from the R script is provided below.

![alt text](https://cloud.githubusercontent.com/assets/14978794/18690494/f0370136-7fc0-11e6-9be5-6c746bef5483.png "Example plot of habitat data")




<HR>
</HR>

#<a name="introduction"></a>Folder structure

The above script assumes that you have a folder strucutre following this format:

![alt text](https://cloud.githubusercontent.com/assets/14978794/18631738/5438d4a0-7ea6-11e6-83b4-9795445876b9.png "Example folder structure")


<HR>
</HR>

#<a name="bibliography"></a>Bibliography

1. Langlois, T. J., S. J. Newman, M. Cappo, E. S. Harvey, B. M. Rome, C. L. Skepper, and C. B. Wakefield. 2015. Length selectivity of commercial fish traps assessed from in situ comparisons with stereo-video: Is there evidence of sampling bias? Fisheries research 161:145–155.
<br></br>
2. Hadley Wickham (2016). tidyr: Easily Tidy Data with `spread()` and `gather()` Functions. R package version 0.4.1.
  https://CRAN.R-project.org/package=tidyr
<br></br>
3. Hadley Wickham and Romain Francois (2015). dplyr: A Grammar of Data Manipulation. R package version 0.4.3.
  https://CRAN.R-project.org/package=dplyr

