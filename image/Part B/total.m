#reading image
im = imread("highdetail.jpg");

#convert it to gray

im = rgb2gray(im);

#convert it to double
im = im2double(im);
figure(1);
subplot(1,3,1);imshow(im);

# first filter
figure(2);

M = ones(3,3);
M = ( 1 / 9 ) * M;
subplot(3,3,1); imshow(M);
# im after convlution
R = imfilter(im, M);
subplot(3,3,2); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,3); imshow(W, []);

# second filter
figure(3);

M = ones(7,7);
M = ( 1 / 49 ) * M;
subplot(3,3,1); imshow(M);
# im after convlution
R = imfilter(im, M);
subplot(3,3,2); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,3); imshow(W, []);

# third filter

figure(4);

M = ones(11,11);
M = ( 1 / 11*11 ) * M;
subplot(3,3,1); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,2); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,3); imshow(W, []);

# fourth filter

figure(5);

M = ones(15,15);
M = ( 1 / 15*15 ) * M; 
subplot(3,3,1); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,2); imshow(R, []);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,3); imshow(W, []);


# fifth filter

figure(6);

M = ones(21,21);
M = ( 1 / 21*21 ) * M;
subplot(3,3,1); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,2); imshow(R,[]);

# M : fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,3); imshow(W, []);


##########################################################
###########################################################
#reading image
im = imread("Low_detail.jpg");



#convert it to double
im = im2double(im);
figure(1);
subplot(1,3,2);imshow(im);

# first filter
figure(2);

M = ones(3,3);
M = ( 1 / 9 ) * M;
subplot(3,3,4); imshow(M);
# im after convlution
R = imfilter(im, M);
subplot(3,3,5); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,6); imshow(W, []);

# second filter
figure(3);

M = ones(7,7);
M = ( 1 / 49 ) * M;
subplot(3,3,4); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,5); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,6); imshow(W, []);

# third filter

figure(4);

M = ones(11,11);
M = ( 1 / 11*11 ) * M;
subplot(3,3,4); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,5); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,6); imshow(W, []);

# fourth filter

figure(5);

M = ones(15,15);
M = ( 1 / 15*15 ) * M; 
subplot(3,3,4); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,5); imshow(R, []);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,6); imshow(W, []);


# fifth filter

figure(6);

M = ones(21,21);
M = ( 1 / 21*21 ) * M;
subplot(3,3,4); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,5); imshow(R,[]);

# M : fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,6); imshow(W, []);


#######################################################
#######################################################
#reading image
im = imread("my_choice.jpg");

#convert it to gray

im = rgb2gray(im);

#convert it to double
im = im2double(im);
figure(1);
subplot(1,3,3); imshow(im);

# first filter
figure(2);

M = ones(3,3);
M = ( 1 / 9 ) * M;
subplot(3,3,7); imshow(M);
# im after convlution
R = imfilter(im, M);
subplot(3,3,8); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,9); imshow(W, []);

# second filter
figure(3);

M = ones(7,7);
M = ( 1 / 49 ) * M;
subplot(3,3,7); imshow(M);
# im after convlution
R = imfilter(im, M);
subplot(3,3,8); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,9); imshow(W, []);

# third filter

figure(4);

M = ones(11,11);
M = ( 1 / 11*11 ) * M;
subplot(3,3,7); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,8); imshow(R,[]);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,9); imshow(W, []);

# fourth filter

figure(5);

M = ones(15,15);
M = ( 1 / 15*15 ) * M; 
subplot(3,3,7); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,8); imshow(R, []);

# M : inverse fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,9); imshow(W, []);


# fifth filter

figure(6);

M = ones(21,21);
M = ( 1 / 21*21 ) * M;
subplot(3,3,7); imshow(M,[]);
# im after convlution
R = imfilter(im, M);
subplot(3,3,8); imshow(R,[]);

# M : fourier of W
W = fft2(M);
W = fftshift(W);
W = abs(W);
W = log( W + 1);
subplot(3,3,9); imshow(W, []);
