%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------- PreComputationViscoRegular_3D ----------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------Description---------------------------------%
% This function performs pre-computations for the efficient solution of the
% periodic BVP needed to compute the homogenized viscoelastic properties 
% of multi-phase viscoelastic materials. This function precomputes the
% element stiffness matrices needed to solve the periodic BVP for
% homogenization, and it is optimized for regular meshes. It stores the
% information in the "fem" structure. 
%
%--------------------------------Input------------------------------------
% "fem" = Structure containing the information of the Finite Element model
%
%-------------------------------Output------------------------------------
% "fem" = An updated "fem" structure with additional information computed
%         in this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fem = PreComputationViscoRegular_3D(fem)
if ~isfield(fem,'Precond'); fem.Precond='Direct';
elseif strcmp(fem.Precond,'gpu'); reset(gpuDevice); end
%% Element volumes
if ~isfield(fem,'ElemVolume'), fem.ElemVolume = Volumes(fem); end
%% Stiffness matrix
fem = femPreComputations(fem);
fprintf('PRE-CALCULATIONS FINISHED!\n');
%--------------------------- GLOBAL STIFFNESS MATRIX AND ASSEMBLY OPERATORS
function [fem] = femPreComputations(fem)
fem.ElemNDof = 3*cellfun(@length,fem.Element); % # of DOFs per element
iH = zeros(sum(fem.ElemNDof),1); indexH = 0;
fem.eDof = zeros(sum(fem.ElemNDof),1);
%% Compute element stiffness matrices
fem = TabShapeFnc(fem);
Ke = LocalK(fem); % Element stiffness matrix
% if(~isfield(fem,'k_elem')), Ke = LocalK(fem); % Element stiffness matrix
% else, Ke = fem.k_elem; end
indexK = 0; i2 = zeros(sum(fem.ElemNDof.^2),1); j = i2; k = j;
%% Obtain all stiffness matrices (k) and assembly matrices (H, S)
for el = 1:fem.NElem
  NDof = fem.ElemNDof(el); NKE = NDof^2;
  eDof = reshape([3*fem.Element{el}-2;...     % Element DOFs
                  3*fem.Element{el}-1;...
                  3*fem.Element{el}],NDof,1);
  fem.eDof(indexH+1:indexH+NDof) = eDof;
  %% Obtain 1/2 of stiffness matrix
  I = repmat(eDof ,1,NDof); J = I';
  Ke_temp = Ke; Ke_temp(I<J) = 0; Ke_temp(I==J) = Ke_temp(I==J)/2;
  J = (el-1)*24+1:el*24; J = repmat(J,24,1); I = J';
  i2(indexK+1:indexK+NKE) = I(:);
  j(indexK+1:indexK+NKE) = J(:);
  k(indexK+1:indexK+NKE) = Ke_temp(:);
  iH(indexH+1:indexH+NDof) = eDof(:);
  %% Update counters
  indexK = indexK + NKE;
  indexH = indexH + NDof;
