#
# neuroechobot, core functions
# summary: various functions to implement an echo state network that handles text and convo
# author: Rick Dale (rdale@ucla.edu), Department of Communication, UCLA
# version: early beta 0.011
# 

train_and_return_esn_convo = function(convo,esn.name,codes=NULL,p) {
  
  l = length(codes)+1 # note we add 1 for "quiet"...
  convo.chars = data_frame(line=1:nrow(convo),txt=convo$content) %>% 
    unnest_tokens(character,txt,token='characters',strip_non_alphanum = F)
  me.ixes = which(convo$char_name==esn.name)
  input.chars = unlist(lapply(convo.chars$character,function(x){return(which(codes==x))}))
  output.chars = (convo.chars$line %in% ixes) * input.chars
  output.chars[output.chars==0] = l
  
  dataIn = matrix(0,nrow=length(input.chars),ncol=l)
  set.ixes = ((0:(nrow(dataIn)-1))*l)+input.chars
  dataIn = t(dataIn)
  dataIn[set.ixes] = 1
  dataIn = t(dataIn)
  dataIn[!(convo.chars$line %in% me.ixes),107] = 1
  dataOut = dataIn
  
  
  dataOut[!(convo.chars$line %in% me.ixes),] = 0
  dataOut[!(convo.chars$line %in% me.ixes),107] = 1
  dataOut = dataOut[2:nrow(dataOut),]
  dataIn = dataIn[1:(nrow(dataIn)-1),]
  
  stop.ix = which(codes=='.')
  
  esn = build_esn(sz=p$res_sz,in_size=l,fac=p$fac,input.bias=0.8,working.memory=.0,seed=p$seed)
  info = run_esn(esn,iterations=nrow(dataIn),inputs=dataIn,passInputToHistory=F,print.iteration=F,stop.ix=stop.ix)
  esn$out = train_esn_readout(info$history,rbind(dataOut))
  esn$history = c()
  return(esn)
  
}

take_turn = function(esn,codes,stop.ix,in.text=NULL) {
  #if (is.null(in.text)) {
  #  in.text = readline(prompt="Start the convo... using a-z and .: ")
  #}
  all = make_text_input(in.text,uniqChar=codes)
  esn$iterate = iterate_esn(esn,iterations = 100,
                            passInputToHistory = F,luce = Inf,initial.inputs = all$data,noise=0,stop.ix=stop.ix)
  out_indices = apply(esn$iterate$readouts[(nrow(all$data)+1):nrow(esn$iterate$history),],1,which.max)
  where.stop = which(out_indices==stop.ix)[1]
  if (!is.na(where.stop)) {
    out_str = paste0(codes[out_indices[1:(where.stop+0)]],collapse='')
  } else {
    out_str = paste0(codes[out_indices],collapse='')
  }
  return(list(out_str=out_str,X=esn$iterate$reservoir_states))
}

chooser = function(O,luce=NULL) {
  if (is.null(luce)) {
    O = O
  } else if (luce==Inf) { # ******* Q: streamline this... how should we use Luce? Inf or set to 1 or 0.9, etc.?
    ix = which.max(O) # for symbolic output
    O = 0*O
    O[ix] = 1
  } else {
    ix = which.max(O) # for symbolic output
    O = O^luce
    O = O/sum(O) # let's normalize at each pass...
  }    
  return(O)
}

iterate_esn = function(esn,iterations=1000,type='ols',passInputToHistory=F,withFeedback=0,luce=NULL,noise=0,initial.inputs=NULL,stop.ix=NULL) {
  
  n.O = nrow(esn$out$readout_weights)
  reservoir_states = esn$reservoir_states 
  input_weights = esn$input_weights
  reservoir_weights = esn$reservoir_weights
  working.memory = esn$working.memory
  if (passInputToHistory) {
    # most of this matches the above under "run_esn"... so check that out for comments
    history = matrix(0,nrow=iterations,ncol=length(reservoir_states)+n.O)    
  } else {
    history = matrix(0,nrow=iterations,ncol=length(reservoir_states))
  }
  if (is.null(initial.inputs)) {
    O = rep(0,n.O) # O is the generated output, here we initialize it
  }
  else {
    O = initial.inputs[1,]
  }
  Oh = 0
  readouts = matrix(0,nrow=iterations,ncol=n.O) # initialize the readout set
  predictions = matrix(0,nrow=iterations,ncol=n.O) # initialize the readout set
  input.bias = esn$input.bias
  for (t in 1:iterations){
    ###################################################### update reservoir
    u = matrix(c(1,O),ncol=1)
    if (!is.null(stop.ix)) {
      if (which(O==1)[1]==stop.ix) {
        reservoir_states = reservoir_states*.1+rnorm(length(reservoir_states))*0.01
      }
    }
    reservoir_states = (1-input.bias)*reservoir_states + input.bias*tanh( input_weights %*% u + reservoir_weights %*% reservoir_states )
    reservoir_states = reservoir_states+noise*rnorm(length(reservoir_states))
    #reservoir_states = (1-input.bias)*reservoir_states + input.bias*tanh(input_weights %*% u + reservoir_weights %*% reservoir_states)
    ###################################################### generate and save output reservoir
    
    # collect reservoir activations
    if (passInputToHistory) {
      Oh = O + working.memory*Oh
      history[t,] = c(reservoir_states,Oh)
    } else {
      history[t,] = reservoir_states
    }
    
    if (passInputToHistory) {
      O = c(reservoir_states,O) %*% t(esn$out$readout_weights) # if we need input, then use it to generate output  
    } else {
      O = c(reservoir_states) %*% t(esn$out$readout_weights)  
    }
    
    predictions[t,] = O
    # collect outputs from model
    readouts[t,] = chooser(O,luce=luce)
    
    # allow multiple rows of input...
    if (nrow(initial.inputs)>t) {
      O = initial.inputs[t+1,]
    } else {
      O = chooser(O,luce=luce)
    }
    
  }
  return(list(history=history,readouts=readouts,reservoir_states=reservoir_states,predictions=predictions))  
}


