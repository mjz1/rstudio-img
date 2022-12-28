#!/bin/bash

# This file was created by copying the text box on this site: https://packagemanager.rstudio.com/client/#/repos/2/overview
# After specifying ubuntu v22
# Then used vscode to remove all duplicate lines

# rriskDistributions requirements:
apt-get install -y tcl
apt-get install -y tk
apt-get install -y tk-dev
apt-get install -y tk-table
# bdpopt requirements:
apt-get install -y jags
# gbp requirements:
apt-get install -y make
# dataframes2xls requirements:
apt-get install -y python3
# ezknitr requirements:
apt-get install -y pandoc
# caRpools requirements:
apt-get install -y bowtie2
# helloJavaWorld requirements:
apt-get install -y default-jdk
R CMD javareconf
# skm requirements:
# Deducer requirements:
# MDSGUI requirements:
apt-get install -y bwidget
# PortfolioEffectHFT requirements:
# simplexreg requirements:
apt-get install -y libgsl0-dev
# elexr requirements:
# Rdroolsjars requirements:
# BiBitR requirements:
# gcbd requirements:
apt-get install -y nvidia-cuda-dev
# sharx requirements:
# RKEA requirements:
# RNetLogo requirements:
# collUtils requirements:
# diskImageR requirements:
apt-get install -y imagej
# Plasmidprofiler requirements:
# PreKnitPostHTMLRender requirements:
# x.ent requirements:
apt-get install -y perl
# PortfolioEffectEstim requirements:
# dcmle requirements:
# PVAClone requirements:
# PhViD requirements:
# RcmdrPlugin.RMTCJags requirements:
# ABC.RAP requirements:
# cycleRtools requirements:
# RNCBIEUtilsLibs requirements:
# lightsout requirements:
# poisbinom requirements:
apt-get install -y libfftw3-dev
# subspace requirements:
# DALY requirements:
# tcltk2 requirements:
# openNLPdata requirements:
# slowraker requirements:
# specklestar requirements:
# rGroovy requirements:
# mutossGUI requirements:
# corehunter requirements:
# RH2 requirements:
# lira requirements:
# Rbgs requirements:
# RcppMeCab requirements:
# TAQMNGR requirements:
apt-get install -y zlib1g-dev
# ChoR requirements:
# rhli requirements:
# qualpalr requirements:
# GreedyExperimentalDesignJARs requirements:
# ADMMsigma requirements:
# rJPSGCS requirements:
# libstableR requirements:
# CommonJavaJars requirements:
# beanz requirements:
# readbitmap requirements:
apt-get install -y libjpeg-dev
apt-get install -y libpng-dev
# blandr requirements:
# pysd2r requirements:
# dclone requirements:
# ssMousetrack requirements:
# sequenza requirements:
# RPyGeo requirements:
# ruta requirements:
# Rglpk requirements:
apt-get install -y libglpk-dev
# dfpk requirements:
# r.blip requirements:
# NestedCategBayesImpute requirements:
# CPAT requirements:
# Scalelink requirements:
# PBSmodelling requirements:
# StMoSim requirements:
# rPref requirements:
# elliptic requirements:
apt-get install -y pari-gp
# untb requirements:
# represtools requirements:
# igate requirements:
# otsad requirements:
# visit requirements:
# LeafArea requirements:
# MixAll requirements:
# cloudml requirements:
# biplotbootGUI requirements:
# OpenStreetMap requirements:
# rCBA requirements:
# openNLP requirements:
# RWekajars requirements:
# RKEAjars requirements:
# nbconvertR requirements:
# YPPE requirements:
# optimalThreshold requirements:
# publipha requirements:
# rDEA requirements:
# conStruct requirements:
# scaffolder requirements:
# kza requirements:
# GRANBase requirements:
apt-get install -y git
# phase1PRMD requirements:
# matchingMarkets requirements:
# botor requirements:
# REPLesentR requirements:
# LCMCR requirements:
# rblt requirements:
apt-get install -y libhdf5-dev
# rpostgis requirements:
apt-get install -y libpq-dev
# MethComp requirements:
# JMbayes requirements:
# rapidjsonr requirements:
# NobBS requirements:
# pdSpecEst requirements:
# rsparkling requirements:
# dti requirements:
# spsurv requirements:
# oceanmap requirements:
apt-get install -y imagemagick
apt-get install -y libmagick++-dev
apt-get install -y gsfonts
# rscala requirements:
# moveVis requirements:
# gMCP requirements:
# conflr requirements:
# patternplot requirements:
# concaveman requirements:
apt-get install -y libgdal-dev
apt-get install -y gdal-bin
apt-get install -y libgeos-dev
apt-get install -y libproj-dev
# blastula requirements:
# glmulti requirements:
# DCPO requirements:
# bacistool requirements:
# BCHM requirements:
# pdfminer requirements:
# bellreg requirements:
# bigMap requirements:
# YPBP requirements:
# HydeNet requirements:
# glmmfields requirements:
# roll requirements:
# MUACz requirements:
# image.CannyEdges requirements:
# lcra requirements:
# microclass requirements:
# MaOEA requirements:
# IOHexperimenter requirements:
# bsam requirements:
# RODBC requirements:
apt-get install -y unixodbc-dev
# XML requirements:
apt-get install -y libxml2-dev
# arrangements requirements:
apt-get install -y libgmp3-dev
# rmdcev requirements:
# rjdmarkdown requirements:
# SAR requirements:
# rTorch requirements:
apt-get install -y pandoc-citeproc
# cbq requirements:
# MrSGUIDE requirements:
# trialr requirements:
# MixSIAR requirements:
# BeastJar requirements:
# milr requirements:
# colorizer requirements:
# sudachir requirements:
# xlsx requirements:
# varitas requirements:
# GWnnegPCA requirements:
# qCBA requirements:
# rstanemax requirements:
# rmdfiltr requirements:
# wordnet requirements:
# dynBiplotGUI requirements:
# motifr requirements:
# GetoptLong requirements:
# DataExplorer requirements:
# StanHeaders requirements:
# frequency requirements:
# adimpro requirements:
apt-get install -y dcraw
# RcppBigIntAlgos requirements:
# prettydoc requirements:
# staplr requirements:
# ECOSolveR requirements:
# extRatum requirements:
# feamiR requirements:
# idem requirements:
# Crossover requirements:
# survHE requirements:
# SymbolicDeterminants requirements:
# shinyloadtest requirements:
# metagear requirements:
# rkeops requirements:
apt-get install -y cmake
# CBSr requirements:
# tiler requirements:
# MIRES requirements:
# rsubgroup requirements:
# spatsoc requirements:
# RPushbullet requirements:
[ $(which google-chrome) ] || apt-get install -y gnupg curl
[ $(which google-chrome) ] || curl -fsSL -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
[ $(which google-chrome) ] || DEBIAN_FRONTEND='noninteractive' apt-get install -y /tmp/google-chrome.deb
rm -f /tmp/google-chrome.deb
# fftwtools requirements:
# forImage requirements:
# phonfieldwork requirements:
# ondisc requirements:
# rchallenge requirements:
# govdown requirements:
# pkgnews requirements:
# metaBMA requirements:
# exifr requirements:
# r2pmml requirements:
# plumberDeploy requirements:
apt-get install -y libssh2-1-dev
# drf requirements:
# prophet requirements:
# HierDpart requirements:
# ProcData requirements:
# sasfunclust requirements:
# modeltime.h2o requirements:
# bmggum requirements:
# rapport requirements:
# SIBER requirements:
# AWR requirements:
# pivmet requirements:
# juicr requirements:
# rzmq requirements:
apt-get install -y libzmq3-dev
# xslt requirements:
apt-get install -y libxslt-dev
# rviewgraph requirements:
# detrendr requirements:
# RKEEL requirements:
# h2o4gpu requirements:
# cit requirements:
# autocart requirements:
# GMKMcharlie requirements:
# rapidraker requirements:
# ip2location requirements:
# flan requirements:
# BivRec requirements:
# mbbefd requirements:
# nucim requirements:
apt-get install -y libcurl4-openssl-dev
apt-get install -y libtiff-dev
apt-get install -y libssl-dev
# diversitree requirements:
# rextendr requirements:
apt-get install -y rustc
apt-get install -y cargo
# bayesforecast requirements:
# jagsUI requirements:
# GGally requirements:
# tkRplotR requirements:
# textmineR requirements:
# jackalope requirements:
# sdmApp requirements:
# smam requirements:
# DA requirements:
# magickGUI requirements:
# rater requirements:
# bayesbr requirements:
# AovBay requirements:
# OpenCL requirements:
apt-get install -y ocl-icd-opencl-dev
# findInGit requirements:
# fRLR requirements:
# R2jags requirements:
# concatipede requirements:
# reportfactory requirements:
# websocket requirements:
# sentometrics requirements:
# magick requirements:
# ip2proxy requirements:
# bridger requirements:
apt-get install -y texlive
# ubiquity requirements:
# arulesNBMiner requirements:
# CNVRG requirements:
# fuzzywuzzyR requirements:
# nmslibR requirements:
# GeoMongo requirements:
# strawr requirements:
# MBNMAtime requirements:
# hsstan requirements:
# rmcfs requirements:
# nlrx requirements:
apt-get install -y libudunits2-dev
# DesignCTPB requirements:
# orderly requirements:
# lgpr requirements:
# pcFactorStan requirements:
# thurstonianIRT requirements:
# trackdem requirements:
apt-get install -y libimage-exiftool-perl
# Thermimage requirements:
# bayes4psy requirements:
# bayesdfa requirements:
# bmlm requirements:
# CoNI requirements:
# mrbayes requirements:
# TriDimRegression requirements:
# animation requirements:
# Rlibeemd requirements:
# coga requirements:
# VBLPCM requirements:
# switchboard requirements:
# dataMaid requirements:
# survSNP requirements:
# saotd requirements:
apt-get install -y libmpfr-dev
# textshaping requirements:
apt-get install -y libfreetype6-dev
apt-get install -y libfribidi-dev
apt-get install -y libharfbuzz-dev
# rminizinc requirements:
# slasso requirements:
# rpf requirements:
# CoordinateCleaner requirements:
# QF requirements:
# BrailleR requirements:
# BTSPAS requirements:
# rmatio requirements:
# bigGP requirements:
apt-get install -y libopenmpi-dev
# tsapp requirements:
# webp requirements:
apt-get install -y libwebp-dev
# gsl requirements:
# dataReporter requirements:
# BayesPostEst requirements:
# autoharp requirements:
# MapeBay requirements:
# RWeka requirements:
# Statsomat requirements:
# rcdd requirements:
# matrixprofiler requirements:
# GWpcor requirements:
# credentials requirements:
# odbc requirements:
# xml2 requirements:
# remotes requirements:
# EpiSignalDetection requirements:
# bcTSNE requirements:
# rkafkajars requirements:
# mailR requirements:
# anticlust requirements:
# fs requirements:
# SimJoint requirements:
# rJava requirements:
# gslnls requirements:
# bmgarch requirements:
# workflowr requirements:
# gfilogisreg requirements:
# eaf requirements:
# simplermarkdown requirements:
# cogmapr requirements:
# pcaL1 requirements:
apt-get install -y coinor-libclp-dev
# RcppParallel requirements:
# ymd requirements:
# JGR requirements:
# redux requirements:
apt-get install -y libhiredis-dev
# rbioacc requirements:
# PoissonMultinomial requirements:
# rcbayes requirements:
# N2R requirements:
# lamW requirements:
# redland requirements:
apt-get install -y librdf0-dev
# BayesGWQS requirements:
# HiClimR requirements:
apt-get install -y libnetcdf-dev
# rofanova requirements:
# MetaStan requirements:
# clustermq requirements:
# RAQSAPI requirements:
# tidysq requirements:
# tiff requirements:
# httpgd requirements:
apt-get install -y libcairo2-dev
apt-get install -y libfontconfig1-dev
# switchr requirements:
# fcirt requirements:
# PlanetNICFI requirements:
# svglite requirements:
# minidown requirements:
# bioacoustics requirements:
# rubias requirements:
# showtext requirements:
# zoid requirements:
# CytOpT requirements:
# monoreg requirements:
# systemfonts requirements:
# caracas requirements:
# altair requirements:
# bhmbasket requirements:
# gdtools requirements:
# footBayes requirements:
# eggCounts requirements:
# bfw requirements:
# easyNCDF requirements:
# SuperGauss requirements:
# WriteXLS requirements:
# iMRMC requirements:
# MBNMAdose requirements:
# fgitR requirements:
# psrwe requirements:
# saeHB.spatial requirements:
# conleyreg requirements:
# seewave requirements:
apt-get install -y libsndfile1-dev
# popbayes requirements:
# officedown requirements:
# fftw requirements:
# rbedrock requirements:
# jarbes requirements:
# jqr requirements:
apt-get install -y libjq-dev
# rTRNG requirements:
# sysfonts requirements:
# baggr requirements:
# vdiffr requirements:
# LOMAR requirements:
# git2r requirements:
apt-get install -y libgit2-dev
# venneuler requirements:
# IncDTW requirements:
# DNAtools requirements:
# bayesGAM requirements:
# pander requirements:
# KSgeneral requirements:
# jSDM requirements:
# tmbstan requirements:
# bistablehistory requirements:
# ggExtra requirements:
# loo requirements:
# isotracer requirements:
# XBRL requirements:
# scModels requirements:
# Rsagacmd requirements:
apt-get install -y saga
# BINtools requirements:
# bamdit requirements:
# gifski requirements:
# densEstBayes requirements:
# ordinalbayes requirements:
# networkscaleup requirements:
# texreg requirements:
# ech requirements:
# breathtestcore requirements:
# breathteststan requirements:
# rstanarm requirements:
# saeHB requirements:
# rtmpt requirements:
# rstantools requirements:
# ridge requirements:
# maGUI requirements:
# Libra requirements:
# rmsb requirements:
# stringfish requirements:
# neptune requirements:
# runjags requirements:
# mapview requirements:
# xgboost requirements:
# bayesZIB requirements:
# rjags requirements:
# ftExtra requirements:
# abn requirements:
# mwa requirements:
# smile requirements:
# gastempt requirements:
# RPostgres requirements:
# tidycwl requirements:
# bssm requirements:
# modeLLtest requirements:
# archive requirements:
apt-get install -y libarchive-dev
# bayescount requirements:
# prome requirements:
# saeHB.twofold requirements:
# quantdr requirements:
# saeHB.panel requirements:
# cncaGUI requirements:
# multibiplotGUI requirements:
# rnetcarto requirements:
# camtrapR requirements:
# gdata requirements:
# latentnet requirements:
# blavaan requirements:
# ggquickeda requirements:
# unmarked requirements:
# tkImgR requirements:
# Rlgt requirements:
# FLSSS requirements:
# opencpu requirements:
apt-get install -y libapparmor-dev
# grwat requirements:
# rdataretriever requirements:
# FCPS requirements:
# rego requirements:
# nloptr requirements:
# SGP requirements:
# tesseract requirements:
apt-get install -y libleptonica-dev
apt-get install -y libtesseract-dev
apt-get install -y tesseract-ocr-eng
# RoBSA requirements:
# bioimagetools requirements:
# coveffectsplot requirements:
# PoissonBinomial requirements:
# uavRmp requirements:
# crandep requirements:
# Rmpfr requirements:
# prevalence requirements:
# RJSDMX requirements:
# saeHB.gpois requirements:
# outerbase requirements:
# sodium requirements:
apt-get install -y libsodium-dev
# ggseg requirements:
# geno2proteo requirements:
# causact requirements:
# hgwrr requirements:
# redist requirements:
# saeHB.zinb requirements:
# hoopR requirements:
# RMariaDB requirements:
apt-get install -y libmysqlclient-dev
# GWmodel requirements:
# pedometrics requirements:
# rMIDAS requirements:
# BANOVA requirements:
# phacking requirements:
# MIMSunit requirements:
# batchmix requirements:
# GeneralizedWendland requirements:
# oddsapiR requirements:
# pharmr requirements:
# StanMoMo requirements:
# ggtrace requirements:
# bayeslm requirements:
# DIZutils requirements:
# PRIMME requirements:
# RNetCDF requirements:
# CausalQueries requirements:
# papaja requirements:
# precommit requirements:
# markovchain requirements:
# PoolTestR requirements:
# saeHB.hnb requirements:
# r5r requirements:
# Cairo requirements:
# idm requirements:
# bootUR requirements:
# stringi requirements:
apt-get install -y libicu-dev
# entropart requirements:
# mwcsr requirements:
# bmstdr requirements:
# RMOA requirements:
# RMOAjars requirements:
# pema requirements:
# RoBMA requirements:
# brinton requirements:
# SPARSEMODr requirements:
# worcs requirements:
# mallet requirements:
# ngboostForecast requirements:
# RBesT requirements:
# BayesSenMC requirements:
# GPBayes requirements:
# qqconf requirements:
# BeeGUTS requirements:
# kantorovich requirements:
# rkafka requirements:
# lpcde requirements:
# RcppAlgos requirements:
# bws requirements:
# elbird requirements:
# pandocfilters requirements:
# fsdaR requirements:
# cleanNLP requirements:
# spcosa requirements:
# cubature requirements:
# PMCMRplus requirements:
# coreNLP requirements:
# kerasR requirements:
# reprex requirements:
# hwep requirements:
# mHMMbayes requirements:
# scatteR requirements:
# disbayes requirements:
# tsmp requirements:
# arulesCBA requirements:
# bdpar requirements:
# Rssa requirements:
# surveil requirements:
# MADPop requirements:
# haven requirements:
# sendigR requirements:
# designmatch requirements:
# pathfindR requirements:
# scs requirements:
# OncoBayes2 requirements:
# dialr requirements:
# rticles requirements:
# MODIStsp requirements:
# link2GI requirements:
# ropenblas requirements:
# multinma requirements:
# altmeta requirements:
# RcppCWB requirements:
apt-get install -y libglib2.0-dev
# soilhypfit requirements:
# pcnetmeta requirements:
# reticulate requirements:
# rPBK requirements:
# vitae requirements:
# eyelinkReader requirements:
# greta.dynamics requirements:
# streamMOA requirements:
# JointAI requirements:
# greta.gp requirements:
# TreeBUGS requirements:
# gittargets requirements:
# disaggregation requirements:
# fastTopics requirements:
# chromote requirements:
# rstan requirements:
# gitcreds requirements:
# greta requirements:
# mapme.biodiversity requirements:
# truncnormbayes requirements:
# EvidenceSynthesis requirements:
# RGF requirements:
# historicalborrowlong requirements:
# BayesTools requirements:
# rmBayes requirements:
# MFPCA requirements:
# FlexReg requirements:
# idiogramFISH requirements:
# surveyvoi requirements:
apt-get install -y automake
# SparseChol requirements:
# dismo requirements:
# bartMachineJARs requirements:
# text requirements:
# RoBTT requirements:
# PTXQC requirements:
# igraph requirements:
# sdcTable requirements:
# sen2r requirements:
apt-get install -y libnode-dev
# h2o requirements:
# fastGLCM requirements:
# dtwclust requirements:
# mixture requirements:
# hBayesDM requirements:
# memoiR requirements:
# DatabaseConnector requirements:
# openCR requirements:
# neuronorm requirements:
# rgl requirements:
apt-get install -y libglu1-mesa-dev
apt-get install -y libgl1-mesa-dev
# rtika requirements:
# rcdk requirements:
# webshot requirements:
# mlr requirements:
# InSilicoVA requirements:
# Orcs requirements:
# leidenAlg requirements:
# slendr requirements:
# RCurl requirements:
# hdf5r requirements:
# registr requirements:
# BayesCACE requirements:
# exiftoolr requirements:
# geouy requirements:
# digitalDLSorteR requirements:
# h3jsr requirements:
# EcoDiet requirements:
# curl requirements:
# landsepi requirements:
# SimInf requirements:
# bakR requirements:
# gdalcubes requirements:
apt-get install -y libsqlite3-dev
# Rpoppler requirements:
apt-get install -y libpoppler-cpp-dev
# qpdf requirements:
# clinDataReview requirements:
# bbsBayes requirements:
# gpg requirements:
apt-get install -y libgpgme11-dev
apt-get install -y haveged
# PReMiuM requirements:
# excursions requirements:
# pdftools requirements:
# factset.protobuf.stach.v2 requirements:
apt-get install -y libprotobuf-dev
apt-get install -y protobuf-compiler
# ravetools requirements:
# walker requirements:
# deforestable requirements:
# exams requirements:
# ndjson requirements:
# tables requirements:
# dynr requirements:
# unix requirements:
# RAppArmor requirements:
# Rmixmod requirements:
# cartogramR requirements:
# ssh requirements:
# minqa requirements:
# asteRisk requirements:
# ISEtools requirements:
# OpenMx requirements:
# PolygonSoup requirements:
# delaunay requirements:
# rmumps requirements:
# irace requirements:
# symengine requirements:
# XLConnect requirements:
# cld3 requirements:
# RDieHarder requirements:
# econetwork requirements:
# ragg requirements:
# clinUtils requirements:
# bartMachine requirements:
# protolite requirements:
# RQuantLib requirements:
apt-get install -y libquantlib0-dev
# pbdZMQ requirements:
# rtkore requirements:
# pbdMPI requirements:
# pbdSLAP requirements:
# meltt requirements:
# BGVAR requirements:
# tidync requirements:
# inlpubs requirements:
# keyring requirements:
apt-get install -y libsecret-1-dev
# rts2 requirements:
# mRpostman requirements:
# morse requirements:
# TDA requirements:
# RcppGSL requirements:
# MeshesTools requirements:
# MinkowskiSum requirements:
# reproj requirements:
# jagstargets requirements:
# Boov requirements:
# RcppRedis requirements:
# sportyR requirements:
# multibridge requirements:
# bfp requirements:
# spate requirements:
# IRkernel requirements:
# BayesXsrc requirements:
# RProtoBuf requirements:
# V8 requirements:
# tipsae requirements:
# ctsem requirements:
# ijtiff requirements:
# fdaPDE requirements:
# Boom requirements:
# RSiena requirements:
# EcoEnsemble requirements:
# mongolite requirements:
apt-get install -y libsasl2-dev
# pRecipe requirements:
# uchardet requirements:
# sf requirements:
# learnr requirements:
# dbmss requirements:
# FFD requirements:
# stplanr requirements:
# ubms requirements:
# yamlme requirements:
# glpkAPI requirements:
# cgalMeshes requirements:
# apcf requirements:
# RJDemetra requirements:
# datasailr requirements:
# restoptr requirements:
# biblio requirements:
# fasano.franceschini.test requirements:
# ggdemetra requirements:
# flexsiteboard requirements:
# seqminer requirements:
# hermiter requirements:
# rbmi requirements:
# vapour requirements:
# data.table requirements:
# bayesplot requirements:
# hpa requirements:
# snSMART requirements:
# glmmTMB requirements:
# exactextractr requirements:
# GreedyExperimentalDesign requirements:
# s2 requirements:
# rflsgen requirements:
# IceSat2R requirements:
# R2SWF requirements:
# asbio requirements:
# ctrdata requirements:
# inTextSummaryTable requirements:
# patientProfilesVis requirements:
# happign requirements:
# lwgeom requirements:
# knitr requirements:
# remiod requirements:
# lazyNumbers requirements:
# rsvg requirements:
apt-get install -y librsvg2-dev
# ergm requirements:
# RCzechia requirements:
# BayesVarSel requirements:
# bspm requirements:
# sass requirements:
# ebvcube requirements:
# BSPBSS requirements:
# AlphaHull3D requirements:
# emayili requirements:
# scistreer requirements:
# seqinr requirements:
# Rserve requirements:
# GeneralizedUmatrix requirements:
# hellorust requirements:
# FedData requirements:
# PKI requirements:
# numbat requirements:
# png requirements:
# jpeg requirements:
# secr requirements:
# proj4 requirements:
# JavaGD requirements:
# ROpenCVLite requirements:
# cppRouting requirements:
# NNS requirements:
# geostan requirements:
# ggiraph requirements:
# ncdf4 requirements:
# terra requirements:
# tiledb requirements:
# SqlRender requirements:
# mappoly requirements:
# catSurv requirements:
# gert requirements:
# AMAPVox requirements:
# aphid requirements:
# RMySQL requirements:
# topicmodels requirements:
# openssl requirements:
# paws.common requirements:
# NACHO requirements:
# arrow requirements:
# dodgr requirements:
# dialrjars requirements:
# argparse requirements:
# glmmrBase requirements:
# RSAGA requirements:
# oncomsm requirements:
# reservr requirements:
# units requirements:
# nanonext requirements:
# spaMM requirements:
# glmmPen requirements:
# pmparser requirements:
# ClusterR requirements:
# blogdown requirements:
# pagedown requirements:
# bookdown requirements:
# SDMtune requirements:
# grf requirements:
# gmp requirements:
# nimble requirements:
# httpuv requirements:
# forsearch requirements:
# pkgdown requirements:
# rgeos requirements:
# rgdal requirements:
# highs requirements:
apt-get install -y pkg-config
# LMMELSM requirements:
# rmarkdown requirements:
# string2path requirements:
# huxtable requirements:
# OpenImageR requirements:
# MFSIS requirements:
# fangs requirements:
# imager requirements:
# bamm requirements:
apt-get install -y libmagic-dev
# caviarpd requirements:
# rswipl requirements:
# devEMF requirements:
apt-get install -y libxft-dev
# rTLS requirements:
# salso requirements:
# EloSteepness requirements:
# textrecipes requirements:
# rvg requirements:
# qspray requirements:
# IBRtools requirements:
# rolog requirements:
# rgeedim requirements: