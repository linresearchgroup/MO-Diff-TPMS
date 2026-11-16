# MO-Diff-TPMS

Conditional diffusion and forward-surrogate workflows for multi-objective inverse design of multiphase triply periodic minimal surface (TPMS) materials.

The framework conditions a diffusion model on six constituent viscoelastic moduli and two prescribed homogenized moduli, generates candidate phase-distribution parameters (`t1`, `t2`), and ranks the candidates with a forward surrogate. The repository also contains the soft-to-high-stiffness domain-extension workflow and the trained checkpoints used for inference.

## Repository contents

```text
MO-Diff-TPMS/
├── notebooks/
│   ├── soft_material/      # soft-material diffusion and inverse-design workflows
│   ├── high_stiffness/     # expanded soft–hard models and independent evaluations
│   └── figures/            # panel-generation utilities
├── artifacts/
│   ├── soft_material/      # checkpoints, scalers, histories, and saved predictions
│   └── high_stiffness/     # expanded-domain checkpoints, scalers, and predictions
├── experimental/           # later variants not used for the reported soft-material results
├── data/                   # input datasets and validation summaries
├── matlab/                 # homogenization sources and guarded fixed-input entry
├── verification/round2/    # complete revision checks and case provenance
└── requirements.txt
```

## Model inputs and outputs

- Constituent conditions: `Ep1`, `Ep2`, `Ep3`, `Epp1`, `Epp2`, `Epp3`
- Phase-distribution parameters: `t1`, `t2`
- Homogenized targets: `EpH`, `EppH`
- Diffusion task: generate `t1` and `t2` conditioned on the six constituent moduli and prescribed `EpH`, `EppH`
- Forward-surrogate task: predict `EpH`, `EppH` from the six constituent moduli and `t1`, `t2`

## Recommended environment

The notebooks were last executed with Python 3.11. The serialized `StandardScaler` objects were created with scikit-learn 1.7.2, which is pinned in `requirements.txt` to avoid model-persistence compatibility warnings.

```bash
python -m venv .venv
source .venv/bin/activate       # Windows: .venv\Scripts\activate
pip install -r requirements.txt
jupyter lab
```

Launch Jupyter from the repository root because the notebooks use root-relative `data/` and `artifacts/` paths.

## Suggested workflow

### Soft-material model

1. `notebooks/soft_material/diffusion_model_soft.ipynb`
2. One of the inverse-design notebooks in `notebooks/soft_material/`
3. `notebooks/soft_material/prediction_with_refinement.ipynb` for the optional local gradient-refinement demonstration

The soft-material forward-surrogate checkpoint, architecture, training history and saved validation predictions support inference and comparison. Exact historical training reproduction is not claimed.

### High-stiffness extension

1. `notebooks/high_stiffness/diffusion_model_high_stiffness.ipynb`
2. `notebooks/high_stiffness/forward_model_high_stiffness.ipynb`
3. `notebooks/high_stiffness/prediction_high_stiffness.ipynb`

The supplied `*_soft_hard*` artifacts correspond to the expanded soft–hard property domain.

## Scope of retained workflows

The `experimental/` notebooks are retained variants. Their presence does not certify the historical generation of every saved row. Downstream training/validation material groups are disjoint and the downstream scalers match the training subset. BiLSTM-stage normalization uses the complete original database; the full weight-fitting group membership is unresolved. No split-first augmentation history or complete pipeline independence is claimed.

## MATLAB and numerical verification

See [`matlab/README.md`](matlab/README.md) for original-material and high-stiffness spreadsheet entries, the guarded fixed-input CSV wrapper, all numerical dependencies and retained attribution. The CPU verification path preserves the original numerical algorithm.

[`verification/round2/`](verification/round2/) contains all eight stored augmentation-label checks (including large errors), selection and source records, convergence evidence, final Table S9 with 35 complete target–prediction–calculation cases (70 component results), and the excluded unpaired case. These are different error tasks; their definitions and scope are documented there.

Current Figure 2 shows four TPMS structures. Current Figure 3l–o uses the 22 audited cases in `verification/round2/forward_comparison/figure3_l_o_source.csv`. Legacy `notebooks/figures/figure2_i_o.ipynb` reads the archived 34-row worksheet and does not reproduce the corrected accuracy panels. Legacy `figure5_i_o.ipynb` relates to current Figure 6. Supplementary tables end at S9; the augmentation check is now repository documentation, not a separate supplementary table.

## Data availability

The trained checkpoints, scalers, training histories, derived prediction records, and input spreadsheets required for the reported workflows are included. Dataset roles and verification details are listed in [`data/README.md`](data/README.md).

The optional `new samples.xlsx` demonstration input is not included because it is not used for the reported manuscript results.

The separate utility originally used for current Fig. 3(j–k), previously numbered Fig. 2(j–k), is not included. The corresponding results remain documented in the manuscript and supporting material.

## Reproducibility notes

- Inverse sampling is stochastic; regenerated candidate sets may differ slightly unless the same random seed and software/CUDA configuration are used.
- The `best` checkpoint should be used for inference when both best and final checkpoints exist.
- Model weights and pickle files should be loaded only from trusted sources.

## Citation

Please cite the associated manuscript when using this repository. Full citation information will be added after publication.

