# Round two verification records

- [Eight augmentation-label checks](augmentation_label_check/): complete saved inputs, labels, calculations, errors, selection rule, source rows and convergence evidence. These records replace the former detailed augmentation table in the Supplementary Information.
- [Thirty five inverse-design comparisons](inverse_design/): final Table S9, 70 component results, all candidate inputs, unchanged 7/28-case statistics, correction records and the excluded unpaired case.
- [Forward-comparison data](forward_comparison/figure3_l_o_source.csv): the 22 cases used in current Figure 3l–o. Sixteen retained calculation records, four corrected original rows and two previously checked added candidates are included; 14 unconfirmed archived rows are excluded. All included errors and outliers are retained. The 34 original rows are audited in `forward_comparison/original_34_row_audit.csv`. This differs from the 35 target comparisons.
- `logs/`: retained original calculations and completed diagnostic replays, with flags, true relative residuals and histories where actually recorded. Machine paths are redacted; numerical results are unchanged.
- `normalization_audit.json`: numerical audit of the two scaler stages. Downstream groups are disjoint and their scalers match training-only rows. BiLSTM-stage normalization uses all original rows; full historical weight-fitting group membership is unresolved. This is not a split-first or full-pipeline-independence claim.
- `SOURCE_MANIFEST.json`: origins, copy types and hashes. See [MATLAB instructions](../../matlab/README.md) from the repository root at `matlab/README.md`.

No model training, candidate resampling or additional FE calculation was performed to publish this archive. The retained sources and data support fixed-input numerical reproduction and inspection of the reported comparisons, not complete historical model-training reproduction. No new software license is assigned.
