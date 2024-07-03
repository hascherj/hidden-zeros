## ---------------------------
##
## hiddenZeroColors.R
##
## Input: clean data
##
## Output: combined data for paper, main figure
##
## Author: Josh Hascher
##
## Date Created: 1/19/23
##
##
## ---------------------------
##
## Notes: This is for the df's we need for the analyses in the paper
## ---------------------------

# Clear the workspace
rm(list = ls())

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(viridis)
library(vroom)
library(lemon)
library(dplyr)
library(gdata)
library(ggplot2)
library(moments)

# Using double backslashes to escape spaces
setwd("/Users/hascherj/Documents/Steph Projects/HiddenZero/hidden-zeros")

n = 10

colorsViridis = viridis(n, alpha = 0.7, begin = .15, end = .85, option = "D")
image(
  1:n, 1, as.matrix(1:n),
  col = colorsViridis,
  xlab = "viridis n", ylab = "", xaxt = "n", yaxt = "n", bty = "n"
)


colorsTurbo = viridis(n, alpha = 0.7, begin = .07, end = .93, option = "H")
image(
  1:n, 1, as.matrix(1:n),
  col = colorsTurbo,
  xlab = "turbo n", ylab = "", xaxt = "n", yaxt = "n", bty = "n"
)

