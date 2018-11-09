function img = rand_warp(img, is_rotate)
sz = size(img);
scale = 1-0.1 + 0.2.*rand;
% trans_scale = randi([-4,4], 1, 1);
if nargin < 2,
    img = imresize(imresize(img, scale), [sz(1) sz(2)]);
else
    a = -180/16;
    b = 180/16;
    r = a + (b-a).*rand;
    img = imresize(imresize(imrotate(img, r), scale), [sz(1) sz(2)]);
end