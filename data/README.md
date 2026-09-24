# Data manifest

The notebooks use repository-root-relative paths. The datasets required for the reported workflows are included in this directory.

## Soft-material workflows

| File | Used by | Role |
|---|---|---|
| `combined_augmented_train.xlsx` | soft diffusion and prediction notebooks | pre-split augmented training set |
| `val.xlsx` | soft diffusion and prediction notebooks | held-out group-wise validation set |
| `TrainingData_all_validation.xlsx` | sample-group 1 evaluation | independent/combined validation inputs |
| `combined_augmented_all_data.xlsx` | sample-group 2 evaluation | combined augmented dataset used by the retained evaluation script |
| `testing_2.xlsx` | `figure2_i_o.ipynb` | saved predictions and MATLAB-calculated values for Fig. 2 panels |

`val_result.xlsx`, inverse-candidate spreadsheets, and ranked-candidate CSV files are generated outputs rather than required source data.

## High-stiffness workflows

| File | Used by | Role |
|---|---|---|
| `combined_soft_hard_train.xlsx` | high-stiffness diffusion and forward-model training | expanded-domain training set |
| `combined_soft_hard_val.xlsx` | high-stiffness diffusion and forward-model evaluation | expanded-domain validation set |
| `HardMaterial_Independent_Test_5Groups_calculated.xlsx` | high-stiffness prediction | independent MATLAB-calculated test cases |
| `HardMaterial_Independent_Test_Selected15.xlsx` | selected high-stiffness evaluation | selected independent test cases; sheet `Selected15` |
| `testing_2_hard_all.xlsx` | `figure5_i_o.ipynb` | final 28-case high-stiffness validation summary |

Files named `*_prediction_soft_hard.xlsx`, `*_comparison.xlsx`, or `*_refined_comparison.xlsx` are notebook outputs.

The optional `new samples.xlsx` demonstration input is not included because it is not used for the reported manuscript results.

## Expected columns

The principal numerical columns are:

```text
Ep1, Ep2, Ep3, Epp1, Epp2, Epp3, t1, t2, EpH, EppH
```

Some independent-test files contain additional group IDs, calculated moduli, or error columns used only for plotting and reporting.

## Dataset checks

- The soft-material augmented training and validation sets contain 32,938 and 8,631 rows, respectively, with 144 and 37 non-overlapping material groups.
- `combined_augmented_all_data.xlsx` is the exact row-wise union of those two sets.
- The expanded soft–hard training and validation sets contain 16,016 and 4,095 rows, respectively, with no overlapping constituent-material groups.
- Blank group-ID fields in the soft rows of the expanded datasets are intentional because those identifiers apply only to the hard-material enrichment records.
- `testing_2_hard_all.xlsx` contains the 28 retained high-stiffness validation cases reported in the manuscript.
