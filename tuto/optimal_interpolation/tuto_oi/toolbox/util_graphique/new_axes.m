function ax = new_axes(ny,nx,dy,dx,ylim,xlim)
% NEW_AXES	define new_axes for subplots
% SYNTAX
%  ax = new_axes(ny,nx,ylim,xlim,dy,dx)
% REQUIRED PARAMETERS
%  	ny = number of lines
%	nx = number of columns
% OPTIONAL PARAMETERS
%	dy = space between successive plots along lines (default: .02)
%	dx = space between successive plots along columns (default: .02)
%       ylim = limits of the figure along lines (default: [.05 .95])
%	xlim = limits of the figure along columns (default: [.05 .95])

if nargin<6
   xlim = [.05 .95];
end
if nargin<5 | isempty(ylim)
   ylim = [.05 .95];
end
if nargin<4 | isempty(dx)
   dx = .02;
end
if nargin<3 | isempty(dy);
   dy = .02;
end

dxw = (diff(abs(xlim))-(nx-1)*dx)/nx;
dyw = (diff(abs(ylim))-(ny-1)*dy)/ny;

ax = [];
for j=1:ny
    for i=1:nx
        xx = xlim(1) + (i-1)*(dxw+dx);
        yy = ylim(end) - j*dyw -(j-1)*dy;
        ax = [ax; xx yy dxw dyw];
    end;
end; 
