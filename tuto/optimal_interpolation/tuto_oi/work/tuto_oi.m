% ___________________________________________________________________________________________________________
% Training Session - Optimal Interpolation - 28. june 2017 - Brest
% LOPS - Axe Data
% ___________________________________________________________________________________________________________
% TRAINING 1:
% This training aims at construct a monthly Optimal Interpolation (OI) algorithm (along with background field, covariance
% matrix, ...etc) using Argo float to produce analysed temperature and salinity field at a given depth level
% end for a given month in a given box in the Subtropical/Tropical Atlantic ocean.
% (tested Matlab(r) version : R2015a)
% ___________________________________________________________________________________________________________
% OBJECTIVE :
% This training will help us to understand how to:
% 1) Set optimal interpolation configuration
% 2) Use a priori statisitcs for optimal interpolation 
% 3) Constructes the interpolation and covariance matrix
% 4) Compute the anlysed fields
% 5) Understand and discuss the results of analyse
% ___________________________________________________________________________________________________________
% ADVICES :
% 1) All the matlab function needed are documented using the comande help in the matlab terminal
% Example: To show up the help page for 'find()' matlab function, type 'help find' in matlab terminal
% >> help find
% FIND   Find indices of nonzero elements.
%    I = FIND(X) returns the linear indices corresponding to 
%    the nonzero entries of the array X.  X may be a logical expression
% ...etc 
%
% 2) Save regularly the modifications (ctrl+s)
%
% 3) Use/erase the matlab command 'break' between the exercises to interupt/extend the programe execution
%
% 4) Replace where it is asked/suggested and replace %????????? by matlab code to ask the questions
%
% 5) Do not hesitate to use the lecture documents
% ___________________________________________________________________________________________________________

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;

% -----------------------------------------------------------------------------------------------------------
% Set Path
addpath('../toolbox/util_graphique/');
addpath('../toolbox/m_map1.4/');
addpath('../toolbox/nanfun/');
addpath('../toolbox/gsw_matlab_v2_0/');
addpath('../toolbox/gsw_matlab_v2_0/library/');

