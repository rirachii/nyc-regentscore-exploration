########### PHASE 4 EDA ##############
rm(list = ls())
require(ggplot2)
library(dplyr)
library("readxl")
library(openxlsx)
require(graphics)

# Loading Data

school_info <- read_excel('schools.xlsx')
staff_info <- read_excel('staff21.xlsx')
budget_info <- read_excel('budget21.xlsx')
View(staff_info)
View(budget_info)

#### EDA
# numeric_cols <- unlist(lapply(budget_info, is.numeric))         # Identify numeric columns
# data_numeric <- budget_info[ , numeric_cols]                    # Subset numeric columns of data
# data_numeric
# pairs(data_numeric, main = "budget_info data")

################### EDA: 1. BUDGET_INFO ###################
boxplot(`Total School Funding per Pupil` ~`DISTRICT`, data=budget_info)


################### EDA: 2. BUDGET_INFO ###################
# Merging funding per pupil with a school's mean avg score
regent_2019 <- read_excel('nyc_2019.xlsx')
pupil_mean <- merge(x=regent_2019,y=budget_info,by="BEDS CODE")

ggplot(pupil_mean) + geom_point(mapping = aes(x=`MEAN SCALE SCORE`, y=`Total School Funding per Pupil`))

################### EDA: 3. Compare Regent score 2019 to 2021 ###################
regent_2019 <- read_excel('nyc_2019.xlsx')
regent_2019 = merge(x=school_info,y=regent_2019,by="BEDS CODE")
regent_2019["YEAR"] = "2019" 
regent_2021 <- read_excel('nyc_2021.xlsx')
regent_2021 = merge(x=school_info,y=regent_2021,by="BEDS CODE")
regent_2021["YEAR"] = "2021"
regent_2021 <- regent_2021 %>%
  select(-'TOTAL NOT TESTED', -'TOTAL ENROLLED')
regent_19_21 <- rbind(regent_2019, regent_2021)
View(regent_2019)
# View(regent_2021)
# View(regent_19_21)

bp_2019_2021 <- ggplot(regent_19_21, aes(x=DISTRICT, y=`MEAN SCALE SCORE`, fill=YEAR)) + 
  geom_boxplot() 
bp_2019_2021


################### EDA: 4. Order Districts by Mean Scale Score ###################
highest_rengent_21 <- regent_2021 %>% 
  group_by(DISTRICT) %>% # group by DISTRICT 
  summarize(regent_mean = mean(`MEAN SCALE SCORE`, na.rm = TRUE)) %>% # compute mean delay
  arrange( desc(regent_mean) )
head(highest_rengent_21)
highest_rengent_21 <- regent_2021 %>% 
  group_by(DISTRICT) %>% # group by DISTRICT 
  summarize(regent_mean = mean(`MEAN SCALE SCORE`, na.rm = TRUE)) %>% # compute mean delay
  arrange( desc(regent_mean) )
tail(highest_rengent_21)

highest_rengent_19 <- regent_2019 %>% 
  group_by(DISTRICT) %>% # group by DISTRICT 
  summarize(regent_mean = mean(`MEAN SCALE SCORE`, na.rm = TRUE)) %>% # compute mean delay
  arrange( desc(regent_mean) )
head(highest_rengent_19)
highest_rengent_19 <- regent_2019 %>% 
  group_by(DISTRICT) %>% # group by DISTRICT 
  summarize(regent_mean = mean(`MEAN SCALE SCORE`, na.rm = TRUE)) %>% # compute mean delay
  arrange( desc(regent_mean) )
tail(highest_rengent_19)


################### EDA: 5. Students to Teacher Ratio ###################
for(i in 1:nrow(staff_info)) {  
  teachers <- staff_info[i, "Total Classroom Teachers"]
  students <- staff_info[i, "K-12 Enrollment"]
  staff_info[i, "Students To Teacher Ratio"] <- (students/teachers)
}
View(staff_info)
boxplot(`Students To Teacher Ratio` ~`DISTRICT`, data=staff_info)




################### Other Testing ###################

# boxplot(`Federal Funding \r\nper Pupil` ~`DISTRICT`, data=budget_info)
# boxplot(`State & Local\r\nFunding per Pupil` ~`DISTRICT`, data=budget_info)
# names(budget_info)
# names(staff_info)
# View(school_info)
# 
# p<-ggplot(regent_19_21, aes(x=DISTRICT, y=`MEAN SCALE SCORE`, group=DISTRICT)) +
#   geom_boxplot()
# p+scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"))
# 
# ggplot(regent_19_21, aes(x=DISTRICT, y=`MEAN SCALE SCORE`, fill=SUBJECT)) + 
#   geom_boxplot()
# 
# regent_2021 = merge(x=regent_2019,y=regent_2021,by="BEDS CODE")
# boxplot(`MEAN SCALE SCORE` ~`DISTRICT`, data=regent_2019)
# boxplot(`MEAN SCALE SCORE` ~`DISTRICT`, data=regent_2021)





