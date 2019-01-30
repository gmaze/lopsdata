function str = num2lat(lon,fmt)
if nargin<2
   fmt = '%1.0f';
end
if length(lon)==1
   str = strlon(lon,fmt);
else
   for nl=1:length(lon)
       str{nl} = strlon(lon(nl),fmt);
   end;
end;

function str = strlon(lon,fmt)
if lon>=0
   str = sprintf([fmt char(176) 'E'],lon);

else
   str = sprintf([fmt char(176) 'W'],-lon);

end
