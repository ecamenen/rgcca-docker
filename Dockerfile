# Author: Etienne CAMENEN
# Date: 2019
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: data integration, omics, multi-block, regularized generalized, canonical correlation analysis, RGCCA
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space.

FROM rocker/shiny

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION hotfix/3.1
ENV TOOL_NAME rgcca_Rpackage
ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git r-base
ENV RPKGS MASS lattice roxygen2 testthat RGCCA ggplot2 optparse scales plotly visNetwork igraph devtools shiny shinyjs

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get install -y ${PKGS}
RUN Rscript -e 'install.packages(commandArgs(TRUE), repos = "http://cran.us.r-project.org")' ${RPKGS} && \
    R -e 'devtools::install_github(c("ijlyttle/bsplus"))'
RUN git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
    cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
    cd / && \
	apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean
RUN cp -r $TOOL_NAME/R/ /srv/R && \
	mv $TOOL_NAME/inst/shiny /srv/shiny-server/ && \
	mv $TOOL_NAME/inst/extdata/ data/ && \
	cp -r /srv/R /R/ && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $TOOL_NAME

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]