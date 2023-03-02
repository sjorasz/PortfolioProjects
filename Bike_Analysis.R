# This analysis is based on the Divvy case study "'Sophisticated, Clear, and Polished': Divvy and Data Visualization written by Kevin Hartman (found here: https://artscience.plot/home/divvy-dataviz-case-study). The puropose of this script is to consolidate downloaded Divvy data into a single dataframe and then conduct simple analysis to help answer the key question: "In what ways do members and casual riders use Divvy bikes differently?"

# Installing packages needed for analysis
# Tidyverse for data import and wrangling
# Lubridate for date functions
# ggplot for visualizations

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot")

library(tidyverse)
library(lubridate)
library(ggplot2)
getwd()
setwd("C:/Users/Scott/OneDrive/Documents/Data Analysis Course Materials/Projects/Google Course Capstone Project/Trip Data CSV")

# Upload datasets(csv files)
jan_2023 <- read_csv('01_2023_Trip_Data.csv')
feb_2022 <- read_csv('02_2022_Trip_Data.csv')
mar_2022 <- read_csv('03_2022_Trip_Data.csv')
apr_2022 <- read_csv('04_2022_Trip_Data.csv')
may_2022 <- read_csv('05_2022_Trip_Data.csv')
jun_2022 <- read_csv('06_2022_Trip_Data.csv')
jul_2022 <- read_csv('07_2022_Trip_Data.csv')
aug_2022 <- read_csv('08_2022_Trip_Data.csv')
sep_2022 <- read_csv('09_2022_Trip_Data.csv')
oct_2022 <- read_csv('10_2022_Trip_Data.csv')
nov_2022 <- read_csv('11_2022_Trip_Data.csv')
dec_2022 <- read_csv('12_2022_Trip_Data.csv')

# Checking to see if column names are the same for each file
colnames(jan_2023)
colnames(feb_2022)
colnames(mar_2022)
colnames(apr_2022)
colnames(may_2022)
colnames(jun_2022)
colnames(jul_2022)
colnames(aug_2022)
colnames(sep_2022)
colnames(oct_2022)
colnames(nov_2022)
colnames(dec_2022)

# Appears that all column names are the exact same, so I will be able to perform the join later

# Inspect the dataframes for incongruencies
str(jan_2023)
str(feb_2022)
str(mar_2022)
str(apr_2022)
str(may_2022)
str(jun_2022)
str(jul_2022)
str(aug_2022)
str(sep_2022)
str(oct_2022)
str(nov_2022)
str(dec_2022)

# All column types are consistent, I can now stack each month's data into one big dataframe

all_trips <- bind_rows(jan_2023,feb_2022,mar_2022,apr_2022,may_2022,jun_2022,jul_2022,aug_2022,sep_2022,oct_2022,nov_2022,dec_2022)

# Inspecting the new dataframe that has been created
colnames(all_trips) #List of column names
nrow(all_trips) #Number of rows
dim(all_trips) #Dimensions of dataframe
head(all_trips) #Look at first few rows of data
tail(all_trips) #Look at last few rows of data
str(all_trips) #Looking at columns and their data types
summary(all_trips) #Statistical summary of data

# Adding columns that list the date, month, day, and year of each ride
# This will allow me to aggregate ride data for each month, day, or year

all_trips$date <- as.Date(all_trips$started_at, format = "%m/%d/%Y %H:%M")
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")

# Add a ride_length column to all_trips (in seconds)
# Changing the data type for the ended_at and started_at columns
all_trips$ended_at <- as.POSIXct(all_trips$ended_at, format = "%m/%d/%Y %H:%M")
all_trips$started_at <- as.POSIXct(all_trips$started_at, format = "%m/%d/%Y %H:%M")

# Calculating the ride_length column by subtracting started_at from ended_at
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)


str(all_trips)

# Converting ride_length to numeric so I can perform calculations on that column
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)

# Checking to see if there are any negative ride_lengths
sum(all_trips$ride_length < 0)

# The negative ride_lengths are when bikes were taken out of docks and checked for quality by the company, we don't need these values for our analysis
# I will create a new version of the dataframe (v2) since data is being removed so I can reference the old data if necessary
all_trips_v2 <- all_trips[!(all_trips$ride_length<0),]

# Looking at some descriptive analysis of the ride_length column (in seconds)
mean(all_trips_v2$ride_length) #straight average (total ride length / rides)
median(all_trips_v2$ride_length) #midpoint number in the ascending array of ride lengths
max(all_trips_v2$ride_length) #longest ride
min(all_trips_v2$ride_length) #shortest ride

# Can also get same results using summary
summary(all_trips_v2$ride_length)

# Making a comparisonn between members and casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# Looking at the average ride time grouped by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# The days of the week are out of order. I want them in order from Sunday to Saturday
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Analyzing ridership data by type and weekday
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% #creates weekday field using wday()
  group_by(member_casual, weekday) %>% #groups by usertype and weekday
  summarise(number_of_rides = n() #calculates the number of rides and average duration 
  ,average_duration = mean(ride_length)) %>% # calculates the average duration
  arrange(member_casual, weekday) # sorts

# Creating a visualization based on the number of rides by rider type
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

# Creating a visualization based on the duration of the rides by rider type
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")

# Exporting data to create more visualizations using Tableau
counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(counts, file = "C:/Users/Scott/OneDrive/Documents/Data Analysis Course Materials/Projects/Google Course Capstone Project/avg_ride_length.csv")