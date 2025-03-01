% ReconMain.m - MR image reconstruction from Pfile
% Marquette University
%
% Fred J. Frigo
% Oct 17, 2017
% Oct 27, 2017 - use Hamming window for apodization
% Oct 15, 2020 - Resize Final Image if necessary
% Feb 22, 2025 - Extract corner points & other parameters from Pfile

% Enter name of Pfile
pfile = "";
if(pfile == "")
    [fname, pname] = uigetfile('*.*', 'Select Pfile');
    pfile = strcat(pname, fname);
end

slice_no = 6;   % specify slice number if multiple slices are present

%1: Read Pfile containing the raw data for each channel
[raw_data, chop, da_xres, da_yres, gw_coil, corner_points] = getChannelData(pfile, slice_no);
num_chan = size(raw_data,3);

%2: Perform Fermi apodization and chopping
xdim = size(raw_data, 1);
ffilter = fermi(xdim, 0.45*xdim, 0.1*xdim);  % try fermi( xdim, 0.1*xdim, 0.01*xdim)
figure;
mesh(ffilter);  % this plots the apodization filter
filt_data = filterChannelData(raw_data, ffilter, chop, num_chan);

% display the k-space magnitude 
displayMagnitude(raw_data, 'K-space log-magnitude', 1);

%3: Transform to image domain
im_data = transformChannelData(filt_data);

%4: Display the image magnitude for each channel
displayMagnitude(im_data, 'Image magnitude', 0);

%5: Display the image phase for each channel
displayPhase(im_data, 'Image Phase');

%6: calculate magnitude image
if (num_chan > 1)
   % for multi-coil, get coil weights used in sum of squares combination
   weights = read_weights(pfile);
else
   weights = 1.0;
end
sos_image = sumOfSquares(im_data, weights);

%7: Resize image if necessary
zip_factor =1;
final_image = resize_image( sos_image, da_xres, da_yres, zip_factor);

%8: Create DICOM image file from Pfile name
new_dfile = strcat(pfile, ".dcm");

%9 Create the new DICOM image  
result = dicomwrite(final_image, new_dfile);
info = dicominfo(new_dfile);

% udpate default window width and window level
info.WindowWidth  = max(max(final_image));  %default window width for new image
info.WindowCenter = info.WindowWidth/2;  %defautl window level for new image
info.PatientName.FamilyName = fname;
info.SeriesDescription = 'No Gradwarp';
info.ExamNumber = '1';
info.SeriesNumber = 1;
result = dicomwrite(final_image,new_dfile,info,'CreateMode','copy');

msg=sprintf('New dicom file created = %s', new_dfile);
disp(msg);

