function [a] = odvpal(fine)
% ODVPAL  Creates a Ocean Data View-like palette
%
%	This command allow the user to specify the number of 
%	colours in a Ocean Data View-like palette.
%
%	>> odvpal(13);
%
%	This will produce a palette with exactly 13 colours in
%	it (equal to the number used to definte the palette).  
% The colours used are drawn from a estimate of the
% Ocean Data View palette.
% 
% Andrew Yool (axy@noc.soton.ac.uk), 15 May 2008.

basefine = 1000;

pal = [0.95   0.80   0.95;
       0.85   0.40   0.85;
       0.55   0.50   0.85;
       0.10   0.35   0.95;
       0.60   0.95   0.90;
       0.25   0.75   0.45;
       0.10   0.86   0.15;
       0.55   0.85   0.40;
       0.95   0.95   0.00;
       1.00   0.65   0.05;
       0.90   0.45   0.00;
       1.00   0.05   0.20;
       1.00   0.85   0.65];

szpal = max(size(pal));
     
clear pal2;
basefine=basefine + 1;

if basefine<0
pal2=pal;
else
pal2(1,:)=pal(1,:);
for i=1:1:(szpal-1)
	pos=((i-1)*basefine)+1;
	stepr=(pal(i,1) - pal(i+1,1))/basefine;
	stepg=(pal(i,2) - pal(i+1,2))/basefine;
	stepb=(pal(i,3) - pal(i+1,3))/basefine;
	for j=1:1:basefine
		pal2(pos+j,1)=pal(i,1) - (stepr*j);
		pal2(pos+j,2)=pal(i,2) - (stepg*j);
		pal2(pos+j,3)=pal(i,3) - (stepb*j);
	end
end
end
pal2(pal2 < 0) = 0; pal2(pal2 > 1) = 1;
bigpal = max(size(pal2));

if fine < 2
	pal3 = pal2(1,:);
elseif fine == 2
	pal3(1,:) = pal2(1,:);
	pal3(fine,:) = pal2(end,:);
elseif fine > 10000
	error (' Please be serious - do you really want such a large palette?');
else
	pal3(1,:) = pal2(1,:);
	pal3(fine,:) = pal2(end,:);
	
	t1 = bigpal - fine;
	t2 = (t1 / (fine - 1));
	pos = 1;
	for i = 2:1:(fine - 1)
		pos = pos + t2 + 1;
		pos2 = round(pos);
		pal3(i,:) = pal2(pos2,:);
	end
end

colormap(pal3);
a = pal3;

% This is the ODV palette as I originally sampled it from
% an ODV plot (using Paint Shop Pro to give me the numbers)
% pal=[0.9412    0.7843    0.9412;
%      0.8706    0.3922    0.8431;
%      0.5490    0.5098    0.8627;
%      0.1176    0.3529    0.9412;
%      0.6078    0.9412    0.9020;
%      0.2353    0.7451    0.4706;
%      0.1176    0.8627    0.1569;
%      0.5490    0.8627    0.3922;
%      0.9020    0.9020    0.2549;
%      1.0000    0.6471    0.0588;
%      0.9020    0.4510         0;
%      1.0000    0.0588         0;
%      0.9843    0.0588    0.1961;
%      1.0000    0.8627    0.6667];
