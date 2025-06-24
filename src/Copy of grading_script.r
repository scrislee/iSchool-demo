###############################################
###Script for Grading learnr Tutorials#########
###############################################

####This form is automated, except for the following items:
#Line 39: Update the Semester ("Fall", "Spring", "Summer", "other").
#Line 40: Update the Year (YYYY).
#Line 41: Update the Notebook Name (number and first word from the Google Form
#         dropdown is fine).
#
#Line 44: Update the weight of the Correctness portion of the grade. 
#         The Completeness (Effort) portion will update automatically.
#
#Line 48: Update the weight of the code blocks (as opposed to multiple choice 
#questions). The multiple choice weight will update automatically.
#
#Line 52: Ensure the path to the Hash Form Response Spreadsheet is the link to 
#         your file on Google Drive -- Navigate to Google Drive, find the 
#         spreadsheet, and right-click to obtain the link to the file. Paste 
#         that link inside the quotes on line 52.
###############################################


###Press `ctrl+a` or `cmd+a` to highlight all and Enter/Return to run the entire 
###notebook. Grades will be in the `overall_scores` data frame. The first run 
###won't complete if you are prompted to choose a Google Account to authenticate.
###If this happens, just make the choice of account by choosing a number in the 
###console and hit Enter/Return. Now ctrl+a or cmd+a and Enter/Return will run 
###the script.


#rm(list = ls())

library(googlesheets4)
library(learnrhash)
library(tidyverse)

#Choose semester ("Fall", "Spring", "Summer", "Other"), year (YYYY), and notebook
semester_id <- "Fall"
year_id <- 2025
notebook_id <- "1 Intro"

#Balance correctness/completeness weighting
correctness_weight <- 0.2
effort_weight <- 1 - correctness_weight

#Balance code versus multiple choice weighting
code_blocks_weight <- 0.5
multiple_choice_weight <- 1 - code_blocks_weight

#Set the path to the Google Sheet
path_to_sheet <- "https://docs.google.com/spreadsheets/d/1g9nO2Agw6o2r83Qjjgc7eI7QufX9fD7rkOM1pu9xF-c/edit?usp=drive_link"

#Read the student submissions into R
studentSubmissions <- googlesheets4::read_sheet(path_to_sheet)

#Generate better columns names
names(studentSubmissions) <- c("timestamp", "first_name", "last_name", "semester", "year", "notebook", "hash", "rating", "comments")

#See the student submissions
studentSubmissions %>%
  head()

#Filter to the current semester and notebook of interest
toGrade_df <- studentSubmissions %>%
  filter((((semester == semester_id) & (year == year_id)) | (last_name == "Instructor"))  & (str_detect(notebook, notebook_id))) 

#Filter to most recent submission for each student
toGrade_df <- toGrade_df %>%
  group_by(first_name, last_name) %>%
  arrange(timestamp) %>% 
  slice(n()) %>%
  ungroup() %>%
  select(-timestamp)

#Collect Question Responses (Multiple Choice)
question_results <- learnrhash::extract_questions(toGrade_df)

#Collect Exercise Responses (Code Blocks)
exercise_results <- learnrhash::extract_exercises(toGrade_df)

#Get graded exercise and questions lists
graded_exercises <- read_csv("https://raw.githubusercontent.com/agmath/IntroductoryStatistics/main/ASI_graded_exercises.csv")
graded_questions <- read_csv("https://raw.githubusercontent.com/agmath/IntroductoryStatistics/main/ASI_graded_questions.csv")

exercise_results <- exercise_results %>%
  inner_join(graded_exercises)
question_results <- question_results %>%
  inner_join(graded_questions)

#Obtain number of total graded exercises and questions
num_exercises <- graded_exercises %>%
  filter(str_detect(notebook, notebook_id)) %>%
  nrow()

num_questions <- graded_questions %>%
  filter(str_detect(notebook, notebook_id)) %>%
  nrow()

##################################################
##Compute Grades##################################
##################################################

###################
#Grade Questions###
###################

#See Question Results
question_results %>%
  head()

