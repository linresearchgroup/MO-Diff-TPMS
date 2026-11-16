%------------------------------ PolyTop ----------------------------------%
% Ref: C Talischi, GH Paulino, A Pereira, IFM Menezes, "PolyTop: A Matlab %
% implementation of a general topology optimization framework using       %
% unstructured polygonal finite element meshes", Struct Multidisc Optim,  %
% DOI 10.1007/s00158-011-0696-x                                           %
%-------------------------------------------------------------------------%
function [E,dEdy,V,dVdy] = MultiMatIntFncVisc(y,MatIntFncR,MatIntFncI,Ep,Epp,param)
eps = 1e-4;  %Ersatz stiffness
gamma = param;
[w{1},dwdy{1},V,dVdy] = MatIntFncR(y); % w1 = rho^p1 (for storage modulus)
[w{2},dwdy{2},~,~] = MatIntFncI(y); % w1 = rho^p2 (for loss modulus)
NElem = size(y,1); NMat = size(y,2);
E = cell(1,1); E{1} = zeros(NElem,2);
dEdy = cell(1,1); dEdy{1} = zeros(NElem,NMat,2);
E0 = [Ep, Epp];
for ii=1:2
  % Compute E
  S = 1-(gamma(ii).*w{ii});
  Prod = ones(NElem,NMat);
  for m = 1:NMat-1
    S = [S(:,NMat),S(:,1:NMat-1)];
    Prod = Prod.*S;
  end
  E{1}(:,ii) = (w{ii}.*Prod)*E0(:,ii);
  E{1}(:,ii) = eps + (1-eps).*E{1}(:,ii);
  % Compute dEdy
  dEdw = zeros(NElem,NMat);
  for m = 1:NMat
    S2 = 1-(gamma(ii).*w{ii});
    S2(:,m) = ones(NElem,1);
    dProd = ones(NElem,NMat);
    for j = 1:NMat-1
      S2 = [S2(:,NMat),S2(:,1:NMat-1)];
      dProd = dProd.*S2;
    end  
    w_tmp = -gamma(ii).*w{ii};
    w_tmp(:,m) = ones(NElem,1);
    dEdw(:,m) = (w_tmp.*dProd)*E0(:,ii);
  end
  dEdw = (1 - eps).*dEdw;
  dEdy{1}(:,:,ii) = dwdy{ii}.*dEdw;
end
%-------------------------------------------------------------------------%