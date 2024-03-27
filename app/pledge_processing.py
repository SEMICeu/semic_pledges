""" Importing the relevant libraries """
import pandas as pd
import numpy as np
from langdetect import detect # Language detection models
import string # For handling textual data
import re # For preprocessing

import nltk # NLP libraries and packages for preprocessing
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
from nltk.corpus import wordnet
import contractions # For dealing with contractions, e.g., I'm --> I am

# To use only once to download all the libraries from nltk
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('punkt')
nltk.download('averaged_perceptron_tagger')

import gensim # For building and fine-tuning Word2Vec model
#import gensim.downloader as api # Helpful for downloading pre-trained models
from gensim.models import KeyedVectors

from sklearn.cluster import KMeans # For applying K-Means clustering
from sklearn.manifold import TSNE # For applying a dimensionality reduction (t-SNE)

import logging
import os
import sys
import json
import boto3

MODEL_FILES_PATH = "/app/model/Word2Vec"

# Create and configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Create a formatter
formatter = logging.Formatter('%(asctime)s | %(levelname)s | %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

# Create a handler and set the formatter
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(stream_handler)


class Pledge:
    def __init__(self):
        self.s3_in_bucket = None
        self.s3_out_bucket = None
        self.sheet_name = "Pledges text"
        self.key = None

    def pledge_processing(self):
        logging.info("Start processing")

        self.s3_in_bucket = os.environ['BUCKET_NAME']
        self.key = os.environ['OBJECT_KEY']
        logging.info(f"Handling s3 bucket: {self.s3_in_bucket}, s3 key: {self.key}")

        # Get file from s3
        self.Df = pd.read_excel(f"s3://{self.s3_in_bucket}/{self.key}", sheet_name=self.sheet_name)

        self.cleaning()
        self.pre_processing()
        self.embedding()
        self.clustering()
        self.save_to_s3()

        logging.info("Finished processing")


    def get_model_files_path(self):
        return os.getenv('MODEL_FILES_PATH', MODEL_FILES_PATH)

    def check_model_files(self):
        directory_path = self.get_model_files_path()

        files = [file for file in os.listdir(directory_path) if os.path.isfile(os.path.join(directory_path, file))]
        logging.warning(f"Files found in directory: {directory_path}")
        logging.warning(files)

    def create_pledge_ID(self):
        # Drop duplicate rows
        self.Df = self.Df.drop_duplicates()
        # Get the unique values in the column.
        self.Df["PledgeID"] = self.Df.groupby(self.Df.columns.tolist(), sort=False).ngroup() + 1

    def cleaning(self):
        # Proper Name convention and add missing columns
        if set(["Pledge", "Organisation name", "Type", "Pledge status", "Topic", "Country"]) == set(self.Df.columns):  
            self.Df.rename({"Pledge": "PledgeText", "Organisation name": "OrganisationName", "Type": "OrganisationType", "Pledge status": "PledgeStatus", "Topic": "TopicAction"}, axis=1, inplace=True)
            self.create_pledge_ID() 
            if 'Area' not in self.Df.columns:
                self.Df["Area"] = "Not available"
        elif set(["Pledge text", "Organisation name", "Organisation type", "Pledge status (Published or not yet Published)", "Topic/Action", "Country"]) == set(self.Df.columns):  
            self.Df.rename({"Pledge text": "PledgeText", "Organisation name": "OrganisationName", "Organisation type": "OrganisationType", "Pledge status (Published or not yet Published)": "PledgeStatus", "Topic/Action": "TopicAction"}, axis=1, inplace=True)
            self.create_pledge_ID() 
            if 'Area' not in self.Df.columns:
                self.Df["Area"] = "Not available"
        else:
            logging.info("\nWrong columns names")
            sys.exit(2)
        
        self.Df = self.Df.dropna()  # Dealing with the potential presence of nan in the data
        self.Df["PledgeID"] = self.Df["PledgeID"].astype(int)  # Dealing with the potential presence of nan in the data

        if not all(self.Df['PledgeText'].map(
                type) == str):  # Controlling the presence of Data types errors in the two remaining columbs
            logging.info("\nData type issue in Pledges")
        elif not all(self.Df['TopicAction'].map(type) == int):
            logging.info("\nData Type issue in Topic")
        else:
            logging.info("\nNo apparent Data Type issues")

        """ Splitting by languages (Fr and En) """

        liste = []  # List to contain the rows of French pledges

        for i in self.Df.index:
            text = self.Df.iloc[i, 1]  # Looping over all Pledges row by row

            if detect(text) != "en":  # If the majority of the text is french
                logging.info(i)
                liste.append(i)  # Then add the row index to the list

        self.Df = self.Df[~self.Df.index.isin(liste)]

        return ("Cleaned")


    def pre_processing(self):
        PreProcessing = PreProcessor()
        self.Df['PreProcessedText'] = self.Df['PledgeText'].apply(lambda x: PreProcessing.PreProcessing(x))

        return ("Preprocessed")


    def embedding(self):
        self.tokens = [nltk.word_tokenize(i) for i in self.Df["PreProcessedText"]]
        # Removing extra stopwords (tourist, tourism) --> to furter develop
        self.Df['PreProcessedText'] = self.Df['PreProcessedText'].apply(lambda x: re.sub("tourism | tourist","", x))

        """ Word2Vec model """

        # w2v = api.load('word2vec-google-news-300') # Downloading a word2vec model pre-trained on Google News dataset, i.e., trained on more than 100 bn words
        w2v = KeyedVectors.load(os.path.join(self.get_model_files_path(),'model.model'))
        # Model contains a corpora of 3bn words represented by vectors of dimension 300

        """ Indexing Pledges with Mean Embedding """
        w2v = dict(zip(w2v.index_to_key, w2v.vectors))
        modelw = MeanEmbeddingVectorizer(w2v)

        # converting text to numerical data using Word2Vec
        self.W2v = pd.DataFrame(modelw.transform(self.tokens))

        return "Embedded"


    def clustering(self):
        self.W2v["TopicAction"] = self.Df["TopicAction"].values  # Adding a Topic column to the IndexedData dataframe
        Cluster = Clusterer()

        """ Finding optimal clusters """

        # Applying the function to our data for 6 clusters
        x = np.array(self.W2v.loc[:, self.W2v.columns != "TopicAction"])
        yKm = Cluster.OptiCluster(x, 6)

        """ Saving the results """

        self.Df["ContentGroups"] = yKm + 1  # Ensure that clusters are listed from 1 to 6
        self.Df["ContentGroups"] = self.Df["ContentGroups"].astype(np.int64)

        """ Dimensionality reduction for visuals """

        self.Df["Y1"], self.Df["Y2"] = Cluster.Tsne(self.W2v)

        return "Clustered"


    def save_to_s3(self):
        parquet_file=self.key.replace(".xlsx", ".parquet")

        self.s3_out_bucket = self.s3_in_bucket.replace("input", "output")

        s3_key_parquet = f"s3://{self.s3_out_bucket}/parquet/{parquet_file}"
        session_id = self.key.split('/')[0]

        self.Df.insert(0, 'SessionID', session_id)
        self.Df = self.Df.reindex(["SessionID", "PledgeID", "PledgeText", "PreProcessedText", "ContentGroups", "TopicAction", "Area", "Y1", "Y2", "OrganisationName", "Country", "OrganisationType", "PledgeStatus"], axis=1)

        self.Df.to_parquet(s3_key_parquet, engine='pyarrow', index=False)

        logging.info(f"Result pushed to s3 in parquet format: {s3_key_parquet}")

        # Save file also in CSV format for user download
        csv_file=self.key.replace(".xlsx", ".csv")

        s3_key_csv = f"s3://{self.s3_out_bucket}/csv/{csv_file}"

        self.Df.to_csv(s3_key_csv, index=False, sep=";")

        logging.info(f"Result pushed to s3 in CSV format: {s3_key_csv}")

class PreProcessor():
    def __init__(self):
        self = self
        self.wl = WordNetLemmatizer()

    # This is a helper function to map NTLK position tags

    """ Defining common pre-processing functions """

    def FirstClean(self, text):
        """
        FirstClean takes a Text as input and replace tabulations (\n and _x000D_) by whitespaces

        :param text: A piece of text under string format
        :return: Original string without \n and _x000D_
        """

        return " ".join(text.split()).replace("_x000D_", "")

    def ReplaceContractions(self, text):
        """
        ReplaceContractions replaces contractions in string of text, e.g., I'm --> I am

        :param text: A piece of text in string format
        :return: Original string with the contractions replaced by their full form
        """

        return contractions.fix(text)

    def PreProcess(self, text):
        """
        PreProcess applies a set of common preprocessing transformations on a text

        :param text: Piece of text in string format
        :return: Preprocessed string
        """

        text = re.sub(r"https:\s?\S+", "", text)
        text = re.sub(r"http\S+", "", text)  # Remove urls
        text = text.lower()  # Lowercase all the characters from the string
        text = text.strip()  # Remove the leading and trailing whitespaces
        text = re.compile('<.*?>').sub('', text)
        text = re.compile('[%s]' % re.escape(string.punctuation)).sub(' ', text)  # Removing Punctuation
        text = re.sub(r'\[[0-9]*\]', ' ', text)
        text = re.sub(r'[^\w\s]', '', str(text))  # Remove non alphanumeric characters
        text = re.sub(r'\d', '', text)  # Removing digits
        text = re.sub(r"\b[a-zA-Z]\b", "", text)  # Removing single characters
        text = re.sub(r'\s+', ' ', str(text).strip())  # Replacing "double, triple, etc" whitespaces by one
        return text  # Output - Same string after all the transformations

    def StopWord(self, string):
        """
        StopWord removes stopwords from a string using NLTK stopwords corpus

        :param string: A string
        :return: Original string without stopwords
        """

        a = [i for i in string.split() if
             i not in stopwords.words('english')]  # Removing usual english stopwords from the string
        return ' '.join(a)  # Output - Same string after all the transformations

    def GetWordnetPos(self, tag):
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

    def Lemmatizer(self, string):
        """
        Lemmatizer uses a WordNetLemmatizer to change all the words from a string to their root form (lemmatization)

        :param string: string to lemmatize
        :return: Lemmatized string
        """
        WordPosTags = nltk.pos_tag(nltk.word_tokenize(string))  # Get position tags
        a = [self.wl.lemmatize(tag[0], self.GetWordnetPos(tag[1])) for idx, tag in
             enumerate(WordPosTags)]  # Map the position tag and lemmatize the word/token
        return " ".join(a)

    def PreProcessing(self, text):
        """
        Preprocessing combines all the previous functions to preprocess a text

        :param text: Piece of text in a string format to be preprocessed
        :param n: integer to count the number of pledge
        :return: Preprocessed text
        """
        # n = 1

        # logging.info("**************")
        # logging.info("n is : ")
        # logging.info(n)
        # logging.info("length of the text is : ")
        # logging.info(len(self.FirstClean(text)))
        return self.Lemmatizer(self.StopWord(self.PreProcess(self.ReplaceContractions(self.FirstClean(text)))))


# building Word2Vec representation of each pledge using an averaging approach
class MeanEmbeddingVectorizer(object):
    def __init__(self, word2vec):
        self.word2vec = word2vec
        # if a text is empty we should return a vector of zeros
        # with the same dimensionality as all the other vectors
        self.dim = len(next(iter(word2vec.values())))

    def fit(self, X, y):
        return self

    def transform(self, X):
        return np.array([
            np.mean([self.word2vec[w] for w in words if w in self.word2vec]
                    or [np.zeros(self.dim)], axis=0)
            for words in X
        ])


class Clusterer():
    def __init__(self):
        self = self

    # Function to find optimal cluster: x = the data to cluster , c = the number of clusters to find
    def OptiCluster(self, x, c):
        """
        OptiCluster find the optimal clusters for a given c based on the inertia criterion

        :param x: The data to cluster (np array)
        :param c: Number of clusters to find (int)
        :return: Array containing the predicted clusters
        """

        # Initialisation of a first k-means algorithm
        try:
            kmeans = KMeans(n_clusters=c, random_state=0)
            kmeans.fit(x)

            inertia = kmeans.inertia_  # Quality criterion --> The lower the inertia the better the clusters
            logging.info(inertia)

            yKm = kmeans.fit_predict(x)  # Storing the predicted clusters in a temporary variable

            # Repeating the process 100 times to find an optimum
            for i in range(50):
                kmeansN = KMeans(n_clusters=c, random_state=i + 1)
                kmeansN.fit(x)
                # Change the values of yKm and inertia only if the new clusters have a better quality
                if kmeansN.inertia_ < inertia:
                    inertia = kmeansN.inertia_
                    yKm = kmeansN.fit_predict(x)

        except ValueError: # Handling the case where less than 6 pledges are provided
            kmeans = KMeans(n_clusters=1, random_state=0)
            kmeans.fit(x)
            yKm = kmeans.fit_predict(x)

        # logging.info(inertia)

        return yKm

    def Tsne(self, IndexedData):
        """
        Tsne reduces the dimensionality of a pandas dataframe to 2

        :param IndexedData: Dataframe containing the indexed vectors of all pledges + 1 column containing the topics of the pledges
        :return: Dataframe containing the reduced representation of pledges + a topic column
        """

        if len(IndexedData.index) > 15:
            # Reducing the dimension of the Indexed vectors from 300 to 2 using t-SNE
            results = TSNE(n_components=2, random_state=0, perplexity=15).fit_transform(
                IndexedData.loc[:, IndexedData.columns != "TopicAction"])
        elif len(IndexedData.index) == 1:
            # Reducing the dimension when only one pledge was provided
            results = np.array(IndexedData.iloc[:,[0,1]])
        else:
            # Reducing the dimension of the Indexed vectors from 300 to 2 using t-SNE
            results = TSNE(n_components=2, random_state=0, perplexity=1).fit_transform(
                IndexedData.loc[:, IndexedData.columns != "TopicAction"])

        return results[:, 0], results[:, 1]