""" Library to import """

import os # For finding source files
from pathlib import Path

import pandas as pd # For data handling
import string # For handling of textual data

import matplotlib.pyplot as plt # For data visualization
import seaborn as sns # For statistical and data visualization


""" Uploading the source file: PledgeList.xlsx """

DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path's parent
PledgeFilePath = str(DirPpath.absolute()) + "\semic_pledges\PledgeList.xlsx"  

print("Current Location of the Source file is :", PledgeFilePath)

PledgeSheet = "Pledge List 25 October 2022" # Define the excel sheet where the pledges are to be found
PledgeDf = pd.read_excel(PledgeFilePath, sheet_name = PledgeSheet) # Creating a dataframe from the content of the excel file

# Inspecting the first rows of the dataframe
print(PledgeDf.head())


""" Data Cleansing """

PledgeDf = PledgeDf.fillna("") # Dealing with the potential presence of nan in the data

ToDrop =  ["Organisation name", "Country", "Type"] # The 3 last Variables are not used for the purpose of this project
PledgeDf.drop(ToDrop, inplace = True, axis = 1) # Using the .drop function to get rid of unnecessary columns (as listed in ToDrop) # Args: inplace = True to apply the changes directly into the dataframe ; axis = 1 to drop the values in the columns of df

print("\n")
print(PledgeDf.head()) #Inspecting the first rows of the modified df

if not all(PledgeDf['Pledge'].map(type) == str):  # Controlling the presence of Data types errors in the two remaining columbs
    print("\nData type issue in Pledges")
elif not all(PledgeDf['Topic'].map(type) == int):
    print("\nData Type issue in Topic")
else:
    print("\nNo apparent Data Type issues")


""" Exporting Cleaned Data """

CSVFilePath = str(DirPpath.absolute()) + "\semic_pledges\CleanedData.csv" 
PledgeDf.to_csv(CSVFilePath)