#Compute Question Responses
question_scores <- question_results %>%
  group_by(first_name, last_name) %>%
  summarize(tot_q_answered = sum(!is.na(answer)),
            tot_q_correct = sum(correct, na.rm = TRUE),
            pct_q_answered = ifelse(num_questions == 0, 1, tot_q_answered/num_questions),
            pct_q_correct = ifelse(num_questions == 0, 1, tot_q_correct/num_questions),
            weighted_q_score = effort_weight*pct_q_answered + correctness_weight*pct_q_correct
            )

question_scores
###################
#Grade Exercises###
###################

#See Exercise Results
exercise_results %>%
  head()

#Compute Code Exercise Grades
exercise_scores <- exercise_results %>%
  group_by(first_name, last_name) %>%
  summarize(tot_ex_answered = sum(!is.na(answer)),
            tot_ex_correct = sum(correct, na.rm = TRUE),
            pct_ex_answered = ifelse(num_exercises == 0, 1, tot_ex_answered/num_exercises),
            pct_ex_correct = ifelse(num_exercises == 0, 1, tot_ex_correct/num_exercises),
            weighted_ex_score = effort_weight*pct_ex_answered + correctness_weight*pct_ex_correct
            )

exercise_scores

#######################################
####Aggregate Multiple Choice and Code#
####Block Scores#######################
#######################################
overall_scores <- question_scores %>%
  full_join(
    exercise_scores,
    by = c("first_name", "last_name")) %>%
  mutate(
    weighted_ex_score = ifelse(num_exercises == 0, 1, weighted_ex_score),
    weighted_q_score = ifelse(num_questions == 0, 1, weighted_q_score),
    weighted_ex_score = ifelse(is.na(weighted_ex_score), 0, weighted_ex_score),
    weighted_q_score = ifelse(is.na(weighted_q_score), 0, weighted_q_score),
    overall_weighted_score = code_blocks_weight*weighted_ex_score + multiple_choice_weight*weighted_q_score
    ) %>%
  select(first_name, last_name, overall_weighted_score)

overall_scores

comments <- studentSubmissions %>% 
  filter(!is.na(comments)) %>%
  filter(semester == semester_id, year == year_id) %>%
  filter(str_detect(notebook, notebook_id)) %>%
  select(first_name, last_name, comments)
  #select(comments)

comments %>%
  pull(comments)

question_results %>%
  group_by(label) %>%
  summarize(class_score = mean(correct))

exercise_results %>%
  group_by(label) %>%
  summarize(class_score = mean(correct, na.rm = TRUE))
# 
studentSubmissions %>% 
  #filter(!is.na(comments)) %>%
  filter(semester == semester_id, year == year_id) %>%
  filter(str_detect(notebook, notebook_id)) %>%
  ggplot() + 
  geom_histogram(aes(x = rating, after_stat(density)),
           color = "black",
           fill = "purple",
           binwidth = 1) +
  geom_density(aes(x = rating),
               fill = "purple",
               alpha = 0.5) + 
  labs(
    title = "Overall Comfort and Confidence",
    x = "Comfort Level",
    y = ""
  ) + 
  expand_limits(x = c(0, 10))

question_results %>%
  count(label, correct) %>%
  mutate(correct = ifelse(correct == TRUE, "correct", "incorrect")) %>%
  ggplot() + 
  geom_col(aes(x = label, fill = correct, y = n),
                 color = "black",
           position = "dodge") +
  scale_fill_manual(values = c("purple", "darkred")) +
  labs(
    title = "Question Results",
    x = "",
    y = ""
  ) + 
  coord_flip()

exercise_results %>%
  count(label, correct) %>%
  mutate(correct = ifelse(correct == TRUE, "correct", "incorrect")) %>%
  ggplot() + 
  geom_col(aes(x = label, fill = correct, y = n),
           color = "black",
           position = "dodge") +
  scale_fill_manual(values = c("purple", "darkred")) +
  labs(
    title = "Exercise Results",
    x = "",
    y = ""
  ) + 
  coord_flip()

rm(list = setdiff(ls(), c("comments", "exercise_scores", "question_scores", "overall_scores", "semester_id", "year_id", "notebook_id", "correctness_weight", "code_blocks_weight")))
