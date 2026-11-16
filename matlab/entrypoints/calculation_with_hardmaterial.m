%-------------------------------------------------------------------------%
% 1) Read Ep1-Ep3, Epp1-Epp3, t1, and t2 from the input Excel file.
% 2) Call Homog_TPMS_Visco3 row by row.
% 3) Calculate EpH and EppH.
% 4) Append EpH and EppH to the original table and save the output.
%-------------------------------------------------------------------------%

clear;
clc;

%% Paths
% Modify these paths according to your computer.

% Packaging-only path isolation; solver and row-wise calculations are unchanged.
matlabRoot = fileparts(fileparts(mfilename('fullpath')));
candidateRoot = matlabRoot;
addpath(matlabRoot);
addpath(fullfile(matlabRoot, 'Function_Files'));
infile = fullfile(candidateRoot, 'inputs', 'HardMaterial_Supplement_1.xlsx');
outdir = fullfile(candidateRoot, 'outputs');
if ~isfolder(outdir), mkdir(outdir); end
outfile = fullfile(outdir, 'HardMaterial_Supplement_calculated.xlsx');
if isfile(outfile)
    error('Output already exists. Archive it before running this entry script: %s', outfile);
end


%% Read input data

T = readtable( ...
    infile, ...
    'Sheet', 'ReplacementInput', ...
    'VariableNamingRule', 'preserve');


%% Check required columns

needCols = {
    'Ep1', 'Ep2', 'Ep3', ...
    'Epp1', 'Epp2', 'Epp3', ...
    't1', 't2'
};

missingCols = setdiff(needCols, T.Properties.VariableNames);

if ~isempty(missingCols)
    error( ...
        'The input table is missing the following columns: %s', ...
        strjoin(missingCols, ', '));
end


%% Retrieve input data

Ep_mat = T{:, {'Ep1', 'Ep2', 'Ep3'}};
Epp_mat = T{:, {'Epp1', 'Epp2', 'Epp3'}};
PARAM = T{:, {'t1', 't2'}};

N = height(T);

fprintf('Total rows to calculate: %d\n', N);


%% Output positions from Homog_TPMS_Visco3

idx_EpH = 9;
idx_EppH = 10;


%% Preallocate output arrays

EpH = nan(N, 1);
EppH = nan(N, 1);


%% Calculate EpH and EppH row by row

%% Initialize fem only once

fem = [];
Color = [];

EpH = nan(N, 1);
EppH = nan(N, 1);

%% Calculate row by row while reusing fem

for ii = 1:N

    t1 = PARAM(ii, 1);
    t2 = PARAM(ii, 2);

    Epf  = Ep_mat(ii, :).';
    Eppf = Epp_mat(ii, :).';

    try
        [out_row, fem] = Homog_TPMS_Visco3( ...
            fem, ...
            t1, ...
            t2, ...
            Epf, ...
            Eppf, ...
            Color);

        if numel(out_row) < max(idx_EpH, idx_EppH)
            error( ...
                ['Homog_TPMS_Visco3 returned insufficient output ', ...
                 'values. numel(out_row) = %d.'], ...
                numel(out_row));
        end

        EpH(ii)  = out_row(idx_EpH);
        EppH(ii) = out_row(idx_EppH);

    catch ME
        warning( ...
            'Calculation failed at row %d: %s', ...
            ii, ...
            ME.message);

        EpH(ii)  = NaN;
        EppH(ii) = NaN;
    end

    if mod(ii, 100) == 0 || ii == N
        fprintf('Completed: %d / %d rows\n', ii, N);
    end
end


%% Add calculated results to the original table
% If EpH and EppH already exist, their original values will be overwritten.

T.EpH = EpH;
T.EppH = EppH;


%% Save results

writetable( ...
    T, ...
    outfile, ...
    'FileType', 'spreadsheet');


%% Summary

nSuccess = sum(isfinite(EpH) & isfinite(EppH));
nFailed = N - nSuccess;

fprintf('\nCalculation completed.\n');
fprintf('Successful rows: %d\n', nSuccess);
fprintf('Failed rows: %d\n', nFailed);
fprintf('Output file:\n%s\n', outfile);