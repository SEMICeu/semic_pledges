# Text Mining on GROW Tourism Pledges - Documentation

<div style='text-align: justify;'>
This project is the result of a collaboration between DG DIGIT and DG GROW on the use of text mining for the analysis of pledges on the Transition Pathway for Tourism. This project had two goals: 

(1) topic extraction 

(2) result extraction from pledges.

The objective of topic extraction was to identify emerging topics in the provided pledges: each pledge should be assigned to its respective topic and each topic should be identified. To reach this objective, we relied on a text clustering process divided in two main steps: 

(1) the indexing of pledges using a Word2Vec model 

(2) the clustering of pledges using K-means algorithm. 

For results extraction, the goal was to identify what were the different results presented in the pledges and to derive timelines of results based on their implementation date. In other words, for this section of the project, we had to extract both dates and results from textual data. From a technical point of view, the extraction of both entities was done by using Named Entity Recognition (NER) and regular expressions. 

The next pages document the different steps taken in this project. We will give an overview of the text mining processes and models used as well as the limitations of those approaches. 


## Data exploration

As previously mentioned, this text mining project aimed at analysing a set of stakeholder pledges the EU’s Transition Pathway for Tourism. The dataset was an Excel file containing the list of these pledges as of March 27, 2022. Aside from the pledge’s texts, the source file also contained additional information about it (topic of the pledge, the name, country, and type of organisation that wrote the text, and the status of the pledge). 


<p align="center">
    <img src="/Figures/Figure1.png" width = 618 height = 152>
</p>


At this stage of the project, the dataset was composed of 382 pledges distributed across 28 different topics. Note that those topics were assigned by the pledge’s author based on a predefined list of 27 topic names and description plus an ‘Other’ category. 


### Pre-processing: Data cleaning


Since the goal of this project was to perform text clustering and results extraction, i.e., it mainly focuses on analysing textual data from pledges, the first cleaning step consisted in dropping all the non-textual columns from the dataset. Hence, we dropped the “Organisation name”, “Country”, “Type”, and “Pledge status” variables. However, the “Topic” column was kept as it provides relevant information about expected clusters in the pledges. 


<p align="center">
    <img src="/Figures/Figure2.png" width = 623 height = 158>
</p>


Next to this initial step, we needed to deal with two common data issues: Missing Values and Data Type errors. Therefore, we first looked for the presence of potential NaN (Not a Number) in the list of pledges and removed them from the dataset if needed. Then we ensured that all the topics and pledges in our data were having the correct data type, i.e., pledges should be strings and topics integers. 

Finally, as we analysed in which language the pledges were written. Though most pledges were written in English, we noticed that 8 of those were using French as a main language. Since those French pledges were only representing a small minority of the data, we decided to sort them out of the dataset. 

After those 4 transformation steps, the initial pledge dataset was reduced to a CSV file containing two columns (Topic, Pledge) and 373 rows. 


### Early data visualization


In this section, we used a set of visuals to give an overview of the Pledges (global understanding, outstanding topics, exploring vocabulary) after the cleaning process. 
Figure 3 displays the distribution of already labelled topics across the dataset. We can observe that on average a topic was addressed in 13 out of the 373 pledges. Furthermore, we can notice that among the 28 topics, 4 of them (topic 2, 13, 17, and 18) contain less than 5 pledges.

Next to this bar plot, we also investigated how the length of Pledges’ text was varying across our dataset. Figures 4 and 5 show that over 90% of the data consists of pledges containing between 50 and 400 words, with some topics presenting more variance than others. We can also note that we had to deal with 13 very large pledges.   


<p align="center">
    <img src="/Figures/Figure3.png" height = 284 width = 624 class = "center">
</p>

<p align="center">
    <img src="/Figures/Figure4.png" height = 402 width = 517 class = "center">
</p>

<p align="center">
    <img src="/Figures/Figure5.png" height = 396 width = 500 class = "center">
</p>

## Topic extraction


