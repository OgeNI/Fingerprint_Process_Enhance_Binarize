# FingerprintProcessBinarize Repository

## A fingerprint image processing and binarization algorithm 

##### 
The codes in this repository proposes carry out an adaptive contrast enhancement and binarisation of fair and poor qualities plain and rolled fingerprints with large regions of low quality, prior to orientation field estimation. The algorithm effectively enhances smudged and faded ridges uniformly in recoverable regions, based on values of statistical variables computed locally in each region. The preprocessing algorithm employs a locally adaptive thresholding approach resulting in enhanced binarised images. 

<hr/>

## ReadMe Instructions

### Code Implementation
##### 
The codes were originally implemented in m-codes and recently translated to Python. There are two folders of codes for m-codes (MATLAB) and python respectively, and are meant to be used separately.


### Database
The Fingerprint Verification Competition (FVC) Benchmarked databases are available from the following <a href="link https://bias.csr.unibo.it/fvc2000/databases.asp"> FVC Databases </a>

### Code Usage

##### 
1. Use Step 1 codes for the FVC and any scanned fingerprints <br>
2. Use Step 2 codes for rolled fingerprints or the NIST Special Database 4 (SD4) if available<br>
<i>(Please note that the NISTSD4 has been withdrawn and read the following information <a href="https://www.nist.gov/srd/nist-special-database-4">here</a> on the possibility of a future dataset</i>.

The rest of the codes are functions.

You need to pass in your input and output folder paths while running the codes

<hr/>

## Citation of the Published Paper

##### 
The codes were developed and based on the following published IET Image processing journal paper <a href="https://digital-library.theiet.org/doi/10.1049/iet-bmt.2015.0064">Effective statistical-based and dynamic fingerprint preprocessing technique</a>. <br>

The following should therefore be cited whenever these codes are used in a research or published article:

@article{doi:10.1049/iet-bmt.2015.0064, <br>
author = {Ogechukwu N. Iloanusi }, <br>
title = {Effective statistical-based and dynamic fingerprint preprocessing technique}, <br>
journal = {IET Biometrics}, <br>
volume = {6}, <br>
issue = {1}, <br>
pages = {9-18}, <br>
year = {2017}, <br>
doi = {10.1049/iet-bmt.2015.0064}, <br>
URL = {https://digital-library.theiet.org/doi/abs/10.1049/iet-bmt.2015.0064}, <br>
eprint = {https://digital-library.theiet.org/doi/pdf/10.1049/iet-bmt.2015.0064} <br>
}

<hr/>
