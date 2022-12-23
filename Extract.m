%%
%{
        --------------- Extraction Process--------------
%}

%% Read the Final Watermark and matrices
Final_watermark = imread('FinalWatermarked.png');
alpha = 0.1;
beta = 0.2;


% biometric = im2gray(imread('biometric.png'));
% signature = im2gray(imread('2.bmp'));
% %signature = imresize(signature,[128 128]);
biometric = imread('biometric.png');
signature = im2gray(imread('ruthvik1.jpg'));
%% Attacks
%{
1.crop
[rows, cols, dim] = size(Final_watermark);
BB = [round(cols*0.175) round(rows*0.175) round(cols*0.45) round(rows*0.45)];
J = imcrop(Final_watermark,BB);
figure(2);
subplot(1,2,1); imshow(Final_watermark)
subplot(1,2,2); imshow(J)
Final_watermark = imresize(J,[512 512]);
%}

%{
2.noise
Final_watermark = imnoise(Final_watermark,"salt & pepper", 0.2);
%}

%{
3.rotate (use -ve beta for clear signature)
Final_watermark = imrotate(Final_watermark,10,'crop');
%figure;imshow(Final_watermark);
%}

%{
4.scale
Final_watermark = imresize(Final_watermark,2);
Final_watermark = imresize(Final_watermark,[512 512]);
figure(2);imshow(Final_watermark);
%}

%{
5.median
Final_watermark = medfilt2(Final_watermark,[512 512]);
%}

%{
6.sharpen
Final_watermark = imsharpen(Final_watermark,'Amount',0.2);
%}

%{
7.motion blur(alpha = 0.82; beta = 0.01;)
h = fspecial('motion',7,4);
Final_watermark = imfilter(Final_watermark,h,'replicate');
%}

%{
8.Average Filter
h = fspecial('average',[4 4]);
Final_watermark = imfilter(Final_watermark,h,'replicate');
%}

%{
9.histogram equalization
Final_watermark = histeq(Final_watermark);
%}

%{
10.Jpeg compression

%}

FileData = load(fullfile(tempdir, 'cS.mat'));
cS = FileData.cS;
FileData = load(fullfile(tempdir, 'pwU.mat'));
pwU = FileData.pwU;
FileData = load(fullfile(tempdir, 'pwV.mat'));
pwV = FileData.pwV;
FileData = load(fullfile(tempdir, 'BS.mat'));
BS = FileData.BS;
FileData = load(fullfile(tempdir, 'SU.mat'));
SU = FileData.SU;
FileData = load(fullfile(tempdir, 'SV.mat'));
SV = FileData.SV;

%% Extraction of Pwatermark from Final Watermark

[fLL, fLH, fHL, fHH] = dwt2(Final_watermark, 'haar');
dfLL = dct2(fLL);
[fU, fS, fV] = svd(dfLL);

Pw_s = (fS - cS)./beta;
w_hat = pwU * Pw_s * pwV';

Expw = uint8(w_hat);
imwrite(Expw,'Extracted_pw.png');

%% Extraction of Signature from Pwatermark
[pLL, pLH, pHL, pHH] = dwt2(Expw, 'haar');
Pw = dct2(pLL);
[ESU, ESS, ESV] = svd(Pw);
SS = (ESS - BS)./alpha;

ExSS = SU*SS*SV';
EXS = uint8(ExSS);
imwrite(EXS,'ExSig.png');

%% Display
figure()
subplot(1,2,1);imshow(Expw);title('Ext processes watermark');
subplot(1,2,2);imshow(EXS);title('Extracted signature');

disp(psnr(Expw,biometric));
disp(psnr(EXS,signature));
disp(corr2(Expw,biometric));
disp(corr2(EXS,signature));
