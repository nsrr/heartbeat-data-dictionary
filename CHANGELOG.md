## 0.2.1

- Fixed naming convention of "HeartBEAT Medical Outcomes Study (SF-36)" form
- Fixed a coverage issue for agecat
- **Gem Changes**
  - Updated to ruby 2.3.0
  - Updated to spout 0.11.0

## 0.2.0 (August 29, 2014)

### Changes
- Sleep and Health Questionnaire variables and Medication variables have been condensed into single, omni-visit variables, rather than visit-specific ones where possible
- Eligibility variables for which all responses were either 'Yes' or 'No' (exclusion or inclusion criteria) have been removed from the dataset
- Many date variables have been removed from the dataset as well, because they are synonymous with either the `index date` or `final_visit_date` variables
- Treatment arm has been added to the final dataset to allow it to be used as a stratification factor on sleepdata.org graphs
- The CSV datasets generated from a SAS export is located here:
  - `\\rfa01\bwh-sleepepi-heartbeat\nsrr-prep\_releases\0.2.0\`
    - `heartbeat-baseline-dataset-0.2.0.csv`
    - `heartbeat-final-dataset-0.2.0.csv`

## 0.1.2 (August 27, 2014)

### Changes
- Variables are now associated with the appropriate annotated codebook forms
- Summary variables have been marked as `commonly_used: true` for sleepdata.org
- Randomized treatment arm is now a stratification for sleepdata.org graphs
- Forms now follow a standardized naming convention
- **Gem Changes**
  - Updated to spout 0.9.0.beta2

## 0.1.1 (July 11, 2014)

### Changes
- Display names have been cleaned up to remove the prefix of what form they belong to, in order to place more focus on the actual question
- Variable descriptions now contain detailed information for certain ECG and Screening variables

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
