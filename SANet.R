#Collect network data from structured api scrapes using non-JSON compliant methods
#Author: Christopher Steven Marcum <cmarcum@uci.edu>
#Last Modified: 1 May 2018
#Current data:

load("socarxiv.FriApr201457482018.Rdata")

#Check for errors
length(unlist(autlist)[grep("errors",names(unlist(autlist)))]) #Should be 255, all which have been remedied by autlist2
#autlist 2 were called a second time due to time-out, dns, or other errors in first calls
length(unlist(autlist2)[grep("errors",names(unlist(autlist2)))]) #Should be 6, which are all deleted papers

#Combine autlist and autlist 2
autlist<-c(autlist,autlist2)

#First, build contributor list:
#total:

auth.inc<-unlist(lapply(autlist,function(x) unlist(x)[grep("full_name",names(unlist(x)))]))
trail.aut<-unlist(lapply(strsplit(names(auth.inc),"full_name"),function(x) x[[length(x)]]))
trail.aut[grep("embeds",trail.aut)]<-"e"

#Next some attributes. It appears that some of these attributes are missing on only one contributor.
#author id
auth.id<-unlist(autlist)[grep("relationships.users.data.id",names(unlist(autlist)))]

#Find whom is the missing contrib:
auth.loc<-unlist(autlist)[grep("locale",names(unlist(autlist)))]
trail.loc<-unlist(lapply(strsplit(names(auth.loc),"locale"),function(x) x[[length(x)]]))
trail.loc[grep("embeds",trail.loc)]<-"e"

bout<-which(trail.aut!=trail.loc)[1]
auth.inc[bout]

#Here's the correction
trail.loc<-c(trail.loc[1:(bout-1)],NA,trail.loc[bout:length(trail.loc)])
auth.loc<-c(auth.loc[1:(bout-1)],NA,auth.loc[bout:length(auth.loc)])
auth.tz<-unlist(autlist)[grep("timezone",names(unlist(autlist)))]
auth.tz<-c(auth.tz[1:(bout-1)],NA,auth.tz[bout:length(auth.tz)])

#Twitter names
twitter<-unique(unlist(autlist)[grep("twitter",names(unlist(autlist)))])

#Uattribs
uattribs<-unlist(autlist)[grep("data.embeds.users.data.attributes",names(unlist(autlist)))]
longforms<-uattribs[grep("http",names(uattribs))]
names(longforms)<-unlist(lapply(strsplit(names(longforms),"contributors/."),function(x) x[[2]]))
names(uattribs)[grep("http",names(uattribs))]<-names(longforms)
rm(longforms)

AllAttribs<-by(uattribs,names(uattribs),unique)

TimeZone<-paste(as.character(unlist(by(auth.loc,auth.inc,unique))),as.character(unlist(by(auth.tz,auth.inc,unique))),sep="-")

#The "4" term reflects that trailing fencepost repetition
repmat<-cbind(which(trail.aut=="1"),c(diff(which(trail.aut=="1")),4))
repvec<-vector("list",length=nrow(repmat))

for(i in 1:nrow(repmat)){
 repvec[[i]]<-rep(i,repmat[i,2])
}

repvec<-unlist(repvec)
length(repvec)==length(trail.aut)

repvec[which(trail.aut=="e")]<-NA

#Some descriptives
#Dist. of multi-authorship counts
table(table(repvec))

#No. unique
length(unique(auth.inc))

#Per-author incidence
table(auth.inc)

#Generate network
auth.levs<-by(auth.inc,repvec,unique)

outmat<-matrix(0,nrow=length(unique(auth.inc)),ncol=length(unique(auth.inc)),dimnames=list(sort(unique(auth.inc)),sort(unique(auth.inc))))

for(i in 1:length(auth.levs)){
outmat[auth.levs[[i]],auth.levs[[i]]]<-outmat[auth.levs[[i]],auth.levs[[i]]]+1
}

library(sna)
library(network)
socarxiv<-network(outmat,directed=FALSE)
socarxiv%v%"contribs"<-diag(outmat)
socarxiv%e%"numcollab"<-outmat
socarxiv%v%"locale"<-c(unlist(by(auth.tz,auth.inc,function(x) as.character(x)[1])))
socarxiv%v%"uid"<-c(unlist(by(auth.id,auth.inc,function(x) as.character(x)[1])))

#Nearest authname to twitter handle (within depth of k)
#Could be vectorized instead of a loop, but meh.
twit.locs<-c(grep("twitter",names(unlist(autlist))))
nv<-"full_name"
k<-11
olist<-list()
for(i in 1:length(twit.locs)){
 twit.locs2<-c(twit.locs[i]:(twit.locs[i]-k))
 olist[[i]]<-unlist(autlist)[twit.locs2][grep(nv,names(unlist(autlist)[twit.locs2]))][[1]]
}

nntw<-cbind(unlist(autlist)[twit.locs],unlist(olist))
rownames(nntw)<-NULL
nntw<-nntw[order(nntw[,1]),]

#This gets written out, hand coded and read back in
#note that it's possible (and easier, actually) 
# to simply call the auth information
# from the API for this information. Meh.
#write.csv(nntw,file="nntw.csv",row.names=FALSE)
nntw<-read.csv("nntw.csv",colClasses="character")
#Encoding for eddiermartinez and richardohrvall is awry:
nntw$V2[which(nntw$V1=="eddiermartinez")]<-c(socarxiv%v%"vertex.names")[grep("Eddier",c(socarxiv%v%"vertex.names"))]
nntw$V2[which(nntw$V1=="richardohrvall")]<-c(socarxiv%v%"vertex.names")[grep("Richard Ã",c(socarxiv%v%"vertex.names"))]

#Are the on twitter?
socarxiv%v%"twitter"<-socarxiv%v%"vertex.names"%in%nntw[,2]
#Twitter handle
socarxiv%v%"twhandle"<-nntw[match(socarxiv%v%"vertex.names",nntw[,2]),1]

#write out file
save(socarxiv,file="socarxiv.Rdata",compress="xz")


