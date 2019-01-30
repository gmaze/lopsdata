function a = sfile2(fig,filename);
%sauvgarde d'une image 'fig' en .EPSC, dans le répertoire associé au 'chap' voulu sous le nom 'filename' 

figure(fig);
orient portrait;
strfilename = strcat('~/documents/NK_Documents/Manuscrit/manuscrit/article/figures_new/',filename);
%saveas(gcf,strfilename,'epsc');

print(gcf,'-zbuffer','-deps','-r200',strcat(strfilename,'.eps'));
