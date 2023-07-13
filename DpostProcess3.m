function [I_final, dk1]=DpostProcess3(I, darkchannel, Sigma, Amount,A)
I_gray=rgb2ycbcr(I);
I=double(I);
YY=I_gray(:,:,1);
if(isempty(Sigma))
    Sigma=2.0;  
end
if(isempty(Amount))
    Amount=1.5;
end

fK1=1.0/(2*Sigma*Sigma);
fK2=fK1/pi;

w=5;
[X,Y]=meshgrid(-w:w,-w:w);
H=fK2*exp(-(X.^2+Y.^2)*fK1); 

YY_low=imfilter(YY,H,'conv','replicate'); 
YY_low=YY_low.*255;
YY_low = qxfilter2(YY_low,YY*255,0.05);
maxlarge=YY_low;
YY_hig=YY.*255-YY_low; 
delta=abs(YY_hig);

vb=delta./maxlarge;  
vb_max=max(vb(:));
deta=vb./vb_max;  
detamean= mean(deta(:));
dk1=1./(1+exp((detamean-deta)/0.001));
darkchannelMean=mean(darkchannel(:));
dk2=1./(1+exp((darkchannel-darkchannelMean)/0.1));
finalDk=dk1.*dk2;
dk2=finalDk;
dk2=dk2./max(dk2(:));

weightfinal(:,:,1)=dk2;
weightfinal(:,:,2)=weightfinal(:,:,1);
weightfinal(:,:,3)=weightfinal(:,:,1);
 
J2 = qxfilter2(I*255,I*255,0.08)/255;
I_hight=(I-J2);
Enhance_pro = Amount*mean(1-darkchannel(:));

I_final=double(I)+Enhance_pro.*weightfinal.*double(I_hight);
I_final=max(min(1,I_final),0);
end

