from textblob import TextBlob
import sys
import tweepy
import pandas as pd
import numpy as np
import os
import nltk
import pycountry
import re
import string
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from langdetect import detect
from nltk.stem import SnowballStemmer
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from sklearn.feature_extraction.text import CountVectorizer
import nltk
import text2emotion as te
from deep_translator import GoogleTranslator
nltk.download('vader_lexicon')
nltk.download('omw-1.4')

consumerKey = "YOUR_CONSUMER_KEY"
consumerSecret = "YOUR_CONSUMER_SECRET"
accessToken = "YOUR_ACCES_TOKEN"
accessTokenSecret = "YOUR_TOKEN_SECRET"
auth = tweepy.OAuthHandler(consumerKey, consumerSecret)
auth.set_access_token(accessToken, accessTokenSecret)
api = tweepy.API(auth)





def extract_hashtags(trends):
    hashtags = [trend["name"] for trend in trends if "#" in trend["name"]]
    return hashtags
  


def percentage(part,whole):
 return 100 * float(part)/float(whole)

def count_values_in_column(data,feature):
 total=data.loc[:,feature].value_counts(dropna=False)
 percentage=round(data.loc[:,feature].value_counts(dropna=False,normalize=True)*100,2)
 return pd.concat([total,percentage],axis=1,keys=["Total","Percentage"])




def get_sentiment(keyword, nb_tweet, popular="recent", langage=None):
  
  tweets = api.search_tweets(q = keyword + " -filter:retweets", count = nb_tweet, result_type = popular, lang = langage)
  tweet_list = []
  ids = []
  ret_count = []
  lang = []
  location = []
  screen_names = []
  
  for tweet in tweets:
    tweet_list.append(tweet.text)
    ids.append(tweet.id_str)
    ret_count.append(tweet.retweet_count)
    lang.append(tweet.lang)
    users = tweet.user
    location.append(users.location)
    screen_names.append(users.screen_name)
    
  
  tweet_list = pd.DataFrame(tweet_list)
  
  
  tweet_list["text"] = tweet_list[0]
  remove_rt = lambda x: re.sub("RT @\w+: "," ",x)
  rt = lambda x: re.sub("(@[A-Za-z0–9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)"," ",x)
  tweet_list["text"] = tweet_list.text.map(remove_rt).map(rt)
  tweet_list["text"] = tweet_list.text.str.lower()
  
  tweet_list[["polarity", "subjectivity"]] = tweet_list["text"].apply(lambda Text: pd.Series(TextBlob(Text).sentiment))
  for index, row in tweet_list["text"].iteritems():
   score = SentimentIntensityAnalyzer().polarity_scores(row)
   neg = score["neg"]
   neu = score["neu"]
   pos = score["pos"]
   comp = score["compound"]
   if neg > pos:
     tweet_list.loc[index, "sentiment"] = "negative"
   elif pos > neg:
     tweet_list.loc[index, "sentiment"] = "positive"
   else:
     tweet_list.loc[index, "sentiment"] = "neutral"
     tweet_list.loc[index, "neg"] = neg
     tweet_list.loc[index, "neu"] = neu
     tweet_list.loc[index, "pos"] = pos
     tweet_list.loc[index, "compound"] = comp
   
  tweet_list["id"] = ids
  tweet_list["rt_count"] = ret_count
  tweet_list["lang"] = lang
  tweet_list["screen"] = screen_names
  tweet_list["location"] = location
  
  tweet_list = tweet_list.drop(columns = ['text','polarity', 'subjectivity','neg','neu','pos','compound'])
  
  
  #Count_values for sentiment
  sentiments = count_values_in_column(tweet_list,"sentiment") 

  
  
  return(tweet_list, sentiments)


def get_trends(woeid):
  
  liste = []
  
  if isinstance(woeid, list) == False:
    a = api.get_place_trends(int(woeid))
    b = a[0]["trends"]
    liste.extend(extract_hashtags(b))
  else:
    woeid = [int(x) for x in woeid]
    for identifiant in woeid:
      a = api.get_place_trends(identifiant)
      b = a[0]["trends"]
      liste.extend(extract_hashtags(b))
    
  
  return(liste)


def get_emotions(texte):
  return(te.get_emotion(GoogleTranslator(source='auto', target='en').translate(texte)))



# def get_geocoded_data(hashtag):
#   tweets = api.search_tweets(q = hashtag + " -filter:retweets", count = 99, result_type = "recent")
#   tweet_list = []
#   ids = []
#   ret_count = []
#   lang = []
#   location = []
#   screen_names = []
# 
#   for tweet in tweets:
#     tweet_list.append(tweet.text)
#     ids.append(tweet.id_str)
#     ret_count.append(tweet.retweet_count)
#     lang.append(tweet.lang)
#     users = tweet.user
#     location.append(users.location)
#     screen_names.append(users.screen_name)
# 
# 
#   locations = pd.DataFrame(location)
#   locations["ids"] = ids
#   locations["loc"] = locations[0]
#   locations["texte"] = tweet_list
# 
# 
#   from geopy.geocoders import Nominatim
#   import gmplot
# 
#   geolocator = Nominatim(user_agent="tutorial")
# 
#   # Go through all tweets and add locations to 'coordinates' dictionary
#   coordinates = {"id_tweet": [],"place": [],'latitude': [], 'longitude': [], "hashtag":[], "texte":[]}
#   for index in range(len(locations)):
#     user_loc = locations["loc"].iloc[index]
#     id_tweet = locations["ids"].iloc[index]
#     texte = locations["texte"].iloc[index]
#     try:
#       location = geolocator.geocode(user_loc)
# 
#       if location:
#         coordinates["hashtag"].append(hashtag)
#         coordinates["id_tweet"].append(id_tweet)
#         coordinates['place'].append(user_loc)
#         coordinates['latitude'].append(location.latitude)
#         coordinates['longitude'].append(location.longitude)
#         coordinates["texte"].append(texte)
# 
#     except:
#       pass
# 
#   d = pd.DataFrame(coordinates)
#   return(d)
# 
# 


