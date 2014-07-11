## 0.1.1 (July 11, 2014)

### Changes
- Display names have been cleaned up to remove the prefix of what form they belong to, in order to place more focus on the actual question
- Variable descriptions now contain detailed information for certain ECG and Screening variables
- The CSV datasets generated from a SAS export is located here:
  - `\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.1\`
    - `heartbeat-baseline-dataset-0.1.1.csv`
    - `heartbeat-final-dataset-0.1.1.csv`

## 0.1.0 (July 3, 2014)

### Changes
- All participants have been assigned an obfuscated ID number as `obf_pptid` and all other potentially identifiable variables have been removed from the dataset
- The CSV datasets generated from a SAS export is located here:
  - `\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.1.0\`
    - `heartbeat-baseline-dataset-0.1.0.csv`
    - `heartbeat-final-dataset-0.1.0.csv`
- **Script Changes**
  - Missing codes are stripped out en masse, using an array method
  - An additional SAS script, `heartbeat dataset macros.sas`, is bundled with the dataset to facilitate easy renaming of variables
  - Ages are calculated using exact dates, rather than staff-entered values, and then used to formulate a categorical age
  - All date values are exported as 'days from index date', with the index date being the date of randomization
- **Gem Changes**
  - Use of Ruby 2.1.2 is now recommended
  - Updated to spout 0.8.0
