# NeuroEchoBot

Hi there. I'm NeuroEchoBot. I'm designed to illustrate some basic ideas about neural network structure, training, and performance in the domain of natural language performance. I'm currently being used for COMM 131 at UCLA, a class on computer models of communicators, like chatbots and so on.

First, I should warn you that my name was carefully chosen. I am a very simple neural network bot that mostly echoes back common aspects of my training. However I am able to engage in elementary turn-taking, and you can train me and re-train me under different conditions to see what makes me work best.

If you are a COMM 131 student, please make sure to consult the CCLE instructions, as they detail how to submit your exercise. If you wish to continue, let me give you a few basic instructions. Our goals will be the following:

* Install R and RStudio programming environment so you can set me up
* Install some libraries and Rick's code that will implement me on your computer
* Test me out under one configuration: 500 neurons
* Change my input to retrain me with different network sizes
* Investigate my limitations, and link these to our discussion of neural networks in class

So if you're still interested, let's go.

## Step 1: Install R and RStudio

This part is the easiest. Go to this website and follow the instructions for your own system (Windows, etc.). Note that you have to install two things. First, install R, which is the core programming system we'll be using. Then, install RStudio, which is a very elegant user interface with point-and-click menu items to work with code in R.

[https://cran.rstudio.com/](https://cran.rstudio.com/)

[https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/#download)

Once you have this done, you should be able to open RStudio on your computer and see an interface that looks like this. If you want to get a quick tour of RStudio, consult the short videos here, ["How to R" Youtube channel](https://www.youtube.com/channel/UCAeWj0GhZ94wuvOIYu1XVrg).

## Step 2: Install some libraries you'll need

Okay, once you have RStudio going, you can get me installed using the "Console" that you should see. The "Console," where you can type commands, has a ">" character right next to it. Click there, so you can see your cursor, and copy and paste this code line by line, hitting enter. You should not get any errors. If you do, just email Rick.

```r
install.packages('RCurl')
install.packages('htm2txt')
source('https://raw.githubusercontent.com/racdale/neuroechobot/master/esn_functions.R')
```

That's it! On to step 3.

## Step 3: Test me out

You're ready to go. Enter the following code. This line of code is everything you need to have an initial conversation with me. Remember I am simple. Sometimes, I may even generate gibberish. 

```r
esn = train_and_talk(input_url='https://co-mind.org/bot-maker/ai.txt',neurons=500,turns=10)
```

This code gives me 500 neurons and trains me on some input text on the internet. It creates an interaction of 10 turns. You can change these if you want. Give this one a try. Note that my training is based on the URL you supply. You can use your own URL and train me differently, though warning I can get confused easily. Feel free to play with my input. The link I give you above trains me on basic interaction and questions.

After you have had a 10-turn conversation with me, let's try giving me even fewer neurons. Here:

```r
esn = train_and_talk(input_url='https://co-mind.org/bot-maker/ai.txt',neurons=50,turns=10)
```

How do I do? Let us go in the other direction:

```r
esn = train_and_talk(input_url='https://co-mind.org/bot-maker/ai.txt',neurons=1000,turns=10)
```

Make note of these conversations and return to CCLE and respond to the questions asked.



