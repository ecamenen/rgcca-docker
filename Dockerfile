# Author: Etienne CAMENEN
# Date: 2021
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: data integration, omics, multi-block, regularized generalized, canonical correlation analysis, RGCCA
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (e.g., PCA, CCA, PLS, R/SGCCA) and produces textual and graphical outputs (e.g., variables and individuals plots).

ARG U_VERSION=latest
FROM ubuntu:${U_VERSION}

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION 3.0.0
ENV TOOL_NAME RGCCA
ENV DEBIAN_FRONTEND noninteractive
ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-science r-base
ENV RPKGS parallel pbapply grDevices ggplot2 optparse scales igraph gridExtra Deriv openxlsx devtools rmarkdown pander ggrepel plotly visNetwork
ENV _R_CHECK_FORCE_SUGGESTS_ FALSE

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.2

LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get install -y ${PKGS}
RUN Rscript -e 'install.packages(commandArgs(TRUE),repos = "http://cran.us.r-project.org")' ${RPKGS}
RUN git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/rgcca-factory/$TOOL_NAME && \
    cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
    R -e 'devtools::document()' && \
    cd / && \
    R -e 'devtools::build_vignettes("RGCCA")' && \
    R CMD build $TOOL_NAME && \
    R CMD check *.tar.gz && \
    R -e "install.packages('"${TOOL_NAME}_${TOOL_VERSION}".tar.gz'"", repos = NULL, type = 'source')" && \
	apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	mkdir -p /inst/shiny && \
	cp -r $TOOL_NAME/inst/extdata/ $TOOL_NAME/R/ / && \
	mv $TOOL_NAME/inst/launcher.R inst/launcher.R && \
	mv $TOOL_NAME/inst/shiny inst/ && \
	mv extdata/ data && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $TOOL_NAME

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/

RUN chmod +x /functional_tests.sh

ENTRYPOINT ["Rscript", "inst/launcher.R", "-h"]