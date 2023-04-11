""" Importing Relevant Libraries """

import os # For finding the location of Cleaned Data file
from pathlib import Path

import pandas as pd # For data handling
import matplotlib.pyplot as plt # For plotting data
from wordcloud import WordCloud # For plotting wordclouds

import string # For handling textual data
import re # For preprocessing

import nltk # NLP libraries and packages for preprocessing
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
from nltk.corpus import wordnet

# nltk.download('stopwords')
# nltk.download('wordnet')
# nltk.download('punkt')
# nltk.download('averaged_perceptron_tagger')


""" Loading the cleaned data file: CleanedData.csv """

DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path
PledgesCsvPath = str(DirPpath.absolute()) + "\semic_pledges\CleanedData.csv" 

print("The current location of CleanedData.csv is: ", PledgesCsvPath)

PledgesDf = pd.read_csv(PledgesCsvPath, index_col=0) # Reading the csv file using a DataFrame


""" Defining common pre-processing functions """

def FirstClean(text): #Input - String or text you want to process
    return " ".join(text.split()).replace("_x000D_","") #Output - Same string without \n and _x000D_

def PreProcess(text): #Input - String or text you want to process
    text = text.lower() # Lowercase all the characters from the string
    text = text.strip() # Remove the leading and trailing whitespaces
    text = re.compile('<.*?>').sub('', text)
    text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text) # Removing Punctuation
    text = re.sub(r'\[[0-9]*\]', ' ', text)
    text = re.sub(r'[^\w\s]', '', str(text)) # Remove non alphanumeric characters
    text = re.sub(r'\d', '', text) # Removing digits
    text = re.sub(r'\s+', ' ', str(text).strip()) # Replacing "double, triple, etc" whitespaces by one
    return text #Output - Same string after all the transformations

def StopWord(string): #Input - String or text to process
    a = [i for i in string.split() if i not in stopwords.words('english')] # Removing usual english stopwords from the string
    return ' '.join(a) #Output - Same string after all the transformations

# LEMMATIZATION
# Initialize the lemmatizer
wl = WordNetLemmatizer()
# This is a helper function to map NTLK position tags
def GetWordnetPos(tag):
    if tag.startswith('J'):
        return wordnet.ADJ
    elif tag.startswith('V'):
        return wordnet.VERB
    elif tag.startswith('N'):
        return wordnet.NOUN
    elif tag.startswith('R'):
        return wordnet.ADV
    else:
        return wordnet.NOUN
# Tokenize the sentence
def Lemmatizer(string):
    WordPosTags = nltk.pos_tag(nltk.word_tokenize(string))  # Get position tags
    a = [wl.lemmatize(tag[0], GetWordnetPos(tag[1])) for idx, tag in
         enumerate(WordPosTags)]  # Map the position tag and lemmatize the word/token
    return " ".join(a)


def PreProcessing(text): # Combining all pre-processing steps

    global n
    n = n +1
    
    print("**************")
    print("n is : ")
    print(n)
    print("length of the text is : ")
    print(len(FirstClean(text)))
    return Lemmatizer(StopWord(PreProcess(FirstClean(text))))


""" Main function """
n=0
print("begin pre-processing")
PledgesDf['PreProcessedText'] = PledgesDf['Pledge'].apply(lambda x: PreProcessing(x))
print("end pre-processing\n")

print(PledgesDf.head())

""" Visualisation """

# Building a wordcloud for visualizing most frequent words
cloud=WordCloud(colormap="ocean_r",width=600,height=400, background_color="#e5e5e5").generate(PledgesDf['PreProcessedText'].str.cat(sep=' ')) # Setting color for the map, background + defining dimensions
fig=plt.figure(figsize=(13,18)) # Size of the figure
plt.axis("off") # Removing the axis
plt.imshow(cloud,interpolation='bilinear')
plt.show() 

# Most frequent words in the pledges after pre-processing
plt.style.use('ggplot')  # Setting up the style
plt.figure(figsize=(14,6)) # Setting up the size of the figure
freq=pd.Series(" ".join(PledgesDf['PreProcessedText']).split()).value_counts()[:30] # Defining the series to plot, i.e., the 30 most frequent words
freq.plot(kind="bar", color = "orangered") # Choosing the plot type (bar) and colore (orangered)
plt.title("30 most frequent words",size=20) # Title
plt.show()

""" Adding extra stopwords """

# No coherent results at the moment
# StopWords2 = pd.Series(" ".join(PledgesDf['PreProcessedText']).split()).value_counts()[:30].index.tolist()
# print(StopWords2)

# def RemoveFrequentWords(string, FrequentWords):
#     a = [i for i in string.split() if i not in FrequentWords] # Removing usual english stopwords from the string
#     return ' '.join(a) #Output - Same string after all the transformations

# PledgesDf['PreProcessedText'] = PledgesDf['PreProcessedText'].apply(lambda x: RemoveFrequentWords(x, StopWords2))

# print(PledgesDf.head())


""" Outputing the pre-process data """

PreProcessedDataPath = str(DirPpath.absolute()) + "\semic_pledges\PreProcessedData.csv"
PledgesDf.to_csv(PreProcessedDataPath)

#PledgeTokens = [nltk.word_tokenize(i) for i in PledgesDf["PreProcessedText"]]



