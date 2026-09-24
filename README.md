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
├── data/                   # input-data manifest; datasets are added separately
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

The trained soft-material forward-surrogate checkpoint and its architecture are supplied for inference. The original training notebook was overwritten during later high-stiffness model-development experiments and is unavailable; the matching checkpoint, training history, validation predictions, and inference implementation are retained.

### High-stiffness extension

1. `notebooks/high_stiffness/diffusion_model_high_stiffness.ipynb`
2. `notebooks/high_stiffness/forward_model_high_stiffness.ipynb`
3. `notebooks/high_stiffness/prediction_high_stiffness.ipynb`

The supplied `*_soft_hard*` artifacts correspond to the expanded soft–hard property domain.

## Historical-code note

Two later development notebooks are retained under `experimental/` for transparency:

- `forward_model_experimental_high_stiffness.ipynb` contains a later forward-surrogate variant with `fusion_norm` and stronger dropout. It was not used to generate the reported soft-material results.
- `rnn_augmentation_experimental.ipynb` performs BiLSTM fitting before its final group-wise split. It is not the split-first augmentation implementation described in the manuscript. The original split-first notebook was overwritten during later development.

These notebooks should not be treated as exact reproduction scripts for the reported soft-material preprocessing and forward-surrogate training.

## Data availability

The model checkpoints and derived prediction records are included. The input spreadsheets required by individual notebooks are listed in [`data/README.md`](data/README.md) and will be added separately after dataset review. Until those files are present, the included checkpoints can be inspected, but the complete notebooks cannot be executed end to end.

Code for Fig. 2(j–k), originally generated in Google Colab, is not included. The corresponding results remain documented in the manuscript and supporting material.

## Reproducibility notes

- Inverse sampling is stochastic; regenerated candidate sets may differ slightly unless the same random seed and software/CUDA configuration are used.
- The `best` checkpoint should be used for inference when both best and final checkpoints exist.
- Model weights and pickle files should be loaded only from trusted sources.

## Citation

Please cite the associated manuscript when using this repository. Full citation information will be added after publication.

