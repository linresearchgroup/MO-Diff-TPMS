%--------------------------- HomogVisco3D -------------------------------%
function [out, fem] = Homog_TPMS_Visco3(fem, t1, t2, Ep, Epp, Color)

%% Validate material inputs

Ep  = Ep(:);
Epp = Epp(:);

if numel(Ep) ~= numel(Epp)
    error('Ep and Epp must contain the same number of materials.');
end

NMatCurrent = numel(Ep);

if NMatCurrent < 1
    error('At least one material must be provided.');
end

if nargin < 6
    Color = [];
end


%% Generate mesh and perform precomputation only once

if ~isstruct(fem)

    Nx = 50;  % Number of elements in each direction

    [Node, Element, ~, ~, ElemCtrd] = ...
        RegMesher(@UnitCell, Nx, Nx, Nx);

    BDofs = BdryNodes(Node);

    b = max(Node(:,1)) - min(Node(:,1));

    fem = struct( ...
        'NNode', size(Node,1), ...
        'NElem', size(Element,1), ...
        'Node', Node, ...
        'Element', {Element}, ...
        'ElemCtrd', ElemCtrd, ...
        'd', {BDofs}, ...
        'Lx', b, ...
        'Ly', b, ...
        'Lz', b, ...
        'Nu0', 0.3, ...
        'E0', 1, ...
        'Ep', Ep, ...
        'Epp', Epp, ...
        'NMat', NMatCurrent, ...
        'Color', Color, ...
        'cutoff', 0.5, ...
        'Reg', 1, ...
        'precond', 'gpu');

    fem = PreComputationViscoRegular_3D(fem);
end


%% Update row-dependent material properties
% These values may change for every row.

fem.Ep   = Ep;
fem.Epp  = Epp;
fem.NMat = NMatCurrent;

if ~isempty(Color)
    fem.Color = Color;
end


%% Density distribution

z = MultiMatTPMS( ...
    t1, ...
    t2, ...
    fem.ElemCtrd, ...
    fem.NMat, ...
    fem.Lx);


%% Material interpolation

pR = 2;                  % Storage-modulus penalization
pI = 3;                  % Loss-modulus penalization
gamma = [1, 1];

MatIntFncR = @(y) MatIntFnc(y, 'SIMP', pR);
MatIntFncI = @(y) MatIntFnc(y, 'SIMP', pI);

MMatIntFnc = @(y, EpLocal, EppLocal) ...
    MultiMatIntFncVisc( ...
        y, ...
        MatIntFncR, ...
        MatIntFncI, ...
        EpLocal, ...
        EppLocal, ...
        gamma);

Epf  = fem.Ep;
Eppf = fem.Epp;

[E, ~, ~, ~] = MMatIntFnc(z, Epf, Eppf);


%% Homogenization

tic;

[Epk, ~, Eppk, ~] = HomogTensor3D(fem, E{1});

elapsedTime = toc;

ReportTime( ...
    elapsedTime, ...
    'Time to compute homogenized complex modulus');


%% Output
% Columns:
% Ep1 Ep2 Ep3 Epp1 Epp2 Epp3 t1 t2 EpH EppH

out = [
    Epf.', ...
    Eppf.', ...
    t1, ...
    t2, ...
    Epk, ...
    Eppk
];

end