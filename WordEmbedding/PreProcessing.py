""" Importing Relevant Libraries """

import os # For finding the location of Cleaned Data file
from pathlib import Path

import pandas as pd # For data handling

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
PledgesCsvPath = str(DirPpath.absolute()) + "\semic_pledges\DataExploration\CleanedData.csv" 

print("The current location of CleanedData.csv is: ", PledgesCsvPath)

PledgesDf = pd.read_csv(PledgesCsvPath, index_col=0) # Reading the csv file using a DataFrame


""" Defining common pre-processing functions """

def first_clean(text): #Input - String or text you want to process
    return " ".join(text.split()).replace("_x000D_","") #Output - Same string without \n and _x000D_

def preprocess(text): #Input - String or text you want to process
    text = text.lower() # Lowercase all the characters from the string
    text = text.strip() # Remove the leading and trailing whitespaces
    text = re.compile('<.*?>').sub('', text)
    text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text) # Removing Punctuation
    text = re.sub(r'\[[0-9]*\]', ' ', text)
    text = re.sub(r'[^\w\s]', '', str(text)) # Remove non alphanumeric characters
    text = re.sub(r'\d', '', text) # Removing digits
    text = re.sub(r'\s+', ' ', str(text).strip()) # Replacing "double, triple, etc" whitespaces by one
    return text #Output - Same string after all the transformations

def stopword(string): #Input - String or text to process
    a = [i for i in string.split() if i not in stopwords.words('english')] # Removing usual english stopwords from the string
    return ' '.join(a) #Output - Same string after all the transformations

# LEMMATIZATION
# Initialize the lemmatizer
wl = WordNetLemmatizer()
# This is a helper function to map NTLK position tags
def get_wordnet_pos(tag):
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
def lemmatizer(string):
    word_pos_tags = nltk.pos_tag(nltk.word_tokenize(string))  # Get position tags
    a = [wl.lemmatize(tag[0], get_wordnet_pos(tag[1])) for idx, tag in
         enumerate(word_pos_tags)]  # Map the position tag and lemmatize the word/token
    return " ".join(a)


def preprocessing(text): # Combining all pre-processing steps

    global n
    n = n +1
    
    print("**************")
    print("n is : ")
    print(n)
    print("length of the text is : ")
    print(len(first_clean(text)))
    return lemmatizer(stopword(preprocess(first_clean(text))))


""" Main function """
n=0
print("begin pre-processing")
PledgesDf['PreProcessedText'] = PledgesDf['Pledge'].apply(lambda x: preprocessing(x))
print("end pre-processing\n")

print(PledgesDf.head())

# Outputting the pre-processed files
PledgesDf.to_csv(str(DirPpath.absolute()) + "\PreProcessedData.csv")

#PledgeTokens = [nltk.word_tokenize(i) for i in PledgesDf["PreProcessedText"]]



