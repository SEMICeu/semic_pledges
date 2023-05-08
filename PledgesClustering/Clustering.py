""" Importing relevant libraries """

import os 
from pathlib import Path # For fetching the required files
import pandas as pd # For data handling
import numpy as np

import matplotlib.pyplot as plt # For building plots
import seaborn as sns # For visualization

from sklearn.manifold import TSNE # For applying a dimensionality reduction (t-SNE)
from sklearn.cluster import KMeans # For applying K-Means clustering

""" Loading the Indexed Pledges and Topic """

# Load the Indexed data
DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path

IndexedPath  = str(DirPpath.absolute()) + "\semic_pledges\OutputFiles\IndexedDataV1.csv"
IndexedData = pd.read_csv(IndexedPath, index_col=0)  

# Load the Topic column from the preprocessed data
PreprocessedPath  = str(DirPpath.absolute()) + "\semic_pledges\OutputFiles\PreProcessedData.csv"  
Topics = pd.read_csv(PreprocessedPath, index_col=0)

IndexedData["Topic"] = Topics["Topic"].values # Adding a Topic column to the IndexedData dataframe

print(IndexedData.head()) # Controlling the data loaded


""" Dimensionality reduction for visuals """

# Reducing the dimension of the Indexed vectors from 300 to 2 using t-SNE
results = TSNE(n_components=2, random_state=0, perplexity=15).fit_transform(IndexedData.loc[:, IndexedData.columns != "Topic"])

# Building a new df for better visualization of t-SNE results
df = pd.DataFrame()
df["Topic"] = IndexedData["Topic"].values
df["Y1"] = results[:,0]
df["Y2"] = results[:,1]


""" Finding optimal clusters """

# Function to find optimal cluster: x = the data to cluster , c = the number of clusters to find
def OptiCluster(x, c):

# Initialisation of a first k-means algorithm
    kmeans = KMeans(n_clusters=c, random_state=0)
    kmeans.fit(x)

    inertia = kmeans.inertia_ # Quality criterion --> The lower the inertia the better the clusters
    print(inertia)

    yKm = kmeans.fit_predict(x) # Storing the predicted clusters in a temporary variable

# Repeating the process 500 times to find an optimum
    for i in range(500): 
        kmeansN = KMeans(n_clusters=c, random_state=i+1)
        kmeansN.fit(x)
# Change the values of yKm and inertia only if the new clusters have a better quality
        if kmeansN.inertia_ < inertia: 
            inertia = kmeansN.inertia_
            yKm = kmeansN.fit_predict(x)
    
    print(inertia)

    return yKm

# Applying the function to our data for 6 clusters
x = np.array(IndexedData.loc[:, IndexedData.columns != "Topic"]) 
yKm = OptiCluster(x, 6)

""" Visualizing results """

# Plotting the global results using t-SNE: tsne = dataframe containing the results of a t-SNE dimensionality reduction ; labels = predicted clusters
def ClusterPlot(tsne, labels):
    df = pd.DataFrame()
    df["x"] = tsne[:,0]
    df["y"] = tsne[:,1]
    df["cluster"] = labels

    csfont = {'fontname':'Arial'} # setting font for axis labels
    hfont = {'fontname':'Georgia'} # setting font for title

    #plt.figure(figsize=(8.75,3)) # setting size of the graph
    sns.scatterplot(

        x="x", y="y", # Data to plot
        hue="cluster",  # Group by cluster
        palette=sns.color_palette(), # Apply a given color palette
        data=df, # Data source file

        
    ).set_title("2D t-SNE plot", fontdict = hfont) # Adding a title with the font hfont

    plt.show()

ClusterPlot(results, yKm+1) # +1 to have clusters name going from 1 to 6



# Creating a function for building tSNE plots by cluster
def tSNEPlot(x, topic, title):

    csfont = {'fontname':'Arial'} # Font name for labels
    hfont = {'fontname':'Georgia'} # Font name for title

    ax = plt.axes()
    ax.scatter(x["Y1"], x["Y2"], c="#d04a02", marker= "v") # Setting data to plot, color, and markers type
    ax.set_title("2D t-SNE plot of " + str(title) + str(topic[0]), **hfont) # Defining a title and its format
    ax.set_ylabel("Y2", **csfont) # Defining y-label
    ax.set_ylim(-35,35) # Standardizing the scale of y axis
    ax.set_xlabel("Y1", **csfont) # Idem for x axis
    ax.set_xlim(-35,35)

    ax.set_facecolor((218 / 255, 222 / 255, 224 / 256)) # Formatting the background's color
    plt.grid(which='major', color='w', linestyle='-') # Adding a grid to the background
    ax.set_axisbelow(True)  # Formatting the axis style
    for spine in ax.spines:
        ax.spines[spine].set_color('white')

    plt.show()

# Applying the function on all Topic
df["Cluster"] = yKm + 1
df.groupby('Cluster').apply(lambda x: tSNEPlot(x, x["Cluster"].unique(), "Cluster "))


""" Exporting the results in excel """

ResultsDf = pd.DataFrame() # Dataframe to store all the results we are interested in

# Load the original pledge text column from the cleaned data
CleanedPath  = str(DirPpath.absolute()) + "\semic_pledges\CleanedData.csv"  
PledgeDf = pd.read_csv(CleanedPath, index_col=0)

ResultsDf["Pledge"] = PledgeDf["Pledge"]
ResultsDf["PreProcessedText"] = Topics["PreProcessedText"]
ResultsDf["Cluster"] = yKm + 1
ResultsDf["Topics"] = Topics["Topic"]

print(ResultsDf["Cluster"] )

# Adding an extra column with the area of focus
area1 = [1, 2, 3, 4, 5]
area2 = [6,7,8,12,13]
area3 = [9,10,14,15,16]
area4 = [11, 19,20,23,27]
area5 = [17,18,21,22,24,25,26]

areaList = []

for topic in ResultsDf["Topics"]:

    if topic in area1:
        areaList.append("Policy & regulation")
    elif topic in area2: 
        areaList.append("Green Transition")
    elif topic in area3: 
        areaList.append("Digital Transition")
    elif topic in area4:
        areaList.append("Stakeholder support")
    elif topic in area5:
        areaList.append("Skills & resilience")
    else:
        areaList.append("Other")

ResultsDf["Area"] = areaList
ResultsDf.to_excel(str(DirPpath.absolute()) + "\semic_pledges\OutputFiles\Clusters.xlsx")