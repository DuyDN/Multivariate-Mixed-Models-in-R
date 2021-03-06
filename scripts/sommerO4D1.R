rm(list=ls())
setwd("C:\\Users\\joegbr\\Dropbox\\MMM_methods_paper\\wiki\\datafile") #set your working directory
require(sommer)
require(ape)
load("MMM_wiki_data.RData")
## example based on data from supplement of
# Adams, D. C., 2008. Phylogenetic meta-analysis. Evolution 62: 567�572.
# stored in objects "Adams.data" and "phylo.nexus.adams" where last one phylogenetic tree in ape format
# The original data by Adams needs to be standardised to a Z score
Adams.data$Z=0.5*log((1+Adams.data$corr)/(1-Adams.data$corr))
#In a phylogenetic context the equivalent matrix to the A matrix in animal models is equal in dimension to the number of species at the tips of the phylogeny. 
#In this case the elements Aij are equal to the length of the path from the most recent common ancestor of species i and j to the root of the phylogeny. 
#Generally, the length of the path from the tips to the root of the phylogeny is scaled to unity so that the matrix is the correlation matrix with all the diagonal elements being 1.
#
#we scale the ultrametric tree so the maximum length is 1 (Adams uses 100)
phylo.nexus.adams2<-phylo.nexus.adams
phylo.nexus.adams2$edge.length<-phylo.nexus.adams2$edge.length/100
plot(phylo.nexus.adams2)
axisPhylo()
# we use a function from the ape package to calculate the distance of the node of common ancestor of two tips to the root
A.phylo<- 1-(cophenetic(phylo.nexus.adams2)/2)
# sommer (mmer2) has not the capacity for weights and hence not for meta-analysis
# sommer can fit the basic phylogenetic model specified by 
# Lynch, M., 1991. Methods for the analysis of comparative data in evolutionary biology. Evolution 45: 1065�1080. 
# Pagel, M., 1999. Inferring the historical patterns of biological evolution. Nature 401: 877�884.
# which is model 7 (m7) in the overview of
#HADFIELD, J. D. and NAKAGAWA, S. (2010), General quantitative genetic methods for comparative biology: phylogenies, taxonomies and multi-trait models for continuous and categorical characters. 
# Journal of Evolutionary Biology, 23: 494�508. 
# see this last publication for more details
m7<-mmer2(Z~1, random=~g(tips), G=list(tips=A.phylo), data=Adams.data) 
summary(m7)
#proportion of variance which is between-species variance
pin(m7, propV.spec~V1/(V1+V2)) 
#multivariate
# random variable Z2 to get a second response variable
# generated by running: Adams.data$Z2<-rnorm(nrow(Adams.data),sd=2) (a number of times to get reasonable findings)
# MMM
m7.biv<-mmer2(cbind(Z,Z2)~1, random=~us(trait):g(tips), G=list(tips=A.phylo), rcov = ~ us(trait):units, data=Adams.data) 
summary(m7.biv)
#between-species correlation 
#==================================================
#Variance-Covariance components:
#               VarComp VarCompSE  Zratio
#g(tips).Z-Z    0.29017    0.2417  1.2003
#g(tips).Z-Z2   0.04198    0.2992  0.1403
#g(tips).Z2-Z2  0.08891    0.6570  0.1353
#units.Z-Z      0.41555    0.1347  3.0861
#units.Z-Z2    -0.18019    0.2618 -0.6882
#units.Z2-Z2    3.85209    0.9923  3.8821
#==================================================
#proportion of all variance between species
pin(m7.biv, propV.spec.Z1~V1/(V1+V4))
pin(m7.biv, propV.spec.Z2~V3/(V3+V6))
#correlation on different levels:
#between species
pin(m7.biv, corr.spec.Z1.Z2~V2/sqrt(V1*V3))
#within species 
pin(m7.biv, corr.res.Z1.Z2~V5/sqrt(V4*V6))
#overall (phenotypic)
pin(m7.biv, corr.pheno.Z1.Z2~(V2+V5)/sqrt((V1+V4)*(V3+V6)))




#save(list=c("Adams.data", "df.z", "gryphondata", "gryphonped", "phylo.nexus.adams"), file="MMM_wiki_data.RData")
