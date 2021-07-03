# Author: Etienne CAMENEN
# Date: 2019
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: data integration, omics, multi-block, regularized generalized, canonical correlation analysis, RGCCA
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space.

FROM rocker/shiny

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION 3.0.2
ENV TOOL_NAME_UI rgcca_ui
ENV TOOL_NAME RGCCA
ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git
ENV RPKGS parallel pbapply grDevices MASS lattice ggplot2 optparse scales plotly visNetwork igraph ggrepel devtools shiny shinyjs DT Deriv opensxlsx gridExtra methods stats graphics

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.3
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get install -y ${PKGS}
RUN Rscript -e 'install.packages(commandArgs(TRUE), repos = "http://cran.us.r-project.org")' ${RPKGS} && \
    R -e 'devtools::install_github(c("ijlyttle/bsplus"))' && \
    R -e 'devtools::install_github("rgcca-factory/'${TOOL_NAME}'", ref = "'${TOOL_VERSION}'")'
RUN git clone --depth 1 --single-branch --branch master https://github.com/BrainAndSpineInstitute/$TOOL_NAME_UI
RUN apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean
RUN mkdir inst/ && \
	mv $TOOL_NAME_UI/inst/launcher.R inst/launcher.R && \
	mv $TOOL_NAME_UI/inst/shiny /srv/shiny-server/ && \
	mv $TOOL_NAME_UI/inst/extdata/ data/ && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $TOOL_NAME_UI

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/
RUN chmod +x /functional_tests.sh
RUN chown -R shiny srv/shiny-server/shiny/
USER shiny

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]