end
a = find(k~=0);  S_k_V=sparse(i2(a),j(a),k(a));
%% Assembly matrix
base = 1:(24*fem.NElem);
elem = reshape(repmat(1:fem.NElem,24,1),[],1);
h = mod(base,24);  h(h==0) = 24;  h=(elem-1)*24+h';
H = sparse(h,iH,ones(length(h),1));
%% Singular value decompostion of the element stiffness matrix
% if(~isfield(fem,'k_elem')), fem.k_elem = reshape(Ke,24,24); end
fem.k_elem = reshape(Ke,24,24); 
fem.k_elem = (fem.k_elem+fem.k_elem')/2;
%% Material interpolation assembly matrix
fem.phi = S_k_V*H;
fem.H_T = H';
%% Material interpolation stiffness function map
fem.e = reshape(repmat(1:fem.NElem,24,1),[],1);
%------------------------------------------------- ELEMENT STIFFNESS MATRIX
function [Ke] = LocalK(fem)
eNode = fem.Element{1}; Nu0 = fem.Nu0; E0 = fem.E0;
D = E0/((1+Nu0)*(1-2*Nu0))*[1-Nu0 Nu0   Nu0   0       0       0;
                            Nu0   1-Nu0 Nu0   0       0       0;
                            Nu0   Nu0   1-Nu0 0       0       0;
                            0     0     0     1/2-Nu0 0       0;
                            0     0     0     0       1/2-Nu0 0;
                            0     0     0     0       0       1/2-Nu0];
nn = length(eNode); jj = 1;
Ke = zeros(3*nn,3*nn);
W = fem.ShapeFnc{nn,jj}.W;
for q = 1:length(W)  % Quadrature loop
  dNdxi = fem.ShapeFnc{nn,jj}.dNdxi(:,:,q);
  J0 = fem.Node(eNode,:)'*dNdxi;
  dNdx = dNdxi/J0;
  B = zeros(6,3*nn); % B matrix
  B(1,1:3:3*nn) = dNdx(:,1)';
  B(2,2:3:3*nn) = dNdx(:,2)';
  B(3,3:3:3*nn) = dNdx(:,3)';
  B(4,1:3:3*nn) = dNdx(:,2)'; B(4,2:3:3*nn) = dNdx(:,1)';
  B(5,2:3:3*nn) = dNdx(:,3)'; B(5,3:3:3*nn) = dNdx(:,2)';
  B(6,1:3:3*nn) = dNdx(:,3)'; B(6,3:3:3*nn) = dNdx(:,1)';
  Ke = Ke+B'*D*B*W(q)*det(J0);
end
%------------------------------------------------- TABULATE SHAPE FUNCTIONS
function fem = TabShapeFnc(fem)
ElemNNode = cellfun(@length,fem.Element); % number of nodes per element
fem.ShapeFnc = cell(max(ElemNNode),1);
for nn = min(ElemNNode):max(ElemNNode)
  if nn==4 % TET4
    QuadFncPtr = @TET4Quad;
    ShapeFncPtr = @TET4ShapeFnc;
  elseif nn==8 % HEX8
    QuadFncPtr = @HEX8Quad;
    ShapeFncPtr = @HEX8ShapeFnc;
  else
    fprintf('Error: Element not definied\n');
    return;
  end
  [W,Q] = QuadFncPtr();
  jj = 1;
  fem.ShapeFnc{nn,jj}.W = W;
  for q = 1:size(Q,1)
    [N,dNdxi] = ShapeFncPtr(Q(q,:));%PolyShapeFnc(nn,QMtop(q,:),fem);
    fem.ShapeFnc{nn,jj}.N(:,:,q) = N;
    fem.ShapeFnc{nn,jj}.dNdxi(:,:,q) = dNdxi;
  end
end
%---------------------------------------------------------- TET4 QUADRATURE
function [weight,point] = TET4Quad()
point = [1/4,1/4,1/4]; weight = 1/6;   
%------------------------------------------------------ TET4 SHAPE FUNCTION
function [N,dNdxi] = TET4ShapeFnc(xi)
N = [1 - xi(1) - xi(2) - xi(3); xi(1); xi(2); xi(3)];
dNdxi =  [-1, -1, -1; 1, 0, 0; 0, 1, 0; 0, 0, 1];
%---------------------------------------------------------- HEX8 QUADRATURE
function [weight,point] = HEX8Quad()
b = 1/sqrt(3);
point = [-b, b, b; -b,-b, b; b,-b, b; b, b, b;...
         -b, b,-b; -b,-b,-b; b,-b,-b; b, b,-b];
weight = [1;1;1;1;1;1;1;1];
%------------------------------------------------------ HEX8 SHAPE FUNCTION
function [N,dNxi] = HEX8ShapeFnc(xi)    
N = [(1-xi(1))*(1+xi(2))*(1+xi(3))/8;...
     (1+xi(1))*(1+xi(2))*(1+xi(3))/8;...
     (1+xi(1))*(1-xi(2))*(1+xi(3))/8;...
     (1-xi(1))*(1-xi(2))*(1+xi(3))/8;...
     (1-xi(1))*(1+xi(2))*(1-xi(3))/8;...
     (1+xi(1))*(1+xi(2))*(1-xi(3))/8;...
     (1+xi(1))*(1-xi(2))*(1-xi(3))/8;...
     (1-xi(1))*(1-xi(2))*(1-xi(3))/8];
dNxi = 1/8*[...
    -(1+xi(2))*(1+xi(3))  (1-xi(1))*(1+xi(3))  (1-xi(1))*(1+xi(2));
     (1+xi(2))*(1+xi(3))  (1+xi(1))*(1+xi(3))  (1+xi(1))*(1+xi(2));
     (1-xi(2))*(1+xi(3)) -(1+xi(1))*(1+xi(3))  (1+xi(1))*(1-xi(2));
    -(1-xi(2))*(1+xi(3)) -(1-xi(1))*(1+xi(3))  (1-xi(1))*(1-xi(2));
    -(1+xi(2))*(1-xi(3))  (1-xi(1))*(1-xi(3)) -(1-xi(1))*(1+xi(2));
     (1+xi(2))*(1-xi(3))  (1+xi(1))*(1-xi(3)) -(1+xi(1))*(1+xi(2));
     (1-xi(2))*(1-xi(3)) -(1+xi(1))*(1-xi(3)) -(1+xi(1))*(1-xi(2));
    -(1-xi(2))*(1-xi(3)) -(1-xi(1))*(1-xi(3)) -(1-xi(1))*(1-xi(2))];
%---------------------------------------------------------- ELEMENT VOLUMES
function ElemVolume = Volumes(fem)
ElemVolume = zeros(fem.NElem,1);
[~,ElemVolume1] = convhulln(fem.Node(fem.Element{1},:));
ElemVolume(:) = ElemVolume1;
%-------------------------------------------------------------------------%