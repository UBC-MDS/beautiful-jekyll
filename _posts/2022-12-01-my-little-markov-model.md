---
toc: true
title: My Little Markov Model - Now Tweeting New Taylor Swift Lyrics
date: 2022-12-01
hero: /images/tswift-trump-logo-banner.jpg
excerpt: Built a Markov Model that can write Taylor Swift lyrics or Tweet like Trump. 
timeToRead: 10
subtitle: By Ty Andrews and Jonah Hamilton
---
{{< table-of-contents >}}

## Picture This...

You're sitting at your desk browsing the news and you see a head line something like:

{{< figure src="../img/blog/TJ/google-news-headline.jpg" caption="(this is a real headline from Nov 2022)">}}

You're skeptical but you check out the AI startups demos and sure enough it looks like it could pass most first year university degrees with a 4.0. 

Now imagine you're in a Masters of Data Science program, working on a lab that is writing a basic text generation model from scratch and you read the same headline. I suspect you would feel somewhere about here on the Dunning-Kruger curve:

{{< figure src="../img/blog/TJ/dunning-kruger-effect.png" caption=" ">}}

You finally get to the magical moment you spent 5hrs getting to and it starts generating new text based on Taylor Swift lyrics and you have a hard time telling which are real and which are fake, try it for yourself:

{{< figure src="../img/blog/TJ/tswift-fake-lyrics.jpg" caption="(Answer at the end!)">}}

<center>
<section id="contactSection" class="section narrow">
  <div class="subscription-container">
    <div class="subscription-content">
      <h3 class="subscription-heading">Which lyrics do you think are fake?</h3>
      <!-- <p class="subscription-text">
      Which one is fake?. -->
      <form id="form"
        id="lyricsvote"
        action="https://formspree.io/f/xdojqlpa"
        method="POST">
      <input type="radio" id="lyrics_1" name="lyrics" value="lyrics1">
      <label for="child" style="font-size:22px;">Lyrics 1</label> <br>
      <input type="radio" id="lyrics_2" name="lyrics" value="lyrics2">
      <label for="adult" style="font-size:22px;">Lyrics 2</label> <br><br>
      <button 
        id="submitButton" 
        type="submit"
        style="  background-color: #0A98F2; /* Green */
                  border: none;
                  color: white;
                  padding: 15px 32px;
                  text-align: center;
                  text-decoration: none;
                  display: inline-block;
                  font-size: 16px;
                  border-radius: 8px;
                  transition-duration: 0.4s;"
      >
        Vote
      </button>
      <br>
      <br>
      <br>
      </form>
    </div>
  </div>
</section>
</center>

This sparked myself and Jonah Hamilton onto the idea for a fun project!

Now you might be wondering how we achieved that and how simple was it REALLY? Well read on to learn something new!
## Challenge: Build a text generation model from scratch and Tweet with it

Breaking this down into steps we needed to:  

1. **Build a text generation model** (in base python)
1. **Scrape sample text to train on** (e.g. Taylor Swift lyrics)
2. **Setup a Twitter account and access the Developer API's**
3. **Deploy the models to Google Cloud to Tweet regularly**

## TLDR: It's Alive and Tweeting like TSwift & Sherlock Holmes @mylittlemarkov!

Here are it's latest tweets!  
<a class="twitter-timeline" data-height="400" href="https://twitter.com/mylittlemarkov?ref_src=twsrc%5Etfw">Tweets by mylittlemarkov</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<section id="contactSection" class="section narrow">
  <div class="subscription-container">
    <div class="subscription-content">
      <h3 class="subscription-heading">We need YOUR help! What would you like to see @mylittlemarkov Tweet next? &#128640;</h3>
      <p class="subscription-text">
      Could be your favorite artist, author, movie star etc. or at least fun! If you put in your email you'll be notified when it goes live on the <a href="[url](https://twitter.com/mylittlemarkov)">@mylittlemarkov Twitter account</a>.
      </p>
      <form
        id="contactForm"
        class="subscription-form"
        action="https://formspree.io/f/xjvzneak"
        method="POST"
      >
        <input
          id="nameInput"
          class="subscription-input"
          placeholder="Your BIG idea here"
          name="suggestion"
          type="text"
          required
        />
        <input
          id="emailInput"
          class="subscription-input"
          placeholder="your@email.com (Optional Sign-up for New Articles)"
          name="email"
          type="email"
          required
          pattern="^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        />
        <button id="submitButton" class="submit-button" type="submit">
          Submit Idea
        </button>
        <div class="subscription-error-message">
          The email you entered is not valid.
        </div>
      </form>
    </div>
  </div>
