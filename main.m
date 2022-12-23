%% Digital image watermarking
%  Digital Image Watermarking method based on hybrid RDWT-SVD-DWT-SVD Technique: 
%  Attacks, PSNR, SSIM, NC
%
%% Intilize
clc
clear
close all

%% Import image
cover_image=im2gray(imresize(imread('2.bmp'),[512 512]));
biometric = imresize(imread('104-8.png'),[256 256]);
signature = im2gray(imresize(imread('signature.jpg'),[128 128]));
disp(size(cover_image));
disp(size(biometric));
disp(size(signature));
%signature = imread('ruthvik1.jpg');


%% Plot cover image and watermark image
figure
subplot(1,3,1);
imshow(cover_image);
title('Cover image: 512 x 512');
xlabel('a');
subplot(1,3,2);
imshow(biometric);
title('Biometric: 256 x 256');
xlabel('b');
subplot(1,3,3);
imshow(signature);
title('signature: 128 x 128'); 
xlabel('c');
%% watermark embedding and extraction  alpha=0.1 all Attacks
method = 'DWT-DCT-SVD';          % Apply 'RDWT-SVD-DWT-SVD Method
alpha = 0.1;
beta = 0.05;

attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median';...
    'Gaussian noise'; 'Salt and pepper noise';'Speckle noise';...
    'JPEG compression'; 'JPEG2000 compression'; 'Sharpening attack';...
    'Histogram equalization'; 'Average filter'; 'Motion blur'};

% Attack papameters
params = [0; 3; 3; 0.001; 0.2; 0.002; 50; 12; 0.8; 0; 0; 0];
for j=1:length(attacks)
    
    attack = string(attacks(j));
    param = params(j);
    [Final_watermark, extpw, extsig] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);

    % Plot results
    figure;
    subplot(2, 3, 1);
    imshow(cover_image);
    xlabel('a) Cover image');
    subplot(2, 3, 2);
    imshow(biometric);
    xlabel('b) biometric watermark');
    subplot(2, 3, 3);
    imshow(signature);
    xlabel('c) signature');
    subplot(2, 3, 4);
    imshow(Final_watermark);
    xlabel('d) Final watermarked image');
    subplot(2, 3, 5);
    imshow(extpw);
    xlabel('e) Extracted Processed watermark');
    subplot(2, 3, 6);
    imshow(extsig);
    xlabel('f) Extracted signature');

    sgtitle(['DWT-DCT-SVD method \alpha = '+string(alpha) attack]);

end
%% NC vs alpha RDWT-SVD-DWT-SVD figure 5
%  Plot normalized correlation  for different alpha with biometric
method = 'RDWT-SVD-DWT-SVD';
alpha =0.005:0.005:0.2;
beta = 0.2;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median';...
    'Gaussian noise'; 'Salt and pepper noise';'Speckle noise';...
    'JPEG compression'; 'JPEG2000 compression'; 'Sharpening attack';...
    'Histogram equalization'; 'Average filter'; 'Motion blur'};

% Attack papameters
params = [0; 3; 3; 0.001; 0.2; 0.002; 50; 12; 0.8; 0; 0; 0];
NC = NC_alpha(cover_image,biometric,signature,method,alpha,beta,attacks,params);
%%  plot NC vs alpha figure 5
NC_plot(alpha,NC,attacks);

%% PSNR vs alpha RDWT-SVD-DWT-SVD
method = 'RDWT-SVD-DWT-SVD';
alpha =0.05:0.2:0.2;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
PSNR = PSNR_alpha(cover_image,biometric,signature,method,alpha,beta,attacks,params);

%% plot PSNR vs alpha
PSNR_plot(alpha,PSNR,attacks);

%% SSIM vs alpha RDWT-SVD-DWT-SVD figure 7 paper (see README)
method = 'RDWT-SVD-DWT-SVD';
alpha =0.005:0.005:0.2;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
SSIM = SSIM_alpha(cover_image,biometric,signature,method,alpha,beta,attacks,params);

%% plot SSIM vs alpha
SSIM_plot(alpha,SSIM,attacks);

%% FIGURE 8. Invisibility performance: Watermarked images and corresponding extracted
%  watermarks with various sizes and their corresponding PSNRs, SSIMs and NCs.

method = 'DWT-DCT-SVD';
alpha =0.05;
beta = 0.08;
attack = 'No Attack';
param = 0;

