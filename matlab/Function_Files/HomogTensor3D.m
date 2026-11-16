%-------------------- HOMOGENIZED MODULI MATRIX
function [Ep,Gp,Epp,Gpp] = HomogTensor3D(fem,E)
[U,fem] = PeriodicFEA_3D(fem,E);
Q = zeros(6,6);
for ii = 1:6
  for jj = 1:6
    Ui = (reshape(U(fem.eDof,ii),24,[]));
    Uj = (reshape(U(fem.eDof,jj),24,[]));
    qe_ij = sum(reshape((sum(Ui.*(fem.k_elem*Uj))),fem.NElem,[]),2)./...
               (fem.Lx*fem.Ly*fem.Lz);
    Q(ii,jj) = E(:,1).'*qe_ij+1i*E(:,2).'*qe_ij;
  end
end
Dp = real(Q); Dpp = imag(Q);
Dp(4:6,1:3) = 0; Dp(1:3,4:6) = 0; Dpp(4:6,1:3) = 0; Dpp(1:3,4:6) = 0;
Dp(5:6,4) = 0; Dp(4,5:6) = 0; Dp(6,5) = 0; Dp(5,6) = 0;
Dpp(5:6,4) = 0; Dpp(4,5:6) = 0; Dpp(6,5) = 0; Dpp(5,6) = 0;
Sp = inv(Dp); Ep = 1/Sp(1,1); Gp = 1/Sp(4,4);
Spp = inv(Dpp); Epp = 1/Spp(1,1); Gpp = 1/Spp(4,4);