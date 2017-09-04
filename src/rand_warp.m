function img = rand_warp(img)
a = -180/16;
b = 180/16;
r = a + (b-a).*rand;
sz = size(img);
scale = 1-0.1 + 0.2.*rand;
% trans_scale = randi([-4,4], 1, 1);
img = imresize(imresize(imrotate(img, r), scale), [sz(1) sz(2)]);
