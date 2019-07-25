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

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=1.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq

ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-science r-base

RUN apt-get install -y ${PKGS}

ENV RPKGS MASS lattice roxygen2 testthat RGCCA ggplot2 optparse scales plotly visNetwork igraph devtools rmarkdown pander shiny shinyjs bsplus

RUN Rscript -e 'install.packages(commandArgs(TRUE))' ${RPKGS}
RUN R -e 'devtools::install_github(c("ijlyttle/bsplus"))' && \
    git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
    cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
    R -e 'devtools::document()'
RUN cd / && \
    R -e 'devtools::build_vignettes("rgcca_Rpackage")' && \
    R CMD build --no-build-vignettes $TOOL_NAME && \
    R CMD check rgccaLauncher_1.0.tar.gz && \
    R -e "install.packages('rgccaLauncher_1.0.tar.gz', repos = NULL, type = 'source')" && \
	apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	mkdir -p /inst/shiny && \
	cp -r $TOOL_NAME/inst/extdata/ $TOOL_NAME/R/ / && \
	mv $TOOL_NAME/inst/shiny inst && \
	mv extdata/ data && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $TOOL_NAME

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/

RUN chmod +x /functional_tests.sh && \
    ./functional_tests.sh

ENTRYPOINT ["Rscript", "inst/shiny/app.R"]