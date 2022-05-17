library(ggplot2)
library(plyr)
library(tidyverse)
library(scales)

GResults <- read.csv("GeneralResults.csv")
DResults <- read.csv("DoctorResults.csv")

low = c(1,2,3,4,5,6,7,11,12,16) #Indexes of the patients with core:tissue at risk <= 0.4
high = c(8,9,10,13,14,15,17,18,19,20)#Indexes of the patients with core:tissue at risk > 0.4

DLow = DResults[low,]
DHigh = DResults[high,]

meansd.fig <- data.frame(
  Question1Rater1 = c(mean(DResults$d1_q1_real), mean(DResults$d1_q1_pred), sd(DResults$d1_q1_real), sd(DResults$d1_q1_pred)),
  Question1Rater2 = c(mean(DResults$d2_q1_real), mean(DResults$d2_q1_pred), sd(DResults$d2_q1_real), sd(DResults$d2_q1_pred)),
  Question1Rater3 = c(mean(DResults$d3_q1_real), mean(DResults$d3_q1_pred), sd(DResults$d3_q1_real), sd(DResults$d3_q1_pred)),
  ###################
  QuestionQ2ARater1 = c(mean(DResults$d1_Q2A_real), mean(DResults$d1_Q2A_pred), sd(DResults$d1_Q2A_real), sd(DResults$d1_Q2A_pred)),
  QuestionQ2ARater2 = c(mean(DResults$d2_Q2A_real), mean(DResults$d2_Q2A_pred), sd(DResults$d2_Q2A_real), sd(DResults$d2_Q2A_pred)),
  QuestionQ2ARater3 = c(mean(DResults$d3_Q2A_real), mean(DResults$d3_Q2A_pred), sd(DResults$d3_Q2A_real), sd(DResults$d3_Q2A_pred)),
  ###################
  QuestionQ2BRater1 = c(mean(DResults$d1_Q2B_real), mean(DResults$d1_Q2B_pred), sd(DResults$d1_Q2B_real), sd(DResults$d1_Q2B_pred)),
  QuestionQ2BRater2 = c(mean(DResults$d2_Q2B_real), mean(DResults$d2_Q2B_pred), sd(DResults$d2_Q2B_real), sd(DResults$d2_Q2B_pred)),
  QuestionQ2BRater3 = c(mean(DResults$d3_Q2B_real), mean(DResults$d3_Q2B_pred), sd(DResults$d3_Q2B_real), sd(DResults$d3_Q2B_pred)),
  ###################
  QuestionQ2CRater1 = c(mean(DResults$d1_Q2C_real), mean(DResults$d1_Q2C_pred), sd(DResults$d1_Q2C_real), sd(DResults$d1_Q2C_pred)),
  QuestionQ2CRater2 = c(mean(DResults$d2_Q2C_real), mean(DResults$d2_Q2C_pred), sd(DResults$d2_Q2C_real), sd(DResults$d2_Q2C_pred)),
  QuestionQ2CRater3 = c(mean(DResults$d3_Q2C_real), mean(DResults$d3_Q2C_pred), sd(DResults$d3_Q2C_real), sd(DResults$d3_Q2C_pred)),
  ###################
  QuestionQ2DRater1 = c(mean(DResults$d1_Q2D_real), mean(DResults$d1_Q2D_pred), sd(DResults$d1_Q2D_real), sd(DResults$d1_Q2D_pred)),
  QuestionQ2DRater2 = c(mean(DResults$d2_Q2D_real), mean(DResults$d2_Q2D_pred), sd(DResults$d2_Q2D_real), sd(DResults$d2_Q2D_pred)),
  QuestionQ2DRater3 = c(mean(DResults$d3_Q2D_real), mean(DResults$d3_Q2D_pred), sd(DResults$d3_Q2D_real), sd(DResults$d3_Q2D_pred)),
  ###################
  Question3Rater1 = c(mean(DResults$d1_q3_real), mean(DResults$d1_q3_pred), sd(DResults$d1_q3_real), sd(DResults$d1_q3_pred)),
  Question3Rater2 = c(mean(DResults$d2_q3_real), mean(DResults$d2_q3_pred), sd(DResults$d2_q3_real), sd(DResults$d2_q3_pred)),
  Question3Rater3 = c(mean(DResults$d3_q3_real), mean(DResults$d3_q3_pred), sd(DResults$d3_q3_real), sd(DResults$d3_q3_pred)),
  ###################
  Question1Rater1 = c(mean(DResults$d1_q4_real), mean(DResults$d1_q4_pred), sd(DResults$d1_q4_real), sd(DResults$d1_q4_pred)),
  Question1Rater2 = c(mean(DResults$d2_q4_real), mean(DResults$d2_q4_pred), sd(DResults$d2_q4_real), sd(DResults$d2_q4_pred)),
  Question1Rater3 = c(mean(DResults$d3_q4_real), mean(DResults$d3_q4_pred), sd(DResults$d3_q4_real), sd(DResults$d3_q4_pred))
 )
write.csv(meansd.fig,"meansd.csv", row.names = TRUE)