% -----------------------------------------------------------------------------------------------------------
% Geophysical parameters
deglat = gsw_distance([0 0],[0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set OI Config - Select here the space and time domain for OI
%
% Select area
area= [-50 -15 15 35]; % [lonmin lonmax latmin latmax] Here you can change the geographical area of analysis
box_oi = area;

% time setup is frozen!!
% Select month
iyear= 2011; % [2002 ... 2012] Here you can change the year of analysis
imonth = 7; % [1 ... 12] Here you can change the month of analysis
date_cent = datenum(iyear,imonth,15);
month = num2str(imonth,'%2.2i');          
year = num2str(iyear,'%4.2i');

% depth setup is frozen!!
% Select depth level
ilev = 1; % [1 ... 152] Here you can change the level of interpolation 
% Exemple:
% level  |   depth (m depth)
% 1      |   5

% Set plotting parameters
clim_sal = [35:.1:38];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['------------------------ ARGO OI ------------------------']);
disp(['Reading climatology']);

% -----------------------------------------------------------------------------------------------------------
% Read statistics and data

% -----------------------------------------------------------------------------------------------------------
% Read climatology
load('../data/SAL_CLIM');

% Extract Lon/Lat 
ilo = find(lon_clim>=box_oi(1) & lon_clim<=box_oi(2));
ila = find(lat_clim>=box_oi(3) & lat_clim<=box_oi(4));
SAL_CLIM=squeeze(SAL_CLIM(ilo,ila,ilev));

load('../data/TEM_CLIM');
TEM_CLIM=squeeze(TEM_CLIM(ilo,ila,ilev));

LAT_CLIM = lat_clim(ila); 
LON_CLIM = lon_clim(ilo);

% -------------------------------------------------------------------------------
% Read Standard deviation (netcd files)

load('../data/SAL_STD');

% select area
ilo = find(lon_std>=box_oi(1) & lon_std<=box_oi(2) );
ila = find(lat_std>=box_oi(3) & lat_std<= box_oi(4));

SAL_STD=squeeze(SAL_STD(ilo,ila,ilev));
STDBOX = sqrt(mynanmean(SAL_STD(:).^2));

% load salinity STD
load('../data/TEM_STD');

% select area
TEM_STD=squeeze(TEM_STD(ilo,ila,ilev));
STDBOX = sqrt(mynanmean(TEM_STD(:).^2));

LAT_STD = lat_std(ila); 
LON_STD = lon_std(ilo);

% --------------------------------------------------------------------------------
% Read Argo profiles data
disp(['---------------------------------------------------------']);
disp(['Reading Argo data']);

load('../data/DATA_TEMP');

load('../data/DATA_PSAL');

% End read data
% --------------------------------------------------------------------------------

% --------------------------------------------------------------------------------
% Selected observation
iprof = find(lon> box_oi(1) & lon<box_oi(2) & lat>box_oi(3) & lat<box_oi(4));

TEM = tem(ilev,iprof);
SAL = sal(ilev,iprof);
TEM_err = tem_err(ilev,iprof);
SAL_err = sal_err(ilev,iprof);
DATE = date(iprof);
LON = lon(iprof);
LAT = lat(iprof);

inan=find(isnan(TEM));
TEM(inan) = [];
SAL(inan) = [];
TEM_err(inan) = [];
SAL_err(inan) = [];
DATE(inan) = [];
LON(inan) = [];
LAT(inan)= [];

inan=find(isnan(SAL));
TEM_err(inan) = [];
SAL_err(inan) = [];
TEM(inan) = [];
SAL(inan) = [];
DATE(inan) = [];
LON(inan) = [];
LAT(inan)= [];

% Selected only few point (to shorten the computation time)
TEM_err=TEM_err(1:40:end);
SAL_err=SAL_err(1:40:end);
TEM=TEM(1:40:end);
SAL=SAL(1:40:end);
DATE=DATE(1:40:end);
LON=LON(1:40:end);
LAT=LAT(1:40:end);

% --------------------------------------------------------------------------------

disp(['---------------------------------------------------------']);
disp(['Date :',datestr(datenum(iyear,imonth,15))]);
disp(['Longitude range : ',num2str(area(1)),'/',num2str(area(2))]);
disp(['Latitude range : ',num2str(area(3)),'/',num2str(area(4))]);
disp(['Depth Level: -10 m depth']);

% --------------------------------------------------------------------------------
% First guess
disp(['---------------------------------------------------------']);

sal_bck = SAL_CLIM;
sal_bck(isnan(sal_bck)) = 0;

% --------------------------------------------------------------------------------
% Plot background

figure;
m_proj('mercator','longitude',[box_oi(1) box_oi(2)],...
                  'latitude', [box_oi(3) box_oi(4)]);
m_contourf(LON_CLIM,LAT_CLIM,sal_bck',clim_sal,'linestyle','none');
hold on;

for i=1:length(LAT)
[x,y] = m_ll2xy(LON,LAT);
scatter(x,y,10,SAL,'o','linewidth',4);
hold on;
m_plot(LON,LAT,'ko','markersize',6);
end

caxis([min(clim_sal) max(clim_sal)])
m_coast('patch',[.8 .7 .6],'edgecolor',[.5 .5 .5]);
m_grid2();
set(findobj('tag','m_grid_color'),'facecolor','none');
title(['SALINITY CLIMATOLOGY - 10 m depth - ',datestr(date_cent)]);
hc = colorbar;
set(hc,'position',[.92 .1 .01 .8]);

% --------------------------------------------------------------------------------
% Main parameters to change
% Grid size/Number of observations
Nx = length(LON_CLIM); 
Ny = length(LAT_CLIM); 
NxNy = Nx*Ny;
Nobs = length(SAL);

% --------------------------------------------------------------------------------
% Set domain size

Lx = box_oi(2)-box_oi(1); Ly = box_oi(4)-box_oi(3);
dx = Lx/(Nx-1); dy = Ly/(Ny-1); dxdy = dx*dy;
x = linspace(box_oi(1),box_oi(2),Nx);
y = linspace(box_oi(3),box_oi(4),Ny);
[xx,yy] = meshgrid(x,y);
xx = xx'; yy = yy';
XX = reshape(xx,NxNy,1);
YY = reshape(yy,NxNy,1);

% --------------------------------------------------------------------------------
% Background field (climatology)
% Rearrange in one-dimensional array.

X_b = reshape(sal_bck,NxNy,1);

% --------------------------------------------------------------------------------
% select Observations
xobs = LON;
yobs = LAT;
tobs = DATE;
Y_o  = SAL';
eobs  = SAL_err';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set OI parameters - Select here the parameters of OI
disp(['Set OI parameter']);

Rdef = 500*1e3; % Radius of correlation in meters 
Tdef = 30; % temporal correlation scale in days
sG = .5*(STDBOX.^2); % STD average over area

Tdeltad = Rdef;
Tdeltat = Tdef;

disp(['Rdef =',num2str(Rdef)]);
disp(['Tdef =',num2str(Tdef)]);
disp(['Sigma2 = ',num2str(sG)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['---------------------------------------------------------']);
disp(['Building Matrix']);

% --------------------------------------------------------------------------------
% Building Interpolation Matrix (H)
disp('Builiding H:');
tic,
H = zeros(Nobs,NxNy);
for nobs=1:Nobs

ix1 = max(find(x<=xobs(nobs)));
ix2 = min(find(x>xobs(nobs)));
iy1 = max(find(y<=yobs(nobs)));
iy2 = min(find(y>yobs(nobs)));

nn = (iy1-1)*Nx+ix1;

wx1 = (x(ix2)-xobs(nobs))*(y(iy2)-yobs(nobs))/dxdy;
wx2 = (xobs(nobs)-x(ix1  ))*(y(iy2)-yobs(nobs))/dxdy;
wx3 = (x(ix2)-xobs(nobs))*(yobs(nobs)-y(iy1  ))/dxdy;
wx4 = (xobs(nobs)-x(ix1  ))*(yobs(nobs)-y(iy1  ))/dxdy;
fprintf('Checksum %g \n',wx1+wx2+wx3+wx4)

H(nobs,nn) = wx1;
H(nobs,nn+1) = wx2;
H(nobs,nn+Nx) = wx3;
H(nobs,nn+Nx+1) = wx4;
	 
end
toc;

% --------------------------------------------------------------------------------
% Building the Matrix of Observation Covariance Error (R)
disp('Builiding R:');
tic,
R = diag(eobs.^2);
toc;

% --------------------------------------------------------------------------------
% Building covariance matrix of analyse: B
disp('Builiding B:');
tic,
for  i = 1:NxNy
	for j = 1:NxNy
	daa = sqrt(((XX(i)-XX(j))*deglat*cos(.5*(YY(i)+YY(j))*pi/180)).^2 + ((YY(i)-YY(j))*deglat).^2);
	B(i,j) = sG*exp(-daa.^2/(2.*Tdeltad.^2));
	end
end
toc;

% --------------------------------------------------------------------------------
% Building covariance matrix of observation: Coo
disp('Builiding Coo:');
tic,
for i=1:Nobs
	for j=1:Nobs
	doo = sqrt(((xobs(i)-xobs(j))*deglat*cos(.5*(yobs(i)+yobs(j))*pi/180)).^2 + ((yobs(i)-yobs(j))*deglat).^2);
	too = sqrt((tobs(i)-tobs(j)).^2);
	Coo(i,j) = sG.*exp(-doo.^2/(2.*Tdeltad.^2)-too.^2/(2.*Tdeltat.^2));
	end
end
toc;

% --------------------------------------------------------------------------------
% Building covariance matrix of observation/analysis: Cao
disp('Builiding Cao:')
tic,
Cao = zeros(NxNy,Nobs);
for i=1:NxNy
	for j=1:Nobs
	dao = sqrt(((XX(i)-xobs(j))*deglat*cos(.5*(YY(i)+yobs(j))*pi/180)).^2 + ((YY(i)-yobs(j))*deglat).^2);
	tao = sqrt((date_cent-tobs(j)).^2);
	Cao(i,j) = sG.*exp(-dao.^2./(2.*Tdeltad.^2)-tao.^2./(2.*Tdeltat.^2));
	end
end
toc;

% --------------------------------------------------------------------------------
%             Objective Analysis Algorithm
% --------------------------------------------------------------------------------
disp(['---------------------------------------------------------']);
disp(['Objective Analysis']);


% --------------------------------------------------------------------------------
% Interpolate background
Y_b = H*X_b;

% Innovation (obs minus background field)
d = Y_o  - Y_b ;

%  Compute the analysed fields.
disp('OI:')
tic,
X_a = X_b + Cao*((Coo+R)\d);
toc;

% Reshape
T_a = reshape(X_a,Nx,Ny);

% Difference analysis-background
T_d = reshape(X_a-X_b,Nx,Ny);

% Residual
delta_f = H*X_a-Y_o;

% Residual
delta_d = Y_o-H*X_b;

% Analyse Error Matrix
disp('PCTVAR:')
tic,
P_a = B - Cao*((Coo+R)\Cao');
P_var = sqrt(reshape(diag(P_a),Nx,Ny)./STDBOX.^2);
toc;

% --------------------------------------------------------------------------------
% plot Analysed fields

% --------------------------------------------------------------------------------
figure;
m_proj('mercator','longitude',[box_oi(1) box_oi(2)],...
                  'latitude', [box_oi(3) box_oi(4)]);
m_contourf(xx,yy,T_a,clim_sal,'linestyle','none');
hold on;

for i=1:length(LAT)
[x,y] = m_ll2xy(LON,LAT);
scatter(x,y,10,SAL,'o','linewidth',4);
hold on;
m_plot(LON,LAT,'ko','markersize',6);
end

caxis([min(clim_sal) max(clim_sal)])
m_coast('patch',[.8 .7 .6],'edgecolor',[.5 .5 .5]);
m_grid2();
set(findobj('tag','m_grid_color'),'facecolor','none');
title(['SALINITY ARGO - lev= 10 m depth - ',datestr(date_cent)]);
hc = colorbar;
set(hc,'position',[.92 .1 .01 .8]);

% --------------------------------------------------------------------------------
% Plot Analysis-background difference field
clim_diff = [-1:.1:1];

figure;
m_proj('mercator','longitude',[box_oi(1) box_oi(2)],...
                  'latitude', [box_oi(3) box_oi(4)]);
m_contourf(xx,yy,T_d,clim_diff,'linestyle','none');
hold on;

for i=1:length(LAT)
[x,y] = m_ll2xy(LON,LAT);
scatter(x,y,10,delta_d,'o','linewidth',4);
hold on;
m_plot(LON,LAT,'ko','markersize',6);
end

caxis([min(clim_diff) max(clim_diff)])
m_coast('patch',[.8 .7 .6],'edgecolor',[.5 .5 .5]);
m_grid2();
set(findobj('tag','m_grid_color'),'facecolor','none');
title(['SALINITY ARGO - lev= 10 m depth - ',datestr(iyear,imonth,15)]);
hc = colorbar;
set(hc,'position',[.92 .1 .01 .8]);

% --------------------------------------------------------------------------------
% Plot analysis error field
clim_err = [0:.01:1];

figure;
m_proj('mercator','longitude',[box_oi(1) box_oi(2)],...
                  'latitude', [box_oi(3) box_oi(4)]);
m_contourf(xx,yy,P_var,clim_err,'linestyle','none');
hold on;

for i=1:length(LAT)
[x,y] = m_ll2xy(LON,LAT);
m_plot(LON,LAT,'ko','markersize',6);
hold on;
m_text(LON,LAT,datestr(DATE));
end

caxis([min(clim_err) max(clim_err)])
m_coast('patch',[.8 .7 .6],'edgecolor',[.5 .5 .5]);
m_grid2();
set(findobj('tag','m_grid_color'),'facecolor','none');
title(['SALINITY ARGO - lev= 10 m depth - ',datestr(iyear,imonth,15)]);
hc = colorbar;
set(hc,'position',[.92 .1 .01 .8]);

% --------------------------------------------------------------------------------