train_esn_readout = function(history,targets) {
  reg = 1e-8  # regularization coefficient
  Wout = t(targets) %*% history %*% solve( t(history) %*% history + reg*diag(ncol(history)) )
  preds = history %*% t(Wout)
  perf = mean(max.col(targets)==max.col(preds))
  return(list(readout_weights=Wout,performance=perf,predictions=preds))
}

run_esn = function(esn,iterations=1000,inputs=c(),passInputToHistory=F,print.iteration=F,stop.ix=NULL) {
  reservoir_states = esn$reservoir_states
  input_weights = esn$input_weights
  reservoir_weights = esn$reservoir_weights
  working.memory = esn$working.memory
  if (passInputToHistory) { # initialize history according to size needed
    history = matrix(0,nrow=iterations,ncol=length(c(reservoir_states,inputs[1,])))    
  } else {
    history = matrix(0,nrow=iterations,ncol=length(reservoir_states))
  }
  Oh = 0
  for (t in 1:iterations){
    if (print.iteration) { print(t) }
    if (length(inputs)>0) {
      ix = t %% nrow(inputs) # loop through inputs if # inputs < # iterations
      if (ix==0) { ix = nrow(inputs) } # if we're at exactly the final iteration, make sure we get the last
      # print(ix) # let's make sure we're getting the input correctly...
      u = matrix(c(1,inputs[ix,]),ncol=1) # give it the "1" burst for: we're running!
      if (!is.null(stop.ix)) {
        if (which(inputs[ix,]==1)[1]==stop.ix) {
          reservoir_states = reservoir_states*0.1
        }
      }
    } else {
      u = matrix(c(1,rep(0,ncol(internal_weights)-1)),ncol=1) # no input? let's give it the bias input marking "running"
    }
    input.bias = esn$input.bias # run the first reservoir layer
    reservoir_states = (1-input.bias)*reservoir_states + input.bias*tanh(input_weights %*% u + reservoir_weights %*% reservoir_states)
    # collect reservoir activations
    if (passInputToHistory) {
      Oh = inputs[ix,]+working.memory*Oh
      history[t,] = c(unlist(reservoir_states),Oh) # save input as part of history, if requested
    } else {
      history[t,] = unlist(reservoir_states) 
    }
  }
  esn$reservoir_states = reservoir_states
  return(list(history=history,esn=esn))
}

build_esn = function(sz=100,in_size=25,fac=1.25,input.bias=0.6,connectivity='random',working.memory=0,seed=42) {
  #print(paste('setting seed',seed))
  set.seed(seed)
  Win = make_weight_matrix(1+in_size,sz,connectivity='random') # input should be random, since small world is square
  W = make_weight_matrix(sz,sz,connectivity=connectivity) # reservoir recurrent connections
  rhoW = abs(eigen(W,only.values=TRUE)$values[1]) # singular values of echo state W
  W = W * fac / rhoW # set spectral radius, related to ES property (Jaeger, 2007; see notes in Lukosevicius & Jaeger, 2009)
  return(list(reservoir_states = matrix(rep(0,sz),ncol=1), input_weights = Win, reservoir_weights = W, input.bias=input.bias,working.memory=working.memory))
}

make_weight_matrix = function(x,y,connectivity='random') {
  if (connectivity=='random') {
    weight_matrix = matrix(runif(y*x,-0.5,0.5),y)  #### ******** Q WHY IS ROW / COL REVERSED??????
  } else if (connectivity=='small-world') { # NB: small world only for reservoir-to-self weights 
    require(igraph)
    g = watts.strogatz.game(1, size=x, nei=round(log(x)), p=.1) 
    weight_matrix = (matrix(get.adjacency(g),x)) * matrix(runif(y*x,-0.5,0.5),x)
  } else if (connectivity=='normal') {
    weight_matrix = matrix(rnorm(y*x),y) 
  }
  return(weight_matrix)
}

