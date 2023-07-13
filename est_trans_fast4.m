function [transmission_estimation, sig, dis, c2] = est_trans_fast4(RGB, A, AA, k, r, low_th, idx, re, dis)
RGB = double(RGB);
A = double(A);
R = RGB(:,:,1)./AA(:,:,1);
G = RGB(:,:,2)./AA(:,:,2);
B = RGB(:,:,3)./AA(:,:,3);
I = RGB./AA;
I = min(I,[],3);
I(I>1) = 1;
I(I<0) = 0;
[m,n,~] = size(RGB);
sig = 1

u_m2 = qxfilter(I*255,I*255,0.02,0.6)/255;  
u_m = FGS(I*255, 0.05, (r)^2, power(I,0.5)*255)/255; 
N = boxfilter(ones(m,n),r); 
sigma_mm = boxfilter((I-u_m).*(I-u_m),r)./N;
sigma_mm = sqrt(sigma_mm);

if(r*6.5>min(m,n))
    r = r/2;
end
sigma_mm2 = fastguidedfilter((I),sigma_mm,r*3,0.001,2);  %
mine = u_m - 1.71*(abs(sigma_mm2));  %

if(mean(mean(AA(:,:,1)))>0.55*255)  %
    pro = 0.01;
    if(k<0.96)
        pro = 0.1;
    end
else
    pro = 0.1;
end
transmission_estimation_r = 1-k*mine;
t_min = transmission_estimation_r(idx);
t_min = max(0.06, t_min); 
t_min = min(0.3, t_min);
transmission_estimation = max(t_min,transmission_estimation_r);
transmission_estimation = min(1,transmission_estimation);

lam = (u_m-mine)./transmission_estimation;
[count,~]=imhist(lam);
[m,n] = size(mine);
sumpoint=0;
maxidx=1;
while (sumpoint<m*n*pro) 
    sumpoint=sumpoint+count(maxidx);
    maxidx=maxidx+1;
end
maxidx = (maxidx/255);
lam(lam>1) = 1;
lam(lam<0) = 0;
lam = (lam/maxidx).^2; 

if(dis==0)
    t_mean = mean(transmission_estimation_r(:));
    t_var = transmission_estimation_r(transmission_estimation_r<(t_mean+0.1));
    num_hist = imhist(t_var)/(m*n);
    [~,lo] = max(num_hist(ceil(t_min*255+2):end-1));
    lo = lo+ceil(t_min*255);
    sum_diff = abs(t_mean-lo/255);
    dis = max(min(0.2/sum_diff,3),low_th) 
end
lam = dis./(dis+exp((min(RGB./AA,[],3)-1).*lam));

c2 = lam;
if(r*6>min(m,n)/2)
    r = r/2;
end
c2 = fastguidedfilter((u_m2),c2,r*5,0.0001,2); 
c2(c2>1) = 1;
transmission_estimation = (1-c2)*max(transmission_estimation(:))+c2.*transmission_estimation;

