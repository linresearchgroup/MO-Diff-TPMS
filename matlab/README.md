# MATLAB homogenization sources and fixed-input verification

`Homog_TPMS_Visco3.m` and the twelve files in `Function_Files/` are retained numerical sources. Headers, attribution and citations are preserved; see [source and attribution](SOURCE_AND_ATTRIBUTION.md). The publication wrapper and organized spreadsheet entries are separately identified. No new blanket license is assigned.

## Inputs, outputs and settings

Inputs are `Ep1, Ep2, Ep3, Epp1, Epp2, Epp3, t1, t2`, in that order. The first six are constituent storage and loss moduli in MPa. The two dimensionless phase parameters are passed exactly as saved, without clipping, sorting or sign changes. All three phases are material assignments, not a declared void phase.

The output vector is the same eight inputs followed by effective storage and loss moduli in MPa. Scalar extraction uses `HomogTensor3D`: the real and imaginary homogenized tensors are processed separately using the retained normal/shear selection and inverse-tensor implementation. These are the scalar definitions used in the reported comparisons.

The fixed-input path uses a 50 × 50 × 50 periodic hexahedral mesh, shared Poisson ratio 0.3, storage/loss SIMP exponents 2/3, interpolation parameter [1,1], ersatz value 1e-4 and the existing CPU diagonal-preconditioned BiCGSTAB branch, tolerance 1e-6, maximum 20,000 iterations. The completed revision calculations used MATLAB R2026a Update 2. The retained solver's default GPU path is also present; using it requires an appropriate GPU/Parallel Computing Toolbox. The guarded CPU wrapper does not require that GPU path.

## Preferred entry for given material moduli and t1/t2

From the repository root in MATLAB, select explicit existing data rows:

```matlab
addpath('matlab');
run_fixed_inputs( ...
    'verification/round2/augmentation_label_check/inputs.csv', ...
    fullfile(pwd,'new_check_output'), 1);
```

To reproduce all eight stored label checks in a different, fresh output directory, explicitly select `1:8`. To inspect a saved inverse-design case, use `verification/round2/inverse_design/fixed_case_inputs_and_results.csv` and its row index. This wrapper performs no learning or candidate generation. It refuses any existing output destination. Inputs must be CSV physical values; no scaler or model checkpoint is loaded. The provided validation CSVs already contain saved candidates; do not regenerate them to reproduce a fixed-input comparison.

`calculations.csv`, `solver_diagnostics.csv`, per-load residual histories and `run.log` are written only inside the new destination. The diagnostic overlay captures actual exit flags, reported/true relative residuals and iteration counts from the existing solver call. Numerical convergence must be checked from those fields. Successful execution or a nonempty result file alone is not a convergence certificate.

The wrapper is a path-organized publication entry. It has been statically reviewed; publishing it did not execute new simulations. Completed calculations and their actually recorded convergence diagnostics are separately archived under `verification/round2/logs/`. Four of the eight augmentation checks have subsequent diagnostic replays; historical residual/flag records are not claimed for the other four.

## Retained spreadsheet entries

| Entry | Actual purpose | Input under `matlab/inputs/` |
|---|---|---|
| `entrypoints/calculation_with_random_input.m` | Original-material-domain fixed-row homogenization and reference comparison; the name does not cause random generation | `testing input.xlsx`, with eight inputs and `EpH_experiment`, `EppH_experiment` |
| `entrypoints/calculation_with_hardmaterial.m` | High-stiffness spreadsheet rows, preserving the existing solver call | `HardMaterial_Supplement_1.xlsx`, sheet `ReplacementInput`, eight inputs |
| `entrypoints/validation_with_random_input.m` | Given material/geometry rows and saved surrogate predictions | `newly generated data for testing input.xlsx`, eight inputs plus `EpH_pred`, `EppH_pred` |

Organized copies use relative paths and refuse an existing output file in `matlab/outputs/`. Supply the stated workbook or use the preferred CSV wrapper above. Legacy column names containing `experiment` denote reference values in those numerical scripts, not newly reported physical experiments. Some legacy error fields use historical calculation-denominator conventions and zero guards; they are not final inverse-target errors. Final Table S9 target errors use `|Calculated − Target|` and denominator `|Target|`, without denominator adjustment for its nonzero targets.

The [round-two record index](../verification/round2/README.md) distinguishes augmentation-label consistency, forward-surrogate agreement, screening and physical target attainment. The archive supports these fixed-input calculations and retained workflows. It does not promise exact reconstruction of all historical training operations or a fully independent augmentation pipeline.
