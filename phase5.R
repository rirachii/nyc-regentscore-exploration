########### PHASE 5 MODELING ##############
rm(list = ls())
library(dplyr)
require(graphics)
library(openxlsx)
library("readxl")
library(ggplot2)

school_info <- read_excel('schools.xlsx')
staff_info <- read_excel('staff21.xlsx')
budget_info <- read_excel('budget21.xlsx')
regent_2021 <- read_excel('nyc_2021.xlsx')
subgroups_2021 <- read_excel('subgroups_2021.xlsx')
subgroups_2019 <- read_excel('subgroups_2019.xlsx')
View(regent_2021)
View(budget_info)



############ 2019 and 2021 RESEARCHER_FILE Data Cleaning ############
districts_2019 <- read_excel('original/3-8_ELA_AND_MATH_RESEARCHER_FILE_2019.xlsx')
districts_2021 <- read_excel('original/3-8_ELA_AND_MATH_RESEARCHER_FILE_2021.xlsx')
View(districts_2019)
no_col_names_df <- districts_2019[0, ]

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
for(i in 190000:nrow(districts_2019)) {
  if (grepl('NEW YORK CITY GEOGRAPHIC DISTRICT', districts_2019[i, 7])){
    district <- districts_2019[i, 7]
    districts_2019[i, 7] <- substrRight(district, 2)
    no_col_names_df[nrow(no_col_names_df) + 1,] <- districts_2019[i,]
  }
}
View(no_col_names_df)
subgroups_2019 = no_col_names_df
subgroups_2019 <- subgroups_2019 %>% mutate_at(c('MEAN_SCALE_SCORE'), as.numeric)
View(subgroups_2019)
names(subgroups_2019)[7] <- "DISTRICT"
colnames(subgroups_2019)
subgroups_2019 <- subgroups_2019 %>%
  select(-'SY_END_DATE', -'NRC_CODE', -'DISTRICT1',-'COUNTY_CODE', -'COUNTY_DESC')
# subgroups_2021 <- na.omit(subgroups_2021)
write.xlsx(subgroups_2019, file='subgroups_2019.xlsx', sheetName = "subgroups_2019",
           colNames = TRUE, rowNames = FALSE, append = FALSE)

hist(subgroups_2019$MEAN_SCALE_SCORE, breaks=10, main="With breaks=4")
############ For 2021
subgroups_2021 <- districts_2021[0, ]
for(i in 180000:nrow(districts_2021)) {
  if (grepl('NEW YORK CITY GEOGRAPHIC DISTRICT', districts_2021[i, 3])){
    
    parse_district <- districts_2021[i, 3]
    districts_2021[i, 3] <- substrRight(parse_district, 2)
    subgroups_2021[nrow(subgroups_2021) + 1,] <- districts_2021[i,]
  }
}
subgroups_2021 <- subgroups_2021 %>% mutate_at(c('MEAN_SCALE_SCORE'), as.numeric)
View(subgroups_2021)
names(subgroups_2021)[3] <- "DISTRICT"
colnames(subgroups_2021)
subgroups_2021 <- subgroups_2021 %>%
  select(-'SY_END_DATE')
# subgroups_2021 <- na.omit(subgroups_2021)
write.xlsx(subgroups_2021, file='subgroups_2021.xlsx', sheetName = "subgroups_2021",
           colNames = TRUE, rowNames = FALSE, append = FALSE)

hist(subgroups_2021$MEAN_SCALE_SCORE, breaks=10, main="With breaks=4")





##### DATA PREPROCESSING
pupil_mean <- merge(x=regent_2021,y=budget_info,by="BEDS CODE")
pupil_mean <- merge(x=pupil_mean,y=staff_info,by="BEDS CODE")
numeric_cols <- unlist(lapply(pupil_mean, is.numeric))         # Identify numeric columns
data_numeric <- pupil_mean[ , numeric_cols]                        # Subset numeric columns of data
data_numeric
colnames(pupil_mean)
View(pupil_mean)
data_numeric = select(pupil_mean,  'MEAN SCALE SCORE','K-12 Enrollment', 'Classroom Teachers', 
          'School Administration', 'General Ed \r\nK-12','Total School Funding per Pupil', 'Classroom Teachers w/ More than 3 Years Experience',
          'Total Classroom Teachers', 'Total Staff')
pairs(data_numeric, main = "budget_info data")
names(pupil_mean)[names(pupil_mean)=="MEAN SCALE SCORE"] <- "MEAN_SCALE_SCORE"
names(pupil_mean)[names(pupil_mean)=="K-12 Enrollment"] <- "K12_Enrollment"
names(pupil_mean)[names(pupil_mean)=="Total School Funding per Pupil"] <- "Total_School_Funding_per_Pupil"
View(pupil_mean)
colnames(pupil_mean)



##### LOGISTIC REGRESSION ED 2021
set.seed(123)
economic <- list("15", "16")
subgroups_2021_ed <- subgroups_2021 %>%
  filter((SUBGROUP_CODE %in% economic))
subgroups_2021_ed <- transform(subgroups_2021_ed, ED=ifelse(SUBGROUP_CODE=='15', 1, 0))
View(subgroups_2021_ed)
sample <- sample(c(TRUE, FALSE), nrow(subgroups_2021_ed), replace = T, prob = c(0.6,0.4))
train <- subgroups_2021_ed[sample, ]
test <- subgroups_2021_ed[!sample, ]
model <- glm(ED ~ MEAN_SCALE_SCORE, family = "binomial", data = train)
summary(model)
exp(coefficients(model))
exp(confint(model))
predict(model, data.frame(MEAN_SCALE_SCORE = c(550,590,600, 615)), type = "response")

