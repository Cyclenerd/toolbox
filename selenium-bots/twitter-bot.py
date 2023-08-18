import sys
import time
import random
import re
import argparse
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

class TwitterBot:
    def __init__(self, email, password, hashtag, since):
        self.email = email
        self.password = password
        self.hashtag = hashtag
        self.since = since
        profile = webdriver.FirefoxProfile()
        profile.set_preference('permissions.default.image', 2) # disable images
        self.bot = webdriver.Firefox(profile)
        self.bot.fullscreen_window() # fullscreen
        self.tweets = {}

    def login(self):
        print("LOGIN")
        bot = self.bot
        bot.get('https://twitter.com/login') # open url
        time.sleep( random.randrange(3, 10) ) # wait
        email = bot.find_element_by_name('session[username_or_email]') # find element
        password = bot.find_element_by_name('session[password]')
        email.clear()
        password.clear()
        email.send_keys(self.email)
        password.send_keys(self.password)
        password.send_keys(Keys.RETURN)
        time.sleep( random.randrange(6, 12) )

    def farm(self):
        print("FARMING")
        bot = self.bot
        bot.get('https://twitter.com/search?q=%23'+ self.hashtag +'%20lang%3Aen%20since%3A'+ self.since +'%20-filter%3Areplies&src=typed_query')
        time.sleep( random.randrange(3, 10) )
        # scroll x times down to load more content
        for i in range(1,15):
            print(i)
            bot.execute_script('window.scrollTo(0, document.body.scrollHeight)')
            time.sleep( random.randrange(3, 10) )
            links = bot.find_elements_by_tag_name('a')
            for link in links:
                url  = link.get_attribute('href')
                # filter usernames
                if re.search('/realCyclenerd/', url): continue # skip own tweets
                if re.search('/GCPcloud/', url): continue
                if re.search('/SAP', url, re.IGNORECASE): continue
                if re.search('/Google', url, re.IGNORECASE): continue
                # save tweet url
                if re.search('/status/\d*$', url): self.tweets[url] = url
        for tweet in self.tweets:
                print("Found: {tweet}".format(tweet = tweet))

    def like(self):
        print("LIKE")
        bot = self.bot
        for tweet in self.tweets:
            try:
                f = open("liked.txt", "r")
                if tweet in f.read():
                    print("Already liked: {tweet} ".format(tweet = tweet))
                    continue
            except FileNotFoundError:
                print('File does not exist')
            except:
                print('Something with the file went wrong')
            print("Like: {tweet} ".format(tweet = tweet))
            bot.get(tweet)
            time.sleep( random.randrange(3, 30) )
            bot.execute_script('window.scrollTo(0, screen.height/4.5)') # scroll down to see the heart icon
            time.sleep( random.randrange(2, 4) )
            try:
                heart = bot.find_element_by_css_selector('[data-testid="like"]').click()
                f = open("liked.txt", "a")
                f.write(tweet + '\n')
                f.close()
                time.sleep( random.randrange(3, 10) )
            except:
                print("Error")

    def profile(self):
        print("DONE")
        bot = self.bot
        bot.get("https://twitter.com/home")
        profile = bot.find_element_by_css_selector('[aria-label="Profile"]').click()

# get command line parameters
parser = argparse.ArgumentParser(
    description='Twitter Bot : Spread a few hearts for tweets with your chosen hashtag',
    epilog="Powered by Selenium with Python")
parser.add_argument('--email', required=True, help='Twitter username or email')
parser.add_argument('--password', required=True, help='Twitter password')
parser.add_argument('--hashtag', required=True, help='Hashtag without #')
parser.add_argument('--since', required=True, help='YYYY-MM-DD')
args = parser.parse_args()

# start twitter bot
marvin = TwitterBot(args.email, args.password, args.hashtag, args.since)
marvin.login()
marvin.farm()
marvin.like()
marvin.profile()