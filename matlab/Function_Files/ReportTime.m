function ReportTime(t,string)
if t<=60; fprintf([string,': %i seconds \n'], round(t));
elseif t<=3600; fprintf([string,': %1.1f minutes \n'], t/60);
elseif t<=86400; fprintf([string,': %1.1f hours \n'], t/3600);
else; fprintf([string,': %1.1f days \n'], t/86400); 
end