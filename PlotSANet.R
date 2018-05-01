#Generates plots of the SocArXiv Network as of April 20th, 2018
#Author: Christopher Steven Marcum <cmarcum@uci.edu>
#Last Modified: 1 May 2018
library(sna)
library(network)
load("socarxiv.Rdata")

socarxiv<-delete.vertices(socarxiv,isolates(socarxiv))

sa.comps<-list()
nc<-components(socarxiv)
sa.cd<-component.dist(socarxiv)
socarxiv%v%"color"<-rainbow(nc)[sa.cd$membership]

for(i in 1:nc){
 sa.comps[[i]]<-get.inducedSubgraph(socarxiv,v=which(sa.cd$membership%in%i))
}

sa.csa<-sa.comps[order(sapply(sa.comps,network.size),decreasing=TRUE)]

set.seed(29917)
png("SANet.png",width=1200,height=1000,pointsize=12)
par(mar=c(1.75,1.75,1.75,1.75),xpd=TRUE)

gplot(socarxiv,usearrows=FALSE,vertex.col=socarxiv%v%"color",main="\n SocArXiv Co-Authorship Network \n As of April 20th, 2018",edge.col=rgb(0,0,0,alpha=.3))

dev.off()

library(animation)
set.seed(1518)
saveGIF(
for(i in 1:10){
par(xpd=TRUE)
gplot(sa.csa[[i]],vertex.col=sa.csa[[i]]%v%"color",usearrows=FALSE,displaylabels=TRUE,edge.col="gray",edge.lwd=sa.csa[[i]]%e%"numcollab",vertex.cex=sqrt(sa.csa[[i]]%v%"contribs"),main=paste("Component ",i))
}, movie.name="SA10Com.gif",interval=6,ani.width=980,ani.height=720)
