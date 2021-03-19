#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(leaflet)
library(sf)
library(shinythemes)
library(ggsci)


# Load data
arvig <- read.csv("data/arvig.csv", encoding = "UTF-8")
counties <- sf::st_read("data/VG250_Kreise.shp")
nsu <- read.csv("data/nsu-taten.csv", encoding = "UTF-8")
rege <- read.csv("data/rege_corr.csv", encoding = "UTF-8")
crimes_county <- read.csv("data/completeREx.csv", encoding = "UTF-8")

# Adjust LK_id label to missing leading zero
crimes_county$LK_id = ifelse(crimes_county$LK_id < 10000, paste0("0", crimes_county$LK_id), crimes_county$LK_id)
crimes_county$LK_id = as.factor(crimes_county$LK_id)

# Turn rege 0 into NA
crimes_county$rege_num_crimes[crimes_county$rege_num_crimes == 0] = NA
crimes_county$rege_num_crimes_log[crimes_county$rege_num_crimes == 0] =  NA

# Generate combined shape files from counties and crime data
shape <- merge(counties, crimes_county, by.x="RS", by.y="LK_id", all.x=TRUE)

# Set up color palettes
crime_color <- c("#EFC000FF", 
                 "#ebeb00FF", 
                 "#008dedFF", 
                 "#217300FF", 
                 "#3fc708FF",
                 "#870017FF",
                 "#c70022FF",
                 "#3B3B3BFF",
                 "#868686FF")
