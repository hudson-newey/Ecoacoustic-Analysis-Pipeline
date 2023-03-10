library(tidyverse)
library(GGally)
library(dplyr)

# new dataset
csv_in <- read_csv("./results_final.csv") %>% tibble()

# new dataset 2
csv_in <- read_csv("./report.csv") %>% tibble()

# old dataset
csv_in <- read_csv("./analysis_results.csv") %>% tibble()

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



ev <- df %>% mutate(heat =
  case_when(
    month == "12" | month == "01" | month == "02" ~ 3,
  month == "06" | month == "07" | month == "08" ~ 1,
    month == "03" | month == "04" | month == "05" ~ 2,
    month == "09" | month == "10" | month == "11" ~ 2
  )
)

# calculate the biodiversity of wet vs dry
dry_winter_detections <- ev %>% filter(heat == 1 & isWet == F)
dry_winter_richness <- dry_winter_detections %>% select(SpeciesCode) %>% unique() %>% count()
dry_winter_biodiversity <- dry_winter_richness / (dry_winter_detections %>% count())

dry_summer_detections <- ev %>% filter(heat == 3 & isWet == F)
dry_summer_richess <- dry_summer_detections %>% select(SpeciesCode) %>% unique() %>% count()
dry_summer_biodiversity <- dry_summer_richess / (dry_summer_detections %>% count())

wet_winter_detections <- ev %>% filter(heat == 1 & isWet == T)
wet_winter_richness <- wet_winter_detections %>% select(SpeciesCode) %>% unique() %>% count()
wet_winter_biodiversity <- wet_winter_richness / (wet_winter_detections %>% count())

wet_summer_detections <- ev %>% filter(heat == 3 & isWet == T)
wet_summer_richness <- wet_summer_detections %>% select(SpeciesCode) %>% unique() %>% count()
wet_summer_biodiversity <- wet_summer_richness / (wet_summer_detections %>% count())

# just seasons biodiversity (both wet + dry)
summer_detections <- ev %>%filter(heat == 3)
summer_richness <- summer_detections %>% select(SpeciesCode) %>% unique() %>% count()
summer_biodiversity <- summer_richness / (summer_richness %>% count()) 

winter_detections <- ev %>% filter(heat==1)
winter_richness <- winter_detections %>% select(SpeciesCode) %>% unique() %>% count()
winter_biodiversity <- winter_richness / (winter_richness %>% count())

# calculate biodiversity of just wet v dry sensors / sites
wet_detections <- ev %>% filter(isWet == T)
wet_richness <- wet_detections %>% select(SpeciesCode) %>% unique() %>% count()
wet_biodiveresity <- wet_richness / (wet_richness %>% count())

dry_detections <- ev %>% filter(isWet == F)
dry_richness <- dry_detections %>% select(SpeciesCode) %>% unique() %>% count()
dry_biodiveresity <- dry_richness / (dry_richness %>% count())

# wet vs dry spring

results <- bind_rows(
  bind_cols(dry_winter_biodiversity, F),
  bind_cols(dry_summer_biodiversity, F),
  bind_cols(wet_winter_biodiversity, T),
  bind_cols(wet_summer_biodiversity, T)
) %>% tibble()

# rejection region |Z| > 1.96

# using p0 = (x1 + x2) / (n1 + n2)
dry_p0 <- (dry_summer_biodiversity + dry_winter_biodiversity) / ((dry_summer_detections %>% count()) + (dry_winter_detections %>% count()))
dry_x1 <- dry_summer_biodiversity
dry_x2 <- dry_winter_biodiversity
dry_n1 <- dry_summer_detections %>% count()
dry_n2 <- dry_winter_detections %>% count()

# Z = (p1-p2)/sqrt(p0*(1-p0)*(1/n1+1/n2))
dry_Z <- (dry_x1 - dry_x2) / sqrt( dry_p0 * ( 1 - dry_p0 ) * ((1 / dry_n1) + (1 / dry_n2)) )
print(dry_Z)
# 10.70703

wet_p0 <- (wet_summer_biodiversity + wet_winter_biodiversity) / ((wet_summer_detections %>% count()) + (wet_winter_detections %>% count()))
wet_x1 <- wet_summer_biodiversity
wet_x2 <- wet_winter_biodiversity
wet_n1 <- wet_summer_detections %>% count()
wet_n2 <- wet_winter_detections %>% count()

wet_Z <- (wet_x1 - wet_x2) / sqrt( wet_p0 * (1 - wet_p0) * ((1 / wet_n1) + (1 / wet_n2)))
print(wet_Z)
# 0.1150728 !> 1.96



# calculate z score of summer v winter
# expected value if there is no difference
both_p0 <- (summer_biodiversity + winter_biodiversity) / ((summer_detections %>% count()) + (winter_detections %>% count()))
# observed values
both_x1 <- summer_biodiversity
both_x2 <- winter_biodiversity
# observed values / # of observations (means)
both_n1 <- summer_detections %>% count()
both_n2 <- winter_detections %>% count()
both_Z <- (both_x1 - both_x2) / sqrt( both_p0 * (1 - both_p0) * ((1 / both_n1) + (1 / both_n2)))
# z score
print(both_Z)
