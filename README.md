Mapping livestock movements in Sahelian Africa 
========================================================================

## Description  

This repositories contains the code and data used to generate maps of potential paths for livestock movements as described in [[1]](https://www.nature.com/articles/s41598-020-65132-8). The method consists in combining the information contained in a livestock mobility network with landscape connectivity based on different mobility conductance layers. We illustrate our approach with a livestock mobility network in Senegal and Mauritania in 2014 in dry and wet seasons.               
## Inputs

The algorithm takes as inputs four rasters in tif (same resolution and extent) and a csv file with column names, **the value separator is a semicolon ";"**.  

* **LU_dry.tif:** Walking layer based on land use features (changes according to the season "dry" or "wet").
* **Road.tif:** Main road network.
* **Border.tif:** Administrative border line and crossing points.
* **Node.tif:** Position of the nodes.
* **OD_dry.csv:** Number of animals (third column) displaced from one node (first column) to another (second column). Changes according to the season ("dry" or "wet").

The three first rasters are combined to build the conductance map. The fourth raster and the csv file are used to build the mobility network. More details about the data sources and preprocessing are available in the paper.
   
## Model

The model **mpp.R** can be launch from the file **main.R** to build a potential map **Current_dry.tif** according to the season (**dry** or **wet**). It has three parameters:

* **season:** For the season to be considered "dry" or "wet".
* **delta_w:** The first parameter used to combined the different layers. Can be used to adjust the relative importance of the walking layer compared to the road layer.
* **delat_r:** The second parameter used to combined the different layers. Can be used to adjust the permeability of the border.

The script **mpp.R** builds the conductance maps based on the three first rasters and the parameter **delta_w** and **delta_r**. It then generates one potential map by pair of nodes calling the Python script **csrun.py** ([Circuitscape 4.0.5](https://pypi.org/project/Circuitscape/)). This script needs a configuration file **Resistance.ini** directly edited in **mpp.R**. Finally, **mpp.R** averages all the potential maps weighted by the number of animals. 
   
More details about the model are available in the paper.

## References

[1] Jahel *et al.* (2019) [Mapping livestock movements in Sahelian Africa .](https://www.nature.com/articles/s41598-020-65132-8) *Scientific Reports* 10, 8339.

## Citation

If you use this code, please cite:

Jahel *et al.* (2019) [Mapping livestock movements in Sahelian Africa .](https://www.nature.com/articles/s41598-020-65132-8) *Scientific Reports* 10, 8339.

If you need help, find a bug, want to give me advice or feedback, please contact me!
You can reach me at maxime.lenormand[at]inrae.fr
