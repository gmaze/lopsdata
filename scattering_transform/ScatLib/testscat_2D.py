#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib as mpl
#mpl.use('PDF')
import matplotlib.pyplot as plt
from scipy.fftpack import fft,ifft
from scatter import scatter
import scipy as scipy


def main():
    
    #=======================================================================
    # Init scatter2D :
    #=======================================================================
    ndata=64
    nstep=5
    norient=8
    scat=scatter.scatter2d(ndata,nstep,norient)

    #=======================================================================
    # Read input 2D data :
    #=======================================================================
    data=np.fromfile('turb2D.dat',dtype='float').reshape(64,64)
    data-=data.mean()

    #=======================================================================
    # Compute noise with the same powespectrum :
    #=======================================================================
    sdata=scat.cnoise(-(5/3.))
    sdata-=sdata.mean()
    sdata*=data.std()/sdata.std()

    #=======================================================================
    # Compute  2Dx2 Levels Scaterring Transform
    #=======================================================================

    coef1_data,coef2_data,dii,doo = scat.compute(data)
    coef1_sdata,coef2_sdata,dii,doo = scat.compute(sdata)

    #=======================================================================
    # Compute powerspectrum
    #=======================================================================
    no_orient_spec=scat.spec1D(data)
    no_orient_sspec=scat.spec1D(sdata)
        
    #=======================================================================
    # VARIOUS PLOT TO COMPARE NOISE and TURBULENCE
    #=======================================================================
    f=plt.figure(figsize = (10, 10))
    plt.gcf().subplots_adjust(left = 0.07, bottom = 0.07, right = 0.98, top = 0.98, wspace = 0.2, hspace = 0.25)
    plt.subplot(221)
    plt.contourf(data,cmap='jet',levels=np.arange(100)*(data.max()-data.min())/100+data.min())
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.subplot(222)
    plt.contourf(sdata,cmap='jet',levels=np.arange(100)*(sdata.max()-sdata.min())/100+sdata.min())
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.subplot(223)
    plt.plot(1+np.arange(32),no_orient_spec[1:33]/no_orient_spec[10],color='blue')
    plt.plot(1+np.arange(32),no_orient_sspec[1:33]/no_orient_sspec[10],color='red')
    plt.xlabel('Frequency [pixel-1]')
    plt.ylabel('Powerspectrum')
    plt.xscale('log')
    plt.yscale('log')
    plt.text(1,1,'Turbulence',fontweight = 'bold',color='blue',horizontalalignment='left')
    plt.text(1,1E-1,'Noise',fontweight = 'bold',color='red',horizontalalignment='left')

    plt.subplot(224)
    plt.plot(dii.reshape(nstep*norient*nstep*norient),coef2_data.reshape(nstep*norient*nstep*norient),'o',color='blue')
    plt.plot(dii.reshape(nstep*norient*nstep*norient),coef2_sdata.reshape(nstep*norient*nstep*norient),'o',color='red')
    plt.ylabel('Scaterring Coefficients')
    plt.xlabel('J2-J1')
    plt.show()
    f.savefig('demo_scatter2d.pdf',bbox_inches='tight')
    
    #=======================================================================
    # Synthetize data :
    #=======================================================================
    #=    ^     :
    #=   /|\    : Be aware that this synthesis process is VERY VERY long !!!
    #   /_°_\   : In this example it is not yet optimise et to be rewritten
    #=======================================================================
    #synthe_data=scat.synthetize(coef1_data,coef2_data,sdata)


    #===============================================================================
    # VARIOUS PLOT TO COMPARE NOISE and TURBULENCE SCATERRING TRANSFORM COEFFICIENTS
    #===============================================================================
    
    plt.gcf().subplots_adjust(left = 0.07, bottom = 0.1, right = 0.98, top = 0.98, wspace = 0.2, hspace = 0.25)  
    for ii in range(nstep-1):
        i=ii+1
        res=np.zeros([nstep,norient])
        nres=np.zeros([nstep,norient])
        res2=np.zeros([nstep,norient])
        for j in range(norient):
            tmp=np.log(coef2_data[:,:,i,j])-np.log(coef1_data[:,:])
            tmp2=np.log(coef2_sdata[:,:,i,j])-np.log(coef1_sdata[:,:])
            for k in range(norient):
                for l in range(nstep):
                    if int(dii[l,k,i,j])>=0:
                        res[int(dii[l,k,i,j]),(j-k+norient+norient//2)%norient]+=tmp[l,k]
                        res2[int(dii[l,k,i,j]),(j-k+norient+norient//2)%norient]+=tmp2[l,k]
                        nres[int(dii[l,k,i,j]),(j-k+norient+norient//2)%norient]+=1
                        
        plt.subplot(4,2,1+ii*2)   
        plt.contourf(res/nres) 
        plt.ylabel('J2-J1') 
        plt.xlabel('O2-O1 (Turbulence)') 
        plt.subplot(4,2,2+ii*2)    
        plt.contourf(res2/nres)
        plt.ylabel('J2-J1') 
        plt.xlabel('O2-O1 (noise)') 
            
    plt.show()
    f.savefig('demo_scatter2d_COEF.pdf',bbox_inches='tight')
#------------------------------------------------------------------
if __name__ == '__main__':
  main()