As a reminder, the first objective was to apply topic extraction on a set of pledges to identify emerging topics, assign pledges to their respective topic, and to determine the main differences between those topics. For this purpose, we chose to rely on text clustering and followed the process displayed in Figures 6, 7, and 8. 


<p align="center">
    <img src="/Figures/Figure68.png" height = 556 width = 802 class = "center">
</p>

### 1) Pre-processing of textual content


The first step consisted in a series of transformations to pre-process the pledges’ text and make it more amenable for analysis. 

Firstly, we used built-in functions from the Python string library to replace contractions (e.g., we’ll, we’re, …) and switch words to lowercase. Then, we used regular expressions to remove unnecessary characters, i.e., elements that did not bring any semantic value to the clustering task, from the pledges. This included URLs, punctuations, digits, non-alphanumeric characters, single characters, and double/triple whitespaces. For the same reasons, we removed common stop words from the English language by using the NLTK stop words corpus. Finally, we applied a lemmatization algorithm (WordNetLemmatizer from NLTK) to bring each word to its root form.     



### 2) Document indexing

After the pre-processing, the next step consisted in indexing the data, i.e., to create a vector representation of the pledges. As displayed on Figure 7, it was achieved by relying on word embeddings and more specifically on a Word2Vec model. 

For the indexing, we started by the tokenization of the pledges using the NLTK word_tokenize function. Thereby we obtained a set of vectors each containing the words from their respective pledge.

Then, the following step consisted in transforming words from into numerical vectors using word embeddings. To achieve this, we decided to use the word vectors from a pre-trained Word2Vec model, Google-News-300 (a Word2Vec model trained on the Google News dataset and containing 300-dimensional vectors for about 3 million words and phrases). Hence, for a given word found in a pledge, the word vector would either be equal to its word embedding in the Word2Vec model, or to a vector of 300 zeros when the word could not be found in the pre-trained model.

Finally, the last step we applied to achieve document indexing was to combine the different word embeddings into a single pledge embedding. In other words, to obtain a single vector for each pledge, we needed to pool the different word embeddings of the pledge. To do this, we decided to use an average operator, i.e., the pledge embedding is equal to the average of its word embeddings. 



### 3) Clustering

After the document indexing, we obtained that every pledge from the dataset to be represented by a 300-dimensional vector that captures its semantic content. Hence, by looking at the distance between pledges’ vectors, we could have an indication on their similarity and start looking for clusters. 

To find those clusters, we first needed to determine how many of them there were. This was achieved by relying on two common clustering techniques, the analysis of an elbow graph and a dendrogram. From this human analysis, it appeared that the optimal number of pledge clusters was equal to 6.  

<p align="center">
    <img src="/Figures/Figure9.png" height = 400 width = 517 class = "center">
</p>

<p align="center">
    <img src="/Figures/Figure10.png" heigth = 370 width = 684 class = "center">
</p>

Knowing this optimal number, we could apply a clustering algorithm to assign each pledge to its respective cluster. As displayed on Figure 8, the chosen algorithm was a K-means algorithm. Note that given the dependence of K-means results to the initial centres, we decided to repeat the algorithm 500 times to find the initial centres that minimised the performance criterion (clusters’ inertia). The results of the optimal K-means algorithm were then stored in an excel file. 


### 4) Analysis of results

To analyse the results of this clustering task, we generated two main sets of visuals. On the one hand, we used t-SNE dimensionality reduction to represent pledges by vectors of 2 instead of 300 dimensions. This transformation allowed us to visualise the distance between pledges through 2D-scatter plots. These graphs can then be used to analyse the coherence of generated clusters and/or of already labelled topics. Given that the graph is a projection of higher dimensionality, the rendering is an approximation of the actual position of the points in the 300-dimension space. 


<p align="center">
    <img src="/Figures/Figure11.png" height = 337 width = 424 class = "center">
</p>


