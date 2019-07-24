# Author: Etienne CAMENEN
# Date: 2019
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: data integration, omics, multi-block, regularized generalized, canonical correlation analysis, RGCCA
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space.

FROM ubuntu:latest

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION hotfix/3.1
ENV TOOL_NAME rgcca_Rpackage
ENV DEBIAN_FRONTEND=noninteractive




LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=2.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-science r-base
RUN R -e 'defaults write org.R-project.R force.LANG en_US.UTF-8' && \
    R -e 'install.packages(c("RGCCA", "ggplot2", "optparse", "scales", "plotly", "visNetwork", "igraph", "devtools", "rmarkdown", "pander", "shiny", "shinyjs", "bsplus"))'
RUN R -e 'devtools::install_github(c("ijlyttle/bsplus"))' && \
    git clone --depth 1 --single-branch --branch $TOOL_VERSION https://github.com/BrainAndSpineInstitute/$TOOL_NAME && \
    cd $TOOL_NAME && \
	git checkout $TOOL_VERSION && \
    R -e 'devtools::document()'
RUN cd / && \
    R -e 'devtools::build_vignettes("rgcca_Rpackage")' && \
    R CMD build --no-build-vignettes $TOOL_NAME && \
    R CMD check rgccaLauncher_1.0.tar.gz && \
	apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	cp -r $TOOL_NAME/inst/extdata/ $TOOL_NAME/R/ / && \
	mv extdata/ data && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/* $TOOL_NAME

COPY functional_tests.sh /functional_tests.sh
COPY data/ /data/

RUN chmod +x /functional_tests.sh && \
    ./functional_tests.sh && \
    cat resultRuns.log && \
    cat warnings.log && echo "done"

ENTRYPOINT ["Rscript", "R/launcher.R"]