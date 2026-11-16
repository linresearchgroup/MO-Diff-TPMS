% [ U, L, s ] = PeriodicFEA_3D( fem, E )
%--------------------------------Input------------------------------------
% "fem" = Structure containing the Finite Element discretization of the
%         domain as well as pre-computed element stiffness matrix and
%         assembly information. These are done in the functions 
%         <a href="matlab: open('initialComputations_regular')">preComputations_regular</a>, or <a href="matlab: open('initialComputations_polygonal')">preComputations_polygonal</a>;
% "E" = Material interpolation stiffness function;
%-------------------------------Output------------------------------------
% "U" = Displacement vector result of the Finite Element Method;
% "L" = Lower triangular matrix resulting from the Cholesky decompostion of
%       the stiffness matrix;
% "s" = Permuation vector of the Cholesky decomposition;
%__________________________________________________________________________
function [U,fem] = PeriodicFEA_3D(fem,E)
if(~isfield(fem,'tichnov'))
  fem.tichnov=0;
end
if(~isfield(fem,'tol_pcg'))
  fem.tol_pcg=10^-6;
end
% Assemble stiffness matrix
if~(strcmp(fem.precond,'gpu'))
  if(fem.Reg==0)
    K = sparse(fem.i,fem.j,(E(fem.e,1)+1i*E(fem.e,2)).*fem.k);
    K = (K+K.')/2;    
  else
    E_matrix=sparse(1:24*fem.NElem,1:24*fem.NElem,E(fem.e,1)+1i*E(fem.e,2));
    K=fem.H_T*E_matrix*fem.phi;
    K=K+K.';
  end
else
  E_matrix=sparse(1:24*fem.NElem,1:24*fem.NElem,E(fem.e,1)+1i*E(fem.e,2));
  K=fem.H_T*E_matrix*fem.phi;
  K=K+K.'; % I added this
end
K=K+speye(size(K,1))*fem.tichnov;

% APPLY PERIODIC BOUNDARY CONDITIONS
d_o = fem.d{1}; d_e = fem.d{2}; d_v = fem.d{3}; d_i = fem.d{4};
Lx=fem.Lx; Ly=fem.Ly; Lz=fem.Lz; ee=eye(6,6); w=zeros(length(d_o),6);
fem.u_v=zeros(length(d_v),6);
% Xv = [0 0 0;0 Ly 0; Lx Ly 0; Lx 0 0;0 0 Lz;0 Ly Lz; Lx Ly Lz; Lx 0 Lz]; % Coordinates of vertices A,...,H
Xv = [0 0 0;Lx 0 0; Lx Ly 0; 0 Ly 0;0 0 Lz;Lx 0 Lz; Lx Ly Lz; 0 Ly Lz]; % Coordinates of vertices A,...,H
Nx = round(fem.NElem^(1/3)); % Number of elements per dimension
Ne = (Nx-1); % Number of nodes per edge (excluding corners)
Nf = Ne^2; % Number of interior nodes per face
% All prescribed displacements
for ii=1:6
ex=ee(ii,1); ey=ee(ii,2); ez=ee(ii,3); 
% exy=ee(ii,4); eyz=ee(ii,5); exz=ee(ii,6);
exy=0.5*ee(ii,4); eyz=0.5*ee(ii,5); exz=0.5*ee(ii,6);  
em = [ex exy exz;exy ey eyz;exz eyz ez];
fem.w(:,ii)=-[repmat(em*[Lx;0;0],Nf,1);...
          repmat(em*[0;Ly;0],Nf,1);...
          repmat(em*[0;0;Lz],Nf,1);...
          repmat(em*[Lx;Ly;0],Ne,1);...
          repmat(em*[0;Ly;Lz],Ne,1);...
          repmat(em*[Lx;0;Lz],Ne,1);...
          repmat(em*[-Lx;Ly;0],Ne,1);...
          repmat(em*[0;Ly;-Lz],Ne,1);...
          repmat(em*[Lx;0;-Lz],Ne,1)];
fem.u_v(:,ii) = reshape([ex exy exz;exy ey eyz; exz eyz ez]*Xv',24,1);
end
% REDUCED STIFFNESS MATRIX AND LOAD VECTOR (CONDENSE DOFs)
Kr = [K(d_i,d_i),             K(d_i,d_e)+K(d_i,d_o);...
      K(d_o,d_i)+K(d_e,d_i),  K(d_o,d_e)+K(d_e,d_e)+K(d_o,d_o)+K(d_e,d_o)];  % Reduced stiffness matrix for periodic BVP
Fr = -[K(d_i,d_v);K(d_o,d_v)+K(d_e,d_v)]*fem.u_v-[K(d_i,d_o);K(d_o,d_o)+K(d_e,d_o)]*fem.w; % Equivalent force vector after condensing DOFs and applying periodicity
% SOLVE PERIODIC BVP
U = zeros(3*fem.NNode,6);
U(d_v,:)=fem.u_v;
[U([d_i;d_e],:),fem] = SolveLinearSystem(Kr,Fr,fem);
U(d_o,:) = U(d_e,:)+fem.w;

% % ------------- PLOT DEFORMED SHAPES
% v = [d_o;d_e;d_v]; v=v(3:3:end)./3;
% vo = d_o(3:3:end)/3;
% ve = d_e(3:3:end)/3;
% vv = d_v(3:3:end)/3;
% 
% for m=1:6
% subplot(2,3,m);
% U1=[U(1:3:end,m),U(2:3:end,m),U(3:3:end,m)];
% Node=fem.Node+U1;
% plot3(Node(vo,1),Node(vo,2),Node(vo,3),'r.',...
%       Node(ve,1),Node(ve,2),Node(ve,3),'g.',...
%       Node(vv,1),Node(vv,2),Node(vv,3),'bo');
% grid on; hold on
% xlabel('x'); ylabel('y'); zlabel('z'); axis equal
% drawnow
% end



function [U,fem] = SolveLinearSystem(K,F,fem)
maxiter = 20000; NL = size(F,2);
switch(fem.precond)
  case('Cholesky')
    if ~isfield(fem,'U'); fem.U=zeros(size(F)); end
    alpha = 0.1;% max(sum(abs(KK),2)./diag(KK))-2;struct('michol','on')
    L = ichol(K,struct('type','ict','droptol',1e-2,'diagcomp',alpha));
    M1 = L; M2 = L'; L_T=M2; U=fem.U;
    for ii=1:NL
%       [U(:,ii),~,] = bicg(K,F(:,ii),fem.tol_pcg,maxiter,M1,M2,fem.U(:,ii)); % Third fastest
%       [U(:,ii),~,] = cgs(K,F(:,ii),fem.tol_pcg,maxiter,M1,M2,fem.U(:,ii)); % Slowest
      [U(:,ii),~,] = bicgstab(K,F(:,ii),fem.tol_pcg,maxiter,M1,M2,fem.U(:,ii)); % Fastest
%       [U(:,ii),~,] = qmr(K,F(:,ii),fem.tol_pcg,maxiter,M1,M2,fem.U(:,ii)); % Second fastest
    end
    fem.U=U;
  case('Diagonal')
    if ~isfield(fem,'U'); fem.U=zeros(size(F)); end
    D=sparse(1:length(K),1:length(K),diag(K)); U=fem.U;
%     K = [real(K), -imag(K); imag(K),]
    for ii=1:NL
%       % Biconjugate gradients method (third fastest)
%       [U(:,ii),~] = bicg(K,F(:,ii),fem.tol_pcg,maxiter,D,[],fem.U(:,ii)); 
%       % Conjugate gradients squared method (slowest)
%       [U(:,ii),~] = cgs(K,F(:,ii),fem.tol_pcg,maxiter,D,[],fem.U(:,ii));       
      % Biconjugate gradients stabilized method (fastest)
      auditTimer=tic;
      [U(:,ii),auditFlag,auditRelres,auditIter,auditResvec] = bicgstab(K,F(:,ii),fem.tol_pcg,maxiter,D,[],fem.U(:,ii));
      auditAbs=norm(K*U(:,ii)-F(:,ii)); auditRHS=norm(F(:,ii));
      if auditRHS>0, auditTrue=auditAbs/auditRHS; else, auditTrue=auditAbs; end
      auditPath=getenv('TPMS_DIAGNOSTICS_FILE');
      auditExists=isfile(auditPath); auditF=fopen(auditPath,'a');
      if ~auditExists, fprintf(auditF,'Case,LoadCase,Flag,ReportedRelativeResidual,TrueRelativeResidual,AbsoluteResidual,RHSNorm,Iterations,Seconds,Tolerance,MaxIterations\n'); end
      fprintf(auditF,'%s,%d,%d,%.17g,%.17g,%.17g,%.17g,%.17g,%.17g,%.17g,%d\n',getenv('TPMS_AUDIT_CASE'),ii,auditFlag,auditRelres,auditTrue,auditAbs,auditRHS,auditIter,toc(auditTimer),fem.tol_pcg,maxiter); fclose(auditF);
      writematrix(auditResvec,fullfile(fileparts(auditPath),sprintf('residual_%s_load%d.csv',getenv('TPMS_AUDIT_CASE'),ii)));
      fprintf('DIAGNOSTIC %s load=%d flag=%d relres=%.6g true=%.6g iter=%.1f\n',getenv('TPMS_AUDIT_CASE'),ii,auditFlag,auditRelres,auditTrue,auditIter);
%       % Quasi-minimal residual method (second fastest)
%       [U(:,ii),~] = qmr(K,F(:,ii),fem.tol_pcg,maxiter,D,[],fem.U(:,ii));
    end
%     U = pcg(K,F,fem.tol_pcg,maxiter,D,[],fem.U);
    fem.U=U;
  case('Direct')
    U = K\F; 
  case('gpu')
    if ~isfield(fem,'gU'); fem.gU=zeros(size(F)); end
    nK=length(K);
%     L_T=gpuArray(sparse(1:nK,1:nK,spdiags(K,0)*2));
    L_T=gpuArray(sparse(1:nK,1:nK,spdiags(K,0)));
    K=gpuArray(K);
%     K=K+K.';
    U = gpuArray(fem.gU);
    for ii=1:NL
%     [U(:,ii),~] = bicg(K,gpuArray(F(:,ii)),fem.tol_pcg,maxiter,L_T,[], gpuArray(fem.gU(:,ii)));
%     [U(:,ii),~] = cgs(K,gpuArray(F(:,ii)),fem.tol_pcg,maxiter,L_T,[], gpuArray(fem.gU(:,ii)));
      [U(:,ii),~] = bicgstab(K,gpuArray(F(:,ii)),fem.tol_pcg,maxiter,L_T,[], gpuArray(fem.gU(:,ii)));
%     [U(:,ii),~] = qmr(K,gpuArray(F(:,ii)),fem.tol_pcg,maxiter,L_T,[], gpuArray(fem.gU(:,ii)));
    end
    U = gather(U);
    fem.gU = U;
  otherwise
    %r=symrcm(KK);
    [K,~,s] = chol(K,'lower','vector');
    L_T=K';
    x(s) =L_T\(K\F(s));
    U = x;
end

% function U = SolveLinearSystem(K,F,fem)
% L_T=[]; s=[]; maxiter = 20000; NL = size(F,2);
% switch(fem.precond)
%   case('Cholesky')
%     if ~isfield(fem,'U'); fem.U=zeros(size(F)); end
%     alpha = 0.1;% max(sum(abs(KK),2)./diag(KK))-2;struct('michol','on')
%     L = ichol(K,struct('type','ict','droptol',1e-2,'diagcomp',alpha));
%     M1 = L; M2 = L'; L_T=M2; U=fem.U;
%     for ii=1:NL
%       [U(:,ii),~,] = pcg(K,F(:,ii),fem.tol_pcg,maxiter,M1,M2,fem.U(:,ii));
%     end
% %     [U,~,~,nit] = pcg(K,F(:,1),fem.tol_pcg,maxiter,M1,M2,fem.U);
%     fem.U=U;
%   case('Diagonal')
%     if ~isfield(fem,'U'); fem.U=zeros(size(F)); end
%     D=sparse(1:length(K),1:length(K),diag(K)); U=fem.U;
%     for ii=1:NL 
%       [U(:,ii),~] = pcg(K,F(:,ii),fem.tol_pcg,maxiter,D,[],fem.U(:,ii)); 
%     end
% %     U = pcg(K,F,fem.tol_pcg,maxiter,D,[],fem.U);
%     fem.U=U;
%   case('Direct')
%     U = K\F; 
%   case('gpu')
%     nK=length(K);
%     L_T=gpuArray(sparse(1:nK,1:nK,spdiags(K,0)*2));
%     K=gpuArray(K);
%     K=K+K.';
%     fem.gU = gather(pcg(K,gpuArray(fem.gF),fem.tol_pcg,maxiter,L_T,[], gpuArray(fem.gU)));
%     U=fem.gU;
%   otherwise
%     %r=symrcm(KK);
%     [K,~,s] = chol(K,'lower','vector');
%     L_T=K';
%     x(s) =L_T\(K\F(s));
%     U = x;
% end