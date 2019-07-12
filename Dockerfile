# Author: Etienne CAMENEN
# Date: 2019
# Contact: arthur.tenenhaus@l2s.centralesupelec.fr
# Key-words: data integration, omics, multi-block, regularized generalized, canonical correlation analysis, RGCCA
# EDAM operation: analysis, correlation, visualisation
# Short description: performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space.

FROM rocker/tidyverse:3.4.1

MAINTAINER Etienne CAMENEN ( iconics@icm-institute.org )

ENV TOOL_VERSION hotfix/3.1
ENV TOOL_NAME rgcca_Rpackage

LABEL Description="Performs multi-variate analysis (PCA, CCA, PLS, RGCCA) and projects the variables and samples into a bi-dimensional space."
LABEL tool.version="{TOOL_VERSION}"
LABEL tool="{TOOL_NAME}"
LABEL docker.version=2.0
LABEL tags="omics,RGCCA,multi-block"
LABEL EDAM.operation="analysis,correlation,visualisation"

RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y git texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-science && \
    apt-get install -y r-base r-cran-ggplot2 r-cran-scales r-cran-shiny r-cran-igraph
RUN R -e 'install.packages(c("RGCCA", "optparse", "shinyjs", "plotly", "visNetwork", "devtools", "rmarkdown", "pander", "bsplus"))'
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