</section>

## Tweet Generation: Markov Model

This idea originated from an Algorithms and Data Structures lab where we were asked to code the "training" of a Markov Model. 

**Attribution:** the lab exercise was adapted with permission from Princeton COS 126, Markov Model of Natural Language. Original assignment was developed by Bob Sedgewick and Kevin Wayne and adapted for the Masters of Data Science program by [Mike Gelbart](https://www.mikegelbart.com/). All code and figures unless otherwise attributed were created by Ty Andrews and Jonah Hamilton.

A Markov Model uses the text you give it and learns that for every unique series of _N_ letters, e.g. *N* = 2, there are some letters which are more likely to follow some than others. For example, if you only look at any two letters such as "_TH_" and guess what letter follows it you'd likely say "_E_" or "_I_". This is what a Markov Model does.

This is a bit hard to visualize so lets look at an example. Say we have text that contains "their there they're" and an N of 3. We start by sliding across each N-gram of size 3 and counting the letters that follow.

{{< figure src="../img/blog/TJ/creating-ngrams.jpg" caption=" ">}}

Once we've slid across the entire text we have some N-grams with multiple letters and some with only one.

{{< figure src="../img/blog/TJ/counting-ngrams.jpg" caption=" ">}}

With these counts we generate the probability of each letter following that N-gram. So for the example "_the_" we see that each of "_r/i/y_" have a 33% probability of following the N-gram "_the_".

{{< figure src="../img/blog/TJ/ngram-probabilities.jpg" caption=" ">}}

We've been asked not to include our coded solution so as to not give the solutions to following cohorts but here's some useful pseudo code and brief explanation of how you do it.

So to code this we first start off by finding all the unique N-grams and counting which letters follow them. We did this with default dictionaries but there are two useful data structures from the `collections` package, specifically `Counter` and `DefaultDict` which make our lives much simpler.

- **`defaultdict`** - a dictionary like data structure which deals with a key not existing by creating it on assignment of a value to a new key. A default data type must be set as the `default_factory` meaning when it creates new objects internally what data structure should they be.
- **`Counter`** - dictionary like object that on setting of a value will either initialize it if it doesn't already exist and set to 1, or increment the value by 1.

Once we have the counts of each letter for each n-gram for a given text, we divide the letter counts by the total number of letter counts to get a probability for each letter of occurring between 0 and 1.

And finally with these probabilities of N-grams and letters we can generate new text! All we do is tell it how many characters to generate. Then give it a starting N-gram which then is found in the dataset of N-grams and the following letter probabilities. Once a letter has been selected from the likely candidates the process repeats now with the new N-gram.

{{< figure src="../img/blog/TJ/text-generation-example.png" caption="Markov Model text generation process.">}}

The code to run the text generation is as follows:

```python
# the start prompt to start generating from
s = "the"

# how many characters to generate
sequence_length = 100

while len(s) < sequence_length:
    
    current_ngram = s[-N :]

    # check if the ngram exists to pull letter probabilties from
    # if not just use a space
    if current_ngram in ngram_dict.keys():
        next_letter = np.random.choice(
            a=list(ngram_dict[current_ngram].keys()),
            p=list(ngram_dict[current_ngram].values()),
        )
    else:
        next_letter = " "

    # append the chosen letter and start over again
    s = s + next_letter
```

Once all characters are generated you've just made your first text generation model!

Now after this is the hard part, ensuring the text is coherent! Here are some things we did to achieve decent results:

1. **Tune the parameter N from 3-20 and inspect sample generated results**   
We had to be careful as too large of an N-gram and it just memorizes sentences, inspecting result at each stage helps this

1. **Tokenize useful two character symbols like new line "`\n`" characters**  
Replacing "`\n`" with a "`^`" symbol before training then reinserting after generation works 

1. **Truncate generated text to natural finishing points**  
Since we generate until we have X characters, the ends of these strings don't make sense. We find periods and new line characters and truncate after them.

1. **Writing custom model saving/loading functions to keep size of n-gram, weights etc. together**  
This also included start prompts for the model so it used real segments from the training data stored with the model to be used upon generation.

Now with all of this we get to pick some text to train on! We started with the following corpuses:

- **Taylor Swift Lyrics** - as you saw above, we found a dataset of all of Taylor Swifts lyrics publicly available [HERE](https://www.kaggle.com/datasets/PromptCloudHQ/taylor-swift-song-lyrics-from-all-the-albums)
- **Trumps Tweets** - again a nicely compiled list of all of Trumps Tweets is available [HERE](https://www.kaggle.com/datasets/austinreese/trump-tweets)
- **All of the Sherlock Holmes Books: Sir Arthur Conan Doyle** - we found a public compiled document that included all of his texts

To attempt to visualize the absurdity of these we got a computer generated image from OpenAI's DALL-E 2 image generation demo given the prompt: **"A blond female singer in her 30's, an orange faced politician in his 70's and Sherlock Holmes are sitting on a red couch on a tv show arguing with each other in hyper realism."**

{{< figure src="../img/blog/TJ/dalle-trump-tswift.png" caption="[Credit: DALL-E 2](https://openai.com/dall-e-2/)">}}


## Twitter Bot: Tweepy & Twitter Developer API

With the Markov Model up and running the next task at hand was to connect to the Twitter API. Lucky for us there is a ready-made Python library that is designed exactly for this purpose called [Tweepy](https://www.tweepy.org/).   
​  
Using Tweepy greatly simplifies the process of authentication and interaction with Twitter API. Tweepy allows users to easily do anything you normally might do on Twitter but with the added benefit of being able to programmatically define how and what those actions might be.  
​  
Before we could get our bot fired up, we needed to obtain access to the Twitter API. The process is well documented online and a step-by-step process can be found [HERE](https://developer.twitter.com/en/docs/tutorials/step-by-step-guide-to-making-your-first-request-to-the-twitter-api-v2), but the main points are listed below. 
​
1.	**Sign up for a Twitter developer account**
2.	**Create a project for your application**
3. **Apply for "Elevated Access" to be able to to tweet and not just scrape tweets**
3.	**Generate your Twitter API Credentials**
4.	**Using Tweepy connect to the Twitter API using the above credentials**

​
Like most things in life when something seems straightforward it rarely is (especially in the world of programming). Building the bot was not too much of a hassle given we had access to Tweepy but authenticating to the API with correct credentials was a bit of mucking around so we hope we can save you some of that should you want to do this in the future!

Below is the code that we were able to authenticate correctly with.
​
```python
class TwitterBot:
    """A twitter bot that will post tweets generated from a Markov model of languages based on character frequencies in text."""

    def __init__(self):

        self.verified_api = None

    def create_authenticate_api(self):

        """creates and authenticates an twiter api . Access token/Consumer keys
        must be available

        Returns:
            twitter_api: An authenticated twitter api that can be used to interact
            with the twitter environment
        """
        # pulls keys/secrets from env
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")
        access_token = os.getenv("TWITTER_ACCESS_TOKEN")
        access_token_secret = os.getenv("TWITTER_ACCESS_TOKEN_SECRET")

        # sets up authentication
        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(access_token, access_token_secret)

        # creates twitter api object
        twitter_api = tweepy.API(
            auth,
            wait_on_rate_limit=True,  # wait_on_rate_limit_notify=True
        )

        # tests if authentication is successful
        try:
            twitter_api.verify_credentials()
            self.verified_api = twitter_api
        except Exception as e:
            logger.error("Error creating API", exc_info=True)
            raise e
        logger.info("API created")
```
​
And finally the actual sending of the tweet is quite simple, this is all that's needed once you've authenticated!

```python
def send_tweet(self, tweet_text):

     # success flag
     success = False

     # attempts to send tweet
     try:
         self.verified_api.update_status(tweet_text)
         success = True
         logger.info("Tweet sent")
     except Exception as e:
         logger.error("Error tweeting tweet", exc_info=False)
         raise e

     return success
```

## Deploy: Cloud Run and Docker 

Now pulling all the pieces together there were 3 main pieces to deploying this:

1. **Randomly select one of the trained models and generate the Tweet**
2. **Authenticate to the Twitter API and send the Tweet**
3. **Schedule this to run every hour from 9AM - 9PM 7 days a week**

The source code found in the [my-little-markov-model GitHub repository](https://github.com/tieandrews/my-little-markov-model) was packaged up into a Docker image with the entry point just being the `main.py` file which kicks off the generation and Tweeting.

Googles [Cloud Build service](https://cloud.google.com/build) was used for managing builds and storing in [Google Artifact Registry](https://cloud.google.com/artifact-registry). From Artifact Registry the newly built image is selected and deployed to a Cloud Run instance.

All of this is orchestrated in the `cloudbuild.yaml` file, you can see the steps above outlined below:

```python
steps:
  # Install dependencies
  - name: python
    entrypoint: pip
    args: ["install", "-r", "requirements.txt", "--user"]

    # Docker Build
  - name: 'gcr.io/cloud-builders/docker'
    args: [ 'build', '-t', 'us-central1-docker.pkg.dev/${PROJECT_ID}/${_ARTIFACT_REGISTRY_REPO}/${_DOCKER_IMAGE_NAME}:$SHORT_SHA', '.'] 

  # Docker push to Google Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push',  'us-central1-docker.pkg.dev/${PROJECT_ID}/${_ARTIFACT_REGISTRY_REPO}/${_DOCKER_IMAGE_NAME}:$SHORT_SHA']

  # Deploy to Cloud Run, make sure cloudbuild service account has cloud run write permissions
  - name: google/cloud-sdk
    args: ['gcloud', 'beta', 'run', 'jobs', 'update', '${_CLOUD_RUN_NAME}', 
           '--image=us-central1-docker.pkg.dev/${PROJECT_ID}/${_ARTIFACT_REGISTRY_REPO}/${_DOCKER_IMAGE_NAME}:$SHORT_SHA', 
           '--region', 'us-central1']

substitutions:
  _ARTIFACT_REGISTRY_REPO: '<DIRECTORY IN ARTIFACT REGISTRY WHERE IMAGE IS BUILT TO>'
  _DOCKER_IMAGE_NAME: '<NAME TO GIVE BUILT IMAGE>v'
  _CLOUD_RUN_NAME: '<CLOUD RUN SERVICE NAME>'
images:
- 'us-central1-docker.pkg.dev/${PROJECT_ID}/${_ARTIFACT_REGISTRY_REPO}/${_DOCKER_IMAGE_NAME}:$SHORT_SHA'
```

Googles secrets manager is used to expose the Twitter API keys required securely as environment variables.

{{< figure src="../img/blog/TJ/secrets-manager.jpg" caption=" ">}}

And FINALLY we use Google Cloud Scheduler to run the container to Tweet every hour from 9AM to 9PM. I found a useful guide on how to write CRON scheduling commands and so here is ours used with the reference above.

```python
# Use the hash sign to prefix a comment
# +---------------- minute (0 - 59)
# |  +------------- hour (0 - 23)
# |  |  +---------- day of month (1 - 31)
# |  |  |  +------- month (1 - 12)
# |  |  |  |  +---- day of week (0 - 7) (Sunday=0 or 7)
# |  |  |  |  |
# *  *  *  *  *  command to be executed
#-------------------------------------------------------------------------
# every day, every hour from 9-9pm
0 9,10,11,12,13,14,15,16,17,18,19,20,21 * * *
```

## Which Taylor Swift Lyrics Were ACTUALLY Fake?

First of all THANKS if you made it this far. We hope you laughed or at least learnt a little something new.


**Please suggest a new text topic to train on and we will get the account Tweeting with it as soon as possible!**

<section id="contactSection" class="section narrow">
  <div class="subscription-container">
    <div class="subscription-content">
      <h3 class="subscription-heading">We need YOUR help! What would you like to see @mylittlemarkov Tweet next? &#128640;</h3>
      <p class="subscription-text">
      Could be your favorite artist, author, movie star etc. or at least fun! If you put in your email you'll be notified when it goes live on the <a href="[url](https://twitter.com/mylittlemarkov)">@mylittlemarkov Twitter account</a>.
      </p>
      <form
        id="contactForm"
        class="subscription-form"
        action="https://formspree.io/f/xjvzneak"
        method="POST"
      >
        <input
          id="nameInput"
          class="subscription-input"
          placeholder="Your BIG idea here"
          name="suggestion"
          type="text"
          required
        />
        <input
          id="emailInput"
          class="subscription-input"
          placeholder="your@email.com (Optional Sign-up for New Articles)"
          name="email"
          type="email"
          required
          pattern="^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        />
        <button id="submitButton" class="submit-button" type="submit">
          Submit Idea
        </button>
        <div class="subscription-error-message">
          The email you entered is not valid.
        </div>
      </form>
    </div>
  </div>
</section>

And the moment you've all been scrolling for: **Lyrics 1 were generated by the Markov Model**

{{< figure src="../img/blog/TJ/tswift-fake-lyrics.jpg" caption=" ">}}
