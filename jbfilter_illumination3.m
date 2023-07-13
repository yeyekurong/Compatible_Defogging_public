% JBFILTER2 Two dimensional Joint bilateral filtering.
%    This function implements 2-D bilateral filtering using
%    the method outlined in, however with weights calculated according
%    to another image. 
%
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%
%    B = jbfilter2(D,C,W,SIGMA) performs 2-D bilateral filtering
%    for the grayscale or color image A. D should be a double
%    precision matrix of size NxMx1 (i.e., grayscale) 
%    with normalized values in the closed interval [0,1]. 
%    C should be similar to D, from which the weights are 
%    calculated, with normalized values in the closed 
%    interval [0,1].  The half-size of the Gaussian
%    bilateral filter window is defined by W. The standard
%    deviations of the bilateral filter are given by SIGMA,
%    where the spatial-domain standard deviation is given by
%    SIGMA(1) and the intensity-domain standard deviation is
%    given by SIGMA(2).
%
% Based on the code from Douglas R. Lanman, Brown University, September 2006.
%
% Varuna De Silva, University of Surrey, May 2010
% varunax@gmail.com


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process input and select appropriate filter.
function B = jbfilter_illumination2(D,C,rr,sigma)

% Verify that the input image exists and is valid.
if ~exist('D','var') || isempty(D)
   error('Input image D is undefined or invalid.');
end
if ~isfloat(D) || ~sum([1,3] == size(D,3)) || ...
      min(D(:)) < 0 || max(D(:)) > 1
   error(['Input image D must be a double precision ',...
          'matrix of size NxMx1 or NxMx3 on the closed ',...
          'interval [0,1].']);      
end

% Verify bilateral filter window size.
if ~exist('w','var') || isempty(w) || ...
      numel(w) ~= 1 || w < 1
   w = 5;
end
w = ceil(w);

% Verify bilateral filter standard deviations.
if ~exist('sigma','var') || isempty(sigma) 
   sigma =  0.1;
end

% Apply either grayscale or color bilateral filtering.
if size(D,3) == 1
   B = jbfltGray(D,C,rr,sigma);
else
   B = jbfltGray(D,C,rr,sigma);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements bilateral filtering for grayscale images.
function B = jbfltGray(D,C,rr,sigma_r)
win=rr; %1-118 1-117
% Pre-compute Gaussian distance weights.
%[X,Y] = meshgrid(-w:w,-w:w);
%G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
%h = waitbar(0,'Applying bilateral filter on gray image...');
%set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
inx = (1:1:128)/255;
Table = exp(-(0.2./(inx*(2*sigma_r^2)))); 
dim = size(D);
B = zeros(dim);
D = uint8(D*255+1);
C = uint8(C*255+1);
D = double(D/2);
C = double(C/2);
colh = zeros(1,128);
si = 0;
sj = 0;
ed = win;
for i=1:win
    for j = 1:2:win
        colh(D(i,j)) = colh(D(i,j)) + 1;
    end
end

for i=1:2:dim(1)
    if(i>win)
        si = i-(win-1);
        for k=1:2:win
            colh(D(si,k)) = colh(D(si,k)) - 1;
            colh(D(si-1,k)) = colh(D(si-1,k)) - 1;
        end
    end
    if((i<(dim(1)-win+2))&&i>1)
        ed = i + win - 1;
        for k = 1:2:win
            colh(D(ed,k)) = colh(D(ed,k)) + 1;
            colh(D(ed-1,k)) = colh(D(ed-1,k)) + 1;
        end
    end
    rowh = colh;
    for j = 1:2:dim(2)
        if(j>win)
            sj = j-(win);
            for k = (si+1):(ed)
                rowh(D(k,sj)) = rowh(D(k,sj)) - 1;
            end
        end
        if(j<(dim(2)-win+2)&&j>1)
            ed2 = j + win-2;
            for k = (si+1):(ed)
                rowh(D(k,ed2)) = rowh(D(k,ed2)) + 1;
            end
        end
        th = C(i,j);
        th2 = D(i,j);
        csum = 0;
        vsum = 0;
        for t = th:128
            csum = Table(t-th+1)*rowh(t) + csum;
            vsum = t*Table(t-th+1)*rowh(t) + vsum;
        end
        if(csum==0)
            B(i:i+1,j:j+1) = th;
        else
            B(i:i+1,j:j+1) = vsum/csum;
        end
    end
end
B = B(1:dim(1),1:dim(2));
B = B*2;    
B(B>255) = 255;
B(B<0) = 0;
      