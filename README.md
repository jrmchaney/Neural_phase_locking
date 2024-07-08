# FFR_PLV
Phase locking values for FFRs to /ba/ /da/ and /ga/
Created by Jacie R. McHaney

This script calculates phase locking values to FFRs elicited by speech stimuli. This example uses FFRs to 170ms stimuli (ba, da, and ga)

These scripts assume that the FFR data has been preprocessed already (i.e, filtered, artifact rejection, epoching)

## Step 1

Run the `format_FFR_PLV.m` script. This compiles all of the subject FFRs into a format necessary for PLV. You'll need the trail-by-trial FFR data for each polarity, stimulus name, listening condition and time domain.

## Step 2

This script runs the actual PLV. This script uses the function `mtplv.m` that was created by the [SNAP Lab Group](https://github.com/SNAPlabgroup/ANLffr). Check out their github for more information. The output of this script saves each subject's PLV into a large CSV file, which can then be plotted/analyzed in your program of choice.
