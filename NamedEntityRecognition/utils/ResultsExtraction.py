""" Importing relevant libraries """

import re # For dealing with regular expressions


""" Extracting results """

def GetResults(DatesSent):
    """
    GetResults analyses Dated sentences and identifies the presence of results

    :param DatesSent: List of sentences containing dates

    :return: List of 0 and 1 indicating the presence of results into the sentences ; List of sentences containing results
    """

    # List of typical phrases announcing a results
    ResultsPatterns = "goal|goals|target|targets|objective|objectives|result|results|aim|aims to have by|increases by|decreases by|we expect to|expected for|are expected to|for [12][0-9]{3}|expect that by|as of [12][0-9]{3}|in [12][0-9]{3}|for [12][0-9]{3}|by [12][0-9]{3}|expected by|aimed at|our target for [12][0-9]{3} is to have|should be online|should be ready|from [12][0-9]{3}|measurable|milestones"
    
    # Variables
    ResultsSent = []
    Results = []

    # Loop over the dated sentences
    for sent in DatesSent:
        try: 
            # Identify results sentences based on patterns
            re.findall(ResultsPatterns, sent, re.IGNORECASE)[0]
            ResultsSent.append(1) 
            Results.append(sent)
        except:
            ResultsSent.append(0)

    return ResultsSent, Results