# Box Plot for all the questions
boxplot(GResults$Q1_real, GResults$Q1_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 1 Boxplot")
boxplot(GResults$Q2A_real, GResults$Q2A_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 2A Boxplot")
boxplot(GResults$Q2B_real, GResults$Q2B_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 2B Boxplot")
boxplot(GResults$Q2C_real, GResults$Q2C_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 2C Boxplot")
boxplot(GResults$Q2D_real, GResults$Q2D_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 2D Boxplot")
boxplot(GResults$Q3_real, GResults$Q3_predicted, names = c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 3 Boxplot")
boxplot(GResults$Q4_real, GResults$Q4_predicted, names =c("Real CTP", "Synthetic CTP"), ylab = "Scores Reported", col = c("blue","red"), main = "Question 4 Boxplot")


### Question 1 Plots
# creating data frame
Q1_gen <- data.frame(
  votes = c(sum(1*GResults$Q1_real == 0), sum(1*GResults$Q1_real == 1), sum(1*GResults$Q1_predicted == 0), sum(1*GResults$Q1_predicted == 1)),
  imageType = c("Real CTP", "Real CTP", "Synthetic CTP", "Synthetic CTP"),
  voted = c("not real", "is real", "not real" , "is real"))

write.csv(Q1_gen,"Q1_gen.csv", row.names = TRUE)

Q1_d1 <- data.frame(
  votes = c(sum(1*DResults$d1_q1_real == 0), sum(1*DResults$d1_q1_real == 1), sum(1*DResults$d1_q1_pred == 0), sum(1*DResults$d1_q1_pred == 1)),
  imageType = c("Real CTP", "Real CTP", "Synthetic CTP", "Synthetic CTP"),
  voted = c("not real", "is real", "not real" , "is real"))

write.csv(Q1_d1,"Q1_d1.csv", row.names = TRUE)

Q1_d2 <- data.frame(
  votes = c(sum(1*DResults$d2_q1_real == 0), sum(1*DResults$d2_q1_real == 1), sum(1*DResults$d2_q1_pred == 0), sum(1*DResults$d2_q1_pred == 1)),
  imageType = c("Real CTP", "Real CTP", "Synthetic CTP", "Synthetic CTP"),
  voted = c("not real", "is real", "not real" , "is real"))

write.csv(Q1_d2,"Q1_d2.csv", row.names = TRUE)

Q1_d3 <- data.frame(
  votes = c(sum(1*DResults$d3_q1_real == 0), sum(1*DResults$d3_q1_real == 1), sum(1*DResults$d3_q1_pred == 0), sum(1*DResults$d3_q1_pred == 1)),
  imageType = c("Real CTP", "Real CTP", "Synthetic CTP", "Synthetic CTP"),
  voted = c("not real", "is real", "not real" , "is real"))

write.csv(Q1_d3,"Q1_d3.csv", row.names = TRUE)

Q2_low <- data.frame(
  votes = c(sum(1*(DLow$d1_Q2A_pred > DLow$d1_Q2A_real)) + sum(1*(DLow$d1_Q2B_pred > DLow$d1_Q2B_real)) + sum(1*(DLow$d1_Q2C_pred > DLow$d1_Q2C_real)) + sum(1*(DLow$d1_Q2D_pred > DLow$d1_Q2D_real)), 
            sum(1*(DLow$d1_Q2A_pred == DLow$d1_Q2A_real)) + sum(1*(DLow$d1_Q2B_pred == DLow$d1_Q2B_real)) + sum(1*(DLow$d1_Q2C_pred == DLow$d1_Q2C_real)) + sum(1*(DLow$d1_Q2D_pred == DLow$d1_Q2D_real)), 
            sum(1*(DLow$d1_Q2A_pred < DLow$d1_Q2A_real)) + sum(1*(DLow$d1_Q2B_pred < DLow$d1_Q2B_real)) + sum(1*(DLow$d1_Q2C_pred < DLow$d1_Q2C_real)) + sum(1*(DLow$d1_Q2D_pred < DLow$d1_Q2D_real)), 
            sum(1*(DLow$d2_Q2A_pred > DLow$d2_Q2A_real)) + sum(1*(DLow$d2_Q2B_pred > DLow$d2_Q2B_real)) + sum(1*(DLow$d2_Q2C_pred > DLow$d2_Q2C_real)) + sum(1*(DLow$d2_Q2D_pred > DLow$d2_Q2D_real)), 
            sum(1*(DLow$d2_Q2A_pred == DLow$d2_Q2A_real)) + sum(1*(DLow$d2_Q2B_pred == DLow$d2_Q2B_real)) + sum(1*(DLow$d2_Q2C_pred == DLow$d2_Q2C_real)) + sum(1*(DLow$d2_Q2D_pred == DLow$d2_Q2D_real)), 
            sum(1*(DLow$d2_Q2A_pred < DLow$d2_Q2A_real)) + sum(1*(DLow$d2_Q2B_pred < DLow$d2_Q2B_real)) + sum(1*(DLow$d2_Q2C_pred < DLow$d2_Q2C_real)) + sum(1*(DLow$d2_Q2D_pred < DLow$d2_Q2D_real)), 
            sum(1*(DLow$d3_Q2A_pred > DLow$d3_Q2A_real)) + sum(1*(DLow$d3_Q2B_pred > DLow$d3_Q2B_real)) + sum(1*(DLow$d3_Q2C_pred > DLow$d3_Q2C_real)) + sum(1*(DLow$d3_Q2D_pred > DLow$d3_Q2D_real)), 
            sum(1*(DLow$d3_Q2A_pred == DLow$d3_Q2A_real)) + sum(1*(DLow$d3_Q2B_pred == DLow$d3_Q2B_real)) + sum(1*(DLow$d3_Q2C_pred == DLow$d3_Q2C_real)) + sum(1*(DLow$d3_Q2D_pred == DLow$d3_Q2D_real)), 
            sum(1*(DLow$d3_Q2A_pred < DLow$d3_Q2A_real)) + sum(1*(DLow$d3_Q2B_pred < DLow$d3_Q2B_real)) + sum(1*(DLow$d3_Q2C_pred < DLow$d3_Q2C_real)) + sum(1*(DLow$d3_Q2D_pred < DLow$d3_Q2D_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2_high <- data.frame(
  votes = c(sum(1*(DHigh$d1_Q2A_pred > DHigh$d1_Q2A_real)) + sum(1*(DHigh$d1_Q2B_pred > DHigh$d1_Q2B_real)) + sum(1*(DHigh$d1_Q2C_pred > DHigh$d1_Q2C_real)) + sum(1*(DHigh$d1_Q2D_pred > DHigh$d1_Q2D_real)), 
            sum(1*(DHigh$d1_Q2A_pred == DHigh$d1_Q2A_real)) + sum(1*(DHigh$d1_Q2B_pred == DHigh$d1_Q2B_real)) + sum(1*(DHigh$d1_Q2C_pred == DHigh$d1_Q2C_real)) + sum(1*(DHigh$d1_Q2D_pred == DHigh$d1_Q2D_real)), 
            sum(1*(DHigh$d1_Q2A_pred < DHigh$d1_Q2A_real)) + sum(1*(DHigh$d1_Q2B_pred < DHigh$d1_Q2B_real)) + sum(1*(DHigh$d1_Q2C_pred < DHigh$d1_Q2C_real)) + sum(1*(DHigh$d1_Q2D_pred < DHigh$d1_Q2D_real)), 
            sum(1*(DHigh$d2_Q2A_pred > DHigh$d2_Q2A_real)) + sum(1*(DHigh$d2_Q2B_pred > DHigh$d2_Q2B_real)) + sum(1*(DHigh$d2_Q2C_pred > DHigh$d2_Q2C_real)) + sum(1*(DHigh$d2_Q2D_pred > DHigh$d2_Q2D_real)), 
            sum(1*(DHigh$d2_Q2A_pred == DHigh$d2_Q2A_real)) + sum(1*(DHigh$d2_Q2B_pred == DHigh$d2_Q2B_real)) + sum(1*(DHigh$d2_Q2C_pred == DHigh$d2_Q2C_real)) + sum(1*(DHigh$d2_Q2D_pred == DHigh$d2_Q2D_real)), 
            sum(1*(DHigh$d2_Q2A_pred < DHigh$d2_Q2A_real)) + sum(1*(DHigh$d2_Q2B_pred < DHigh$d2_Q2B_real)) + sum(1*(DHigh$d2_Q2C_pred < DHigh$d2_Q2C_real)) + sum(1*(DHigh$d2_Q2D_pred < DHigh$d2_Q2D_real)), 
            sum(1*(DHigh$d3_Q2A_pred > DHigh$d3_Q2A_real)) + sum(1*(DHigh$d3_Q2B_pred > DHigh$d3_Q2B_real)) + sum(1*(DHigh$d3_Q2C_pred > DHigh$d3_Q2C_real)) + sum(1*(DHigh$d3_Q2D_pred > DHigh$d3_Q2D_real)), 
            sum(1*(DHigh$d3_Q2A_pred == DHigh$d3_Q2A_real)) + sum(1*(DHigh$d3_Q2B_pred == DHigh$d3_Q2B_real)) + sum(1*(DHigh$d3_Q2C_pred == DHigh$d3_Q2C_real)) + sum(1*(DHigh$d3_Q2D_pred == DHigh$d3_Q2D_real)), 
            sum(1*(DHigh$d3_Q2A_pred < DHigh$d3_Q2A_real)) + sum(1*(DHigh$d3_Q2B_pred < DHigh$d3_Q2B_real)) + sum(1*(DHigh$d3_Q2C_pred < DHigh$d3_Q2C_real)) + sum(1*(DHigh$d3_Q2D_pred < DHigh$d3_Q2D_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))


Q2_gen <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2A_pred > DResults$d1_Q2A_real)) + sum(1*(DResults$d1_Q2B_pred > DResults$d1_Q2B_real)) + sum(1*(DResults$d1_Q2C_pred > DResults$d1_Q2C_real)) + sum(1*(DResults$d1_Q2D_pred > DResults$d1_Q2D_real)), 
            sum(1*(DResults$d1_Q2A_pred == DResults$d1_Q2A_real)) + sum(1*(DResults$d1_Q2B_pred == DResults$d1_Q2B_real)) + sum(1*(DResults$d1_Q2C_pred == DResults$d1_Q2C_real)) + sum(1*(DResults$d1_Q2D_pred == DResults$d1_Q2D_real)), 
            sum(1*(DResults$d1_Q2A_pred < DResults$d1_Q2A_real)) + sum(1*(DResults$d1_Q2B_pred < DResults$d1_Q2B_real)) + sum(1*(DResults$d1_Q2C_pred < DResults$d1_Q2C_real)) + sum(1*(DResults$d1_Q2D_pred < DResults$d1_Q2D_real)), 
            sum(1*(DResults$d2_Q2A_pred > DResults$d2_Q2A_real)) + sum(1*(DResults$d2_Q2B_pred > DResults$d2_Q2B_real)) + sum(1*(DResults$d2_Q2C_pred > DResults$d2_Q2C_real)) + sum(1*(DResults$d2_Q2D_pred > DResults$d2_Q2D_real)), 
            sum(1*(DResults$d2_Q2A_pred == DResults$d2_Q2A_real)) + sum(1*(DResults$d2_Q2B_pred == DResults$d2_Q2B_real)) + sum(1*(DResults$d2_Q2C_pred == DResults$d2_Q2C_real)) + sum(1*(DResults$d2_Q2D_pred == DResults$d2_Q2D_real)), 
            sum(1*(DResults$d2_Q2A_pred < DResults$d2_Q2A_real)) + sum(1*(DResults$d2_Q2B_pred < DResults$d2_Q2B_real)) + sum(1*(DResults$d2_Q2C_pred < DResults$d2_Q2C_real)) + sum(1*(DResults$d2_Q2D_pred < DResults$d2_Q2D_real)), 
            sum(1*(DResults$d3_Q2A_pred > DResults$d3_Q2A_real)) + sum(1*(DResults$d3_Q2B_pred > DResults$d3_Q2B_real)) + sum(1*(DResults$d3_Q2C_pred > DResults$d3_Q2C_real)) + sum(1*(DResults$d3_Q2D_pred > DResults$d3_Q2D_real)), 
            sum(1*(DResults$d3_Q2A_pred == DResults$d3_Q2A_real)) + sum(1*(DResults$d3_Q2B_pred == DResults$d3_Q2B_real)) + sum(1*(DResults$d3_Q2C_pred == DResults$d3_Q2C_real)) + sum(1*(DResults$d3_Q2D_pred == DResults$d3_Q2D_real)), 
            sum(1*(DResults$d3_Q2A_pred < DResults$d3_Q2A_real)) + sum(1*(DResults$d3_Q2B_pred < DResults$d3_Q2B_real)) + sum(1*(DResults$d3_Q2C_pred < DResults$d3_Q2C_real)) + sum(1*(DResults$d3_Q2D_pred < DResults$d3_Q2D_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2_Q2A <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2A_pred > DResults$d1_Q2A_real)), 
            sum(1*(DResults$d1_Q2A_pred == DResults$d1_Q2A_real)), 
            sum(1*(DResults$d1_Q2A_pred < DResults$d1_Q2A_real)), 
            sum(1*(DResults$d2_Q2A_pred > DResults$d2_Q2A_real)), 
            sum(1*(DResults$d2_Q2A_pred == DResults$d2_Q2A_real)), 
            sum(1*(DResults$d2_Q2A_pred < DResults$d2_Q2A_real)), 
            sum(1*(DResults$d3_Q2A_pred > DResults$d3_Q2A_real)), 
            sum(1*(DResults$d3_Q2A_pred == DResults$d3_Q2A_real)), 
            sum(1*(DResults$d3_Q2A_pred < DResults$d3_Q2A_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2_Q2B <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2B_pred > DResults$d1_Q2B_real)), 
            sum(1*(DResults$d1_Q2B_pred == DResults$d1_Q2B_real)), 
            sum(1*(DResults$d1_Q2B_pred < DResults$d1_Q2B_real)), 
            sum(1*(DResults$d2_Q2B_pred > DResults$d2_Q2B_real)), 
            sum(1*(DResults$d2_Q2B_pred == DResults$d2_Q2B_real)), 
            sum(1*(DResults$d2_Q2B_pred < DResults$d2_Q2B_real)), 
            sum(1*(DResults$d3_Q2B_pred > DResults$d3_Q2B_real)), 
            sum(1*(DResults$d3_Q2B_pred == DResults$d3_Q2B_real)), 
            sum(1*(DResults$d3_Q2B_pred < DResults$d3_Q2B_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2_Q2C <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2C_pred > DResults$d1_Q2C_real)), 
            sum(1*(DResults$d1_Q2C_pred == DResults$d1_Q2C_real)), 
            sum(1*(DResults$d1_Q2C_pred < DResults$d1_Q2C_real)), 
            sum(1*(DResults$d2_Q2C_pred > DResults$d2_Q2C_real)), 
            sum(1*(DResults$d2_Q2C_pred == DResults$d2_Q2C_real)), 
            sum(1*(DResults$d2_Q2C_pred < DResults$d2_Q2C_real)), 
            sum(1*(DResults$d3_Q2C_pred > DResults$d3_Q2C_real)), 
            sum(1*(DResults$d3_Q2C_pred == DResults$d3_Q2C_real)), 
            sum(1*(DResults$d3_Q2C_pred < DResults$d3_Q2C_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2_Q2D <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2D_pred > DResults$d1_Q2D_real)), 
            sum(1*(DResults$d1_Q2D_pred == DResults$d1_Q2D_real)), 
            sum(1*(DResults$d1_Q2D_pred < DResults$d1_Q2D_real)), 
            sum(1*(DResults$d2_Q2D_pred > DResults$d2_Q2D_real)), 
            sum(1*(DResults$d2_Q2D_pred == DResults$d2_Q2D_real)), 
            sum(1*(DResults$d2_Q2D_pred < DResults$d2_Q2D_real)), 
            sum(1*(DResults$d3_Q2D_pred > DResults$d3_Q2D_real)), 
            sum(1*(DResults$d3_Q2D_pred == DResults$d3_Q2D_real)), 
            sum(1*(DResults$d3_Q2D_pred < DResults$d3_Q2D_real))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real", "Syn > Real", "Syn = Real", "Syn < Real"))

Q2A_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2A_pred == -1)), 
            sum(1*(DResults$d1_Q2A_pred == 0)), 
            sum(1*(DResults$d1_Q2A_pred == 1)), 
            sum(1*(DResults$d2_Q2A_pred == -1)), 
            sum(1*(DResults$d2_Q2A_pred == 0)), 
            sum(1*(DResults$d2_Q2A_pred == 1)), 
            sum(1*(DResults$d3_Q2A_pred == -1)), 
            sum(1*(DResults$d3_Q2A_pred == 0)), 
            sum(1*(DResults$d3_Q2A_pred == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2A_pred,"Q2A_syn.csv", row.names = TRUE)

Q2A_real <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2A_real == -1)), 
            sum(1*(DResults$d1_Q2A_real == 0)), 
            sum(1*(DResults$d1_Q2A_real == 1)), 
            sum(1*(DResults$d2_Q2A_real == -1)), 
            sum(1*(DResults$d2_Q2A_real == 0)), 
            sum(1*(DResults$d2_Q2A_real == 1)), 
            sum(1*(DResults$d3_Q2A_real == -1)), 
            sum(1*(DResults$d3_Q2A_real == 0)), 
            sum(1*(DResults$d3_Q2A_real == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2A_real,"Q2A_real.csv", row.names = TRUE)

Q2B_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2B_pred == -1)), 
            sum(1*(DResults$d1_Q2B_pred == 0)), 
            sum(1*(DResults$d1_Q2B_pred == 1)), 
            sum(1*(DResults$d2_Q2B_pred == -1)), 
            sum(1*(DResults$d2_Q2B_pred == 0)), 
            sum(1*(DResults$d2_Q2B_pred == 1)), 
            sum(1*(DResults$d3_Q2B_pred == -1)), 
            sum(1*(DResults$d3_Q2B_pred == 0)), 
            sum(1*(DResults$d3_Q2B_pred == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2B_pred,"Q2B_syn.csv", row.names = TRUE)

Q2B_real <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2B_real == -1)), 
            sum(1*(DResults$d1_Q2B_real == 0)), 
            sum(1*(DResults$d1_Q2B_real == 1)), 
            sum(1*(DResults$d2_Q2B_real == -1)), 
            sum(1*(DResults$d2_Q2B_real == 0)), 
            sum(1*(DResults$d2_Q2B_real == 1)), 
            sum(1*(DResults$d3_Q2B_real == -1)), 
            sum(1*(DResults$d3_Q2B_real == 0)), 
            sum(1*(DResults$d3_Q2B_real == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2B_real,"Q2B_real.csv", row.names = TRUE)

Q2C_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2C_pred == -1)), 
            sum(1*(DResults$d1_Q2C_pred == 0)), 
            sum(1*(DResults$d1_Q2C_pred == 1)), 
            sum(1*(DResults$d2_Q2C_pred == -1)), 
            sum(1*(DResults$d2_Q2C_pred == 0)), 
            sum(1*(DResults$d2_Q2C_pred == 1)), 
            sum(1*(DResults$d3_Q2C_pred == -1)), 
            sum(1*(DResults$d3_Q2C_pred == 0)), 
            sum(1*(DResults$d3_Q2C_pred == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2C_pred,"Q2C_syn.csv", row.names = TRUE)

Q2C_real <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2C_real == -1)), 
            sum(1*(DResults$d1_Q2C_real == 0)), 
            sum(1*(DResults$d1_Q2C_real == 1)), 
            sum(1*(DResults$d2_Q2C_real == -1)), 
            sum(1*(DResults$d2_Q2C_real == 0)), 
            sum(1*(DResults$d2_Q2C_real == 1)), 
            sum(1*(DResults$d3_Q2C_real == -1)), 
            sum(1*(DResults$d3_Q2C_real == 0)), 
            sum(1*(DResults$d3_Q2C_real == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2C_real,"Q2C_real.csv", row.names = TRUE)

Q2D_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2D_pred == -1)), 
            sum(1*(DResults$d1_Q2D_pred == 0)), 
            sum(1*(DResults$d1_Q2D_pred == 1)), 
            sum(1*(DResults$d2_Q2D_pred == -1)), 
            sum(1*(DResults$d2_Q2D_pred == 0)), 
            sum(1*(DResults$d2_Q2D_pred == 1)), 
            sum(1*(DResults$d3_Q2D_pred == -1)), 
            sum(1*(DResults$d3_Q2D_pred == 0)), 
            sum(1*(DResults$d3_Q2D_pred == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2D_pred,"Q2D_syn.csv", row.names = TRUE)

Q2D_real <- data.frame(
  votes = c(sum(1*(DResults$d1_Q2D_real == -1)), 
            sum(1*(DResults$d1_Q2D_real == 0)), 
            sum(1*(DResults$d1_Q2D_real == 1)), 
            sum(1*(DResults$d2_Q2D_real == -1)), 
            sum(1*(DResults$d2_Q2D_real == 0)), 
            sum(1*(DResults$d2_Q2D_real == 1)), 
            sum(1*(DResults$d3_Q2D_real == -1)), 
            sum(1*(DResults$d3_Q2D_real == 0)), 
            sum(1*(DResults$d3_Q2D_real == 1))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("Unacceptable", "Indeterminant", "Acceptable", "Unacceptable", "Indeterminant", "Acceptable","Unacceptable", "Indeterminant", "Acceptable"))

write.csv(Q2D_real,"Q2D_real.csv", row.names = TRUE)

Q3_real <- data.frame(
  votes = c(sum(1*(DResults$d1_q3_real == 1)), 
            sum(1*(DResults$d1_q3_real == 2)), 
            sum(1*(DResults$d1_q3_real == 3)), 
            sum(1*(DResults$d1_q3_real == 4)), 
            sum(1*(DResults$d2_q3_real == 1)), 
            sum(1*(DResults$d2_q3_real == 2)), 
            sum(1*(DResults$d2_q3_real == 3)), 
            sum(1*(DResults$d2_q3_real == 4)), 
            sum(1*(DResults$d3_q3_real == 1)),
            sum(1*(DResults$d3_q3_real == 2)),
            sum(1*(DResults$d3_q3_real == 3)),
            sum(1*(DResults$d3_q3_real == 4))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("1", "2", "3", "4", "1", "2","3", "4", "1", "2", "3", "4"))


Q3_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_q3_pred == 1)), 
            sum(1*(DResults$d1_q3_pred == 2)), 
            sum(1*(DResults$d1_q3_pred == 3)), 
            sum(1*(DResults$d1_q3_pred == 4)), 
            sum(1*(DResults$d2_q3_pred == 1)), 
            sum(1*(DResults$d2_q3_pred == 2)), 
            sum(1*(DResults$d2_q3_pred == 3)), 
            sum(1*(DResults$d2_q3_pred == 4)), 
            sum(1*(DResults$d3_q3_pred == 1)),
            sum(1*(DResults$d3_q3_pred == 2)),
            sum(1*(DResults$d3_q3_pred == 3)),
            sum(1*(DResults$d3_q3_pred == 4))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("1", "2", "3", "4", "1", "2","3", "4", "1", "2", "3", "4"))

Q4_real <- data.frame(
  votes = c(sum(1*(DResults$d1_q4_real == 1)), 
            sum(1*(DResults$d1_q4_real == 2)), 
            sum(1*(DResults$d1_q4_real == 3)), 
            sum(1*(DResults$d1_q4_real == 4)), 
            sum(1*(DResults$d1_q4_real == 5)),
            sum(1*(DResults$d2_q4_real == 1)), 
            sum(1*(DResults$d2_q4_real == 2)), 
            sum(1*(DResults$d2_q4_real == 3)), 
            sum(1*(DResults$d2_q4_real == 4)), 
            sum(1*(DResults$d2_q4_real == 5)),
            sum(1*(DResults$d3_q4_real == 1)),
            sum(1*(DResults$d3_q4_real == 2)),
            sum(1*(DResults$d3_q4_real == 3)),
            sum(1*(DResults$d3_q4_real == 4)),
            sum(1*(DResults$d3_q4_real == 5))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("1", "2", "3", "4", "5", "1", "2","3", "4", "5", "1", "2", "3", "4", "5"))

Q4_pred <- data.frame(
  votes = c(sum(1*(DResults$d1_q4_pred == 1)), 
            sum(1*(DResults$d1_q4_pred == 2)), 
            sum(1*(DResults$d1_q4_pred == 3)), 
            sum(1*(DResults$d1_q4_pred == 4)), 
            sum(1*(DResults$d1_q4_pred == 5)),
            sum(1*(DResults$d2_q4_pred == 1)), 
            sum(1*(DResults$d2_q4_pred == 2)), 
            sum(1*(DResults$d2_q4_pred == 3)), 
            sum(1*(DResults$d2_q4_pred == 4)), 
            sum(1*(DResults$d2_q4_pred == 5)),
            sum(1*(DResults$d3_q4_pred == 1)),
            sum(1*(DResults$d3_q4_pred == 2)),
            sum(1*(DResults$d3_q4_pred == 3)),
            sum(1*(DResults$d3_q4_pred == 4)),
            sum(1*(DResults$d3_q4_pred == 5))),
  voter = c("Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 1", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 2", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3", "Doctor 3"),
  voted = c("1", "2", "3", "4", "5", "1", "2","3", "4", "5", "1", "2", "3", "4", "5"))

############################ Sign Test ##################################
############################# General ###################################
# Rater 1 
binom.test(x = Q2_gen$votes[1], n = Q2_gen$votes[1]+Q2_gen$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_gen$votes[3], n = Q2_gen$votes[1]+Q2_gen$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_gen$votes[4], n = Q2_gen$votes[4]+Q2_gen$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_gen$votes[6], n = Q2_gen$votes[4]+Q2_gen$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_gen$votes[7], n = Q2_gen$votes[7]+Q2_gen$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_gen$votes[9], n = Q2_gen$votes[7]+Q2_gen$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# Low ###################################
# Rater 1 
binom.test(x = Q2_low$votes[1], n = Q2_low$votes[1]+Q2_low$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_low$votes[3], n = Q2_low$votes[1]+Q2_low$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_low$votes[4], n = Q2_low$votes[4]+Q2_low$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_low$votes[6], n = Q2_low$votes[4]+Q2_low$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_low$votes[7], n = Q2_low$votes[7]+Q2_low$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_low$votes[9], n = Q2_low$votes[7]+Q2_low$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# High ###################################
# Rater 1 
binom.test(x = Q2_high$votes[1], n = Q2_high$votes[1]+Q2_high$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_high$votes[3], n = Q2_high$votes[1]+Q2_high$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_high$votes[4], n = Q2_high$votes[4]+Q2_high$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_high$votes[6], n = Q2_high$votes[4]+Q2_high$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_high$votes[7], n = Q2_high$votes[7]+Q2_high$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_high$votes[9], n = Q2_high$votes[7]+Q2_high$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# 2A ###################################
# Rater 1 
binom.test(x = Q2_Q2A$votes[1], n = Q2_Q2A$votes[1]+Q2_Q2A$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2A$votes[3], n = Q2_Q2A$votes[1]+Q2_Q2A$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_Q2A$votes[4], n = Q2_Q2A$votes[4]+Q2_Q2A$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2A$votes[6], n = Q2_Q2A$votes[4]+Q2_Q2A$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_Q2A$votes[7], n = Q2_Q2A$votes[7]+Q2_Q2A$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2A$votes[9], n = Q2_Q2A$votes[7]+Q2_Q2A$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# 2B ###################################
# Rater 1 
binom.test(x = Q2_Q2B$votes[1], n = Q2_Q2B$votes[1]+Q2_Q2B$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2B$votes[3], n = Q2_Q2B$votes[1]+Q2_Q2B$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_Q2B$votes[4], n = Q2_Q2B$votes[4]+Q2_Q2B$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2B$votes[6], n = Q2_Q2B$votes[4]+Q2_Q2B$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_Q2B$votes[7], n = Q2_Q2B$votes[7]+Q2_Q2B$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2B$votes[9], n = Q2_Q2B$votes[7]+Q2_Q2B$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# 2C ###################################
# Rater 1 
binom.test(x = Q2_Q2C$votes[1], n = Q2_Q2C$votes[1]+Q2_Q2C$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2C$votes[3], n = Q2_Q2C$votes[1]+Q2_Q2C$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_Q2C$votes[4], n = Q2_Q2C$votes[4]+Q2_Q2C$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2C$votes[6], n = Q2_Q2C$votes[4]+Q2_Q2C$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_Q2C$votes[7], n = Q2_Q2C$votes[7]+Q2_Q2C$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2C$votes[9], n = Q2_Q2C$votes[7]+Q2_Q2C$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################# 2D ###################################
# Rater 1 
binom.test(x = Q2_Q2D$votes[1], n = Q2_Q2D$votes[1]+Q2_Q2D$votes[3], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2D$votes[3], n = Q2_Q2D$votes[1]+Q2_Q2D$votes[3], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 2 
binom.test(x = Q2_Q2D$votes[4], n = Q2_Q2D$votes[4]+Q2_Q2D$votes[6], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2D$votes[6], n = Q2_Q2D$votes[4]+Q2_Q2D$votes[6], p = 0.5, alternative = "greater") # Test for Syn < Real

# Rater 3 
binom.test(x = Q2_Q2D$votes[7], n = Q2_Q2D$votes[7]+Q2_Q2D$votes[9], p = 0.5, alternative = "greater") # Test for Syn > Real
binom.test(x = Q2_Q2D$votes[9], n = Q2_Q2D$votes[7]+Q2_Q2D$votes[9], p = 0.5, alternative = "greater") # Test for Syn < Real

############################################# Plotting ########################

# creating plot using the above data
ggplot(Q1_gen, aes(imageType, votes, fill = voted)) +
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Test for Realisiticness", subtitle = "Responses by Image Type for all doctors", x = "Image Type", y = "Number of Responses", fill = "Voted") + 
  theme_classic()+
  scale_fill_manual(values = c('#00BFC4',"#F8766D"))

# creating plot using the above data
ggplot(Q1_d1, aes(imageType, votes, fill = voted)) +
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,20)) +
  labs(title="Test for Realisiticness", subtitle = "Responses by Image Type for Doctor 1", x = "Image Type", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c('#00BFC4',"#F8766D"))

# creating plot using the above data
ggplot(Q1_d2, aes(imageType, votes, fill = voted)) +
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,20)) +
  labs(title="Test for Realisiticness", subtitle = "Responses by Image Type for Doctor 2", x = "Image Type", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c('#00BFC4',"#F8766D"))

# creating plot using the above data
ggplot(Q1_d3, aes(imageType, votes, fill = voted)) +
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,20)) +
  labs(title="Test for Realisiticness", subtitle = "Responses by Image Type for Doctor 3", x = "Image Type", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c('#00BFC4',"#F8766D"))

windows(width = 12, height = 10)
ggplot(Q2_gen, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2 General Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2A-2D by Rater", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_low, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2 Low Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2A-2D by Rater for Low Infarct Core : Tissue at Risk Ratio", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_high, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2 High Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2A-2D by Rater for High Infarct Core : Tissue at Risk Ratio", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_Q2A, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2A Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2A by Rater", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_Q2B, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2B Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2B by Rater", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_Q2C, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2C Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2C by Rater", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "blue", "green"))

windows(width = 12, height = 10)
ggplot(Q2_Q2D, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  labs(title="Question 2D Results",subtitle = "Comparison of Corresponding Real and Synthetic CTP for Questions 2D by Rater", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c("red", "purple", "green"))

ggplot(Q2A_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Synthetic CBF Results", subtitle = "Responses for Acceptability for Synthetic CBF by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2A_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Real CBF Results",subtitle = "Responses for Acceptability for Real CBF by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2B_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Synthetic CBV Results", subtitle = "Responses for Acceptability for Synthetic CBV by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2B_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Real CBV Results",subtitle = "Responses for Acceptability for Real CBV by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2C_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Synthetic MTT Results", subtitle = "Responses for Acceptability for Synthetic MTT by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2C_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Real MTT Results",subtitle = "Responses for Acceptability for Real MTT by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2D_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Synthetic Tmax Results", subtitle = "Responses for Acceptability for Synthetic CBF by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q2D_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim=c(0,20))+
  labs(title="Real Tmax Results", subtitle = "Responses for Acceptability for Synthetic CBF by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q3_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge", ylim = c(0,10)) +
  coord_cartesian(ylim = c(0,15)) +
  labs(title="Question 3 Real CTP Results",subtitle = "Comparison of Number of Responses on Questions 3 for Real CTP by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q3_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,15)) +
  labs(title="Question 3 Synthetic CTP Results",subtitle = "Comparison of Number of Responses on Questions 3 for Synthetic CTP by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  theme_classic() +
  scale_fill_manual(values = c("#7CAE00",'#00BFC4',"#F8766D"))

ggplot(Q4_real, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,15)) +
  labs(title="Question 4 Real CTP Results",subtitle = "Comparison of Number of Responses on Questions 4 for Real CTP by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c(1, 2, 3, 4, 5))

ggplot(Q4_pred, aes(voter, votes, fill = voted))+
  geom_bar(stat="identity", position = "dodge") +
  coord_cartesian(ylim = c(0,15)) +
  labs(title="Question 4 Synthetic CTP Results",subtitle = "Comparison of Number of Responses on Questions 3 for Synthetic CTP by Doctor", x = "Rater", y = "Number of Responses", fill = "Voted") +
  scale_fill_manual(values = c(1, 2, 3, 4, 5))


### Question 2
Q2 <- data.frame(
  type = factor(c(rep("Real CTP", 4*length(GResults$Q2A_real)), rep("Synthetic CTP", 4*length(GResults$Q2A_predicted)))),
  ratings = c(GResults$Q2A_real, GResults$Q2B_real, GResults$Q2C_real, GResults$Q2D_real, GResults$Q2A_predicted, GResults$Q2B_predicted, GResults$Q2C_predicted, GResults$Q2D_predicted)
)
mu <- ddply(Q2, "type", summarise, grp.mean=mean(ratings))
ggplot(Q2, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position = "dodge", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 2 All", x = "Rating", y = "Number of Responses") 

### Question 2A
Q2A <- data.frame(
  type = factor(c(rep("Real CTP", length(GResults$Q2A_real)), rep("Synthetic CTP", length(GResults$Q2A_predicted)))),
  ratings = c(GResults$Q2A_real, GResults$Q2A_predicted))
mu <- ddply(Q2A, "type", summarise, grp.mean=mean(ratings))

ggplot(Q2A, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 2A", subtitle = "Shows number of responses each rating received, dashed lines are the mean value", x = "Rating", y = "Number of Responses") 


### Question 2B
Q2B <- data.frame(
  type = factor(c(rep("Real CTP", length(GResults$Q2B_real)), rep("Synthetic CTP", length(GResults$Q2B_predicted)))),
  ratings = c(GResults$Q2B_real, GResults$Q2B_predicted))
mu <- ddply(Q2B, "type", summarise, grp.mean=mean(ratings))

ggplot(Q2B, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 2B", subtitle = "Shows number of responses each rating received, dashed lines are the mean value",x = "Rating", y = "Number of Responses") 
### Question 2C
Q2C <- data.frame(
  type = factor(c(rep("Real CTP", length(GResults$Q2C_real)), rep("Synthetic CTP", length(GResults$Q2C_predicted)))),
  ratings = c(GResults$Q2C_real, GResults$Q2C_predicted))
mu <- ddply(Q2C, "type", summarise, grp.mean=mean(ratings))

ggplot(Q2C, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 2C", subtitle = "Shows number of responses each rating received, dashed lines are the mean value",x = "Rating", y = "Number of Responses") 

### Question 2D 
Q2D <- data.frame(
  type = factor(c(rep("Real CTP", length(GResults$Q2D_real)), rep("Synthetic CTP", length(GResults$Q2D_predicted)))),
  ratings = c(GResults$Q2D_real, GResults$Q2D_predicted))
mu <- ddply(Q2D, "type", summarise, grp.mean=mean(ratings))

ggplot(Q2D, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 2D", subtitle = "Shows number of responses each rating received, dashed lines are the mean value",x = "Rating", y = "Number of Responses") 

### Question 3 (Confusion Matrix probably better for this question)
Q3 <- data.frame(
  type = factor(c(rep("Real CTP", length(GResults$Q3_real)), rep("Synthetic CTP", length(GResults$Q3_predicted)))),
  ratings = c(GResults$Q3_real, GResults$Q3_predicted))
mu <- ddply(Q3, "type", summarise, grp.mean=mean(ratings))

ggplot(Q3, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 3",subtitle = "Shows number of responses each rating received, dashed lines are the mean value", x = "Rating", y = "Number of Responses") 

### Question 4
Q4 <- data.frame(
  type = factor(c(rep("Real CTP",length(GResults$Q4_real)), rep("Synthetic CTP", length(GResults$Q4_predicted)))),
  ratings = c(GResults$Q4_real, GResults$Q4_predicted))
mu <- ddply(Q4, "type", summarise, grp.mean=mean(ratings))

ggplot(Q4, aes(x=ratings, color = type, fill = type)) +
  geom_histogram(binwidth = 1, position="identity", alpha = 0.75) +
  geom_vline(data=mu, aes(xintercept=grp.mean, color=type), linetype="dashed")+
  scale_fill_manual(values = c("red", "blue")) +
  scale_color_manual(values = c("red", "blue")) +
  labs(title="Question 4",subtitle = "Shows number of responses each rating received, dashed lines are the mean value", x = "Rating", y = "Number of Responses") 


##################### Mean and Standard Deviation Graphs #######################
#################################### 1 #########################################
num_patients = length(DResults$d1_q1_real)

data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_q1_real-0)/(1-0))*(1-0) + 0, ((DResults$d1_q1_pred - 0)/(1-0))*(1-0) + 0),
  R2 = c(((DResults$d2_q1_real-0)/(1-0))*(1-0) + 0, ((DResults$d2_q1_pred - 0)/(1-0))*(1-0) + 0),
  R3 = c(((DResults$d3_q1_real-0)/(1-0))*(1-0) + 0, ((DResults$d3_q1_pred - 0)/(1-0))*(1-0) + 0)
)

q1mean <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(q1mean) <- q1mean[,1]
q1mean <- as.matrix(q1mean[,-1])

#Plot boundaries
lim <- 1.5*max(q1mean)

#A function to add arrows on the chart
error.bar <- function(x, y, upper, lower=upper, length = 0.3){
  arrows(x,y+upper, x, y-lower, angle=90, code=3, length = length)
}

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(q1mean , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 1 Mean and Standard Deviation Chart")
error.bar(ze_barplot, q1mean, stdev)
dev.copy(png,"fig/eval 3/Q1_ms_R.png")
dev.off()

################################# Q2A ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_Q2A_real+1)/(1+1))*(1-0) + 0, ((DResults$d1_Q2A_pred + 1)/(1+1))*(1-0) + 0),
  R2 = c(((DResults$d2_Q2A_real+1)/(1+1))*(1-0) + 0, ((DResults$d2_Q2A_pred + 1)/(1+1))*(1-0) + 0),
  R3 = c(((DResults$d3_Q2A_real+1)/(1+1))*(1-0) + 0, ((DResults$d3_Q2A_pred + 1)/(1+1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1.5*max(means)

#A function to add arrows on the chart
error.bar <- function(x, y, upper, lower=upper, length = 0.1){
  arrows(x,y+upper, x, y-lower, angle=90, code=3, length = length)
}

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(means , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 2A Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q2A_ms_R.png")
dev.off()

################################# Q2B ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_Q2B_real+1)/(1+1))*(1-0) + 0, ((DResults$d1_Q2B_pred + 1)/(1+1))*(1-0) + 0),
  R2 = c(((DResults$d2_Q2B_real+1)/(1+1))*(1-0) + 0, ((DResults$d2_Q2B_pred + 1)/(1+1))*(1-0) + 0),
  R3 = c(((DResults$d3_Q2B_real+1)/(1+1))*(1-0) + 0, ((DResults$d3_Q2B_pred + 1)/(1+1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1.5*max(means)

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(means , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 2B Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q2B_ms_R.png")
dev.off()

################################# Q2C ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_Q2C_real+1)/(1+1))*(1-0) + 0, ((DResults$d1_Q2C_pred + 1)/(1+1))*(1-0) + 0),
  R2 = c(((DResults$d2_Q2C_real+1)/(1+1))*(1-0) + 0, ((DResults$d2_Q2C_pred + 1)/(1+1))*(1-0) + 0),
  R3 = c(((DResults$d3_Q2C_real+1)/(1+1))*(1-0) + 0, ((DResults$d3_Q2C_pred + 1)/(1+1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1.5*max(means)

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(means , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 2C Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q2C_ms_R.png")
dev.off()

################################# Q2D ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_Q2D_real+1)/(1+1))*(1-0) + 0, ((DResults$d1_Q2D_pred + 1)/(1+1))*(1-0) + 0),
  R2 = c(((DResults$d2_Q2D_real+1)/(1+1))*(1-0) + 0, ((DResults$d2_Q2D_pred + 1)/(1+1))*(1-0) + 0),
  R3 = c(((DResults$d3_Q2D_real+1)/(1+1))*(1-0) + 0, ((DResults$d3_Q2D_pred + 1)/(1+1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1.5*max(means)

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(means , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 2D Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q2D_ms_R.png")
dev.off()

################################### 3  ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_q3_real-1)/(4-1))*(1-0) + 0, ((DResults$d1_q3_pred - 1)/(4-1))*(1-0) + 0),
  R2 = c(((DResults$d2_q3_real-1)/(4-1))*(1-0) + 0, ((DResults$d2_q3_pred - 1)/(4-1))*(1-0) + 0),
  R3 = c(((DResults$d3_q3_real-1)/(4-1))*(1-0) + 0, ((DResults$d3_q3_pred - 1)/(4-1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 10, height = 8)
ze_barplot <- barplot(means , beside=T , legend.text=T,col=c("blue" , "orange") , ylim=c(0,lim) , ylab="Responses", xlab = "Raters", main = "Question 3 Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q3_ms_R.png")
dev.off()

################################### 4  ########################################
data <- data.frame(
  cat=c(rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients), rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients) , rep("Real CTP" , num_patients) , rep("Synthetic CTP" , num_patients)),
  R1 = c(((DResults$d1_q4_real-1)/(5-1))*(1-0) + 0, ((DResults$d1_q4_pred - 1)/(5-1))*(1-0) + 0),
  R2 = c(((DResults$d2_q4_real-1)/(5-1))*(1-0) + 0, ((DResults$d2_q4_pred - 1)/(5-1))*(1-0) + 0),
  R3 = c(((DResults$d3_q4_real-1)/(5-1))*(1-0) + 0, ((DResults$d3_q4_pred - 1)/(5-1))*(1-0) + 0)
)

means <- aggregate(cbind(R1, R2, R3) ~ cat , data=data , mean)
rownames(means) <- means[,1]
means <- as.matrix(means[,-1])

#Plot boundaries
lim <- 1.5*max(means)

#Then I calculate the standard deviation for each specie and condition :
stdev <- aggregate(cbind(R1,R2,R3)~cat , data=data , sd)
rownames(stdev) <- stdev[,1]
stdev <- as.matrix(stdev[,-1])

#I am ready to add the error bar on the plot using my "error bar" function !
windows(width = 12, height = 10)
ze_barplot <- barplot(means , beside=T , legend.text=T, col=c("blue" , "orange"), 
                      ylim=c(0,lim) , ylab="Responses", xlab = "Raters", 
                      main = "Question 4 Mean and Standard Deviation Chart")
error.bar(ze_barplot, means, stdev)
dev.copy(png,"fig/eval 3/Q4_ms_R.png")
dev.off()

################################ Confusion Matrix #############################
cmatrix = matrix(rep(0,16), nrow = 4, ncol = 4)
for (i in 1:60){
  cmatrix[GResults$Q3_real[i], GResults$Q3_predicted[i]] = cmatrix[GResults$Q3_real[i], GResults$Q3_predicted[i]] + 1;
}
cmatrix
###############################################################################


for (i in 1:20){
  
  patient_i_real = cbind(c(DResults$d1_q1_real[i], DResults$d2_q1_real[i], DResults$d3_q1_real[i]),
                    c(DResults$d1_Q2A_real[i], DResults$d2_Q2A_real[i], DResults$d3_Q2A_real[i]),
                    c(DResults$d1_Q2B_real[i], DResults$d2_Q2B_real[i], DResults$d3_Q2B_real[i]),
                    c(DResults$d1_Q2C_real[i], DResults$d2_Q2C_real[i], DResults$d3_Q2C_real[i]),
                    c(DResults$d1_Q2D_real[i], DResults$d2_Q2D_real[i], DResults$d3_Q2D_real[i]),
                    c(DResults$d1_q3_real[i], DResults$d2_q3_real[i], DResults$d3_q3_real[i]),
                    c(DResults$d1_q4_real[i], DResults$d2_q4_real[i], DResults$d3_q4_real[i])); 
  t(patient_i_real)
  
  patient_i_syn = cbind(c(DResults$d1_q1_pred[i], DResults$d2_q1_pred[i], DResults$d3_q1_pred[i]),
                        c(DResults$d1_Q2A_pred[i], DResults$d2_Q2A_pred[i], DResults$d3_Q2A_pred[i]),
                        c(DResults$d1_Q2B_pred[i], DResults$d2_Q2B_pred[i], DResults$d3_Q2B_pred[i]),
                        c(DResults$d1_Q2C_pred[i], DResults$d2_Q2C_pred[i], DResults$d3_Q2C_pred[i]),
                        c(DResults$d1_Q2D_pred[i], DResults$d2_Q2D_pred[i], DResults$d3_Q2D_pred[i]),
                        c(DResults$d1_q3_pred[i], DResults$d2_q3_pred[i], DResults$d3_q3_pred[i]),
                        c(DResults$d1_q4_pred[i], DResults$d2_q4_pred[i], DResults$d3_q4_pred[i])); 
  t(patient_i_syn)
}


###############################################################################
liberal_estimates = c(0.3125,0.1445,0.073,0.03841)
plot(x=c(3,6,9,12), y =liberal_estimates, type = "l", xlab = "Number of Positive Cases", ylab = "p-value", main = "p-value as a function of Positive cases for the ratio of negative to positive being 1:3")
points(x=1:12, y = rep(0.05,12), col = "red", type = "l")

conservative_estimates = c(0.5, 0.3437, 0.2539, 0.1938, 0.1509, 0.1189, 0.09462, 0.07579, 0.06104, 0.04937)
plot(x=seq(2,20, 2), y = conservative_estimates, type = "l", xlab = "Number of Positive Cases", ylab = "p-value", main = "p-value as a function of positive cases for the ratio of negative to positive being 1:2")
points(x=1:20, y = rep(0.05,20), col = "red", type = "l")

###############################################################################
##################################### Question 2 diff proportions #############
s1 = sum(c(GResults$Q2A_real == 1, GResults$Q2B_real == 1, GResults$Q2C_real == 1, GResults$Q2D_real == 1))
s2 = sum(c(GResults$Q2A_predicted == 1, GResults$Q2B_predicted == 1, GResults$Q2C_predicted == 1, GResults$Q2D_predicted == 1))
p1 = sum(c(GResults$Q2A_real == -1, GResults$Q2B_real == -1, GResults$Q2C_real == -1, GResults$Q2D_real == -1))/240
p2 = sum(c(GResults$Q2A_predicted == -1, GResults$Q2B_predicted == -1, GResults$Q2C_predicted == -1, GResults$Q2D_predicted == -1))/240

p1 =sum(GResults$Q2D_real == -1)/60
p2 = sum(GResults$Q2D_predicted == -1)/60

prop.test(x = c(s1,s2), c(240,240), conf.level = 0.95)


SE = sqrt((p1*(1-p1)+p2*(1-p2))/240)

confidence_interval = c((p1-p2) - 1.96*SE, (p1-p2) + 1.96*SE)
confidence_interval

##################################### Acceptable ###############################
m1r = sum(c(GResults$Q2A_real == 1))
m1s = sum(c(GResults$Q2A_predicted == 1))

prop.test(x = c(m1r, m1s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m2r = sum(c(GResults$Q2B_real == 1))
m2s = sum(c(GResults$Q2B_predicted == 1))

prop.test(x = c(m2r, m2s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m3r = sum(c(GResults$Q2C_real == 1))
m3s = sum(c(GResults$Q2C_predicted == 1))

prop.test(x = c(m3r, m3s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m4r = sum(c(GResults$Q2D_real == 1))
m4s = sum(c(GResults$Q2D_predicted == 1))

prop.test(x = c(m4r, m4s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

################################### Unacceptable prop #########################
m1r = sum(c(GResults$Q2A_real == -1))
m1s = sum(c(GResults$Q2A_predicted == -1))

prop.test(x = c(m1r, m1s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m2r = sum(c(GResults$Q2B_real == -1))
m2s = sum(c(GResults$Q2B_predicted == -1))

prop.test(x = c(m2r, m2s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m3r = sum(c(GResults$Q2C_real == -1))
m3s = sum(c(GResults$Q2C_predicted == -1))

prop.test(x = c(m3r, m3s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

m4r = sum(c(GResults$Q2D_real == -1))
m4s = sum(c(GResults$Q2D_predicted == -1))

prop.test(x = c(m4r, m4s), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

########################### Question 1 diff proportions #######################
p1 = sum(GResults$Q1_real == 1)
p2 = sum(GResults$Q1_predicted == 1)

prop.test(x = c(p1,p2), c(60,60), conf.level = 0.95, alternative = c("two.sided"))

q1d1r = sum(DResults$d1_q1_real == 1)
q1d1s = sum(DResults$d1_q1_pred == 1)

q1d2r = sum(DResults$d2_q1_real == 1)
q1d2s = sum(DResults$d2_q1_pred == 1)

q1d3r = sum(DResults$d3_q1_real == 1)
q1d3s = sum(DResults$d3_q1_pred == 1)

prop.test(x = c(q1d1r,q1d1s), c(20,20), conf.level = 0.95, alternative = c("two.sided"))
prop.test(x = c(q1d2r,q1d2s), c(20,20), conf.level = 0.95, alternative = c("two.sided"))
prop.test(x = c(q1d3r,q1d3s), c(20,20), conf.level = 0.95, alternative = c("two.sided"))
