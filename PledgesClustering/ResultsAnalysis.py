""" Importing relevant libraries """

import os 
from pathlib import Path # For fetching the required files
import pandas as pd # For data handling
import numpy as np

import matplotlib.pyplot as plt # For building plots
import seaborn as sns # For visualization
from wordcloud import WordCloud # For generating wordclouds

from sklearn.feature_extraction.text import TfidfVectorizer # For tf-idf representationfrom sklearn.ensemble import RandomForestClassifier

from sklearn.ensemble import RandomForestClassifier # For building RandomForest models
from sklearn.metrics import accuracy_score # For evaluating performance of predictions
from sklearn.model_selection import train_test_split # For creating train-test split

""" Loading the Clustering results """

# Load the Indexed data
DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path

ResultsPath  = str(DirPpath.absolute()) + "\semic_pledges\OurputFiles\Clusters.xlsx"
ResultsDf = pd.read_excel(ResultsPath)  

print(ResultsDf.head()) # Controlling the data loaded

""" WordClouds analysis """

# Generating wordclouds for each of the clusters based on the tf-idf "frequencies"

# For tf-idf representation
tfidfvectorizer = TfidfVectorizer(analyzer='word') # Initializing the tf-idf vectorizer
tfidfWm = tfidfvectorizer.fit_transform(ResultsDf["PreProcessedText"]) # Generating tf-idf word matrix on pre-processed text
tfidfTokens = tfidfvectorizer.get_feature_names_out() # List of words present in the pledges

dfTfidfVect = pd.DataFrame(data = tfidfWm.toarray(),columns = tfidfTokens) # Matrix tf-idf

dfTfidfVect["Cluster"] = ResultsDf["Cluster"] # Adding column containing the predicted cluster for each pledge

print("\nTD-IDF Vectorizer\n")
print(dfTfidfVect)


# Building word clouds by cluster: data = tf-idf matrix of the cluster ; cluster = name of the cluster
def wordcloudTfIdf(data, cluster):

    data = data.loc[:, data.columns != "Cluster"]
    data = data.T.mean(axis = 1)

    print("Cluster" + str(cluster))
    cloud=WordCloud(colormap="ocean",width=600,height=400, background_color="white", max_words=20).generate_from_frequencies(data) # Setting color for the map, background + defining dimensions
    fig=plt.figure(figsize=(13,18)) # Size of the figure
    plt.axis("off") # Removing the axis
    plt.imshow(cloud,interpolation='bilinear')
    plt.show()

dfTfidfVect.groupby('Cluster').apply(lambda x: wordcloudTfIdf(x, x["Cluster"].unique()))


""" Composition of the clusters """

# Color palette for the different areas
SelfPalette = {"Policy & regulation": "blue", "Green Transition": "green", "Digital Transition": "orange", "Stakeholder support": "red", "Skills & resilience": "purple", "Other": "brown"}

# Function to plot topic distribution across clusters: x = dataframe containing the topic and areas for each pledge ; c = name of the cluster
def plot_cluster(x, c): 

    sns.set_style("dark") # Building a catplot of the number of pledges per topic
    graph = sns.catplot(data=x, x="Topics", kind="count", hue ="Area", height = 3, aspect = 2, dodge = False, palette= SelfPalette)
    plt.title("Cluster {}".format(c[0]))
    plt.show()

ResultsDf.groupby('Cluster').apply(lambda x: plot_cluster(x, x["Cluster"].unique())) # Applying the function on each cluster

""" Identifying the most discriminant words """

# 1° Create 1 binary vector for each cluster: x = tf-idf dataframe ; group = cluster of interest
def binaryClass(x, group): 
    binaryVec = []

    for cluster in x["Cluster"]:

        if cluster == group:
            binaryVec.append(1)
        else:
            binaryVec.append(0)

    return binaryVec

# 2° Build a randomforest classification model to extract the most discriminant words: data = tf-idf matrix ; cluster = binary vector for cluster of interest
def DiscriWordsRF(data, cluster):

    data = data.copy()
    data["Cluster"] = cluster

    # Building training and test sets
    X, xTest, Y, yTest = train_test_split(data.loc[:, data.columns != "Cluster"], data["Cluster"], test_size=0.2)
    
    rf = RandomForestClassifier(random_state=0) # Initializing RF model on training set
    rf.fit(X, Y)

    yPred = rf.predict(xTest) # Prediction on the test set
    accuracy = accuracy_score(yTest, yPred) # Evaluating accuracy
    print("Accuracy:", accuracy)

    FeatureImportances = pd.Series(rf.feature_importances_, index=X.columns).sort_values(ascending=False)

    # Plot a simple bar chart of the 20 most discriminant words
    FeatureImportances[:20].plot.bar()
    plt.show()

for i in range(7): # Looping over the clusters

    DiscriWordsRF(dfTfidfVect, binaryClass(dfTfidfVect, i))
