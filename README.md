# EECE5520_Project
Magnetic Resonance Image Reconstruction Project

- ReconMain.m - Performs MR image reconstruction on a raw data file (Pfile).
- ReconZIP4.m - Performs MR image reconstruction on a raw data file & uses zero filling to interpolate by 4.
- ReconZIP4_laplacian.m - Performs MR image reconstruction on a raw data file, uses zero filling to interpolate by 4, and sharpens the resulting interpolated image with a Laplacian filter.
- carboy - MR raw data file (Pfile) for a 48 cm field of view scan of a carboy filled with copper sulfate solution.
- dqa3 - MR raw data file (Pfile) for a 24 cm field of view scan of the DQA3 phantom.
- displayMagnitude.m - display log magnitude of raw data
- displayPhase.m - display phase of raw data
- fermi.m - Generates Fermi Filter used for data apodization prior to 2D FFT
- filterChannelData.m - Applies Fermi Filter & any required chopping (fftshift) to raw data 
- getChannelData.m - Reads raw data and necessary parameters from Pfile
- laplacian_image.m - Resize image for non-symmetric acquisition sizes & apply Laplacian filter to sharpen image.
- read_weights.m - Reads coil weights from Pfile used in sum of squares coil combination.
- resize_image.m - Resize image for non-symmetric acquisition sizes if necessary.
- sumOfSquares.m - Multi-channel image combination using method described by Roemer
- transformChannelData - Compute 2D FFT
