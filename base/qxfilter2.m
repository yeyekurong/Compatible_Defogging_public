function J=qxfilter2(In,L,sigma_range)
[h,w,p] = size(In);
sigma_spatial = 0.008;   %0.008
if p == 1
    r = In;
    C = L;
    out_r = ones(h,w);
    tempr = ones(h,w);
    ypr = ones(h,w);
    %sigma_range = 0.05;
    inv_sigma_range = 1/(255*sigma_range);
    index = 0:255;
    range_table = exp(-index*inv_sigma_range);
    alpha = exp(-sqrt(2)/(sigma_spatial*w));
    tempr(:,1) = r(:,1);
    ypr(:,w) = r(:,w);
  
    range_dist = uint8((abs(diff(C,1,2))));
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;
    for i=1:w-1
        tempr(:,i+1) = inv_alpha(:,i) .* double(r(:,i+1)) + alpha_(:,i) .* tempr(:,i);
    end
    tempr(:,w) = 0.5*(tempr(:,w) + double(r(:,w)));
  

    range_dist = uint8((abs(diff(fliplr(C),1,2))));
    range_dist = fliplr(range_dist);
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;

    for i=w-1:-1:1
        ypr(:,i) = inv_alpha(:,i) .* double(r(:,i)) + alpha_(:,i) .* ypr(:,i+1);   
        tempr(:,i) = 0.5*(ypr(:,i) + tempr(:,i) );
    end

    alpha = exp(-sqrt(2)/(sigma_spatial*h));
    out_r(1,:) = tempr(1,:);
    ypr(h,:) = tempr(h,:);
    range_dist = uint8((abs(diff(C,1,1))));
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;
    for i=1:h-1
        out_r(i+1,:) = inv_alpha(i,:) .* tempr(i+1,:) + alpha_(i,:) .* out_r(i,:);
    end

    out_r(h,:) = 0.5*(tempr(h,:) + out_r(h,:));
    range_dist = uint8((abs(diff(flipud(C),1,1))));
    range_dist = flipud(range_dist);
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;

    for i=h-1:-1:1
        ypr(i,:) = inv_alpha(i,:) .* tempr(i,:) + alpha_(i,:) .* ypr(i+1,:);
        out_r(i,:) = 0.5*(ypr(i,:) + out_r(i,:) );
    end
    J = out_r;
else 
    r = In(:,:,1);
    g = In(:,:,2);
    b = In(:,:,3);
    C_r = L(:,:,1);
    C_g = L(:,:,2);
    C_b = L(:,:,3);
    out_r = ones(h,w);
    out_g = ones(h,w);
    out_b = ones(h,w);
    tempr = ones(h,w);
    tempg = ones(h,w);
    tempb = ones(h,w);
    ypr = ones(h,w);
    ypg = ones(h,w);
    ypb = ones(h,w);
    %sigma_range = 0.05;
    inv_sigma_range = 1/(255*sigma_range);
    index = 0:255;
    range_table = exp(-index*inv_sigma_range);

    alpha = exp(-sqrt(2)/(sigma_spatial*w));
    tempr(:,1) = r(:,1);
    tempg(:,1) = g(:,1);
    tempb(:,1) = b(:,1);
    ypr(:,w) = r(:,w);
    ypg(:,w) = g(:,w);
    ypb(:,w) = b(:,w);

    range_dist = uint8(0.25*(2*abs(diff(C_r,1,2)) + abs(diff(C_g,1,2)) + abs(diff(C_b,1,2))));
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;
    for i=1:w-1
        tempr(:,i+1) = inv_alpha(:,i) .* double(r(:,i+1)) + alpha_(:,i) .* tempr(:,i);
        tempg(:,i+1) = inv_alpha(:,i) .* double(g(:,i+1)) + alpha_(:,i) .* tempg(:,i);
        tempb(:,i+1) = inv_alpha(:,i) .* double(b(:,i+1)) + alpha_(:,i) .* tempb(:,i);
    end

    tempr(:,w) = 0.5*(tempr(:,w) + double(r(:,w)));
    tempg(:,w) = 0.5*(tempg(:,w) + double(g(:,w)));
    tempb(:,w) = 0.5*(tempb(:,w) + double(b(:,w)));

    range_dist = uint8(0.25*(2*abs(diff(fliplr(C_r),1,2)) + abs(diff(fliplr(C_g),1,2)) + abs(diff(fliplr(C_b),1,2))));
    range_dist = fliplr(range_dist);
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;

    for i=w-1:-1:1
        ypr(:,i) = inv_alpha(:,i) .* double(r(:,i)) + alpha_(:,i) .* ypr(:,i+1);
        ypg(:,i) = inv_alpha(:,i) .* double(g(:,i)) + alpha_(:,i) .* ypg(:,i+1);
        ypb(:,i) = inv_alpha(:,i) .* double(b(:,i)) + alpha_(:,i) .* ypb(:,i+1);
        tempr(:,i) = 0.5*(ypr(:,i) + tempr(:,i) );
        tempg(:,i) = 0.5*(ypg(:,i) + tempg(:,i) );
        tempb(:,i) = 0.5*(ypb(:,i) + tempb(:,i) );
    end

    alpha = exp(-sqrt(2)/(sigma_spatial*h));
    out_r(1,:) = tempr(1,:);
    out_g(1,:) = tempg(1,:);
    out_b(1,:) = tempb(1,:);
    ypr(h,:) = tempr(h,:);
    ypg(h,:) = tempg(h,:);
    ypb(h,:) = tempb(h,:);

    range_dist = uint8(0.25*(2*abs(diff(C_r,1,1)) + abs(diff(C_g,1,1)) + abs(diff(C_b,1,1))));
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;
    for i=1:h-1
        out_r(i+1,:) = inv_alpha(i,:) .* tempr(i+1,:) + alpha_(i,:) .* out_r(i,:);
        out_g(i+1,:) = inv_alpha(i,:) .* tempg(i+1,:) + alpha_(i,:) .* out_g(i,:);
        out_b(i+1,:) = inv_alpha(i,:) .* tempb(i+1,:) + alpha_(i,:) .* out_b(i,:);
    end

    out_r(h,:) = 0.5*(tempr(h,:) + out_r(h,:));
    out_g(h,:) = 0.5*(tempr(h,:) + out_g(h,:));
    out_b(h,:) = 0.5*(tempr(h,:) + out_b(h,:));

    range_dist = uint8(0.25*(2*abs(diff(flipud(C_r),1,1)) + abs(diff(flipud(C_g),1,1)) + abs(diff(flipud(C_b),1,1))));
    range_dist = flipud(range_dist);
    weight = range_table(range_dist+1);
    alpha_ = alpha * weight;
    inv_alpha = 1 - alpha_;

    for i=h-1:-1:1
        ypr(i,:) = inv_alpha(i,:) .* tempr(i,:) + alpha_(i,:) .* ypr(i+1,:);
        ypg(i,:) = inv_alpha(i,:) .* tempg(i,:) + alpha_(i,:) .* ypg(i+1,:);
        ypb(i,:) = inv_alpha(i,:) .* tempb(i,:) + alpha_(i,:) .* ypb(i+1,:);
        out_r(i,:) = 0.5*(ypr(i,:) + out_r(i,:) );
        out_g(i,:) = 0.5*(ypg(i,:) + out_g(i,:) );
        out_b(i,:) = 0.5*(ypb(i,:) + out_b(i,:) );
    end
    J = cat(3,(out_r),(out_g),(out_b));
end