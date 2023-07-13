clear all;
ext         =  {'*.jpg','*.jpeg','*.png','*.bmp'};
filePaths   =  [];
folderTest  = 'E:\工作材料\Dataset\HSTS-selected\original-selected\'; %%% test dataset
folderTest2  = 'E:\工作材料\Dataset\HSTS-selected\original-selected\RGCP'; %%% test dataset
if isdir(folderTest)
    mkdir(folderTest2)
    for i = 1 : length(ext)
        filePaths = cat(1,filePaths, dir(fullfile(folderTest,ext{i})));
    end
else
    filePaths = cat(1,filePaths, dir(folderTest));
    [folderTest,name,ext]=fileparts(folderTest);
end
set(0,'DefaultFigureVisible', 'on')
method = 'manuall';
addpath('./base/');
for i = 1:length(filePaths)
    I = im2double(imread(fullfile(folderTest, filePaths(i).name)))*255;
    [m,n,p] = size(I);
    rr = round(max(m, n) * 0.025); 
    if((rr * 8) > min(m, n))
        rr = round(max(m, n) * 0.015);
    end
    if(rr/8 < 1)
        rr = 8;
    end
    
    [A, idx] = est_air(I, rr*2);                       % estimate atmospheric light
    if strcmp(method, 'manual')
        h = figure, imshow(I/255, []); 
        title('manual airlight estimation: left click to pick a most hazy pixel. ')
        [x, y] = ginput(1);
        A = I(round(y), round(x), :);
        A = double(A) - 1;
        A = min(A, 255);
        close(h);
    end
    %% ---------------estimate illumination--------------------
    Imax = max(I, [], 3);
    Imax = imresize(Imax, 0.5);  
    Imax(Imax > 255) = 255;
    Imax(Imax < 0) = 0;
    pp=minmaxfilt(Imax,[rr/4, rr/4],'max','same');   
    mean_pp = mean(pp(:));
    
    sigma = 8 * (mean_pp/max(A))^2;  %weather parameter
    illu = jbfilter_illumination3(pp/255, Imax/255, round(rr), sigma);  
    illu = FGS(illu, 0.03, (round(rr*1.5))^2, Imax); 
    illu = imresize(illu,[m, n]);
    illu(illu < 0) = 1;
    illu(illu > 255) = 255;
    illu = repmat(illu,[1, 1, 3]);

    rr = round(max(m, n) * 0.06); 
    RGB = I;
    kk = 1; 
    %% ----------------estimate transmission---------------------
    BB = illu;
    A_max = max(A, [], 3);  
    BB(:,:,1) = illu(:,:,1).*A(:,:,1)./A_max;
    BB(:,:,2) = illu(:,:,2).*A(:,:,2)./A_max;
    BB(:,:,3) = illu(:,:,3).*A(:,:,3)./A_max;

    [t,~,~] = est_trans_fast4(RGB, A, BB, kk, rr, 0.5, idx, 1, 0);   % estimate transmission 
    r = I/255;
    %% ----------------detail enhance---------------------    
    [r_de,dk1]=DpostProcess3(r, t, 1, 2, BB);

    %% ----------------fog remove---------------------   
    I_final = r_de;
    I_final = rmv_haze(I_final*255, BB, illu, t)/255;                % remove haze
    I_final(I_final > 1) = 1;
    I_final(I_final < 0) = 0;
    I_l = I_final;
    
    %% ----------------illumination enhance---------------------
    illu2 = log(illu)/log(255);   
    max_r = max(I_l, [], 3);
    t_th = t(round(1):end,:);
    flag = t >= median(t_th(:));
    mean_i = mean(illu(flag));
    beta = 0.6/(mean(max_r(flag))/(mean_i/255));
    illu_pro = 1 - log(beta)/log(mean_i/255);
    illu_pro = max(0.25, illu_pro); 
    illu_pro = min(1, illu_pro);
    r2 = I_l./(power(BB/255, illu_pro)).*illu2;  
    
    r2(r2 > 1) = 1;
    r2(r2 < 0) = 0;
    imwrite(r2, fullfile(folderTest2, [filePaths(i).name, '_EBP_2.png']));

end