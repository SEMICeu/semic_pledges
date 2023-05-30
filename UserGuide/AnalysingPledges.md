# Analysing pledges - How to ? 

In this document, we describe the different steps to follow to reproduce the analysis presented in the documentation. 

## 0) Installing the relevant packages

Before running any of the scripts, it is important to ensure that all the required packages have already been installed on your device. This can be done by entering the following command in a terminal window (for Windows): 
```
pip install -r requirements.txt
```

## 1) Updating the source file

Currently, the file on which the pledges' analysis is performed only contains pledges for the Tourism transition pathway as of 27/03/2022. Hence to apply the analysis on a new set of data, the first step to undertake should be to update the source file **PledgeList.xlsx**

To do so, start by going to the **InputFile** folder and delete the current **PledgeList.xlsx** file. 

Then, create a new excel file containing the data of interest, name it **PledgeList.xlsx**, and save it in the **InputFile** folder. 

**!!! NB !!! :** This new file must have the same format as the initial **PledgeList.xlsx** file. In other words, it should contain 6 columns named *Topic, Pledge, Organisation name, Country, Type, Pledge status*. The first row should only contain the name of those columns, while the other rows are containing nothing else than the data. 

## 2) Creating files of results

To create excel files containing respectively the results from the **Topic** and **Result extraction** (clusters, results sentences, ...), you will have to run the following scritps: 

<p align="center">
    <img src="/UserGuide/Figures/process.png" height = 68 width = 750 class = "center">
</p>

- *1-DataCleaning.py* : Located in the **1. DataExploration** folder, this script creates a CSV file containing the cleaned dataset with only *Topic* and *Pledge*.

- *1-PreProcessing.py* : Located in the **2.1. WordEmbedding** folder, this script applies the different preprocessing procedures to the *CleanedData.csv* and returns a new CSV file with the pre-processed pledges. 

- *2-WordEmbedding.py* : Located in the **2.1. WordEmbedding** folder, this script creates a new CSV file containing vectors of the indexed pre-processed pledges (*IndexedDataV1.csv*).

- *1-Clustering.py* : Located in the **2.2. PledgesClustering** folder, this script uses the indexed pledges to identify and label 6 cluster of pledges in the data. This script also provides some basic visuals (t-SNE plot of each cluster)

- *1-ResultsExtraction.py* : Located in the **3. ResultsExtraction** folder, this script extracts the dated results sentences found in *CleanedData.csv*.

**NB:** For grouping the pledges in more or less than 6 clusters, you can replace the **6** in line 32 of *1-Clustering.py* by the number of your choice.

After running those scripts, the excel containing the final results will be created in the **OutputFile** folder under the name **Clusters.xlsx** and **NerResults.xlsx**. 

## 3) Visualising the results

For each of the tasks, different scripts have been created to visualize the results and facilitate the analysis of the results. You can find here a short description of what each of those script can provide: 

- *2-DataVisualisation.py* in **1. DataExploration**: Creates basic visuals to get a first overview of the pledges after cleaning (see [Documentation](/README.md#early-data-visualization)) 

- *0-VisualExploration.py* in **2.2. PledgesClustering**: Creates a set of visuals to analyse the coherence of already labelled topics, and to determine the number of clusters in the pledges. 

    * Two dimensional representation of the pledges (all together and by topic), see [Documentation](/README.md#4-analysis-of-results) for examples

    * An elbow graph and a dendrogram (see [Documentation](/README.md#3-clustering))

- *2-ResultsAnalysis.py* in **2.2. PLedgesClustering**: Creates a set of visuals to analyse the content of the identified clusters. 

    * Word clouds of the 20 most frequent words for each cluster and barplots of the most discriminant words for each cluster (see [Documentation](/README.md#4-analysis-of-results))

    * Distribution of topics across the different clusters

<p align="center">
    <img src="/UserGuide/Figures/visuals1.png" width = 623 height = 200>
</p>


- *2-ResultsAnalysis.py* in **3. ResultsExtraction**: Creates a set of visuals to display the extracted results and their implementation dates 


    * Timelines of results for all pledges, by clusters and by topics (see [Documentation](/README.md#1-process-and-results))
    
    * Basic visuals 

- *3-WordClouds.py* in **3. ResultsExtraction**: Creates a set of visuals to display the extracted results and their implementation dates 

    * Word clouds of results sentences for the years 2023, 2025 and 2030

<p align="center">
    <img src="/UserGuide/Figures/visuals2.png" width = 623 height = 200>
</p>

**NB:** To display the different visuals, the code automatically opens an independent window. However, one can only see one plot at a time, i.e., to see the next visual (or to end the script) one need to close the current window (the code stops running while the window is open). 



