# ICM - Institut du Cerveau et de la Moelle epiniere (Paris, FRANCE),
# Institut Francais de Bioinformatique (IFB), Centre national de la recherche scientifique (CNRS)
#
# Abstract: A user-friendly multi-blocks analysis (Regularized Generalized Canonical Correlation Analysis, RGCCA)
# with all default settings predefined. Produce two figures to help clinicians to identify biomarkers:
# samples and variables projected on the two first component of the multi-block analysis.


FROM ubuntu:16.04

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION release/2.0
ENV TOOL_NAME rgcca_galaxy

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update && apt-get install -y --no-install-recommends git && apt-get install -y r-base
RUN git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
	cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
	cp -r data/ R/ / && \
	apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cd / && rm -rf $TOOL_NAME

#ADD runTest1.sh /usr/local/bin/functional_tests.sh
#RUN chmod +x /usr/local/bin/functional_tests.sh

ENTRYPOINT ["Rscript", "R/launcher.R"]