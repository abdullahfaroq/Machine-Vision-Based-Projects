%First of all create a new folder of coins
clear all
clc
[fileName, filePath] = uigetfile('*.png', 'Select a PNG image file');
if fileName
    img = imread(fullfile(filePath, fileName));
else
    fprintf('No PNG file selected.\n');
end
%to remove the noise from the image
If = imgaussfilt(img,1.5);

% removing the background 
[BW,maskedImage] = segmentImage(If); 

% selecting invalid coins via "opening"
[BW1,maskedImage1] = segmentImage1(If);

 %logical AND to select the valid coins
final=BW & ~BW1;

%--------------------------------
%creating green box on the valid coins
coin_props = regionprops("table",final,"BoundingBox"); 
img2 = insertShape(img,"Rectangle",coin_props.BoundingBox,"color","green","LineWidth",5);

%creating red box on the invalid coins
BWprops1 = regionprops("table",BW1,"BoundingBox");
img3 = insertShape(img,"Rectangle",BWprops1.BoundingBox,"color","red","LineWidth",5);

%adding the two images using logical OR on each channel "RGB"
red1 = img2(:, :, 1);
green1 = img2(:, :, 2);
blue1 = img2(:, :, 3);

red2 = img3(:, :, 1);
green2 = img3(:, :, 2);
blue2 = img3(:, :, 3);

red_result = bitor(red1, red2);
green_result = bitor(green1, green2);
blue_result = bitor(blue1, blue2);
%catenate the results
final_image = cat(3, red_result, green_result, blue_result);

%-------------------------------------
%Counting valid and invalid coins
invalid_coins=max(max(bwlabel(BW1)));
valid_coins=max(max(bwlabel(final)));

%----------------------------------------------------'
%assigning the total monetary value of the coins via MajorAxisLength
coin_props = regionprops('table', final, 'MajorAxisLength');
total = 0;
cent=0;
quarter=0;
dimes=0;
nickels=0;

% Loop through the regions
for i = 1:max(valid_coins)
    x = coin_props.MajorAxisLength(i);
    if x > 128
        total = total + 0.5;
        cent=cent+1;   
    elseif  x >95 & x<105
        total=total+0.25;
        quarter=quarter+1;
    elseif x > 85 & x< 94
        total= total+ 0.05;
        nickels=nickels+1;

    elseif x> 73 & x< 85
        total=total+0.1;
        dimes=dimes+1;
    end
end
disp(['There are ' num2str(valid_coins) ' valid coins and ' num2str(invalid_coins) ' invalid coins.']);
disp(['There are ' num2str(cent) ' cents, ' num2str(quarter) ' quarters, '  num2str(dimes) ' dimes and ' num2str(nickels) ' nickels in the image']);
disp(['Total Value of Coins: ' num2str(total)])
imshow(final_image)

%------------------------------------------------------
%Function File:1 segmention for all the coins
function [BW,maskedImage] = segmentImage(X)
X = imadjust(X);
BW = imbinarize(X, 'adaptive', 'Sensitivity', 0.500000, 'ForegroundPolarity', 'bright');
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);
radius = 15;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
maskedImage = X;
maskedImage(~BW) = 0;
end
%-----------------------------------------------
%Function File:2 segmentation for invalid coins
function [BW,maskedImage] = segmentImage1(X)
X = imadjust(X);
BW = X > 220;
radius = 24;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);
radius = 35;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
maskedImage = X;
maskedImage(~BW) = 0;
end