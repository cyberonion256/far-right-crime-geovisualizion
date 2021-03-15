# far-right-crime-geovisualizion
R/shiny-based Geovisualization of Two Datasets on Far-Right Crimes in Germany

Not only after the killing of Walther Lübcke, the terror attack on a synagoge in Halle and the shooting spree in Hanau is far-right, anti-Semitic and anit-refugee crime surging in Germany. NGOs and journalists are cooperating to give a more granular picture of these hate crimes throughout Germany. Based on ~6,900 observation from the "arvig" dataset (2014 - today) and ~16,000 observations  of "tatort rechts" (rechte gewalt, rege) dataset (2000 - today), this R-based ShinyApp visualized individual and county level data. I expanded the aggregation on the county level with an 600-variable panel dataset on demographics, social and economic factors from the German Federal Bureau of Statistics. 

## Data Basis

1. ["arvig"](https://github.com/davben/arvig/) dataset by davben: Far-Right Crimes in Germany collected from 2014 until today. The dataset is based on information published by the civil society project [Mut Gegen Rechte Gewalt](https://www.mut-gegen-rechte-gewalt.de/).
2. ["tatort rechts"](https://tatortrechts.de/) (rechte gewalt, rege) dataset by Johannes Filter und Anna Neifer: Far-Right Crimes in a majority of German Bundesländer collected from 2000 until today
3. Aggregated county level dataset with ~600 variables on demographics, social and economic factors from the [German Federal Bureau of Statistics](https://www.regionalstatistik.de/genesis/online/).
4. Other material: Information on the murders and bombings of the far-right terror group ["Nationalsozialistischer Untergrund"](https://en.wikipedia.org/wiki/National_Socialist_Underground) between 1998 and 2011; shapefiles for the German counties from the [Federal Office for Cartography](https://gdz.bkg.bund.de/index.php/default/open-data.html)

## R/ShinyApp & Leaflet

This visualization uses the [Leaflet libary](https://rstudio.github.io/leaflet/) for R including the [Stamen tileset](http://maps.stamen.com/) and is deployed via a R-supplemented [ShinyApp](https://www.shinyapps.io/). To rebuild the server, download the repository, do _not_ change the names or structure of the files and run the ui.R file first locally before editing and possibly deploing it.
