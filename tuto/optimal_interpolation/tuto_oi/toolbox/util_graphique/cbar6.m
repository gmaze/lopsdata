function [nc,ax]=cbar(ax,ext,units,clim,nc,fs,eq,txtplace);
%cbar(ax,ext,units,clim,nc,fs,eq,txtplace);
%   Place une barre de couleur dans ax. Si ax est 'v' ou 'h', le 
%   graphe courant est r?duit pour laisser place ? une bar de couleur 
%   verticale ou horizontale.
% ext              est le vecteur des 2 extremes du parametre. 
% units            est l'unite du parametre.
% clim (optionnel) est applique par caxis(clim). Par defaut, clim=ext.
% nc (optionnel)   est le nb approximatif de cases ou le vecteur des 
%                  valeurs affichees dans la colorbar.
% fs (optionnel)   est la taille des fontes.
% eq (opt) est l'equation de transformation des valeurs affichees
%          avec x pour inconnue. Ex: '10.^(x*2-1)'.
% txtplace (opt)   est la place des textes par rapport aux cases (1 ou 0) 
%                  1 (par def) = sur les limites; 0 = sur les cases;
%Si clim est plus etroit que ext, la colorbar se fera entre les lim de
%clim avec des signes < et > aux extremes.
%
% Si les arguments optionnels sont mis a [], l'argument par defaut est
% applique.
%
% [nc,ax]=cbar(ax,ext,units,clim,nc,fs)
%   donne en sortie le nb de cases effectif et le handle des axes

axcurr=gca;

% efface une cbar 'v' ou 'h' precedente si elle existe, et remet les axes
% principaux a leur taille d'origine
%if isstr(ax),
%  figch = get(gcf,'Children');
%  for ii=1:length(figch), 
%    tag = get(figch(ii),'Tag');
%    if strcmp(tag,'cbar'),
%      delete(figch(ii));
%    elseif strcmp(tag,'axcurrv'),
%      acp=get(figch(ii),'Posi');
%      acp(3)=acp(3);
%      set(figch(ii),'Posi',acp);
%    elseif strcmp(tag,'axcurrh'),
%      acp=get(figch(ii),'Posi');
%      acp(4)=acp(4);
%      acp(2)=acp(2)-acp(4)*.0;
%     set(figch(ii),'Posi',acp);
%    end
%  end
%end

if isstr(ax),
   acp=get(axcurr,'Posi');
   if ax(1)=='v', 
      axposi=[acp(1)+acp(3)*0.9 acp(2)+acp(4)*.15 acp(3)*.05 acp(4)*.7];
      acp(3)=acp(3);
      set(axcurr,'Posi',acp,'Tag','axcurrv');
      ax=axes('Posi',axposi);
   elseif ax(1)=='h',
      axposi=[acp(1)+acp(3)*.15 acp(2) acp(3)*.7 acp(4)*.05];
      acp(2)=acp(2)+acp(4)*.0;
      acp(4)=acp(4);
      set(axcurr,'Posi',acp,'Tag','axcurrh');
      ax=axes('Posi',axposi);
   else
      error('The 1st argument is an axes handle, or ''v'', or ''h''');
   end;
end; 
pos=get(ax,'Posi');
if pos(4)>pos(3), vert=1; leng=pos(4); else vert=0; leng=pos(3); end;
if nargin<8 | isempty(txtplace), txtplace = 1; end;
if nargin<6 | isempty(fs), fs=round(leng*8+5.6); if ~vert, fs=fs-1; end; end;
if nargin<5 | isempty(nc), nc=leng*15; end;
if nargin<4 | isempty(clim), clim=ext; end;
ext=sort(ext);
clim=sort(clim);
if ext(1)==ext(2), lcol=clim+[0 eps]; else lcol=clim; end; 
B=ext; sg1=''; sg2='';
if length(nc)==1,
  if ext(1)<clim(1), B(1)=clim(1); sg1='<'; end;
  if ext(2)>clim(2), B(2)=clim(2); sg2='>'; end; 
  [x,nc]=divrond(B,nc);
else
  x=nc(:); 
  nc=length(x);
  if ext(1)<x(1), sg1='<'; end;
  if ext(2)>x(end), sg2='>'; end;   
end

if nargin < 7 | isempty(eq),
  xtextval=x;
else
  xtextval=eval(eq);
end

axes(ax);
hold off;
if vert,
   pcolor([x x;lcol(2) lcol(1)]);
else
   pcolor([x' lcol(2);x' lcol(1)]);
end;   
caxis(lcol);
axis off;
if vert,
   set(gca,'XLim',[1 2],'YLim',[1 nc+1]);
else
   set(gca,'XLim',[1 nc+1],'YLim',[1 2]);   
end
blkunits=[];
for i=1:length(units), blkunits=[blkunits,' ']; end;
for i=1:8:nc,
   if txtplace, ix = i; else ix = i+0.5; end;
   if vert,
      %tleg(i)=text(4,i,num2str(xtextval(i)),'FontSize',fs,'Horizo','right');
      tleg(i)=text(2.5,ix,num2str(xtextval(i)),'FontSize',fs,'FontWeight','b','Horizo','left');
   else
      tleg(i)=text(ix,0.8,num2str(xtextval(i)),'FontSize',fs,'FontWeight','b','Horizo','center','Vertical','top');
   end;
   if i==1, set(tleg(i),'String',[sg1,num2str(xtextval(i))]);end;
   if i==nc, set(tleg(i),'String',[sg2,num2str(xtextval(i))]);end;
   if vert
     if i==1,
      set(tleg(i),'String',[get(tleg(i),'String'),' ',units]);
     else
      set(tleg(i),'String',[get(tleg(i),'String'),' ',blkunits]); 
     end
     tl=get(tleg(i),'Extent');
     tlx(i)=tl(3);
   else
      if i==nc, text(i+1,0.8,units,'FontSize',fs,'FontWeight','b','Horizo','left','Vertical','top');end;
   end
end;
if vert,
%   tlx=max(tlx)*1.2+2;
%   tlx=max(tlx)+1;
%   for i=1:nc,   
%      set(tleg(i),'Position',[tlx,i]);
%   end;
end

set(gca,'Tag','cbar');
axes(axcurr);

function [y,nc]=divrond(x,n);
%function [y,nc]=divrond(x,n);
%Genere un vecteur de 'chiffres ronds' d'une longueur nc autour de n;
%x est le vecteur ou la matrice d'entree.
eps=1e-10;
xx=max(x(:));
xn=min(x(:));
dx=(xx-xn)/n;
if dx==0,
% y=[xn;xx];
% nc=2;
 y=xn;
 nc=1;
else
 a=ceil(log10(dx)); odg=10.^a;
 dx2=round(dx*2/odg)*odg/2;
 xn2=floor(xn/odg+eps)*odg;
 if dx2==0,  dx2=round(dx/(odg/10))*(odg/10); end;
    y=(xn2:dx2:xx)';
    y=y(y>=xn-eps);
    y(abs(y)<abs(dx)*1e-2)=0;
    if length(y)<=n/2, 
      dx2=dx2/2;
      if xn2-dx2>=xn, xn2=xn2-dx2; end;
      y=(xn2:dx2:xx)';
      y=y(y>=xn-eps);
    end;
    nc=length(y);
end;

