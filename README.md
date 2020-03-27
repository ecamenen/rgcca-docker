# R/SGCCA Docker 

#### Version : 1.1

#### Author : Etienne CAMENEN

#### Key-words: 
omics, RGCCA, multi-block

#### EDAM operation
analysis, correlation, visualisation

#### Contact
arthur.tenenhaus@l2s.centralesupelec.fr

#### Short description
Performs multi-variate analysis (PCA, CCA, PLS, R/SGCCA, etc.) and produces textual and graphical outputs (e.g. variables and individuals plots).

---

## Description
A user-friendly multi-blocks analysis (Regularized Generalized Canonical Correlation Analysis, RGCCA) as described in [1] and [2] with all default settings predefined. The software produces figures to explore the analysis' results: individuals and variables projected on two components of the multi-block analysis, list of top variables and explained variance in the model.
 
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
Rscript inst/launcher.R --datasets <list_block_files> 
```

More information about the command-line parameters [here](https://github.com/BrainAndSpineInstitute/rgcca_Rpackage#command-line).