figure
for i=1:3
    biometrici = imresize(biometric,2^(-i+1));
    [Final_watermark, extpw] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
    extpw = imresize(extpw,2^(-i+1));
    PSNR = psnr(Final_watermark, cover_image);
    SSIM = ssim(Final_watermark, cover_image);
    NC1 = nc(Final_watermark, cover_image);
    NC = nc(biometrici,extpw);
    PSNR1 = psnr(biometrici,extpw);
    SSIM1 = ssim(biometrici,extpw);
    subplot(2,3,i);
    imshow(Final_watermark);
    title(['watermarked image';'watermark size '+string(length(biometrici))+'x'+string(length(biometrici))]);
    xlabel(['PSNR='+string(PSNR);'SSIM='+string(SSIM);'NC='+string(NC1)]);
    subplot(2,3,i+3);
    imshow(extpw);
    title('extracted watermark');
    xlabel(['NC='+string(NC);'PSNR='+string(PSNR1);'SSIM='+string(SSIM1)]);
end
sgtitle('RDWT-SVD-DWT-SVD: Invisibility performance: watermarks with various sizes; alpha='+string(alpha)+'; No Attack');

%% plot watermarked image for different attacks and watermark sizes

method = 'RDWT-SVD-DWT-SVD';
alpha =0.05;
beta = 0.08;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
for i=3:-1:1
biometrici = imresize(biometric,2^(1-i));
figure
for j=1:length(attacks)
    
    attack = string(attacks(j));
    param = params(j);
    [Final_watermark, extpw] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
    PSNR = psnr(Final_watermark, cover_image);
    SSIM = ssim(Final_watermark, cover_image);
    subplot(3,4,j);
    imshow(Final_watermark);
    xlabel(['PSNR='+string(PSNR);'SSIM='+string(SSIM)]);
    title(attack);
end
sgtitle(['RDWT-SVD-DWT-SVD: Attacked watermarked image; Size = '+string(length(biometrici))+'x'+string(length(biometrici))+'; \alpha = '+string(alpha)]);
end

%% FIGURE 10. Extracted watermarks from the attacked watermarked images
%  Evaluate robustness performance
method = 'RDWT-SVD-DWT-SVD';
alpha =0.05;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
for i=3:-1:1
biometrici = imresize(biometric,2^(1-i));
figure

for j=1:length(attacks)
        attack = string(attacks(j));
        param = params(j);
        [Final_watermark, extpw] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
        NC = nc(biometrici,extpw);
        subplot(3,4,j);
        imshow(extpw);
        xlabel([attack 'NC='+string(NC)]);
end
sgtitle(['RDWT-SVD-DWT-SVD: Extracted watermark images under different attacks; Size = '+string(length(biometrici))+'x'+string(length(biometrici))+'; \alpha = '+string(alpha)]);
end

%% FIGURE 11. NC values under different parameters suffering various attacks
biometric1 = biometric;
biometric2 = imresize(biometric,0.5);
biometric3 = imresize(biometric,0.25);
method = 'RDWT-SVD-DWT-SVD';
alpha =0.1;
beta = 0.2;
attacks = {'JPEG compression';'JPEG2000 compression';'Gaussian low-pass filter';...
           'Median';'Gaussian noise';'Sharpening attack'};
figure
for j = 1:length(attacks)
    attack = string(attacks(j));
    params = 0;
    switch attack
        case 'JPEG compression'
            params = 10:10:90;
            y = [0.98 1];
            x = [0 100];
            ticks = string(params);
            label = 'Quality Factor (QF)';
        case 'JPEG2000 compression'
            params = 4:4:36;
            y = [0.98 1];
            ticks = string(params);
            label = 'Compression Ratio (CR)';
        case 'Gaussian low-pass filter'
            params = 0.5:0.5:4.5;
             y = [0.9 1];
             ticks = string(params);
             label = 'sigma';
        case 'Median'
            params = 3:7;
            y = [0.86 1];
            ticks = {'3x3','4x4','5x5','6x6','7x7'};
            label = 'Window size';
        case 'Gaussian noise'
            params = 0.001:0.002:0.009;
            y = [0.88 1];
            ticks = string(params);
            label = 'Variance';
        case 'Sharpening attack'
            params = 0.1:0.1:0.9;
            y = [0.96 1];
            ticks = string(params);
            label = 'Strength (1-Threshold)';
    end
    NC1 = 0;
    NC2 = 0;
    NC3 = 0;
    for i = 1:length(params)
        [Final_watermark1, extpw1] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        [Final_watermark2, extpw2] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        [Final_watermark3, extpw3] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        NC1(i) = nc(biometric1,extpw1);
        NC2(i) = nc(biometric2,extpw2);
        NC3(i) = nc(biometric3,extpw3);
    end
    subplot(3,2,j)
    plot(params,NC1,'k<-');
    hold on
    plot(params,NC2,'rs-');
    hold on
    plot(params,NC3,'g^-');
    hold off
    grid on
    ylim(y);
    xticks(params);
    xticklabels(ticks);
    xlabel(label);
    ylabel('NC(W,W^*)');
    legend('256 x 256', '128 x 128', '64 x 64', 'Location', 'southwest');
    title(attacks(j));
