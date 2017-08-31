% get images from source directory
% src = '/Neutron7/abhinav.moudgil/mdnet/dataset/mydata/Dos';
% img_path = [src '/img/'];
% D = dir([img_path, '*.png']);
% seq_len = length(D(not([D.isdir])));
% if exist([img_path num2str(1, '%05i.png')], 'file'),
%     img_files = num2str((1:seq_len)', [img_path '%05i.png']);
% else
%     error('No image files found in the directory.');
% end

clc; close all; clear;

img_path = '../data/';
D = dir([img_path, '*.jpg']);
seq_len = length(D(not([D.isdir])));
if exist([img_path num2str(1, '%05i.jpg')], 'file'),
    img_files = num2str((1:seq_len)', [img_path '%05i.jpg']);
else
    error('No image files found in the directory.');
end

% save gray images to local directory
% img_files = img_files(43:end, :);
sz = size(img_files);
seq_len = sz(1,1);
% mkdir data; 
% for i = 1 : seq_len
%     im = imread(img_files(i,:));
%     im = rgb2gray(im);
%     imwrite(im, ['data/' num2str(i, '%05i.jpg')], 'jpeg');
% end

% select target from first frame
im = imread(img_files(1,:));
imshow(im);
rect = getrect;
center = [rect(2)+rect(4)/2 rect(1)+rect(3)/2];

% plot gaussian
sigma = 1000;
gsize = size(im);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
g = gaussC(R,C, sigma, center);
g = double2uint8(g);
% imshow(g);
H = ((fft2(g).*conj(fft2(im)))./(fft2(im).*conj(fft2(im))));
h = double2uint8(ifft2(H));
h = double(h);
% imshow(h);
% verify to get ground truth image from the obtained filter
% imshow(multspec(h, im)) 

% random warp original image to create training set
N = 127;
for i = 1:N
    [img, grd] = rand_warp(im, g);
    train_set(:,:,i) = img;
    targets(:,:,i) = grd;
end

for i = 1:N
    gi = targets(:,:,i);
    fi = train_set(:,:,i);
    Hi = ((fft2(gi).*conj(fft2(fi)))./(fft2(fi).*conj(fft2(fi))));
    hi = double2uint8(ifft2(Hi));
    h = h + double(hi);
end;

h = h/N;
h = double2uint8(h);
% figure; imshow(h);
% verify to get ground truth image from the obtained filter
figure;
fig = imshow(im);
set(fig, 'AlphaData', multspec(h, im));




