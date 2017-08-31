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
sigma = 100;
gsize = size(im);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
g = gaussC(R,C, sigma, center);
g = double2uint8(g);

% random warp original image to create training set
img = imcrop(im, rect);
g = imcrop(g, rect);
height = size(g,1);
width = size(g,2);
Ai = (fft2(g).*conj(fft2(img)));
Bi = (fft2(img).*conj(fft2(img)));
N = 127;
for i = 1:N
    [fi, gi] = rand_warp(img, g);
    Ai = Ai + (fft2(gi).*conj(fft2(fi)));
    Bi = Bi + (fft2(fi).*conj(fft2(fi)));
end

% Online training regimen
eta = 0.125;
figure;
for i = 1:size(img_files, 1)
    img = imread(img_files(i,:));
    if (i == 1)
        Ai = eta.*Ai;
        Bi = eta.*Bi;
    else
        Hi = Ai./Bi;
        hi = double2uint8(ifft2(Hi));
        fi = imcrop(img, rect); 
        fi = imresize(fi, [height width]);
        gi = multspec(hi, fi);
        maxval = max(gi(:));
        [P, Q] = find(gi == maxval);
        dx = mean(P)-height/2;
        dy = mean(Q)-width/2;
        rect = [rect(1)+dy rect(2)+dx width height];
        fi = imcrop(img, rect); 
        fi = imresize(fi, [height width]);
        Ai = eta.*(fft2(g).*conj(fft2(fi))) + (1-eta).*Ai;
        Bi = eta.*(fft2(fi).*conj(fft2(fi))) + (1-eta).*Bi;
    end
    
    % visualization
    text_str = ['Frame: ' num2str(i)];
    box_color = 'green';
    position=[1 2];
    result = insertText(img, position,text_str,'FontSize',30,'BoxColor',...
                     box_color,'BoxOpacity',0.4,'TextColor','white');
    result = insertShape(result, 'Rectangle', rect, 'LineWidth', 5);
    imshow(result);
end