On the other hand, different visuals were investigated to determine the subject shared by pledges from the same cluster. To identify those emerging topics, we looked for the most important words in the clusters. To define the notion of the most important word, we relied on two different approaches. First, we searched for the 20 words with the highest tf-idf weights and plotted them in a word cloud. Then, to find words with the highest discriminative power, we relied on the results of binary classification tasks (1 classification per cluster) using a RandomForest classifier. The most discriminant words being the words with the highest feature importance for classifying pledges as being part (or not) of a cluster. The importance was then plotted in horizontal bar plots.  


<p align="center">
    <img src="/Figures/Figure12.png" height = 751 width = 633 class = "center">
</p>


<p align="center">
    <img src="/Figures/Figure13.png" height = 378 width = 509 class = "center">
</p>

<p align="center">
    <img src="/Figures/Figure14.png" height = 362 width = 510 class = "center">
</p>

### Limits and potential for future work


The methodology presented above allowed us to extract relevant insights from the Pledges. However, as this was only a pilot to study the methodology and feasibility of such an automated way of analysis, future developments are possible: 

A first point of attention concerns the embedding of words using Word2Vec. As previously mentioned, the embedding was performed using a pre-trained Word2Vec model. Though this choice was motivated by a gain in efficiency and the proven performance of the generic Google-News-300 model, it forced us to represent some “irregular” words by a vector of zeros, i.e., we had to ignore those. Furthermore, words used in the context of the EU’s Transition Pathway for Tourism might have had a different meaning than in the context of general news. Because of those two elements, the vector representation of pledges could still be improved. A potential solution to investigate would be to fine-tune the Word2Vec model on tourism related data. Yet, for this purpose, the collection of an important Tourism dataset will be required.

Additionally, another limitation was related to the choice of Word2Vec as an embedding model. Although this category of models is highly performant and already captures an important share of semantic information, it is not without flaws and is one of the first semantic representation models – therefore not the best performing one. One important limitation of Word2Vec is that each word has a fixed representation in the model, i.e., it does not take the surrounding context into account. To overcome this issue, one could try to replace Word2Vec by a more complex language model. For instance, we could train and fine-tune a BERT model to generate the word embeddings.  

Finally, a last point of concern regards the chosen methodology for obtaining a document embedding. As a reminder, for this purpose we used an average pooling. Note that this approach is very common and has the advantage of being highly transparent and requiring a low computational capacity. However, since it assigns the same weight to every word from the pledge, this method can be less effective at highlighting differences between documents. Therefore, it could be interesting to investigate whether there exists a more efficient pooling approach for the purpose of text clustering. 


## Result extraction

### 1) Process and results


As previously mentioned, the goal of this result extraction task was to identify the results presented in the pledges and to derive timelines of results based on their anticipated emergence. This was achieved by following the various steps presented by Figures 15 and 16. 


<p align="center">
    <img src="/Figures/Figure1516.png" height = 331 width = 615 class = "center">
</p>


Similarly to clustering, the results extraction started by a pre-processing step. However, the transformation was this time strongly reduced as the performance of the next steps (NER, results identification, etc.) depended not only on words but also on sentence structure. Hence, the pre-processing was limited to a removal of URLs and non-ASCII characters using regular expressions. 

Then, to extract results efficiently, we assumed (based on a manual analysis of the pledges) that measurable results were generally presented in one sentence. Therefore, we took the decision to tokenize pledges on sentences using Spacy sentence tokenizer. Having created this list of sentences, the next steps consisted in finding which one of those was containing both a date and a result. 

First, we looped over the different sentences to extract references to dates greater than 2022 (as we were not interested in past results). As displayed on Figure 15 and 16 this was done by using two distinct approaches. For most of the dates, we were able to use the NER algorithm from Spacy. Yet, for some specific cases (year intervals and unusual sentence structure) we had to define a specific date pattern and use regular expressions to find them. The expressions extracted using both methods are all mentioning a date but not in a uniform format. Therefore, we defined a set of rules to transform all the date expressions into a month/year format. After this last transformation, we ended up with a list of dated sentences with their respective date. 

