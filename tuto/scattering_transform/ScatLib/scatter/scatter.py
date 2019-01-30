#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt

class scatter1d:
    def __init__(self,n,nstep):
        self.n=n
        x=np.arange(n)/n
        self.phi0=np.exp(-8*((x-n/2)**2)/(n**2))

        rr2=(x**2)*16
        self.www=np.zeros([nstep,n])
        self.nstep=nstep

        for j in range(nstep):
            self.www[j,:]=(np.exp(-rr2*2**(2*j))*rr2).astype('float')
            self.www[j,:]/=self.www[j,:].max()

    def compute(self,data):
        tf=np.fft.fft(data)
        coef=np.zeros([self.nstep])
        coef2=np.zeros([self.nstep,self.nstep])
        dii=np.zeros([self.nstep,self.nstep])

        for i1 in range(self.nstep):
            tmp1=abs(np.fft.ifft(tf*self.www[i1,:]))
            coef[i1]=(self.phi0*tmp1).mean()
            tf2=np.fft.fft(tmp1)
            for i2 in range(self.nstep):
                tmp2=abs(np.fft.ifft(tf2*self.www[i2,:]))
                coef2[i1,i2]=(self.phi0*tmp2).mean()
                dii[i1,i2]=i2-i1

        return(coef,coef2,dii)

    def synthetize(self,coef1,coef2,in_yy):

        yy=1*in_yy
        c1,c2,dii=self.compute(yy)

        for itt in range(1000):
            ntest=64
            if itt%100==0:
                print("Iteration : ",itt,((coef2-c2)**2).sum()+0.1*((coef1-c1)**2).sum())
            dx=1E-6*np.random.randn(ntest,self.n)
            dcoef=np.zeros([ntest])
            dy=np.zeros([self.n])
            ndy=np.zeros([self.n])
            for i in range(ntest):
                tc1,tc2,dii=self.compute(yy+dx[i,:])
                dcoef[i]=((coef2-tc2)**2).sum()-((coef2-c2)**2).sum()+0.1*(((coef1-tc1)**2).sum()-((coef1-c1)**2).sum())
                dy+=dcoef[i]*dx[i,:]
                ndy+=dx[i,:]**2
            dy/=ndy
            yy=yy-dy/ntest*1E6
            c1,c2,dii=self.compute(yy)
        print(len(yy))
        return(yy)

    def wnoise(self,ntest=100,tf=1):
        coef=np.zeros([self.nstep])
        coef2=np.zeros([self.nstep,self.nstep])
        for itt in range(ntest):
            data=np.fft.ifft(np.fft.fft(np.random.randn(self.n))*tf)
            tcoef,tcoef2,dii=self.compute(data)
            coef+=tcoef
            coef2+=tcoef2
        
        return(coef/ntest,coef2/ntest,dii)
        


class scatter2d:
    def __init__(self,nn,nstep,norient):
        self.nn=nn
        self.x=np.zeros([nn,nn])
        for i in range(nn):
            self.x[:,i]=i-nn/2
        self.y=self.x.transpose()
        self.phi0=np.exp(-4*((self.x-nn/2)**2+(self.y-nn/2)**2)/(nn**2))

        self.filt=np.zeros([norient,nstep,nn,nn])
        for i in range(norient):
            self.filt[i,0,:,:]=np.exp(-2*((self.x-nn/4*np.cos(i*np.pi/norient))/(nn/4))**2-2*((self.y-nn/4*np.sin(i*np.pi/norient))/(nn/4))**2)

        for j in range(nstep-1):
            k=j+1
            for i in range(norient):
                for l in range(nn//2):
                    for m in range(nn//2):
                        self.filt[i,k,l+nn//4,m+nn//4]=self.filt[i,k-1,2*l,2*m]
        for j in range(nstep):
            for i in range(norient):
                self.filt[i,j,:,:]=np.roll(self.filt[i,j,:,:],nn//2,0)
                self.filt[i,j,:,:]=np.roll(self.filt[i,j,:,:],nn//2,1)
            
        
        self.nstep=nstep
        self.norient=norient
        

    def compute(self,data):
        coef=np.zeros([self.nstep,self.norient])
        coef2=np.zeros([self.nstep,self.norient,self.nstep,self.norient])
        dii=np.zeros([self.nstep,self.norient,self.nstep,self.norient])
        doo=np.zeros([self.nstep,self.norient,self.nstep,self.norient])
        
        tf=np.fft.fft2(data)

        for i1 in range(self.nstep):
            for j1 in range(self.norient):
                tmp1=abs(np.fft.ifft2(tf*self.filt[j1,i1,:,:]))
                coef[i1,j1]=(self.phi0*tmp1).mean()
                    
                tf2=np.fft.fft2(tmp1)
                for i2 in range(self.nstep):
                    for j2 in range(self.norient):
                        tmp2=abs(np.fft.ifft2(tf2*self.filt[j2,i2,:,:]))
                        coef2[i1,j1,i2,j2]=(self.phi0*tmp2).mean()
                        dii[i1,j1,i2,j2]=i2-i1
                        doo[i1,j1,i2,j2]=j2-j1

        return(coef,coef2,dii,doo)


    def cnoise(self,slope):


        filter=np.zeros([self.nn,self.nn])
        for i in range(self.nn):
            for j in range(self.nn):
                if i!=self.nn//2 or j!=self.nn//2:
                    filter[i,j]=np.sqrt((i-self.nn/2)**2+(j-self.nn/2)**2)**(slope)
        filter=np.roll(filter,self.nn//2,0)
        filter=np.roll(filter,self.nn//2,1)

        yy=np.fft.fft2(np.random.randn(self.nn,self.nn))
        noise=np.fft.ifft2(yy*filter).real
        
        return(noise)

    def spec1D(self,data):
        tf=abs(np.fft.fft2(data))
        
        ii=np.floor(np.sqrt(self.x**2+self.y**2)).astype('int')
        ii=np.roll(ii,self.nn//2,0)
        ii=np.roll(ii,self.nn//2,1)
        ncl=ii.max()+1
        cl=np.zeros([ncl])
        for i in range(ncl):
            cl[i]=tf[ii==i].mean()
        return(cl)

    def synthetize(self,coef1,coef2,yy):

        c1,c2,dii,doo=self.compute(yy)

        for itt in range(100):
            ntest=64
            print("Iteration : ",itt,((coef2-c2)**2).sum()+0.1*((coef1-c1)**2).sum())
            dcoef=np.zeros([ntest])
            dy=np.zeros([self.nn,self.nn])
            ndy=np.zeros([self.nn,self.nn])
            for i in range(ntest):
                dx=1E-6*np.random.randn(self.nn,self.nn)
                tc1,tc2,dii,doo=self.compute(yy+dx)
                dcoef[i]=((coef2-tc2)**2).sum()-((coef2-c2)**2).sum()+0.1*(((coef1-tc1)**2).sum()-((coef1-c1)**2).sum())
                dy+=dcoef[i]*dx
                ndy+=dx**2
            dy/=ndy
            yy=yy-dy/ntest*1E5
            c1,c2,dii,doo=self.compute(yy)
        plt.contourf(yy)
        plt.show()
        return(yy)
        
