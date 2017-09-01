% get images from source directory
src = '/Neutron7/abhinav.moudgil/tracking-dataset/Dos_resized_43/';
img_path = [src '/img/'];
D = dir([img_path, '*.png']);
seq_len = length(D(not([D.isdir])));
if exist([img_path num2str(1, '%05i.png')], 'file'),
    img_files = num2str((1:seq_len)', [img_path '%05i.png']);
else
    error('No image files found in the directory.');
end

% select target from first frame
im = imread(img_files(1,:));
f = figure('Name', 'Select object to track'); imshow(im);
rect = getrect;
close(f); clear f;
center = [rect(2)+rect(4)/2 rect(1)+rect(3)/2];

% plot gaussian
sigma = 100;
gsize = size(im);
[R,C] = ndgrid(1:gsize(1), 1:gsize(2));
g = gaussC(R,C, sigma, center);
g = double2uint8(g);

% randomly warp original image to create training set
img = rgb2gray(im);
img = imcrop(img, rect);
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

% MOSSE online training regimen
eta = 0.125;
mkdir results;
fig = figure('Name', 'MOSSE');
for i = 1:size(img_files, 1)
    im = imread(img_files(i,:));
    img = rgb2gray(im);
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
    position=[1 1];
    result = insertText(im, position,text_str,'FontSize',15,'BoxColor',...
                     box_color,'BoxOpacity',0.4,'TextColor','white');
    result = insertShape(result, 'Rectangle', rect, 'LineWidth', 3);
    imshow(result);
    imwrite(result, ['results/' num2str(i, '%05i.png')]);
end
