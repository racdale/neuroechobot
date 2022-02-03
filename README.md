# NeuroEchoBot

## Update (1/25/2022)

The main approach to using NeuroEchoBot is presented below, and please note that you have to install R and RStudio first. This requires you to download R (a programming language) then RStudio (a nice interface for using it). It is completely free and mostly point-and-click design -- we'll just try our hand at a few simple lines of code.

Anyway, after first setting up NeuroEchoBot, I then expanded the options you have to play with NeuroEchoBot. Here are some examples. They permit you to change how chaotic NeuroEchoBot is, how much training you give it, etc. This little preamble is for those who wish to do a bit more after the main exercise (see below).

```r
esn = train_and_talk(training_url='YOUR_URL',neurons=500,turns=3,randomizer=123,maximum_text_length=1250,chaos_factor=1.25,pretrain=TRUE)
```

This line takes your `training_url` (text you feed NeuroEchoBot) and trains it using 500 `neurons` (in its "brain"), and initializes a 3-turn conversation (`turns`). The training is restricted to only 1250 characters (`maximum_text_length`), and pretrains NeuroEchoBot with some greetings material in English (set this to `FALSE` to turn it off). The `chaos_factor` factor determines how chaotic NeuroEchoBot's brain behaves. The number 1.0 is the standard value. Anything below this (e.g., 0.5) will be very regular and unchaotic; anything above one (e.g., 1.25 above) will force NeuroEchoBot to be more chaotic. Feel free to play around with this new version!

## Main Lab #2 Exercise:

NeuroEchoBot is designed to illustrate some basic ideas about neural network structure, training, and performance in the domain of interpersonal language and communication. It is currently being used for COMM 131 at UCLA, a class on computer models of communicators, like chatbots and so on.

It should be noted that the name of this system is apt. It is a very simple neural network bot that mostly echoes back common aspects of its training. However it is able to engage in elementary turn-taking, and you can train it and re-train it under different conditions to see what makes it work best.

If you are a COMM 131 student, please make sure to consult the Bruin Learn instructions, as they detail how to submit your exercise. If you wish to continue, our goals will be the following:

* Install R and RStudio programming environment so you can set NeuroEchoBot up
* Install some libraries and Rick's code that will implement NeuroEchoBot on your computer
* Test NeuroEchoBot under one configuration: 250 neurons
* Retrain NeuroEchoBot with different network sizes
* Investigate its limitations, and link these to our discussion of neural networks in class

So if you're still interested, let's go.

## Step 1: Install R and RStudio

This part is the easiest. Go to this website and follow the instructions for your own system (Windows, etc.). Note that you have to install two things. First, install R, which is the core programming system we'll be using. Then, install RStudio, which is a very elegant user interface with point-and-click menu items to work with code in R.

[https://cran.rstudio.com/](https://cran.rstudio.com/)

[https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/#download)

Once you have this done, you should be able to open RStudio on your computer and see an interface with several different windows. If you want to get a quick tour of RStudio, consult the short videos at the ["How to R" Youtube channel](https://www.youtube.com/channel/UCAeWj0GhZ94wuvOIYu1XVrg). You probably won't need 'em. Let's keep going.

## Step 2: Install some libraries you'll need

Okay, once you have RStudio going, you can get NeuroEchoBot installed using the "Console" window that should be present. The "Console," where you can type commands, has a ">" character right next to it. Click there, so you can see your cursor, and copy and paste this code line by line, hitting enter after each. You should not get any errors. If you have problems, email Rick.

```r
install.packages('RCurl')
install.packages('htm2txt')
install.packages('igraph')
source('https://raw.githubusercontent.com/racdale/neuroechobot/master/esn_functions.R')
```

That's it! Onward to step 3.

## Step 3: Test NeuroEchoBot out

You're ready to go. Enter the following code. This line of code is everything you need to have an initial conversation with NeuroEchoBot. Remember it is simple. Sometimes, it may even generate gibberish. (*Be warned: When it produces unstructured output, because perhaps it hasn't learned enough or well enough, sometimes recognizable words may appear, but these are just "random." If anything surprising or weird pops out, it is random and not intended by the system. Because it's random, it could appear silly or even profane, but it is unlikely. This is an important note so you are aware of the "stochasticity" of NeuroEchoBot, an intrinsic feature of this neural network setup. If you have concerns about this randomness, reminder that it is not required to choose this lab for the class.*) 

```r
esn = train_and_talk(training_url='https://co-mind.org/bot-maker/ai.txt',neurons=250,turns=10)
```

This code gives NeuroEchoBot 250 neurons and trains it on some text from the internet. It creates an interaction of 10 turns. You can change these later if you want. Give this one a try. Note that NeuroEchoBot's training is based on the URL you supply. You can use your own URL and train it differently, though warning NeuroEchoBot can get confused easily. After the exercise, feel free to investigate variations on its input (other websites, etc.). Anyway, the URL above (ai.txt) trains the network on basic interaction and questions.

After you have had a 10-turn conversation with NeuroEchoBot, here's something fun. When NeuroEchoBot is trained, it automatically adjusts its connections to learn character-by-character in text data (here, a URL). This is how it learns to take turns and converse with you. Wanna see all of these connections? A simple little function:

```r
visualize_neuroechobot(esn)
```

Here we are. You can see input, output, and the tendrils of connectivity across the artificial "neurons" that make up NeuroEchoBot's "brain."" These connections have been updated during its training, where it learned the text you exposed it to (as best as it could under its brain size).

Now let's try giving me even fewer neurons. Here:

```r
esn = train_and_talk(training_url='https://co-mind.org/bot-maker/ai.txt',neurons=50,turns=10)
```

How do I do? Let us go in the other direction:

```r
esn = train_and_talk(training_url='https://co-mind.org/bot-maker/ai.txt',neurons=500,turns=10)
```

Hm. Does NeuroEchoBot output a lot of noise and randomness? Here's a tip. You can "randomize" NeuroEchoBot each time you try it, to see if you can "shuffle" its connections when it is initialized. Fun fact about neural networks: Their learning can be impacted by how you set them up. Their "initial brain" is at first all random, and by chance it may be more difficult to train it depending on these initial conditions. You can try the randomizer like this, and just change the numbers to shuffle it differently. Here I'm using "1423," but you can use a different number. (Note: This number is called a "seed" and its value is meaningless -- it just stands for a distinct reshuffling of the brain... so 1 and 100 and 1000 are all just different shufflings; the exact value of the randomizer is not informative.)

```r
esn = train_and_talk(training_url='https://co-mind.org/bot-maker/ai.txt',neurons=500,turns=10,randomizer=1423)
```

Make note of these conversations and return to Bruin Learn and respond to the questions asked.

**Optional reading**

I have published a kind of primer for the type of neural network we're working with here. I share this in case you are interested in its inner-workings.

Dale, R. & Kello, C. T. (2018). "How do humans make sense?" Multiscale dynamics and emergent meaning. *New Ideas in Psychology*, *50*, 61-72. [PDF](https://co-mind.org/rdmaterials/php.cv/pdfs/article/dale_kello_newideas.pdf)




