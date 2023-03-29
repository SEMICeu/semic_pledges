""" Library to import """

import os # For finding source files
from pathlib import Path

import pandas as pd # For data handling
import string # For handling of textual data

import matplotlib.pyplot as plt # For data visualization
import seaborn as sns # For statistical and data visualization


""" Uploading the cleaned file: CleanedData.csv """

DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path's parent
CSVFilePath = str(DirPpath.absolute()) + "\semic_pledges\CleanedData.csv"  

print("Current Location of the Data file is :", CSVFilePath)

PledgeDf = pd.read_csv(CSVFilePath, index_col=0) # Creating a dataframe from the content of the csv file # Args: index_col = 0, first column of the csv contains the indexes

# Inspecting the first rows of the dataframe
print(PledgeDf.head())


""" Plotting some insights about the different topics and pledges """

hist = PledgeDf["Topic"].plot(kind = 'hist', title = 'Count of Pledges per Topic', bins = 28, rwidth = 0.8) # Histogram of the number of pledge per topic
hist.plot()
plt.show()

# Defining a new column containing the number of words per pledge
LengthList = [] # List that will contain the number of words of each pledge
for pledge in PledgeDf["Pledge"]: # Looping over the different pledges from the dataframe
    LengthList.append(len(pledge.split())) # Appending the number of words to the pledge
PledgeDf["Length"] = LengthList

plt.boxplot(PledgeDf["Length"]) # Plotting the dispersion of words across the different pledges (looking for outliers)
plt.show()
sns.boxplot(x = PledgeDf["Topic"], y = PledgeDf["Length"]) # Boxplots of length by topic
plt.show()

