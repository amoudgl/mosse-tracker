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
sigma = 500;
gsize = size(im);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
g = gaussC(R,C, sigma, center);
g = double2uint8(g);
% imshow(g);
% H = ((fft2(g).*conj(fft2(im)))./(fft2(im).*conj(fft2(im))));
% h = double2uint8(ifft2(H));
% h = double(h);
% imshow(h);
% verify to get ground truth image from the obtained filter
% imshow(multspec(h, im)) 

Ai = (fft2(g).*conj(fft2(im)));
Bi = (fft2(im).*conj(fft2(im)));
% random warp original image to create training set
N = 127;
for i = 1:N
    [fi, gi] = rand_warp(im, g);
    Ai = Ai + (fft2(gi).*conj(fft2(fi)));
    Bi = Bi + (fft2(fi).*conj(fft2(fi)));
end
% h = h/N;
% h = double2uint8(h);
% figure; imshow(h);
% verify to get ground truth image from the obtained filter
% figure;
% fig = imshow(im);
% set(fig, 'AlphaData', multspec(h, im));

% Online training regimen
eta = 0.125;
test_images = img_files(1:100,:);
figure;
for i = 1:size(test_images, 1)
    fi = imread(test_images(i,:));
    if (i == 1)
        Ai = eta.*Ai;
        Bi = eta.*Bi;
    else
%         gi = multspec(hi, fi);
        Ai = eta.*(fft2(g).*conj(fft2(fi))) + (1-eta).*Ai;
        Bi = eta.*(fft2(fi).*conj(fft2(fi))) + (1-eta).*Bi;
    end
    
    % track object
    Hi = Ai./Bi;
    hi = double2uint8(ifft2(Hi));
    gi = multspec(hi, fi);
%     imshow(gi);
    I = imlincomb(1, fi, 1, gi, 'uint8');
    text_str = ['Frame: ' num2str(i)];
    box_color = 'green';
    position=[1 2];
    result = insertText(I,position,text_str,'FontSize',30,'BoxColor',...
                     box_color,'BoxOpacity',0.4,'TextColor','white');
    imshow(result);
end