
#!/usr/bin/env python
import logging
from bokeh.sampledata.iris import flowers
from bokeh.models import ColumnDataSource, CDSView, LassoSelectTool
from bokeh.plotting import output_file,save
from bokeh.layouts import layout,column
import bkwidgets
import os
import pandas as pd
fileo = '/home1/datahome/agrouaze/sentinel1/s1_small_df.pkl'


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='bkwidget_tp')
    parser.add_argument('--verbose', action='store_true',default=False)
    parser.add_argument('--output', action='store',default=False,help='output dir')
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(levelname)-5s %(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S')
    else:
        logging.basicConfig(level=logging.INFO,format='%(asctime)s %(levelname)-5s %(message)s',
                    datefmt='%d/%m/%Y %H:%M:%S')
    df = pd.read_pickle(fileo)
    print(df.keys())
    print(len(df))
    df2 = df.dropna()
    df2 = df2.drop('wv_mode',axis=1)
    df2 = df2.drop('pol',axis=1)
    df2 = df2.drop('fdate',axis=1)
    df2 = df2.drop('uwind',axis=1)
    print len(df2)
    source=ColumnDataSource(df2)
    source.remove('index')
    outi = os.path.join(args.output,"sentinel1_wv.html")
    output_file(outi)

    # build filter selectors from source
    selectors=bkwidgets.Filter(source)
    # setup a view connected to selectors
    view=CDSView(source=source,filters=selectors.filters)
    # two scatterplot using the same view, with lasso tool 
    scatter1=bkwidgets.ScatterAxis(view=view,source=source)
    scatter1.fig.add_tools(LassoSelectTool())
    #scatter2=bkwidgets.ScatterAxis(view=view,x="sepal_length",y="petal_length",c="sepal_width")
    #scatter2.fig.add_tools(LassoSelectTool())
    
    # layout, and save
    #p=layout([[selectors.widget,scatter1.widget,scatter2.widget]])
    p=layout([[selectors.widget,scatter1.widget]])
    save(p)
    print(outi," dumped")