end
sgtitle('RDWT-SVD-DWT-SVD: NC values under different parameters suffering various attacks.');



%% For signature subplots 


%% NC vs beta RDWT-SVD-DWT-SVD 
%  Plot normalized correlation  for different alpha with biometric
method = 'RDWT-SVD-DWT-SVD';
beta = 0.005:0.005:0.2;
alpha = 0.1;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median';...
    'Gaussian noise'; 'Salt and pepper noise';'Speckle noise';...
    'JPEG compression'; 'JPEG2000 compression'; 'Sharpening attack';...
    'Histogram equalization'; 'Average filter'; 'Motion blur'};

% Attack papameters
params = [0; 3; 3; 0.001; 0.2; 0.002; 50; 12; 0.8; 0; 0; 0];
NC = sigNC_beta(cover_image,biometric,signature,method,alpha,beta,attacks,params);
%%  plot NC vs alpha figure 5
NC_plot(beta,NC,attacks);

%% PSNR vs alpha RDWT-SVD-DWT-SVD
method = 'RDWT-SVD-DWT-SVD';
beta = 0.005:0.005:0.2;
alpha = 0.1;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
PSNR = PSNR_beta(cover_image,biometric,signature,method,alpha,beta,attacks,params);

%% plot PSNR vs alpha
PSNR_plot(beta,PSNR,attacks);

%% SSIM vs alpha RDWT-SVD-DWT-SVD figure 7 paper (see README)
method = 'RDWT-SVD-DWT-SVD';
beta = 0.005:0.005:0.2;
alpha = 0.1;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
SSIM = SSIM_beta(cover_image,biometric,signature,method,alpha,beta,attacks,params);

%% plot SSIM vs alpha
SSIM_plot(beta,SSIM,attacks);

%% FIGURE 8. Invisibility performance: Watermarked images and corresponding extracted
%  watermarks with various sizes and their corresponding PSNRs, SSIMs and NCs.

method = 'RDWT-SVD-DWT-SVD';
alpha =0.1;
beta = 0.2;
attack = 'No Attack';
param = 0;

figure
for i=1:3
    signaturei = imresize(signature,2^(-i+1));
    [Final_watermark, extpw, extsig] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
    PSNR = psnr(extpw,biometric);
    SSIM = ssim(extpw,biometric);
    NC = nc(signaturei,extsig);
    subplot(2,3,i);
    imshow(extpw);
    title(['Processed watermark';'watermark size '+string(length(signaturei))+'x'+string(length(signaturei))]);
    xlabel(['PSNR='+string(PSNR);'SSIM='+string(SSIM)]);
    subplot(2,3,i+3);
    imshow(extsig);
    title('extracted watermark');
    xlabel('NC='+string(NC));
end
sgtitle('RDWT-SVD-DWT-SVD: Invisibility performance: watermarks with various sizes; alpha='+string(alpha)+'; beta='+string(beta)+'; No Attack');

%% plot watermarked image for different attacks and watermark sizes

method = 'RDWT-SVD-DWT-SVD';
alpha =0.1;
beta = 0.2;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
for i=3:-1:1
signaturei = imresize(signature,2^(1-i));
figure
for j=1:length(attacks)
    
    attack = string(attacks(j));
    param = params(j);
    [Final_watermark, extpw, extsig] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
    PSNR = psnr(extsig,signature);
    disp(PSNR);
    SSIM = ssim(extsig,signature);
    subplot(3,4,j);
    imshow(extsig);
    xlabel(['PSNR='+string(PSNR);'SSIM='+string(SSIM)]);
    title(attack);
