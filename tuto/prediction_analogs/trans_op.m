%trans_op.m
%The code compute the transfer operators for GMT from data of a range of CMIP5 models.
%Hindcast and/or forecast are also provided
%The methodology is based on PROCAST following Sévellec and Drijfhout (Nature Communications, 2018).
%Code developped on 23apr19

clear all;
% close all;

%Flag
fmarkchain=0;%Flag for Markov Chain or Analog Method (1/0, respectively)

%Data Parameter
datadir='./Data/';
year=1990;%Year of Initial Condition
vt=[1:5];%Prediction time increment
vtplot=[1,2,5];%Prediction PDF plotted
timebeg=1862;timeend=2100;%Time beg and end of training model.
nx=16;%Grid number /!\must be even numbers/!\

%Modelname
modelname1='CCSM4';iter1=[1:6];
modelname2='CSIRO-Mk3-6-0';iter2=[1:10];
modelname3='IPSL-CM5A-LR';iter3=[1:4];
vmodel=[1,2,3];nmodel=numel(vmodel);

%Load Obs
time=ncread([datadir,'tall_2017.nc'],'NWTAX');
obs=ncread([datadir,'tall_2017.nc'],'TALL');
obs=obs-mean(obs);time=double(time);

figure;
subplot(2,1,1);
plot(time,obs,'k-','LineWidth',2);
hold on; box on; grid on;
plot(year,obs(find(time==year)),'p','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10)
title('NATURAL GMT (K)','FontSize',14);
xlabel('TIME (year)','FontSize',14)

%Grid definition
dx=3*std(obs)/(0.5*nx);%3*std 99.7%
xmax=max(abs(obs))+eps;
vxp=(0:0.5*nx)*dx;vxp(end)=xmax;
vx=[-fliplr(vxp),vxp(2:end)];
Niobs=zeros(nx,1);
for i=1:numel(vx)-1;
  ind=find((obs>vx(i))&(obs<=vx(i+1)));
  Niobs(i)=numel(ind);
end
Xp=vxp(1:end-1)+0.5*dx;X=[-fliplr(Xp),Xp];
Niobsn=Niobs/sum(Niobs);

subplot(2,1,2);
bar(X,Niobsn*100,0.8,'FaceColor',0.6*[1,1,1],'EdgeColor','k','LineWidth',1);
hold on; box on; grid on;
axis([-2.5*std(obs),2.5*std(obs),0,100*max(Niobsn)]);
axis([-xmax-dx,xmax+dx,0,110*max(Niobsn)]);
title('\bf DISTRIBUTION (%)','FontSize',14);
xlabel('NATURAL GMT (K)','FontSize',14);

%Load Model data
for it=vt(1:end),

  count=0;SAT=zeros(0);SATi=zeros(0);SATf=zeros(0);
  for jmodel=vmodel,
    eval(['modelname=modelname',int2str(jmodel),';']);
    eval(['iter=iter',int2str(jmodel),';']);
    
    for jiter=1:numel(iter);
      MYAX1=ncread([datadir,modelname,'_sat_a_r',int2str(iter(jiter)),'i1p1.nc'],'MYAX');
      SAT_A=ncread([datadir,modelname,'_sat_a_r',int2str(iter(jiter)),'i1p1.nc'],'SAT_A');
      
      ibeg=find(MYAX1==timebeg);iend=find(MYAX1==timeend);
      SAT_A=SAT_A(ibeg:iend);MYAX1=MYAX1(ibeg:iend);
      
      count=count+numel(SAT_A)-1;
      SAT=[SAT;SAT_A];
      SATi=[SATi;SAT_A(1:end-it)];SATf=[SATf;SAT_A(1+it:end)];     
      
    end
    
  end
  
  
  %Fill the Transfer Operators
  A=zeros(nx,nx);
  for i=1:numel(vx)-1;
    ind=find((SATi>vx(i))&(SATi<=vx(i+1)));
    Ni=numel(ind);
    SATff=SATf(ind);
    for ii=1:numel(vx)-1;
      Nf=sum((SATff>vx(ii))&(SATff<=vx(ii+1)));
      A(ii,i)=Nf/Ni;
    end
  end
  A(isnan(A))=0;
  if fmarkchain==1,
    eval(['A',int2str(it),'=A^',int2str(it),';']);
  else,
    eval(['A',int2str(it),'=A;']);
  end
  fprintf([int2str(it),'/',int2str(numel(vt)-1),': ',int2str(it),'-yr TRANSITION MATRIX - NUMBER OF TOTAL TRANSITION: ',int2str(count),'\n']);

end
 

%Prediction
Xval=obs(find(time==year));
iind=min(find(abs(X-Xval)==min(abs(X-Xval))));
Xi=zeros(nx,1);Xi(iind)=1;
Xt=zeros(nx,numel(vt)+1);Xt(:,1)=Xi;
for it=vt(1:end),
  eval(['A=A',int2str(it),';']);Xt(:,it+1)=A*Xi;
end

%Diags
for it=1:numel(vt)+1,
  meanx(it)=X*Xt(:,it);
  stdx(it)=sqrt(((X-meanx(it)).^2)*Xt(:,it));
end
vtobs=1:min([max(vt),max(time)-year]);
obsplot=obs(find(time==year)+[0,vtobs]);
Xobsplot=NaN(size(Xt));
for it=1:numel(vtobs)+1,
  iind=min(find(abs(X-obsplot(it))==min(abs(X-obsplot(it)))));
  Xobsplot(iind,it)=1;
end

figure
for it=1:numel(vtplot);
  itplot=vtplot(it)+1;
  subplot(numel(vtplot),2,1+2*(it-1));
  bar(X,Niobsn*100,1,'FaceColor',0.6*[1,1,1],'EdgeColor',0.6*[1,1,1],'LineWidth',1);
  hold on; box on; grid on;
  bar(X,100*Xt(:,itplot),0.6,'FaceColor','r','EdgeColor','r','LineWidth',1);
  bar(X,100*Xt(:,1),0.1,'FaceColor','b','EdgeColor','b','LineWidth',1);
  bar(X,100*Xobsplot(:,itplot),0.1,'FaceColor','k','EdgeColor','k','LineWidth',1);
  axis([-2.5*std(obs),2.5*std(obs),0,100*max(Niobsn)]);
  axis([-xmax-dx,xmax+dx,0,110*max(Niobsn)]);
  ylabel('PDF (%)','FontSize',14);
  title(['\bf',int2str(itplot-1),'-yr PRED'],'FontSize',14);
  if it==numel(vtplot),xlabel('GMT (K)','FontSize',14);end
  if it==1,legend('CLIM','PRED','INI','OBS');end
end
subplot(1,2,2);
plot([0,vtobs],obsplot,'d','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10);
hold on; box on; grid on;
plot(vt,meanx(2:end),'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',10);
plot(0,meanx(1),'s','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',10);
for it=1:numel(vt),
  plot(vt(it)*[1,1],meanx(it+1)+[-stdx(it+1),stdx(it+1)],'r-','LineWidth',2);
end
plot([0,max(vt)],[0,0],'k-','LineWidth',1);
axis([0,max(vt),-2.5*std(obs),2.5*std(obs)]);
title(['\bf PREDICTION FROM ',int2str(year)],'FontSize',14);
ylabel('GMT (K)','FontSize',14);
xlabel('PRED LAG (yr)','FontSize',14);
