%%
%{
        --------------- Embedding Process--------------
%}

%% Import image
cov = im2gray(imread('jetplane.tif'));
%%cov = imresize(cov,[512 512]);
imshow(cov);
biometric = imread('biometric.png');

signature = im2gray(imread('ruthvik1.jpg'));
%  signature = imread('2.bmp');
%  signature = imresize(signature,[128 128]);

alpha = 0.1;
beta = 0.2;

%%Signature into Biometric
[BLL, BLH, BHL, BHH] = dwt2(biometric, 'haar');
J = dct2(BLL);
[BU, BS, BV] = svd(J, 'econ');
save(fullfile(tempdir, 'BS.mat'), 'BS', '-mat');    %save

% Apply SVD to Signature
[SU, SS, SV] = svd(double(signature), 'econ');
save(fullfile(tempdir, 'SU.mat'), 'SU', '-mat');    %save
save(fullfile(tempdir, 'SV.mat'), 'SV', '-mat');    %save

New_BS = BS + alpha .* SS;
MBS = BU * New_BS * BV';
New_LL = idct2(MBS);

Processed_watermark = idwt2(New_LL, BLH, BHL, BHH, 'haar');
Processed_watermark = uint8(Processed_watermark);

imwrite(Processed_watermark,'Pwatermark.png');

%% embed pwatermark into cover image

[CLL, CLH, CHL, CHH] = dwt2(cov, 'haar');
DLL = dct2(CLL);
[cU, cS, cV] = svd(DLL, 'econ');
save(fullfile(tempdir, 'cS.mat'), 'cS', '-mat');    %save

[pwU, pwS, pwV] = svd(double(Processed_watermark),'econ');
save(fullfile(tempdir, 'pwU.mat'), 'pwU', '-mat');  %save
save(fullfile(tempdir, 'pwV.mat'), 'pwV', '-mat');  %save
HSw = cS + beta.*pwS;
H = cU * HSw * cV';
CLL_new = idct2(H) ;

Final_watermark = idwt2(CLL_new, CLH, CHL, CHH, 'haar');
Final_watermark = uint8(Final_watermark);
imwrite(Final_watermark,'FinalWatermarked.png');


%%
% %%
% %{
%         --------------- Extraction Process--------------
% %}
% 
% %% Extraction of Pwatermark from Final Watermark
% [fLL, fLH, fHL, fHH] = dwt2(Final_watermark, 'haar');
% dfLL = dct2(fLL);
% [fU, fS, fV] = svd(dfLL);
% 
% Pw_s = (fS - cS)./beta;
% w_hat = pwU * Pw_s * pwV';
% 
% Expw = uint8(w_hat);
% imwrite(Expw,'Extracted_pw.png');
% 
% %% Extraction of Signature from Pwatermark
% [pLL, pLH, pHL, pHH] = dwt2(Expw, 'haar');
% Pw = dct2(pLL);
% [ESU, ESS, ESV] = svd(Pw);
% SS = (ESS - BS)./alpha;
% 
% ExSS = SU*SS*SV';
% EXS = uint8(ExSS);
% imwrite(EXS,'ExSig.png');
% 

%%
PSNR1=psnr(cov,Final_watermark);
disp(PSNR1)
SSIM1 = ssim(cov,Final_watermark);
disp(SSIM1)
figure()
subplot(2,3,3);imshow(signature);title('signature used');
subplot(2,3,2);imshow(biometric);title('biometric used');
subplot(2,3,1);imshow(cov);title('cover image used');
subplot(2,3,5);imshow(Final_watermark);title('Final watermarked image');


