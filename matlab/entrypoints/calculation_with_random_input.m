%-------------------------------------------------------------------------%
% 1) Read Ep1..Ep3, Epp1..Epp3, t1, t2, EpH_experiment, and EppH_experiment from Excel.
% 2) Call Homog_TPMS_Visco3 line by line to calculate EpH_calculated and EppH_calculated.
% 3) Calculate the absolute error and relative error (%), and write the results to the output Excel file.
%-------------------------------------------------------------------------%

clear; clc;

% Paths (You need to change D:\...\ below to the path on your computer) 
% Packaging-only path isolation; solver and row-wise calculations are unchanged.
matlabRoot = fileparts(fileparts(mfilename('fullpath')));
candidateRoot = matlabRoot;
addpath(matlabRoot);
addpath(fullfile(matlabRoot, 'Function_Files'));
infile = fullfile(candidateRoot, 'inputs', 'testing input.xlsx');
outdir = fullfile(candidateRoot, 'outputs');
if ~isfolder(outdir), mkdir(outdir); end
outfile = fullfile(outdir, 'testing output.xlsx');
if isfile(outfile)
    error('Output already exists. Archive it before running this entry script: %s', outfile);
end

% Input: Read by column name
T = readtable(infile, 'Sheet', 1, 'VariableNamingRule','preserve');

% Columns check
needCols = {'Ep1','Ep2','Ep3','Epp1','Epp2','Epp3','t1','t2','EpH_experiment','EppH_experiment'};
missing = setdiff(needCols, T.Properties.VariableNames);
if ~isempty(missing)
    error('The input table is missing columns：%s', strjoin(missing, ', '));
end

% Retrieve data
Ep_mat     = T{:, {'Ep1','Ep2','Ep3'}};      % (N x 3)
Epp_mat    = T{:, {'Epp1','Epp2','Epp3'}};   % (N x 3)
PARAM      = T{:, {'t1','t2'}};              % (N x 2)
EpH_exp   = T{:, 'EpH_experiment'};          % (N x 1)
EppH_exp  = T{:, 'EppH_experiment'};         % (N x 1)
N = size(PARAM,1);

idx_EpH  = 9;   
idx_EppH = 10;  

% Solve line by line 
EpH_cal  = zeros(N,1);
EppH_cal = zeros(N,1);

for ii = 1:N
    t1   = PARAM(ii,1);
    t2   = PARAM(ii,2);
    Epf  = Ep_mat(ii,:).';      % (3x1)
    Eppf = Epp_mat(ii,:).';     % (3x1)
    
    fem = [];
    Color = [];  
    [out_row, ~] = Homog_TPMS_Visco3(fem, t1, t2, Epf, Eppf, Color);  

    % Check columns
    if numel(out_row) < max(idx_EpH, idx_EppH)
        error('Homog_TPMS_Visco3 insufficient number of output columns，numel(out_row)=%d。', numel(out_row));
    end

    EpH_cal(ii,1)  = out_row(idx_EpH);
    EppH_cal(ii,1) = out_row(idx_EppH);
end

% Absolute error
EpH_abs  = abs(EpH_cal  - EpH_exp);
EppH_abs = abs(EppH_cal - EppH_exp);

% Prevent the occurrence of zero 
den_Ep  = max(abs(EpH_cal),  eps);   
den_Epp = max(abs(EppH_cal), eps);

% Relative error
EpH_rel  = abs(EpH_cal  - EpH_exp)./ den_Ep  * 100;
EppH_rel = abs(EppH_cal - EppH_exp)./ den_Epp * 100;

% Output 
Out = table();
Out.Ep1  = Ep_mat(:,1);
Out.Ep2  = Ep_mat(:,2);
Out.Ep3  = Ep_mat(:,3);
Out.Epp1 = Epp_mat(:,1);
Out.Epp2 = Epp_mat(:,2);
Out.Epp3 = Epp_mat(:,3);
Out.t1   = PARAM(:,1);
Out.t2   = PARAM(:,2);
Out.EpH_experiment  = EpH_exp;
Out.EppH_experiment = EppH_exp;
Out.EpH_calculated  = EpH_cal;
Out.EppH_calculated = EppH_cal;
Out.EpH_abs     = EpH_abs;
Out.EppH_abs    = EppH_abs;
Out.EpH_rel    = EpH_rel;
Out.EppH_rel   = EppH_rel;

% Write out 
writetable(Out, outfile, 'FileType','spreadsheet');
fprintf('OK -> %s\n', outfile);
