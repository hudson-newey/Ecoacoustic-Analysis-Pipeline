# THIS SCRIPT IS NOW DEPRECATED. PLEASE USE ./auto/plot-biodiversity.r
# the auto directory specifies scripts that will be automatically run by the analysis program

library(tidyverse)
library(GGally)
library(dplyr)

csv_in <- read_csv("./report.csv") %>% tibble()
colnames(csv_in) = c("Selection", "View", "Channel", "BeginTime", "EndTime", "LowFreq", "HighFreq", "SpeciesCode", "CommonName", "Confidence", "date", "season", "isWet")

# since BirdNet logs results with accuracy < 0.5, we need to discard these results
# season data is also incorrect, so extract this
df <- csv_in %>% filter(Confidence >= 0.85) %>% subset(select = -season)

# add seasonal information to tibble
df <- df %>% mutate(month =
                      format(
                        as.POSIXct(date)
                        , "%m"
                      )
)

# environment variables
ev <- df %>% mutate(heat =
                      case_when(
                        month == "12" | month == "01" | month == "02" ~ 1, # summer
                        month == "03" | month == "04" | month == "05" ~ 2, # autumn
                        month == "06" | month == "07" | month == "08" ~ 3, # winter
                        month == "09" | month == "10" | month == "11" ~ 4 # spring
                      )
)

# calculate the biodiversity of wet vs dry
dry_summer_detections <- ev %>% filter(heat == 1 & isWet == F) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(dry_summer_detections) = c("SpeciesCode", "Richness")
dry_summer_precursor <- dry_summer_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
dry_summer_biodiversity <- 1-(sum(dry_summer_precursor$Numerator)/(sum(dry_summer_precursor$Richness)*(sum(dry_summer_precursor$Richness)-1)))

# no dry autmn data anyways
dry_autumn_detections <- ev %>% filter(heat == 2 & isWet == F) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(dry_autumn_detections) = c("SpeciesCode", "Richness")
dry_autumn_precursor <- dry_autumn_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
dry_autumn_biodiversity <- 1-(sum(dry_autumn_precursor$Numerator)/(sum(dry_autumn_precursor$Richness)*(sum(dry_autumn_precursor$Richness)-1)))

dry_winter_detections <- ev %>% filter(heat == 3 & isWet == F) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(dry_winter_detections) = c("SpeciesCode", "Richness")
dry_winter_precursor <- dry_winter_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
dry_winter_biodiversity <- 1-(sum(dry_winter_precursor$Numerator)/(sum(dry_winter_precursor$Richness)*(sum(dry_winter_precursor$Richness)-1)))

dry_spring_detections <- ev %>% filter(heat == 4 & isWet == F) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(dry_spring_detections) = c("SpeciesCode", "Richness")
dry_spring_precursor <- dry_spring_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
dry_spring_biodiversity <- 1- (sum(dry_spring_precursor$Numerator)/(sum(dry_spring_precursor$Richness)*(sum(dry_spring_precursor$Richness)-1)))

# wet locations
wet_summer_detections <- ev %>% filter(heat == 1 & isWet == T) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(wet_summer_detections) = c("SpeciesCode", "Richness")
wet_summer_precursor <- wet_summer_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
wet_summer_biodiversity <- 1- (sum(wet_summer_precursor$Numerator)/(sum(wet_summer_precursor$Richness)*(sum(wet_summer_precursor$Richness)-1)))

wet_autumn_detections <- ev %>% filter(heat == 2 & isWet == T) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(wet_autumn_detections) = c("SpeciesCode", "Richness")
wet_autumn_precursor <- wet_autumn_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
wet_autumn_biodiversity <- 1- (sum(wet_autumn_precursor$Numerator)/(sum(wet_autumn_precursor$Richness)*(sum(wet_autumn_precursor$Richness)-1)))

