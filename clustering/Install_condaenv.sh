#!/bin/bash
#
# This script will create the minimum conda env for a LOPS-data mini-camp session
#

conda create -n lopsformationdata python=2.7

conda install -n lopsformationdata netCDF4 # netcdf4-python: python/numpy interface to the netCDF C library
conda install -n lopsformationdata xarray # N-D labeled arrays and datasets in Python
conda install -n lopsformationdata dask # Dask is a flexible library for parallel computing in Python.
conda install -n lopsformationdata gsw # Python implementation of TEOS-10 GSW based on ufunc wrappers of GSW-C
conda install -n lopsformationdata cartopy # Make drawing maps for data analysis and visualisation as easy as possible
conda install -n lopsformationdata scikit-learn # Machine Learning in Python
conda install -n lopsformationdata seaborn # Statistical data visualization using matplotlib

# Add lopsformationdata kernel to jupyter:
conda install -n lopsformationdata ipykernel
python -m ipykernel install --user --name lopsformationdata --display-name "LOPS - formation - Axe data"

# Cartopy needs more data and will try to connect to the internet to download new data files
# These are stored here:
# $HOME/.local/share/cartopy
# As a Datarmor jupyterhub notebook can't connect to the internet, it is needed to copy the data files
# from a local directory, for instance:
# /home1/datahome/gmaze/.local/share/cartopy