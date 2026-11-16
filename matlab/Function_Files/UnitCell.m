%------------------------------ PolyMesher -------------------------------%
% Ref: C Talischi, GH Paulino, A Pereira, IFM Menezes, "PolyMesher: A     %
%      general-purpose mesh generator for polygonal elements written in   %
%      Matlab," Struct Multidisc Optim, DOI 10.1007/s00158-011-0706-z     %
%-------------------------------------------------------------------------%
function [x] = UnitCell(Demand,Arg)
%   b = 100; BdBox = b.*[0 1 0 1 0 1];
%   b = 2*pi; BdBox = 0.5*b.*[-1 1 -1 1 -1 1];
  b = 2*pi; BdBox = b.*[0 1 0 1 0 1];
  switch(Demand)
    case('Dist');   x = DistFnc(Arg,BdBox);
    case('BC');     x = BndryCnds(Arg{:},BdBox);
    case('BdBox');  x = BdBox;
    case('PFix');   x = FixedPoints(BdBox);
    case('MD');     x = MatDef();     
    case('Normal'); x = Normal(Arg{:});        
  end
%----------------------------------------------- COMPUTE DISTANCE FUNCTIONS
function Dist = DistFnc(P,BdBox)
  Dist = dBox(P,BdBox(1),BdBox(2),BdBox(3),BdBox(4),BdBox(5),BdBox(6));
%---------------------------------------------- SPECIFY BOUNDARY CONDITIONS
function [x] = BndryCnds(Node,Element,BdBox)
  Supp = [];
  Load = [];
  x = {Supp,Load};
%----------------------------------------------------- SPECIFY FIXED POINTS
function [PFix] = FixedPoints(BdBox)
  PFix = [];
%----------------------------------- SPECIFY MATERIAL PROPERTIES AND COLORS
function [x] = MatDef()
  Color = [0 0 1;  %blue % Color of base materials
           1 0 0;  %red
           0 1 0]; %green
  x = {MatModel,MatParam,Color};
%---------------------------------------------------------- SPECIFY NORMALS  
function [x] = Normal(P,n1,n2,n3)
  n1 = repmat([-1  1  0  0  0  0  0],size(n1,1),1);
  n2 = repmat([ 0  0 -1  1  0  0  0],size(n2,1),1);
  n3 = repmat([ 0  0  0  0 -1  1  0],size(n3,1),1);
  x = {n1,n2,n3};  
%-------------------------------------------------------------------------%