wet_winter_detections <- ev %>% filter(heat == 3 & isWet == T) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(wet_winter_detections) = c("SpeciesCode", "Richness")
wet_winter_precursor <- wet_winter_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
wet_winter_biodiversity <- 1- (sum(wet_winter_precursor$Numerator)/(sum(wet_winter_precursor$Richness)*(sum(wet_winter_precursor$Richness)-1)))

# no wet spring data anyways
wet_spring_detections <- ev %>% filter(heat == 4 & isWet == T) %>% group_by(SpeciesCode) %>% count(SpeciesCode)
colnames(wet_spring_detections) = c("SpeciesCode", "Richness")
wet_spring_precursor <- wet_spring_detections %>% select(SpeciesCode, Richness) %>% mutate(Numerator = (Richness * (Richness - 1)))
wet_spring_biodiversity <- 1- (sum(wet_spring_precursor$Numerator)/(sum(wet_spring_precursor$Richness)*(sum(wet_spring_precursor$Richness)-1)))

# just summer winter
dataWD <- data %>% filter(Season == "Summer" | Season == "Winter")

# results holds the biodiversity of every season
dataDry <- bind_rows(
  bind_cols("Summer", dry_summer_biodiversity, F),
  bind_cols("Autumn", dry_autumn_biodiversity, F),
  bind_cols("Winter", dry_winter_biodiversity, F),
  bind_cols("Spring", dry_spring_biodiversity, F)
) %>% tibble()
colnames(dataDry)[1] <- "Season";
colnames(dataDry)[2] <- "Biodiversity";
colnames(dataDry)[3] <- "IsWet";

dataWet <- bind_rows(
  bind_cols("Summer", wet_summer_biodiversity, T),
  bind_cols("Autumn", wet_autumn_biodiversity, T),
  bind_cols("Winter", wet_winter_biodiversity, T),
  bind_cols("Spring", wet_spring_biodiversity, T)
) %>% tibble()
colnames(dataWet)[1] <- "Season";
colnames(dataWet)[2] <- "Biodiversity";
colnames(dataWet)[3] <- "IsWet";

data <- full_join(dataDry, dataWet)

# most important plot
data %>% ggplot(aes(x=factor(Season, level=c('Summer', 'Autumn', 'Winter', 'Spring')),y = Biodiversity, color = IsWet)) +
  geom_point(size = 4) +
  ggtitle("Ecoacoustic Biodiversity Over Seasons")+
  xlab("Season")+
  ylim(0,1)+
  guides(color=guide_legend(title="Location"))+
  scale_color_hue(labels = c("Dry", "Wet"))

# just summer + winter plot
s_w_graph <- data %>% filter(Season=="Summer" | Season =="Winter")
s_w_graph %>% ggplot(aes(x=factor(Season, level=c('Summer', 'Winter')),y = Biodiversity, color = IsWet)) +
  geom_point(size = 4) +
  ggtitle("Ecoacoustic Biodiversity Over Seasons")+
  xlab("Season")+
  ylim(0,1)+
  guides(color=guide_legend(title="Location"))+
  scale_color_hue(labels = c("Dry", "Wet"))

dataWet %>% ggplot(aes(x = Season, y = Biodiversity)) +
  geom_point(size = 4) +
  ggtitle("Ecoacoustic Biodiversity of Wet Sensor Over Seasons")

dataDry %>% ggplot(aes(x = Season, y = Biodiversity)) +
  geom_point(size = 4) +
  ggtitle("Ecoacoustic Biodiversity of Dry Sensor Over Seasons")

dataWD <- dataWD %>% group_by(IsWet)
dataWD %>% ggplot(aes(x = Season, y = Biodiversity, color = IsWet)) +
  geom_point(size = 4) +
  ggtitle("Ecoacoustic Biodiversity Over Seasons")+
  guides(color=guide_legend(title="Location"))+
  scale_color_hue(labels = c("Dry", "Wet"))+
  geom_line(aes(x = Season, y = biodiversity))

