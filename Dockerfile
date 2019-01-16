# Author: Etienne CAMENEN
# Date: 2018
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: omics, RGCCA, multi-block
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space.

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
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends git default-jre default-jdk && \
    apt-get install -y r-base r-cran-ggplot2 r-cran-scales r-cran-optparse && \
    R CMD javareconf && \
    R -e 'install.packages(c("RGCCA", "rJava", "xlsxjars", "xlsx"))' && \
    git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
	cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
	cp -r data/ R/ / && \
	apt-get purge -y git && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*  && \
	cd /

RUN R -e 'install.packages(c("optparse", "pander", "shinyjs"))' && \
    R CMD INSTALL $TOOL_NAME && \
    apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-science && \
    R CMD check $TOOL_NAME && \
	apt-get purge -y g++ && \
	rm -rf $TOOL_NAMEmake clean

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/
RUN chmod +x /functional_tests.sh && \
    ./functional_tests.sh

ENTRYPOINT ["Rscript", "R/launcher.R"]