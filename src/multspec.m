function h = multspec(g, im)
h = uint8(255*mat2gray(ifft2(fft2(g).*fft2(im))));