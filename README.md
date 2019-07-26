# R/SGCCA Docker 

#### Version : 1.0

#### Author : Etienne CAMENEN

#### Key-words: 
omics, RGCCA, multi-block

#### EDAM operation
analysis, correlation, visualisation

#### Contact
arthur.tenenhaus@l2s.centralesupelec.fr

#### Short description
Performs multi-variate analysis (e.g., PCA, CCA, PLS, R/SGCCA) and projects the variables and samples into bi-dimensional plots.

---

## Description
A user-friendly multi-blocks analysis (Regularized Generalized Canonical Correlation Analysis, RGCCA) with all default settings predefined [1, 2]. Produce figures to help clinicians to identify biomarkers: samples and variables projected on the two first component of the multi-block analysis, list of top biomarkers and explained variance in the model.
 
More information about:
- [RGCCA](https://cran.r-project.org/web/packages/RGCCA/vignettes/vignette_RGCCA.pdf)
- [input / output formats](https://github.com/BrainAndSpineInstitute/rgcca_Rpackage#input-files)


## Usage instruction

### Pull
```
docker pull rgcca
```

### Run in Shiny

```
docker run --user shiny --rm -p 3838:3838 rgcca
```

The Shiny server can be accessed from [http://localhost:3838/shiny](http://localhost:3838/shiny).
For direct usage, please read the [Shiny tutorial](https://github.com/BrainAndSpineInstitute/rgcca_Rpackage/blob/master/inst/shiny/tutorialShiny.md).

### Run in command-line

```
docker create -ti --name rgccaDocker --entrypoint bash rgcca
docker start rgccaDocker
docker exec -ti rgccaDocker bash
```

Inside the docker, execute:

```
Rscript R/launcher.R --datasets <list_block_files> [--help] [--names <list_block_names] [--connection <connection_file>] [--response <response_file>] [--scheme <scheme_type>] [--output1 <variables_space_fig_name>] [--output3 <samples_space_fig_name>] [--output3 <biomarkers_fig_name>] [--header] [--separator <separator_type>]
```

More information about the command-line parameters [here](https://github.com/BrainAndSpineInstitute/rgcca_Rpackage#command-line).