end
sgtitle(['RDWT-SVD-DWT-SVD: Attacked watermarked image; Size = '+string(length(signaturei))+'x'+string(length(signaturei))+'; \beta = '+string(beta)]);
end

%% FIGURE 10. Extracted watermarks from the attacked watermarked images
%  Evaluate robustness performance
method = 'RDWT-SVD-DWT-SVD';
alpha =0.1;
beta = 0.2;
attacks = {'No Attack'; 'Gaussian low-pass filter'; 'Median'; 'Gaussian noise';...
    'Salt and pepper noise';'Speckle noise'; 'JPEG compression';...
    'JPEG2000 compression'; 'Sharpening attack'; 'Histogram equalization';...
    'Average filter'; 'Motion blur'};
params = [0; 3; 3; 0.001; 0; 0; 50; 12; 0.8; 0; 0; 0];
for i=3:-1:1
signaturei = imresize(signature,2^(1-i));
figure

for j=1:length(attacks)
        attack = string(attacks(j));
        param = params(j);
        [Final_watermark, extpw, extsig] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,param);
        NC = nc(signaturei,extsig);
        subplot(3,4,j);
        imshow(extsig);
        xlabel([attack 'NC='+string(NC)]);
end
sgtitle(['RDWT-SVD-DWT-SVD: Extracted signature under different attacks; Size = '+string(length(signaturei))+'x'+string(length(signaturei))+'; \alpha = '+string(alpha)+'; \beta = '+string(beta)]);
end

%% FIGURE 11. NC values under different parameters suffering various attacks
signature1 = signature;
signature2 = imresize(signature,0.5);
signature3 = imresize(signature,0.25);
method = 'RDWT-SVD-DWT-SVD';
alpha =0.1;
beta = 0.2;
attacks = {'JPEG compression';'JPEG2000 compression';'Gaussian low-pass filter';...
           'Median';'Gaussian noise';'Sharpening attack'};
figure
for j = 1:length(attacks)
    attack = string(attacks(j));
    params = 0;
    switch attack
        case 'JPEG compression'
            params = 10:10:90;
            y = [0.98 1];
            x = [0 100];
            ticks = string(params);
            label = 'Quality Factor (QF)';
        case 'JPEG2000 compression'
            params = 4:4:36;
            y = [0.98 1];
            ticks = string(params);
            label = 'Compression Ratio (CR)';
        case 'Gaussian low-pass filter'
            params = 0.5:0.5:4.5;
             y = [0.9 1];
             ticks = string(params);
             label = 'sigma';
        case 'Median'
            params = 3:7;
            y = [0.86 1];
            ticks = {'3x3','4x4','5x5','6x6','7x7'};
            label = 'Window size';
        case 'Gaussian noise'
            params = 0.001:0.002:0.009;
            y = [0.88 1];
            ticks = string(params);
            label = 'Variance';
        case 'Sharpening attack'
            params = 0.1:0.1:0.9;
            y = [0.96 1];
            ticks = string(params);
            label = 'Strength (1-Threshold)';
    end
    NC1 = 0;
    NC2 = 0;
    NC3 = 0;
    for i = 1:length(params)
        [Final_watermark1, extpw1, extsig1] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        [Final_watermark2, extpw2, extsig2] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        [Final_watermark3, extpw3, extsig3] = watermark(cover_image,biometric,signature,method,alpha,beta,attack,params(i));
        NC1(i) = nc(signature1,extsig1);
        NC2(i) = nc(signature2,extsig2);
        NC3(i) = nc(signature3,extsig3);
    end
    subplot(3,2,j)
    plot(params,NC1,'k<-');
    hold on
    plot(params,NC2,'rs-');
    hold on
    plot(params,NC3,'g^-');
    hold off
    grid on
    ylim(y);
    xticks(params);
    xticklabels(ticks);
    xlabel(label);
    ylabel('NC(W,W^*)');
    legend('256 x 256', '128 x 128', '64 x 64', 'Location', 'southwest');
    title(attacks(j));
end
sgtitle('RDWT-SVD-DWT-SVD: NC values under different parameters suffering various attacks.');