subgroups_2021_ed %>%
  mutate(prob = ifelse(ED == 1, 1, 0)) %>%
  ggplot(aes(MEAN_SCALE_SCORE, prob)) +
  geom_point(alpha = .15) +
  geom_smooth(method = "glm", method.args = list(family = "binomial")) +
  ggtitle("Logistic regression model fit") +
  xlab("Mean Scale Score") +
  ylab("Probability of being Economically Disadvantage")


##### LOGISTIC REGRESSION ED 2019
set.seed(123)
economic <- list("15", "16")
subgroups_2019_ed <- subgroups_2019 %>%
  filter((SUBGROUP_CODE %in% economic))
subgroups_2019_ed <- transform(subgroups_2019_ed, ED=ifelse(SUBGROUP_CODE=='15', 1, 0))
View(subgroups_2019_ed)
sample <- sample(c(TRUE, FALSE), nrow(subgroups_2019_ed), replace = T, prob = c(0.6,0.4))
train <- subgroups_2019_ed[sample, ]
test <- subgroups_2019_ed[!sample, ]
model <- glm(ED ~ MEAN_SCALE_SCORE, family = "binomial", data = train)
summary(model)
exp(coefficients(model))
exp(confint(model))
predict(model, data.frame(MEAN_SCALE_SCORE = c(550,590,600, 615)), type = "response")

subgroups_2019_ed %>%
  mutate(prob = ifelse(ED == 1, 1, 0)) %>%
  ggplot(aes(MEAN_SCALE_SCORE, prob)) +
  geom_point(alpha = .15) +
  geom_smooth(method = "glm", method.args = list(family = "binomial")) +
  ggtitle("Logistic regression model fit") +
  xlab("Mean Scale Score") +
  ylab("Probability of being Economically Disadvantage")

##### LOGISTIC REGRESSION Homeless 2019
set.seed(123)
homeless <- list("20", "21")
subgroups_2019_hl <- subgroups_2021 %>%
  filter((SUBGROUP_CODE %in% homeless))
subgroups_2019_hl <- transform(subgroups_2019_hl, HL=ifelse(SUBGROUP_CODE=='20', 1, 0))
# View(subgroups_2019_hl)
sample <- sample(c(TRUE, FALSE), nrow(subgroups_2019_hl), replace = T, prob = c(0.6,0.4))
train <- subgroups_2019_hl[sample, ]
test <- subgroups_2019_hl[!sample, ]
model <- glm(HL ~ MEAN_SCALE_SCORE, family = "binomial", data = train)
summary(model)
exp(coefficients(model))
exp(confint(model))
predict(model, data.frame(MEAN_SCALE_SCORE = c(550, 590 ,600 ,615)), type = "response")

subgroups_2019_hl %>%
  mutate(prob = ifelse(HL == 1, 1, 0)) %>%
  ggplot(aes(MEAN_SCALE_SCORE, prob)) +
  geom_point(alpha = .15) +
  geom_smooth(method = "glm", method.args = list(family = "binomial")) +
  ggtitle("Logistic regression of Homelessness 2021") +
  xlab("Mean Scale Score") +
  ylab("Probability of being Homeless")



##### LINEAR REGRESSION
plot(Total_School_Funding_per_Pupil ~ K12_Enrollment, data=pupil_mean)
pupil_lm = lm(Total_School_Funding_per_Pupil ~ K12_Enrollment, data=pupil_mean)
coefficients(pupil_lm)
abline(pupil_lm)
# Evaluate the model
summary(pupil_lm)
plot(pupil_lm)
# Test Model
new.df <- data.frame(K12_Enrollment=c(200,2000))
predict(pupil_lm, new.df)


##### K MEANS
colnames(pupil_mean)
i <- c(3,15,47,38, 60) # 4 features
x <- pupil_mean[, i] # only first 4 columns/features
cl <- kmeans(x, 4, nstart = 1) # cluster 4 features : sepal w,l and petal w,l
print(cl)
plot(x, col = cl$cluster, pch=16, main="Mean Scale Score")
#let's get centers of clusters
cl$centers
# aggregate(pupil_mean, by=list(cluster=cl$cluster), mean)
# Cluster means
cl$size






############ Others
# colnames(staff_info)
# staff_info <- transform(staff_info, students_per_teacher=("K-12 Enrollment"+"Pre-K\r\nEnrollment")/'Total Classroom Teachers')
# 
# 
# numeric_cols <- unlist(lapply(staff_info, is.numeric))         # Identify numeric columns
# data_numeric <- staff_info[ , numeric_cols]                        # Subset numeric columns of data
# data_numeric
# # data_numeric = select(staff_info,  -'DISTRICT', -'All Other', -'Pre-K', -'Preschool', -'Instructional Media', 
#                       # -'Federal Funding \r\nper Pupil', -'Special Ed \r\nK- 12')
# data_numeric = select(data_numeric,  -'DISTRICT', -'Pre-K\r\nEnrollment', -'Preschool Special Ed Enrollment')
# colnames(staff_info)
# pairs(data_numeric, main = "budget_info data")
  