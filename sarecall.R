#Non-End user code for recalling rate-limited / throttled / error-out api GETs
#Author: Christopher Steven Marcum <cmarcum@uci.edu>
#Last Modified: 1 May 2018

library(jsonlite)
library(RCurl)

if(0){
#load("socarxiv.WedApr182115582018.Rdata")
load("socarxiv.WedApr.Rdata")

recall<-which(unlist(lapply(socarxiv.WedApr182115582018[[2]], function(x) length(x[[2]]$errors)))>0)

for(i in recall){
 t0<-Sys.time()
 print(i)
# if(!auth){datlist[[i]]<-try(fromJSON(getURL(ccalls[[i]])))}
# if(auth){datlist[[i]]<-try(fromJSON(system(ccalls[[i]],intern=TRUE)))}
 #Give the server a ten second break between calls
 Sys.sleep(10)
 contlist<-try(datlist[[i]]$data$relationships$contributors$links$related$href)
 autlist[[i]]<-try(sapply(contlist,function(x) try(fromJSON(getURL(x)))))
 #progressively save each 
 now<-gsub(" |:","",date())
# save.image(paste("socarxiv",now,"Rdata",sep="."))
 t1<-Sys.time()
 print(difftime(t1,t0)*(max(pages)-(i+1)))
}

assign(paste("socarxiv",now,sep="."),list(data=datlist,authors=autlist))
save.image(paste("socarxiv",now,"Rdata",sep="."))

q("no")
}

#A few more throttled
load("socarxiv.ThuApr191348592018.Rdata")
recall2<-gsub(".errors.detail","",names(unlist(autlist)[grep("errors",names(unlist(autlist)))]))
