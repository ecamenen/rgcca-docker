# ICM - Institut du Cerveau et de la Moelle epiniere (Paris, FRANCE),
# Institut Francais de Bioinformatique (IFB), Centre national de la recherche scientifique (CNRS)
#
# Abstract: A user-friendly multi-blocks analysis (Regularized Generalized Canonical Correlation Analysis, RGCCA)
# with all default settings predefined. Produce two figures to help clinicians to identify biomarkers:
# samples and variables projected on the two first component of the multi-block analysis.


FROM rocker/tidyverse:3.4.1

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION release/2.0
ENV TOOL_NAME rgcca_Rpackage

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends git default-jre default-jdk && \
    apt-get install -y r-base r-cran-ggplot2 r-cran-scales r-cran-optparse && \
    R CMD javareconf && \
    R -e 'install.packages(c("RGCCA", "rJava", "xlsxjars", "xlsx"))'
    git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
	cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
	cp -r data/ R/ / && \
	apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cd / && rm -rf $TOOL_NAME

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/
RUN chmod +x /functional_tests.sh && \
    ./functional_tests.sh

ENTRYPOINT ["Rscript", "R/launcher.R"]