function run_fixed_inputs(input_csv, output_dir, row_indices)
% Publication wrapper for existing fixed inputs, not historical generation code.
% Calls retained HomogVisco3D sources without changing the numerical algorithm.
% Explicit rows and a new output directory are required; nothing is overwritten.
if nargin~=3 || isempty(row_indices)
    error('Supply input CSV, a NEW output directory, and explicit row indices.');
end
if isfolder(output_dir) || isfile(output_dir)
    error('Refusing an existing output destination: %s',output_dir);
end
T=readtable(input_csv,'VariableNamingRule','preserve');
cols={'Ep1','Ep2','Ep3','Epp1','Epp2','Epp3','t1','t2'};
if ~all(ismember(cols,T.Properties.VariableNames))
    error('Required physical-input columns: Ep1 Ep2 Ep3 Epp1 Epp2 Epp3 t1 t2.');
end
if any(row_indices<1 | row_indices>height(T) | row_indices~=floor(row_indices))
    error('Row indices must be valid one-based integer data-row indices.');
end
T=T(row_indices,:);
if any(~isfinite(T{:,cols}),'all')
    error('All eight physical inputs must be finite.');
end
matlabRoot=fileparts(mfilename('fullpath'));
addpath(matlabRoot);addpath(fullfile(matlabRoot,'Function_Files'));
addpath(fullfile(matlabRoot,'diagnostics'),'-begin');
clear PeriodicFEA_3D
mkdir(output_dir);
diagFile=fullfile(output_dir,'solver_diagnostics.csv');
setenv('TPMS_DIAGNOSTICS_FILE',diagFile);
diary(fullfile(output_dir,'run.log'));
cleanup=onCleanup(@()diary('off')); %#ok<NASGU>
disp(version);disp(which('PeriodicFEA_3D'));
[Node,Element,~,~,ElemCtrd]=RegMesher(@UnitCell,50,50,50);
BDofs=BdryNodes(Node);b=max(Node(:,1))-min(Node(:,1));
fem=struct('NNode',size(Node,1),'NElem',size(Element,1), ...
    'Node',Node,'Element',{Element},'ElemCtrd',ElemCtrd,'d',{BDofs}, ...
    'Lx',b,'Ly',b,'Lz',b,'Nu0',0.3,'E0',1, ...
    'Ep',T{1,{'Ep1','Ep2','Ep3'}}.','Epp',T{1,{'Epp1','Epp2','Epp3'}}.', ...
    'NMat',3,'Color',[],'cutoff',0.5,'Reg',1,'precond','Diagonal');
fem=PreComputationViscoRegular_3D(fem);
T.Calculated_storage=nan(height(T),1);T.Calculated_loss=nan(height(T),1);
for j=1:height(T)
    if ismember('Case',T.Properties.VariableNames)
        caseID=regexprep(char(string(T.Case(j))),'[^A-Za-z0-9_-]','_');
    else
        caseID=sprintf('row_%d',row_indices(j));
    end
    setenv('TPMS_AUDIT_CASE',caseID);
    [v,fem]=Homog_TPMS_Visco3(fem,T.t1(j),T.t2(j), ...
        T{j,{'Ep1','Ep2','Ep3'}}.',T{j,{'Epp1','Epp2','Epp3'}}.',[]);
    assert(max(abs(v(1:8)-T{j,cols}))<1e-12,'Returned input mapping differs.');
    T.Calculated_storage(j)=v(9);T.Calculated_loss(j)=v(10);
    writetable(T,fullfile(output_dir,'calculations.csv'));
end
% Flags and residuals are diagnostic outputs, not inferred from file existence.
S=readtable(diagFile,'VariableNamingRule','preserve');
if any(S.Flag~=0 | S.TrueRelativeResidual>S.Tolerance)
    warning('At least one load-case solve did not meet the logged criterion.');
end
end
