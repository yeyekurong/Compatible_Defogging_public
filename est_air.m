function [A,Aidx] = est_air(RGB, r)
%RGB = double(RGB(:,1:180,:));
%RGB2 = 255*(RGB/255).^0.5;
R = RGB(:,:,1);G = RGB(:,:,2);B = RGB(:,:,3);
I = min(RGB,[],3);
[m,n] = size(I);

%N = boxfilter(ones(m, n), r);
N = 4*r*r;
mean_I = boxfilter(I, r) ./ N;
I_th = max(mean_I(:)) - std(mean_I(:))/2;
th = mean_I>I_th;
while(sum(th(:))/(m*n)<0.1)
    I_th2 = I_th - std(mean_I(:))/2;
    th = xor(mean_I>I_th2,mean_I>I_th);
    I_th = I_th2;
end
[A, Aidx] = max(mean_I(:).*th(:));
%R_th = R(Aidx),G_th = G(Aidx),B_th = B(Aidx);
%figure,imshow(th);
A(:,:,1) = mean(R(th));
A(:,:,2) = mean(G(th));
A(:,:,3) = mean(B(th));




% 
% Imax = max(RGB,[],3);
% sa = (Imax-I)./Imax;
% t = mean_I/255*0.95-0.78*sa;
% figure,imshow(t);
% % flag = t<mean(t(:));
% %index = 0.2*sa+mean_I; %
% % index(flag)=0;
% % figure,imshow(mean_I/255);
% %figure,imshow(index/255);
% [A, Aidx] = max(t(:));
% ceil(Aidx/m)
% Aidx-ceil(Aidx/m-1)*m
% A(:,:,1) = R(Aidx);A(:,:,2) = G(Aidx);A(:,:,3) = B(Aidx);
%max(R(Aidx),G(Aidx));

% for k = 1 : 3
%     minImg = ordfilt2(double(RGB(:, :, k)), 1, ones(r), 'symmetric');
%     A(k) = max(minImg(:));
% end

% h = figure, imshow(RGB/255); 
% title('manual airlight estimation: left click to pick a most hazy pixel. ')
% [x, y] = ginput(1);
% A = RGB(round(y), round(x), :);
% A = double(A) -1;
% A = min(A, 255);
% close(h);