pal <- colorFactor(crime_color, arvig$category_en, reverse = FALSE)
pal_nsu <- colorFactor("Set1", nsu$Type, reverse = TRUE)
pal_afd <- colorNumeric("inferno", shape$afd_proz_2017_log, reverse=TRUE)
pal_crimes_rege <- colorNumeric("plasma", shape$rege_num_crimes_log, reverse=TRUE)
pal_crimes_arvig <- colorNumeric("plasma", shape$total_crimes_log, reverse=TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

        output$map <- renderLeaflet({
            leaflet() %>%
                addProviderTiles(providers$Stamen.Toner) %>%
                addCircleMarkers(
                    data = rege,
                    lat=~latitude,
                    lng=~longitude,
                    color="darkblue",
                    radius=5,
                    stroke = FALSE, 
                    fillOpacity = 0.3,
                    group = "rege",
                    popup = paste0("Datum: <b>", substr(rege$date,1,10), "</b><br>",
                                   paste0("Beschreibung: ", ifelse(
                                       nchar(rege$description)<400, 
                                       rege$description, 
                                       paste0(substr(rege$description, 1, 400), "...")), "<hr>"),
                                   paste0("Motiv: <b>", rege$motives, "</b><br>"),
                                   paste0("Straftatbestand: <b>", rege$title, "</b><hr>"),
                                   paste0('Quelle: <a href="', rege$url,'">', paste0(substr(rege$url, 1,25),"..."),"</a><br>"))
                ) %>%
                addCircleMarkers(
                    data = arvig,
                    lat=~latitude,
                    lng=~longitude,
                    color=~pal(category_en),
                    radius=5,
                    stroke = FALSE, 
                    fillOpacity = 0.3,
                    group = "arvig",
                    popup = paste0("Datum: <b>", arvig$date, "</b><br>",
                                   paste0("Kategorie <b>", arvig$category_de, " (", arvig$category_en, ") </b><hr>"),
                                   paste0("Beschreibung: ", ifelse(
                                       nchar(arvig$description)<400, 
                                       arvig$description, 
                                       paste0(substr(arvig$description, 1, 400), "...")), "<br>"),
                                   paste0('Quelle: <a href="', arvig$source,'">', paste0(substr(arvig$source, 1,25),"..."),"</a><br>"))
                ) %>%
                addPolygons(
                    data = counties,
                    color = "#666",
                    fillOpacity = 0,
                    stroke = TRUE,
                    weight = 2,
                    group = "Landkreise",
                    label=~GEN,
                    popup = paste0("Name: <b>", crimes_county$LK_name, "</b><br>",
                                   paste0("Bundesland / State: <b>", crimes_county$Bundesland, "</b><hr>"),
                                   paste0("Fläche / Area: <b>", crimes_county$km_area, "</b> km<sup>2</sup> <br>"),
                                   paste0("Einwohner / Population: <b>", crimes_county$Pop_total, "</b> (&#x2640: ", 100*round(crimes_county$Pop_female/crimes_county$Pop_total, 4), " %)<br>"),
                                   paste0("Durchnittsalter / Average age: <b>", crimes_county$Durchschnittsalter.Gesamtbevölkerung_Anzahl, "</b> Jahre/years"))
                    ) %>%
                addCircleMarkers(
                    data = nsu,
                    group = "NSU-Taten",
                    lng = ~lng, 
                    lat = ~lat,
                    color = ~pal_nsu(nsu$Type),
                    stroke = FALSE, 
                    fillOpacity = 1,
                    radius = 8,
                    popup = paste0("<b>",nsu$Type, "</b> - ", nsu$City, ", ", nsu$Date, "<hr>", 
                                   nsu$Informatio)
                ) %>%
                leaflet::addLegend(data=arvig, "bottomright", pal = pal, values = ~as.factor(category_en),
                          title = "Type of Crime",
                          opacity = 5,
                          labFormat = labelFormat(),
                          group="arvig") %>%
                addLayersControl(
                    overlayGroups = c("arvig", "rege", "NSU-Taten", "Landkreise"),
                    options = layersControlOptions(collapsed = FALSE)
                ) %>%
            hideGroup(c("rege", "NSU-Taten", "Landkreise"))
                
        }) 
        
        output$map_county <- renderLeaflet({
          leaflet(shape) %>%
            addProviderTiles(providers$Stamen.Toner) %>%
            addPolygons(
              color = ~pal_crimes_rege(rege_num_crimes_log),
              fillOpacity = 0.4,
              stroke = TRUE,
              weight = 2,
              group = "rege Crimes",
              label=~paste0("Number of crimes between 2000 and now: ", rege_num_crimes)
            ) %>%
            addPolygons(
              color = ~pal_crimes_arvig(total_crimes_log),
              fillOpacity = 0.4,
              stroke = TRUE,
              weight = 2,
              group = "arvig Crimes",
              label=~paste0("Number of crimes between 2016 and now: ", total_crimes)
            ) %>%
            addPolygons(
            color = "#666",
            fillOpacity = 0,
            stroke = TRUE,
            weight = 2,
            group = "Landkreise",
            label=counties$GEN,
            popup = paste0("Name: <b>", crimes_county$LK_name, "</b><br>",
                           paste0("Bundesland / State: <b>", crimes_county$Bundesland, "</b><hr>"),
                           paste0("Fläche / Area: <b>", crimes_county$km_area, "</b> km<sup>2</sup> <br>"),
                           paste0("Einwohner / Population: <b>", crimes_county$Pop_total, "</b> (&#x2640: ", 100*round(crimes_county$Pop_female/crimes_county$Pop_total, 4), " %)<br>"),
                           paste0("Durchnittsalter / Average age: <b>", crimes_county$Durchschnittsalter.Gesamtbevölkerung_Anzahl, "</b> Jahre/years"))
            ) %>%
            addPolygons(
              color = ~pal_afd(afd_proz_2017),
              fillOpacity = 0.3,
              stroke = TRUE,
              weight = 2,
              group = "AfD",
              label=~paste0("AfD 2017: ", 100*round(afd_proz_2017, 3), "%")
            ) %>%
            addPolygons(
              color = ~pal_afd(Durchschnittsalter.Gesamtbevölkerung_Anzahl),
              fillOpacity = 0.3,
              stroke = TRUE,
              weight = 2,
              group = "Durchschnittsalter",
              label=~paste0("Durchschnittsalter 2016: ", Durchschnittsalter.Gesamtbevölkerung_Anzahl, " Jahre")
            ) %>%
            addPolygons(
              color = ~pal_afd(income_per_person_2016),
              fillOpacity = 0.3,
              stroke = TRUE,
              weight = 2,
              group = "Einkommen pro Person",
              label=~paste0("Durchschnittseinkommen 2016: ", round(income_per_person_2016,0), " EUR pro Jahr")
            ) %>% 
            addPolygons(
              color = ~pal_afd(Anteil.Personen.mit.MHG.an.der.Gesamtbevölkerung_Prozent),
              fillOpacity = 0.3,
              stroke = TRUE,
              weight = 2,
              group = "Anteil Migrationshintergrund",
              label=~paste0("Anteil der Bevölkerung mit Migrationshintergrund: ", round(Anteil.Personen.mit.MHG.an.der.Gesamtbevölkerung_Prozent,2), "% (2019)")
            ) %>% 
            addPolygons(
              color = ~pal_afd(unemploymentPerPop_2019),
              fillOpacity = 0.3,
              stroke = TRUE,
              weight = 2,
              group = "Arbeitslose",
              label=~paste0("Arbeitslosenquote: ", round(unemploymentPerPop_2019,4)*100, "% ")
            ) %>% 
            addLayersControl(
              overlayGroups = c("rege Crimes", "arvig Crimes", "AfD", "Einkommen pro Person", "Durchschnittsalter", "Arbeitslose", "Anteil Migrationshintergrund", "Landkreise"),
              options = layersControlOptions(collapsed = FALSE)
            ) %>%
            hideGroup(c("arvig Crimes", "Einkommen pro Person", "Durchschnittsalter", "Arbeitslose", "Anteil Migrationshintergrund", "Landkreise"))
        })
        
        output$info <- renderUI({   
          HTML('<br> Please klick on datapoints for more information. Both visualizations are based on the <a href="https://github.com/davben/arvig/")>arvig</a> (2014 - today) and <a href="https://tatortrechts.de/">tatort rechts</a> (rechte gewalt, rege) dataset (2000 - today). <br>')
          })
        
        output$author <- renderUI({   
                HTML('Data Visualization by Louis Jarvers, MPA &#8216;21 (Columbia)')
        })
        
        output$map1_info <- renderUI({   
          HTML('<h3> I. Individual Far-Right Crimes with Background Information and Sources </h3>')
        })
        
        output$map2_info <- renderUI({   
          HTML('<h3> II. Aggregated Far-Right Crimes on County Level with Supplementary Demographic, Social and Economic Data</h3>')
        })
        
        output$imprint <- renderUI({   
                HTML('<br>&#169; 2021 - Made with <a href="https://shiny.rstudio.com/">R/Shiny</a> - <a href="https://www.louisjarvers.de/contact/">Contact the author</a><br><br>')
        })

})
