function a = sfile(fig,filename);
%sauvgarde d'une image 'fig' en .EPSC, dans le répertoire associé au 'chap' voulu sous le nom 'filename' 

figure(fig);
orient portrait;
strfilename = strcat('~/Documents/NK_Documents/Manuscrit/manuscrit/figures/',filename);
print(fig,'-zbuffer','-depsc','-r200',strcat(strfilename,'.eps'));

