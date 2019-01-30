function str = num2lat(lat,fmt)
if nargin<2
   fmt = '%1.0f';
end
if length(lat)==1
   str = strlat(lat,fmt);
else
   for nl=1:length(lat)
       str{nl} = strlat(lat(nl),fmt);
   end;
end;

function str = strlat(lat,fmt)
if lat>0
%     str = sprintf([fmt char(176) 'N'],lat);
   str = [num2str(lat,2) '^\{circ}N']);
elseif lat<0
%     str = sprintf([fmt char(176) 'S'],-lat);
   str = [num2str(lat,2) '^\{circ}S']);
else
   str = sprintf(['Eq.']);
end
