########### PHASE 3 DATE CLEANING AND PROCESSING ##############
rm(list = ls())

# Load data
install.packages("readxl")
install.packages("openxlsx")

library(dplyr)
library("readxl")
library(openxlsx)

nyc_2019 <- read_excel('original/3-8_ELA_AND_MATH_NYC_SUMMARY_2019.xls')
nyc_2021 <- read_excel('original/3-8_ELA_AND_MATH_NYC_SUMMARY_2021.xls')

####################  DATA CLEANING 1, Processing char to numeric
nyc_2019 <- nyc_2019 %>% mutate_at(c('TOTAL TESTED',
                                     'LEVEL 1 COUNT', 'LEVEL 2 COUNT', 'LEVEL 3 COUNT',
                                     'LEVEL 4 COUNT', 'MEAN SCALE SCORE'), as.numeric)
nyc_2021 <- nyc_2021 %>% mutate_at(c('TOTAL ENROLLED','TOTAL NOT TESTED','TOTAL TESTED',
                                     'LEVEL 1 COUNT', 'LEVEL 2 COUNT', 'LEVEL 3 COUNT',
                                     'LEVEL 4 COUNT', 'MEAN SCALE SCORE'), as.numeric)


####################  DATA CLEANING 2, Percent to decimal
is.percentage <- function(x) any(grepl("%$", x))
nyc_2019 <- nyc_2019 %>%
  mutate_if(is.percentage, ~as.numeric(sub("%", "", .))/100)
nyc_2021 <- nyc_2021 %>%
  mutate_if(is.percentage, ~as.numeric(sub("%", "", .))/100)


################### # DATA CLEANING 3, remove rows with NA and unnecessary attributes 
nyc_2019 <- nyc_2019 %>%
  select(-'SCHOOL YEAR END DATE', -'STUDENT SUBGROUP', -'LEVEL 2-4 PCT', -'NAME')
nyc_2019 <- na.omit(nyc_2019)

nyc_2021 <- nyc_2021 %>%
  select(-'SCHOOL YEAR END DATE', -'NAME')
nyc_2021 <- na.omit(nyc_2021)




write.xlsx(nyc_2019, file='nyc_2019.xlsx', sheetName = "nyc_2019", 
           colNames = TRUE, rowNames = FALSE, append = FALSE)
write.xlsx(nyc_2021, file='nyc_2021.xlsx', sheetName = "nyc_2021", 
           colNames = TRUE, rowNames = FALSE, append = FALSE)


# DATA CLEANING 4, Separate DF for Bed Code(primary id), School Name, District #
school_info <- read_excel('original/3-8_ELA_AND_MATH_NYC_SUMMARY_2021.xls') # read 2020-21 assessment dataset
school_info <- school_info[,c("BEDS CODE","NAME")]

school_info = school_info[!duplicated(school_info$'BEDS CODE'),]

district <- 'NEW YORK CITY GEOGRAPHIC DISTRICT # 1'
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
for(i in 1:nrow(school_info)) {       
  if (grepl('NEW YORK CITY GEOGRAPHIC DISTRICT', school_info[i, 2])){
    district <- school_info[i, 2]
    school_info[i, 3] <- (substrRight(district, 2))
  }
  else{
    school_info[i, 3] <- (substrRight(district, 2))
  }}
names(school_info)[3] <- "DISTRICT"
str(school_info)
write.xlsx(school_info, file='schools.xlsx', sheetName = "SCHOOL_INFO", 
           colNames = TRUE, rowNames = FALSE, append = FALSE)


################### DATA CLEANING 5 ################### 
school_info <- read_excel('schools.xlsx')
View(school_info)

budget21 <- read.xlsx('original/2021_nyc_finance.xlsx', sheet=3, skipEmptyRows = FALSE)
budget_col_name <- budget21[6,]

colnames(budget21) <- budget_col_name
names(budget21)[1] <- "BEDS CODE"
budget21 = merge(x=school_info,y=budget21,by="BEDS CODE")
budget_cols <- names(budget21)
budget21 <- budget21 %>%
  select(-'School Name', -'Local School Code', -'BOCES Services')

# set any na to 0
budget21[is.na(budget21)] = 0
# process data type of budget from chr to numeric
budget21 <- budget21 %>% mutate_at(budget_cols[4:24], as.numeric)
str(budget21)
View(budget21)
write.xlsx(budget21, file='budget21.xlsx', sheetName = "budget21", 
           colNames = TRUE, rowNames = FALSE, append = FALSE)


# DP for Staff info
staff21 <- read.xlsx('original/2021_nyc_finance.xlsx', sheet=2, skipEmptyRows = FALSE)
staff_col_names <- staff21[6,]
colnames(staff21) <- staff_col_names
names(staff21)[1] <- "BEDS CODE"
staff21 <- merge(x=school_info,y=staff21,by="BEDS CODE")

staff21 <- staff21 %>%
  select(-'School Name', -'Local School Code', -'Is the school scheduled to close? (Y/N)',
         'If so, what year?')


new_col_names <- names(staff21)
new_col_names
# process data type of budget from chr to numeric
staff21 <- staff21 %>% mutate_at(new_col_names[10:24], as.numeric)

str(staff21)
View(staff21)
write.xlsx(staff21, file='staff21.xlsx', sheetName = "staff21", 
           colNames = TRUE, rowNames = FALSE, append = FALSE)


##### EDA FOR SUBGROUPS
colnames(subgroups_2021)

ethnicity <- list("04", "05", "06", "07", "08", "09")
subgroups_2021_ethn <- subgroups_2021 %>%
  filter((SUBGROUP_CODE %in% ethnicity))
ggplot(subgroups_2021_ethn, aes(fill=subgroup_name, y=TOTAL_ENROLLED, x=DISTRICT)) + 
  geom_bar(position="fill", stat="identity")



# K MEANS
ethnicity <- list("04", "05", "06", "07", "08", "09")
subgroups_2021_eth <- subgroups_2021 %>%
  filter((SUBGROUP_CODE %in% ethnicity))
subgroups_2021_eth <- na.omit(subgroups_2021_eth)
View(subgroups_2021_eth)
i <- grep("DISTRICT", names(subgroups_2021_eth))
x <- subgroups_2021_eth[, i]
cl <- kmeans(x, 3, nstart = 100)
plot(x, col = cl$cluster, pch=17, main="DISTRICT")
#let's evaluate the model: What is the between_SS / total_SS?
print(cl)

i <- c(1,2,3,4) # 4 features
x <- iris[, i] # only first 4 columns/features
cl <- kmeans(x, 3, nstart = 1) # cluster 4 features : sepal w,l and petal w,l
plot(x, col = cl$cluster, pch=16, main="Sepal and Petal")

#let's get centers of clusters
cl$centers

