# read the three images
hd = imread("highdetail.jpg");

# Transfer images from RGB to gray level
hd = rgb2gray(hd);


# convert images to double to perform operations
hd = im2double(hd);


# Fourier Transform for the first image : highdetail
hdft = fft2(hd);
show_hdft = fftshift(hdft); # using for plot
show_hdft = abs(show_hdft);
show_hdft = log(show_hdft + 1);

figure(1);
subplot(3,2,1); imshow(hd);
subplot(3,2,2); imshow(show_hdft, []);
################
# operations on first image
# W is the image will be used in multiplication

## on 0.1
figure(2);

[x, y] = size(hdft);
W = zeros(x,y);
xrad = 0.05 * x;
yrad = 0.05 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end

Whd =  fftshift(hdft) .* W;

subplot(3,2,1); imshow(  abs( log(Whd+1) ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,2); imshow(log ( abs( R ) + 1) , []); 

## on 0.3

figure(3);
W = zeros(x,y);
xrad = 0.15 * x;
yrad = 0.15 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end



Whd =  fftshift(hdft) .* W;

subplot(3,2,1); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,2); imshow( log ( abs(R) + 1 ), []); 

## on 0.5

figure(4);
W = zeros(x,y);
xrad = 0.25 * x;
yrad = 0.25 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,1); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,2); imshow(log(abs( R)+1 ), []); 

## on 0.7

figure(5);
W = zeros(x,y);
xrad = 0.35 * x;
yrad = 0.35 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,1); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,2); imshow(log(abs( R) +1), []); 

## on 0.9
figure(6);
#subplot(4,1,1); imshow(hd);
#subplot(4,1,2); imshow(show_hdft, [ ]);

W = zeros(x,y);
xrad = 0.45 * x;
yrad = 0.45 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,1);
#subplot(4,5,15); 
imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,2);
#subplot(4,5,20); 
imshow(log(abs( R ) +1), []); 

############################################################################################
# read the three images
hd = imread("my_choice.jpg");

# Transfer images from RGB to gray level
hd = rgb2gray(hd);


# convert images to double to perform operations
hd = im2double(hd);


# Fourier Transform for the first image : highdetail
hdft = fft2(hd);
show_hdft = fftshift(hdft); # using for plot
show_hdft = abs(show_hdft);
show_hdft = log(show_hdft + 1);

figure(1);
subplot(3,2,3); imshow(hd);
subplot(3,2,4); imshow(show_hdft, []);
################
# operations on first image
# W is the image will be used in multiplication

## on 0.1
figure(2);

[x, y] = size(hdft);
W = zeros(x,y);
xrad = 0.05 * x;
yrad = 0.05 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end

Whd =  fftshift(hdft) .* W;

subplot(3,2,3); imshow(  abs( log(Whd+1) ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,4); imshow(log ( abs( R ) + 1) , []); 

## on 0.3

figure(3);
W = zeros(x,y);
xrad = 0.15 * x;
yrad = 0.15 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end

Whd =  fftshift(hdft) .* W;

subplot(3,2,3); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,4); imshow( log ( abs(R) + 1 ), []); 

## on 0.5

figure(4);
W = zeros(x,y);
xrad = 0.25 * x;
yrad = 0.25 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,3); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,4); imshow(log(abs( R)+1 ), []); 

## on 0.7

figure(5);
W = zeros(x,y);
xrad = 0.35 * x;
yrad = 0.35 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,3); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,4); imshow(log(abs( R) +1), []); 

## on 0.9
figure(6);
#subplot(4,1,1); imshow(hd);
#subplot(4,1,2); imshow(show_hdft, [ ]);

W = zeros(x,y);
xrad = 0.45 * x;
yrad = 0.45 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,3);
#subplot(4,5,15); 
imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,4);
#subplot(4,5,20); 
imshow(log(abs( R ) +1), []); 

###################################################################
# read the three images
hd = imread("Low_detail.jpg");

# Transfer images from RGB to gray level
#hd = rgb2gray(hd);


# convert images to double to perform operations
hd = im2double(hd);


# Fourier Transform for the first image : highdetail
hdft = fft2(hd);
show_hdft = fftshift(hdft); # using for plot
show_hdft = abs(show_hdft);
show_hdft = log(show_hdft + 1);

figure(1);
subplot(3,2,5); imshow(hd);
subplot(3,2,6); imshow(show_hdft, []);
################
# operations on first image
# W is the image will be used in multiplication

## on 0.1
figure(2);

[x, y] = size(hdft);
W = zeros(x,y);
xrad = 0.05 * x;
yrad = 0.05 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end

Whd =  fftshift(hdft) .* W;

subplot(3,2,5); imshow(  abs( log(Whd+1) ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,6); imshow(log ( abs( R ) + 1) , []); 

## on 0.3

figure(3);
W = zeros(x,y);
xrad = 0.15 * x;
yrad = 0.15 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end



Whd =  fftshift(hdft) .* W;

subplot(3,2,5); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,6); imshow( log ( abs(R) + 1 ), []); 

## on 0.5

figure(4);
W = zeros(x,y);
xrad = 0.25 * x;
yrad = 0.25 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,5); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,6); imshow(log(abs( R)+1 ), []); 

## on 0.7

figure(5);
W = zeros(x,y);
xrad = 0.35 * x;
yrad = 0.35 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,5); imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,6); imshow(log(abs( R) +1), []); 

## on 0.9
figure(6);
#subplot(4,1,1); imshow(hd);
#subplot(4,1,2); imshow(show_hdft, [ ]);

W = zeros(x,y);
xrad = 0.45 * x;
yrad = 0.45 * y;

for i = floor(x/2 - xrad) : floor(x/2 + xrad) 
  for j = floor(y/2 - yrad) : floor(y/2 + yrad)
    W(i,j) = 1; 
   end
end


Whd =  fftshift(hdft) .* W;

subplot(3,2,5);
#subplot(4,5,15); 
imshow(  log( abs( Whd ) + 1 ) , [ ] );
#Whd = ifftshift(Whd);
R = ifft2(Whd);

subplot(3,2,6);
#subplot(4,5,20); 
imshow(log(abs( R ) +1), []); 



