### Descriptive statistics ###

### Getting started --------------------------
# Clean up the working environment by restarting R (on Mac shift command 0)
rm(list = ls())
# In RStudio, Environment tab should show Environment is empty

# Verify working directory on personal machine ends in iSchool-demo
# E.g., "/Users/sarahclee/Documents/Analyses/iSchool-demo"
# getwd()

# Specify required packages
packages <- c("tidyverse", "cowplot")

# Check if required packages are installed and load or install & load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Check for updates
tidyverse_update()


# Read in birthweight data 2023 us territories (not 50 states)
birth_data <-read_csv("data/natality2023ps.csv")

# We care about variable dbwt, which is Birth Weight – Detail in Grams (Edited)

# Quick look data
birth_data %>%
  select(dbwt)%>%
  summary()

# Histogram
ggplot(data = birth_data, aes(x = dbwt)) + 
  geom_histogram(aes(),
                 fill = "firebrick",  
                 binwidth = 50, 
                 boundary = 0, 
                 closed = "left") + 
  labs(x = "Birth weight (g)", y = "Number of babies") + 
  theme_classic()

ggplot(data = birth_data, aes(x = dbwt)) + 
  geom_histogram(aes(y=..density..),
                 fill = "firebrick",  
                 binwidth = 50, 
                 boundary = 0, 
                 closed = "left") + 
  labs(x = "Birth weight (g)", y = "Number of babies") + 
  theme_classic()+
  stat_function(fun = dnorm, args = list(mean = mean(birth_data$dbwt),
                                         sd = sd(birth_data$dbwt)))

# Probability distribution plots
base<-ggplot()+
  xlim(0,6000)
  
base +  geom_function(fun = dnorm, colour = "black", 
                args = list(mean = mean(birth_data$dbwt),
                            sd = sd(birth_data$dbwt)))+
                  labs(x = "Birth weight (g)", y = "Probability density")+
                  theme_classic()

  
# Central Limit Theorem
  
ggplot(birth_data, aes(x = dbwt)) + 
  geom_histogram(fill = "firebrick", col = "black", binwidth = 50, 
                 boundary = 0, closed = "left") + 
  labs(x = "Birth weight (g)", y = "Number of babies") + 
  theme_classic(base_size = 22)+
  xlim(0,6000)

n <- 4
results <- vector()
for(i in 1:100000){
  BwtSample <- sample(birth_data$dbwt, size = n, replace = FALSE)
  results[i] <- mean(BwtSample)
}

ggplot(data.frame(results), aes(x = results)) + 
  geom_histogram(fill = "firebrick", col = "black", binwidth = 50, 
                 boundary = 0, closed = "left") + 
  labs(x = "Mean birth weight (g)", y = "Frequency") + 
  theme_classic(base_size = 22)+
  xlim(0, 6000)

n <- 64
results <- vector()
for(i in 1:100000){
  BwtSample <- sample(birth_data$dbwt, size = n, replace = FALSE)
  results[i] <- mean(BwtSample)
}

ggplot(data.frame(results), aes(x = results)) + 
  geom_histogram(fill = "firebrick", col = "black", binwidth = 50, 
                 boundary = 0, closed = "left") + 
  labs(x = "Mean birth weight (g)", y = "Frequency") + 
  theme_classic(base_size = 22)+
  xlim(0,6000)



# Calculate mean and standard deviation
birth_data %>%
  select(dbwt)%>%
  summarise(
    mean=mean(dbwt),
    sd=sd(dbwt)
  )

# Compare normal distribution and t-distribution
# Plot both distributions
# Define x-axis values
x_values <- seq(-5, 5, length.out = 100)

# Create data frame for plotting
data <- data.frame(x = x_values)

# Plot both distributions
ggplot(data, aes(x = x)) +
  # Student's t-distribution
  stat_function(fun = dt, args = list(df = 3),
                aes(color = "Student's t"), lwd = 1) +
  # Normal distribution
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1),
                aes(color = "Normal"), lwd = 1) +
  labs(title = "Student's t vs. Normal Distribution",
       x = "t or Z", y = "Probability ensity") +
  scale_color_manual(values = c("Student's t" = "blue", "Normal" = "firebrick")) +
  theme_classic()


# Read in beer data
data <- read_csv("data/TCB-Brew-Data.csv",
                          col_types = cols(batch_start = col_datetime(format = "%Y-%m-%d %H:%M:%S")))

# Quick look data
summary(data)

# Summary statistics
summ_beer <- data %>%
group_by(brand) %>%
summarise(
mean = mean(mash_pH),
median = median(mash_pH),
#IQR = IQR(mash_pH),
sd = sd(mash_pH),
var = var(mash_pH)
 )

# Plot mash_pH as a histograms
ggplot(data)+
  geom_histogram(aes(knockout_pH), binwidth = 0.10)+
  facet_wrap(~brand)

# Hefeweisen only

bba_data <- data %>%
  filter(brand=="bba")
ggplot(bba_data)+
  geom_histogram(aes(knockout_pH), binwidth = 0.05)
