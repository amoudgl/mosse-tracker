function img = preprocess(img)
[r,c] = size(img);
win = window2(r,c,@hann);
eps = 1e-5;
img = log(double(img)+1);
img = (img-mean(img(:)))/(std(img(:))+eps);
img = img.*win;
end
