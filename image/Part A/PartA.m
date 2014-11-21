# read the three images
hd = imread("highdetail.jpg");
ld = imread("Low_detail.jpg");
mych = imread("my_choice.jpg");
# convert images to double to perform operations
hd = im2double(hd);
ld = im2double(ld);
mych = im2double(mych);
# Transfer images from RGB to gray level
hd = rgb2gray(hd);
mych = rgb2gray(mych);
# Fourier Transform for the first image : highdetail
hdft = fft2(hd);
show_hdft = fftshift(hdft); # using for plot
show_hdft = log(hdft);
show_hdft = abs(hdft);
# Fourier Transform for the second image : low_detail
ldft = fft2(ld);
show_ldft = fftshift(ldft);
show_ldft = log(ldft);
show_ldft = abs(ldft);
# Fourier Transform for the third image : my choice
mychft = fft2(mych);
show_mychft = fftshift(mychft);
show_mychft = log(mychft);
show_mychft = abs(mychft);

################
# operations on first image
# W is the image will be used in multiplication
W = zeros(x,y);
subplot(2,1,1); imshow(W);
xrad = 0.05 * x;
yrad = 0.05 * y;

for i = (x/2 - xrad) : (x/2 +xrad) 
  for j = (y/2 - yrad) : (y/2 + yrad)
    W(i,j) = 1; 
   end
end
subplot(2,1,2); imshow(W);  