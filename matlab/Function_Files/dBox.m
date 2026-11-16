%------------------------------ PolyMesher -------------------------------%
% Ref: C Talischi, GH Paulino, A Pereira, IFM Menezes, "PolyMesher: A     %
%      general-purpose mesh generator for polygonal elements written in   %
%      Matlab," Struct Multidisc Optim, DOI 10.1007/s00158-011-0706-z     %
%-------------------------------------------------------------------------%
%                                                                         %
%----------------- PolyMesher3D version: 1.2 (Ago14) ---------------------%
% PolyMesher3D developed by Anderson Pereira                              %
% Contact: anderson@tecgraf.puc-rio.br                                    %
%-------------------------------------------------------------------------%
function d = dBox(P,x1,x2,y1,y2,z1,z2)
d = [x1-P(:,1), P(:,1)-x2, y1-P(:,2), P(:,2)-y2, z1-P(:,3), P(:,3)-z2];
d = [d,max(d,[],2)];
%-------------------------------------------------------------------------%