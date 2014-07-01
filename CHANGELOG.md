## 0.1.0

### Changes
- The CSV datasets generated from a SAS export is located here:
  - `\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0.rc2\`
    - `heartbeat-baseline-dataset-0.1.0.rc2.csv`
    - `heartbeat-final-dataset-0.1.0.rc2.csv`
- **Script Changes**
  - Missing codes are stripped out en masse, using an array method
  - An additional SAS script, `heartbeat dataset macros.sas`, is bundled with the dataset to facilitate easy renaming of variables
  - Ages are calculated using exact dates, rather than staff-entered values, and then used to formulate a categorical age
- **Gem Changes**
  - Use of Ruby 2.1.2 is now recommended
  - Updated to spout 0.8.0.rc4
