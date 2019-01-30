function a = sfile(fig,filename);
%sauvgarde d'une image 'fig' en .EPSC, dans le répertoire associé au 'chap' voulu sous le nom 'filename' 

figure(fig);
orient portrait;
strfilename = strcat('/home2/sauvgardes/documents/Article_GG/figures_new/',filename);
print(fig,'-zbuffer','-depsc','-r600',strfilename);
print(fig,'-zbuffer','-dpng','-r600',strfilename);
print(fig,'-dpsc','-r600',strfilename);
%saveas(gcf,strfilename,'epsc');

