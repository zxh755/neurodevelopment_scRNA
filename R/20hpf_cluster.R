library("Matrix")
library("Seurat")
library(tidyverse)
library(dplyr)
library(cowplot)

setwd("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/data")
sample <- readRDS("hpf20_combined_normalised.rds")

#------------------------------------———FIND VARIABLE GENES—————————————————————---------------------------- 
sample <- FindVariableFeatures(object = sample, mean.function = ExpMean, dispersion.function = LogVMR)
head(x = HVFInfo(object = sample))

#------------------------------------———SCALE DATA—————————————————————---------------------------- 
sample <- ScaleData(object = sample, vars.to.regress = c("nCount_RNA", "percent.mito")) 

#------------------------------------———DIMENSIONAL REDUCTION—————————————————————---------------------------- 
sample <- RunPCA(object = sample,  npcs = 30, verbose = FALSE)

#------------------------------------———PLOTS—————————————————————---------------------------- 
pdf("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/plots/20hpf/post-normalisation/20hpf_hmgn2_dimplot.pdf")
FeaturePlot(object = sample, features = "hmgn2")
dev.off()

pdf("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/plots/20hpf/post-normalisation/20hpf_variable_feature_plot.pdf")
VariableFeaturePlot(object = sample)
dev.off()

pdf("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/plots/20hpf/post-normalisation/20hpf_heat_map.pdf")
DimHeatmap(object = sample, reduction = "pca", cells = 200, balanced = TRUE)
dev.off()

#------------------------------------———DETERMINE STATISTICALLY SIGNIFICANT GENES—————————————————————---------------------------- 
sample <- JackStraw(object = sample, reduction = "pca", dims = 20, num.replicate = 100,  prop.freq = 0.1, verbose = FALSE)
sample <- ScoreJackStraw(object = sample, dims = 1:20, reduction = "pca")

pdf("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/plots/20hpf/post-normalisation/20hpf_jack_straw_plot.pdf")
JackStrawPlot(object = sample, dims = 1:20, reduction = "pca", xmax = 0.0025)
dev.off()

pdf("/rds/projects/v/vianaj-development-rna/Zarnaz/neurodevelopment_scRNA/plots/20hpf/post-normalisation/20hpf_elbow_plot.pdf")
ElbowPlot(object = sample)
dev.off()

#------------------------------------———CLUSTER CELLS—————————————————————---------------------------- 
# find k-nearest neighbours
sample <- FindNeighbors(sample, reduction = "pca", dims = 1:20)

# cluster cells
sample <- FindClusters(sample, resolution = 0.5, algorithm = 1)

# save as .rds file
saveRDS(sample, file = "hpf20.cluster.rds")