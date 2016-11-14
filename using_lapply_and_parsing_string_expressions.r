#using lapply
gt<-function(x){x>500} 
lapply(5,gt)

#using lapply and creating function using string expression
cond="x>500"
gt2<-function(x){eval(parse(text=a))}
lapply(500,gt2)