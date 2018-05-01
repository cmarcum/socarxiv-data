######################################################
##Extract SocArXiv data from osf api
##Author: Christopher Steven Marcum <cmarcum@uci.edu>
##Date: 16 April 2018
##Last Modified: 18 April 2018
######################################################

library(jsonlite)
library(RCurl)

#Flag to use authenticated session. You need an API auth token from OSF
# to use this method stored in a file in the pwd called key.txt
auth<-1

#As of 16 April 2018 there are 219 pages (newest first, so if updating, just find the latest paper
# in current stack and back track from there)
pages<-1:219

#If unauthenticated:
if(!auth){
ccalls<-sapply(pages, function(x) paste("https://api.osf.io/v2/preprint_providers/socarxiv/preprints/?page=",x,sep=""))}

#If authenticated
if(auth){
key<-readLines("key.txt")[[1]]
ccalls<-paste("curl -X \"GET\" \"https://api.osf.io/v2/preprint_providers/socarxiv/preprints/?page=",pages,"\" -H \"Authorization: Bearer ",key,"\" ",sep="")
}

datlist<-vector("list",length=length(pages))
autlist<-vector("list",length=length(pages))
for(i in pages){
 t0<-Sys.time()
 print(i)
 if(!auth){datlist[[i]]<-try(fromJSON(getURL(ccalls[[i]])))}
 if(auth){datlist[[i]]<-try(fromJSON(system(ccalls[[i]],intern=TRUE)))}
 #Give the server a ten second break between calls
 Sys.sleep(10)
 contlist<-try(datlist[[i]]$data$relationships$contributors$links$related$href)
 autlist[[i]]<-try(sapply(contlist,function(x) try(fromJSON(getURL(x)))))
 #progressively save each in case of error
 now<-gsub(" |:","",date())
 save.image(paste("socarxiv",now,"Rdata",sep="."))
 t1<-Sys.time()
 print(difftime(t1,t0)*(max(pages)-(i+1)))
}

rm(key,ccalls)

assign(paste("socarxiv",now,sep="."),list(data=datlist,authors=autlist))
save.image(paste("socarxiv",now,"Rdata",sep="."))

