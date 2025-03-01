% ReconZIP4.m - MR image reconstruction from Pfile
% Marquette University
%
% Fred J. Frigo
% Oct 17, 2017
% Oct 15, 2020 - Resize image / modified for zero padding interpolation
% Feb 22, 2025 - Extract corner points & other parameters from Pfile
% Feb 28, 2025 - Call laplacian_image() to resize & sharpen image

% Enter name of Pfile
pfile = "";
if(pfile == "")
    [fname, pname] = uigetfile('*.*', 'Select Pfile');
    pfile = strcat(pname, fname);
end

% Select slice number 6, if not present, it will use slice 1
slice_no = 6;

%1: Read Pfile containing the raw data for each channel
[raw_data, chop, da_xres, da_yres, gw_coil, corner_points] = getChannelData(pfile, slice_no);
num_chan = size(raw_data,3);

%2: Perform Fermi apodization and chopping
xdim = size(raw_data, 1);
ffilter = fermi(xdim, 0.45*xdim, 0.1*xdim);
mesh(ffilter);  % this plots the apodization filter
filt_data = filterChannelData(raw_data, ffilter, chop, num_chan);

%2.5: Zero Pad by zip_factor 
[dayres, daxres, num_chan] = size(raw_data);
zip_factor = 4; % Zero pad by factor of 4
ZP_data = zeros(dayres*zip_factor, daxres*zip_factor, num_chan);
ZP_data(1:dayres,1:daxres,:) = filt_data(1:dayres,1:daxres,:);

% display the k-space magnitude 
displayMagnitude(ZP_data, 'K-space log-magnitude', 1);

%3: Transform to image domain
im_data = transformChannelData(ZP_data);

%4: Display the image magnitude for each channel
% displayMagnitude(im_data, 'Image magnitude', 0);

%4.5: Display the image phase for each channel
% displayPhase(im_data, 'Image Phase');

%5: calculate magnitude image
if (num_chan > 1)
   % 6: for multi-coil, get weights used in sum of squares combination
   weights = read_weights(pfile);
else
   weights = 1.0;
end
sos_image = sumOfSquares(im_data, weights);


%7: Apply Laplacian Filter & resize image if necessary
final_image = laplacian_image( sos_image, da_xres, da_yres, zip_factor);

%8: Create DICOM image file from Pfile name
new_dfile = strcat(pfile, "lp.dcm");

%9 Create the new DICOM image  
result = dicomwrite(final_image, new_dfile);
info = dicominfo(new_dfile);

% udpate default window width and window level
info.WindowWidth  = max(max(final_image));  %default window width for new image
info.WindowCenter = info.WindowWidth/2;  %defautl window level for new image
info.PatientName.FamilyName = fname;
info.SeriesDescription = 'ZIP4, Laplacian Filtered';
info.ExamNumber = '1';
info.SeriesNumber = 3;
result = dicomwrite(final_image,new_dfile,info,'CreateMode','copy');

msg=sprintf('New dicom file created = %s', new_dfile);
disp(msg);

