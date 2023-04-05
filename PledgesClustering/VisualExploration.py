""" Importing Relevant Packages """

import os # For finding pre-processed data
from pathlib import Path

import pandas as pd # For data handling
import numpy as np
import math # For basic mathematical operations

import matplotlib.pyplot as plt # For building plots
import seaborn as sns # For visualization

from sklearn.manifold import TSNE # For applying a dimensionality reduction (t-SNE)
from sklearn.cluster import KMeans # For K-mean clustering algorithm
import scipy.cluster.hierarchy as shc # For building hierachichal clustering algorithms


""" Loading the Indexed Pledges and Topic """

# Load the Indexed data
DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path - Specific for ipynb file - For .py: Path(os.path.dirname(os.path.realpath(__file__)).replace("\\", "/"))
IndexedPath  = str(DirPpath.absolute()) + "\semic_pledges\IndexedDataV1.csv"  

print("The current location of IndexedDataV1.csv is: ", IndexedPath)

IndexedData = pd.read_csv(IndexedPath, index_col=0)  # Loading the indexed pledges into a dataframe

print(IndexedData.head()) # Controlling the data loaded


# Load the Topic column from the preprocessed data
DirPpath = Path(os.path.abspath('')).parent # Fetching the current directory path - Specific for ipynb file - For .py: Path(os.path.dirname(os.path.realpath(__file__)).replace("\\", "/"))
PreprocessedPath  = str(DirPpath.absolute()) + "\semic_pledges\PreProcessedData.csv"  
Topics = pd.read_csv(PreprocessedPath, index_col=0)

IndexedData["Topic"] = Topics["Topic"].values # Adding a Topic column to the IndexedData dataframe


""" Dimensionality reduction """

# Reducing the dimension of the Indexed vectors from 300 to 2 using t-SNE
results = TSNE(n_components=2, random_state=0, perplexity=15).fit_transform(IndexedData.loc[:, IndexedData.columns != "Topic"])

# Building a new df for better visualization of t-SNE results
df = pd.DataFrame()
df["Topic"] = IndexedData["Topic"].values
df["Y1"] = results[:,0]
df["Y2"] = results[:,1]

""" Global Visualization """

# Building a scatter plot for the t-SNE results
csfont = {'fontname':'Arial'} # setting font for axis labels
hfont = {'fontname':'Georgia'} # setting font for title

plt.figure(figsize=(8,6)) # setting size of the graph
sns.scatterplot(

    x="Y1", y="Y2", # Data to plot
    hue="Topic",  # Group by Topic
    palette=sns.color_palette(), # Apply a given color palette
    style = "Topic", # Ensure that each topic has a different style
    data=df, # Data source file
    legend="full", # Adding a legend
    
).set_title("2D t-SNE plot", fontdict = hfont) # Adding a title with the font hfont

plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left', borderaxespad=0, ncol = 2) # Placing the legend on the graph
plt.show()


""" Topic by Topic visualization """

# Creating a function for building tSNE plots
def tSNEPlot(x, topic):

    csfont = {'fontname':'Arial'} # Font name for labels
    hfont = {'fontname':'Georgia'} # Font name for title

    ax = plt.axes()
    ax.scatter(x["Y1"], x["Y2"], c="#d04a02", marker= "v") # Setting data to plot, color, and markers type
    ax.set_title("2D t-SNE plot of Topic " + str(topic), **hfont) # Defining a title and its format
    ax.set_ylabel("Y2", **csfont) # Defining y-label
    ax.set_ylim(-25,25) # Standardizing the scale of y axis
    ax.set_xlabel("Y1", **csfont) # Idem for x axis
    ax.set_xlim(-25,25)

    ax.set_facecolor((218 / 255, 222 / 255, 224 / 256)) # Formatting the background's color
    plt.grid(which='major', color='w', linestyle='-') # Adding a grid to the background
    ax.set_axisbelow(True)  # Formatting the axis style
    for spine in ax.spines:
        ax.spines[spine].set_color('white')

    plt.show()

# Applying the function on all Topic
df.groupby('Topic').apply(lambda x: tSNEPlot(x, x["Topic"].unique()))


""" Optimal Number of clusters - Global """

# To find the optimal number of cluster in the data, we proceed with a visual exploration using:
# 1° The Elbow method:

## Function to compute the Total Sum of Square in the data
def TSS(data):
    
    x = np.array(data)
    size = x.shape[0]
    tss = []

    for i in range(0,size):

        tss.append((math.dist(x[i,:], np.mean(x, axis = 0)))**2)

    return sum(tss)  

## Function to build an elbow graph
def ElbowGraph(x):

    print("Elbow Graph: \n")
    inertias = []
    size = np.array(x).shape[0]

    if size > 26:
        size = 26

    for i in range(1, size):
        kmeans = KMeans(n_clusters=i)
        kmeans.fit(x)
        inertias.append(kmeans.inertia_ / TSS(x))

    plt.plot(range(1,size), inertias, marker='o')
    plt.title('WSS/TSS method')
    plt.xlabel('Number of clusters')
    plt.ylabel('WSS/TSS')
    plt.show()

# 2° Dendrogram
def Dendro(x):

    print("Dendrogram: \n")
    plt.figure(figsize=(30, 7))
    plt.title("Topics Dendrogram")

    # Selecting Annual Income and Spending Scores by index
    selected_data = x
    clusters = shc.linkage(selected_data, 
                method='ward', 
                metric="euclidean")
    shc.dendrogram(Z=clusters)
    plt.show()

# Combining the two functions:
def GraphAnalysis(x, topic):

    print("Cluster Analysis of Topic:" + str(topic) + "\n")

    ElbowGraph(x)
    Dendro(x)

# Applying the function on all data
GraphAnalysis(IndexedData.loc[:, IndexedData.columns != "Topic"], "Global")

""" Optimal Number of clusters - Topic by Topic """

# Applying the function Topic by Topic
IndexedData.groupby('Topic').apply(lambda x: GraphAnalysis(x, x["Topic"].unique()) if np.array(x).shape[0]>2 else print("Less than two items in the topic"))


