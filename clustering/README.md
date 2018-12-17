**Usefull notebooks and scripts for LOPS data-camp on "Clustering"**

Participants must be able to connect to the Jupyterhub on Datarmor
at:

https://datarmor-jupyterhub.ifremer.fr

This requires an Ifremer intranet account and may be some conda tuning following these instructions:

https://w3z.ifremer.fr/intraric/Mon-IntraRIC/Calcul-scientifique/Datarmor/How-to-run-your-calculation-on-datarmor/JupyterHub

If you want to run the notebooks on your own, clone this repo and check out the conda environment at:
https://github.com/gmaze/lopsdata/blob/master/clustering/Install_condaenv.sh

Notebooks require python 2.7 and the following packages:
scikit-learn, netCDF4, xarray, dask, gsw, cartopy, seaborn.

Note that grom the jupyter hub, you won't be able to connect to the internet, so you have to clone this repo from a regular connection before.  Or you can copy my root folder into your working directory from a terminal of the notebook:

    mkdir toto
    cd toto
<<<<<<< HEAD:clustering/README.md
    cp -r /home1/datahome/gmaze/lopsdata .
=======
    cp -r /home1/datahome/gmaze/lopsdata .
>>>>>>> master:README.md