The next step consisted in identifying result sentences among the list of dated sentences. To identify those, our basic intuition was that there should exist some results patterns. Therefore, we analysed the different pledges and found a set of typical expressions and phrases that were used to announce a result in a sentence. Then, we looped over the dated sentences and relied on regular expressions to find the ones containing results. After this last screening, we gathered the results in an excel file containing a column of dated sentences, the pledge from which it comes, the topic and cluster number of the pledge, and finally a column indicating the presence of results in the sentence.

To visualise the results, the initial objective of this task was to create timelines of results (one per topic and one per cluster). To materialise those timelines, we used histograms of dates, i.e., plots displaying the distribution of dates across results sentences. Such timelines were first created for all the sentences and for dates ranging between 2022 and 2050. Then, similar timelines were plotted for each cluster and each topic. 


<p align="center">
    <img src="/Figures/Figure17.png" height = 276 width = 624 class = "center">
</p>

### 2) Limits and potential for future work


As for the topic extraction, the methodology used for the extraction of results can be improved:

A first element to highlight relates to the management of some exceptions during the date’s extraction process. Though most of the dates could be extracted using NER or reusable rules, some exceptions required the use of regular expressions that were very specific to this situation. Hence, this may raise questions about the reproducibility of the task. To overcome this issue, work could be done upstream to prevent these exceptions from appearing in the pledges (especially for the exceptions linked to an unusual sentence structure) or a deeper analysis could be done to define more generalizable rules.     

Similarly, extracting the results using a list of typical results-related expressions was not a perfect method. First, this list was established based on a rather brief analysis of the provided pledges, lacking the expertise of linguistic specialists. Therefore, the resulting set of expressions was non-exhaustive. Then, similarly to the previous point, the use of regular expressions can be problematic in terms of generalisation. A good solution to both problems would be to make a deeper analysis of typical result patterns. 

Finally, work could still be done on the “token” used to extract results. For this project, we used sentences to present results, yet this may not be the optimal solution to do it (too much information, multiple dates, and results in one sentence, etc.). Therefore, a deeper analysis could be done to identify what is the typical structure of a results description in the pledges. Then, we could think of applying tokenization on phrases or dependency analysis to extract the smallest amount of text per result. 



## Conclusions


The objective of this project was to investigate how text mining could be used to automatically extract relevant information from a set of pledges on the Transition Pathway for Tourism. Thus, the focus was put on two different tasks: topic extraction through text clustering, and ‘announced’ results extraction through named entity recognition.

For the text clustering task, we applied a methodology combining two well-known processes in machine learning. First, we used a pre-trained Word2Vec model to achieve the indexing (or vector representation) of the pledges. Then, based on these vectors, we looked for the presence of clusters inside those pledges using a K-means algorithm. This analysis resulted in the identification of 6 distinct clusters in the data. To further investigate those results, we relied on a set of visuals (word clouds and most discriminant words) and were able to identify the topic of each cluster and their differences. 

On the results extraction side, we also proceeded in two steps. First, we relied on named entity recognition and regular expressions to identify, and extract dated sentences. Then, assuming that a result could be defined as a sentence containing a specific result pattern, we used regular expressions to extract those sentences. In the end, we were able to identify a set of dated results sentences that we stored into an excel file. For visualising the results, we built a set of timelines using histogram plots. 

Even if this approach has already allowed us to extract a series of insightful results, there is still room for improvement. In the previous pages, we have thus been able to highlight several limitations of the models, methodologies, and assumptions we used. In the light of the findings in this pilot, we can conclude that with access to larger datasets and the usage of more complex models, this project could represent a good starting point for a potential scale-up and creation of a self-standing reusable tool that can be autonomously employed by policy officers to cluster and extract relevant information from user inputs. On top of data science limitations, such a scale-up would require an in-depth analysis of the needs of DG GROW as well as a technical analysis to understand on which infrastructure such a project should be built, which algorithm should be implemented and using which software. After the implementation, the project should be carefully monitored and tested. 

</div>
