%% ps5 
clear all; clc;

% first, make sure your current directory is where this script is
% then add to path all functions essential to this project
addpath(genpath('../utilities'));  


%% 1 Lucas Kanade optical flow
% read images
clc;
Shift0 = double(imread('input/TestSeq/Shift0.png'))/255;
ShiftR2 = double(imread('input/TestSeq/ShiftR2.png'))/255;
ShiftR10 = double(imread('input/TestSeq/ShiftR10.png'))/255;
ShiftR20 = double(imread('input/TestSeq/ShiftR20.png'))/255;
ShiftR40 = double(imread('input/TestSeq/ShiftR40.png'))/255;
ShiftR5U5 = double(imread('input/TestSeq/ShiftR5U5.png'))/255;


%% 1a compare base-ShiftR2 and base-Shift2U5


h1 = fspecial('gauss', 25, 9);
[U_R2, V_R2] = get_LK_optical_flow(Shift0,ShiftR2,h1);
[U_R5U5, V_R5U5] = get_LK_optical_flow(Shift0,ShiftR5U5,h1);

ccc = gcf;
delete(ccc.Children);

figure(1);
vl_tightsubplot(2,3,1);
imshow(Shift0)
vl_tightsubplot(2,3,2);
imshow(ShiftR2)
vl_tightsubplot(2,3,3);
imshow(ShiftR5U5)

vl_tightsubplot(2,3,4);
imshow(normalise_img(U_R2))
vl_tightsubplot(2,3,5);
imshow(normalise_img(V_R2))

ccc = gcf;
delete(ccc.Children);
plot_optical_flow_displacement(2,U_R2,V_R2)
% print(gcf, '-dpng', './output/ps5-1-a-1.png')

ccc = gcf;
delete(ccc.Children);
H = plot_optical_flow_displacement(2,U_R5U5,V_R5U5);
% print(gcf, '-dpng', './output/ps5-1-a-2.png')


%% 1b compare 


[U_R10, V_R10] = get_LK_optical_flow(Shift0,ShiftR10,h1);

ccc = gcf;
delete(ccc.Children);
plot_optical_flow_displacement(2,U_R10,V_R10)
% print(gcf, '-dpng', './output/ps5-1-b-1.png')


[U_R20, V_R20] = get_LK_optical_flow(Shift0,ShiftR20,h1);

ccc = gcf;
delete(ccc.Children);
plot_optical_flow_displacement(2,U_R20,V_R20)
% print(gcf, '-dpng', './output/ps5-1-b-2.png')


[U_R40, V_R40] = get_LK_optical_flow(Shift0,ShiftR40,h1);
ccc = gcf;
delete(ccc.Children);
plot_optical_flow_displacement(2,U_R40,V_R40)
% print(gcf, '-dpng', './output/ps5-1-b-3.png')


%% 2 setup

clc
yos_1 = double(imread('input/DataSeq1/yos_img_01.jpg'))/255;
yos_2 = double(imread('input/DataSeq1/yos_img_02.jpg'))/255;
yos_3 = double(imread('input/DataSeq1/yos_img_03.jpg'))/255;

% need to be resized for the pyramid purpose:

yos_1 = yos_1(6:end-6,6:end-6);
yos_2 = yos_2(6:end-6,6:end-6);
yos_3 = yos_3(6:end-6,6:end-6);

%% 2-a REDUCE operator

ccc = gcf;
delete(ccc.Children);
figure(3);
vl_tightsubplot(1,3,1);
imshow(yos_1)
vl_tightsubplot(1,3,2);
imshow(yos_2)
vl_tightsubplot(1,3,3);
imshow(yos_3)

% although it is called "Gaussian pyramid", the kernel introduced by Burt
% and Adelson is actually not a Gaussian function. 

a = 0.4;
w = kernel_for_pyramid(a);

[g0,g1,g2,g3] = REDUCE_4_levels(yos_1,w);

ccc = gcf;
delete(ccc.Children);
figure(4);

vl_tightsubplot(1,4,1);
imshow(g0)
vl_tightsubplot(1,4,2);
imshow(g1)
vl_tightsubplot(1,4,3);
imshow(g2)
vl_tightsubplot(1,4,4);
imshow(g3)

% print(gcf, '-dpng', './output/ps5-2-a-1.png')

%% 2b  EXPAND operator

g3_1 = EXPAND_1_level(g3,w);
L2 = g2 - g3_1;
g2_1 = EXPAND_1_level(g2,w);
L1 = g1 - g2_1;
g1_1 = EXPAND_1_level(g1,w);
L0 = g0 - g1_1;

ccc = gcf;
delete(ccc.Children);
figure(4);

vl_tightsubplot(1,4,1);
imshow(g3)
vl_tightsubplot(1,4,2);
imshow(L2)
vl_tightsubplot(1,4,3);
imshow(L1)
vl_tightsubplot(1,4,4);
imshow(L0)

% print(gcf, '-dpng', './output/ps5-2-b-1.png')


%% 3a try and find a good level for LK flow purposes
% first, the Yosemite sequence LK optical flow result

a = 0.4;
w = kernel_for_pyramid(a);

[yos_1_g0, yos_1_g1, yos_1_g2, yos_1_g3] = REDUCE_4_levels(yos_1,w);
[yos_2_g0, yos_2_g1, yos_2_g2, yos_2_g3] = REDUCE_4_levels(yos_2,w);
[yos_3_g0, yos_3_g1, yos_3_g2, yos_3_g3] = REDUCE_4_levels(yos_3,w);

% it turns out that the Gaussian level 0 and level 1 are both acceptable,
% but level 1 has slightly less noise.
im1 = yos_1_g1;
im2 = yos_2_g1;
im3 = yos_3_g1;

h3 = fspecial('gauss', 25,3);
[U12, V12] = get_LK_optical_flow(im1,im2,h3);
[U23, V23] = get_LK_optical_flow(im2,im3,h3);

ccc = gcf;
delete(ccc.Children);
figure(5)
plot_double_optical_flow_displacement(5,U12,V12,U23,V23)

% print(gcf, '-dpng', './output/ps5-3-a-1.png')

%% Yosemite sequence warping result

[x_grid,y_grid] = meshgrid(1:size(im1,2),1:size(im1,1));
im2_warped = interp2(x_grid,y_grid,im2,x_grid+U12,y_grid+V12,'*linear');
im2_warped(isnan(im2_warped)) = 0;
seq12_disp = zeros([size(im1) 3]);
seq12_disp(:,:,1) = im2_warped  ;
seq12_disp(:,:,3) = im1;
RMSE12 = mean(mean((im2_warped - im1).^2)).^0.5;

figure(6)
ccc = gcf; delete(ccc.Children);
vl_tightsubplot(1,2,1);
imshow(seq12_disp)
title(sprintf('Img 1 -> Img 2 based on Gaussian level 1; RMSE = %.05f',RMSE12 ))

im3_warped = interp2(x_grid,y_grid,im3,x_grid+U23,y_grid+V23,'*linear');
im3_warped(isnan(im3_warped)) = 0;
seq23_disp = zeros([size(im2) 3]);
seq23_disp(:,:,1) = im3_warped  ;
seq23_disp(:,:,3) = im2;
RMSE23 = mean(mean((im3_warped - im2).^2)).^0.5;

vl_tightsubplot(1,2,2);
imshow(seq23_disp)
title(sprintf('Img 2 -> Img 3 based on Gaussian level 1; RMSE = %.05f',RMSE23 ))

% print(gcf, '-dpng', './output/ps5-3-a-2.png')


%% girl-and-dog image set up

clc;

gd0 = double(imread('input/DataSeq2/0.png'))/255;
gd1 = double(imread('input/DataSeq2/1.png'))/255;
gd2 = double(imread('input/DataSeq2/2.png'))/255;

% convert to grayscale
gd0 = mean(gd0,3);
gd1 = mean(gd1,3);
gd2 = mean(gd2,3);

% append image to make its size fit the paradigm; 
gd0 = append_1r1c(gd0);
gd1 = append_1r1c(gd1);
gd2 = append_1r1c(gd2);

ccc = gcf;
delete(ccc.Children);
figure(7)
vl_tightsubplot(1,3,1);
imshow(gd0)
vl_tightsubplot(1,3,2);
imshow(gd1)
vl_tightsubplot(1,3,3);
imshow(gd2)


%% girl-and-dog sequence LK optical flow results

a = 0.4;
w = kernel_for_pyramid(a);

[gd0_g0, gd0_g1, gd0_g2, gd0_g3, gd0_g4] = REDUCE_5_levels(gd0,w);
[gd1_g0, gd1_g1, gd1_g2, gd1_g3, gd1_g4] = REDUCE_5_levels(gd1,w);
[gd2_g0, gd2_g1, gd2_g2, gd2_g3, gd2_g4] = REDUCE_5_levels(gd2,w);

% Gauss level 2 is found to be the best granuality for this sequence

im0 = gd0_g2;
im1 = gd1_g2;
im2 = gd2_g2;


h3 = fspecial('gauss', 25,3);
[U01, V01] = get_LK_optical_flow(im0,im1,h3);
[U12, V12] = get_LK_optical_flow(im1,im2,h3);


ccc = gcf;
delete(ccc.Children);
figure(8)
plot_double_optical_flow_displacement(8,U01,V01,U12,V12)
% print(gcf, '-dpng', './output/ps5-3-a-3.png')

%% girl-and-dog sequence warping results

[x_grid,y_grid] = meshgrid(1:size(im1,2),1:size(im1,1));

figure(9)
ccc = gcf;
delete(ccc.Children);

im1_warped = interp2(x_grid,y_grid,im1,x_grid+U01,y_grid+V01,'*linear');
im1_warped(isnan(im1_warped)) = 0;
seq01_disp = zeros([size(im1) 3]);
seq01_disp(:,:,1) = im1_warped  ;
seq01_disp(:,:,3) = im0;
RMSE01 = mean(mean((im1_warped - im0).^2)).^0.5;
vl_tightsubplot(1,2,1);
imshow(seq01_disp)
title(sprintf('Img 0 -> Img 1 based on Gaussian level 2; RMSE = %.05f',RMSE01 ))


im2_warped = interp2(x_grid,y_grid,im2,x_grid+U12,y_grid+V12,'*linear');
im2_warped(isnan(im2_warped)) = 0;
seq12_disp = zeros([size(im1) 3]);
seq12_disp(:,:,1) = im2_warped  ;
seq12_disp(:,:,3) = im1;
RMSE12 = mean(mean((im2_warped - im1).^2)).^0.5;
vl_tightsubplot(1,2,2);
imshow(seq12_disp)
title(sprintf('Img 1 -> Img 2 based on Gaussian level 2; RMSE = %.05f',RMSE12 ))
% print(gcf, '-dpng', './output/ps5-3-a-4.png')

% The dog's tail's motion is different from other parts of the image; so is
% the girl's right foot
%
% A sensible solution the iterative approach.



%% 4a Hierarchical LK optical flow for TestSeq

a = 0.4;
w = kernel_for_pyramid(a);
h4 = fspecial('gauss', 25,3);

[U_R10, V_R10] = run_hierarchical_LK(append_1r1c(Shift0),append_1r1c(ShiftR10),w,h4,3);
[U_R20, V_R20] = run_hierarchical_LK(append_1r1c(Shift0),append_1r1c(ShiftR20),w,h4,5);
[U_R40, V_R40] = run_hierarchical_LK(append_1r1c(Shift0),append_1r1c(ShiftR40),w,h4,5);

UUU = {U_R10,U_R20,U_R40};
[total_min, total_max] = get_UV_min_max(UUU);

figure(10)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(1,3,1,'Margin',0.02,'MarginTop',0.06);
imagesc(U_R10)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Shift0 vs ShiftR10 U map');

vl_tightsubplot(1,3,2,'Margin',0.02,'MarginTop',0.06);
imagesc(U_R20)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Shift0 vs ShiftR20 U map');

vl_tightsubplot(1,3,3,'Margin',0.02,'MarginTop',0.06);
imagesc(U_R40)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Shift0 vs ShiftR40 U map');

% print(gcf, '-dpng', './output/ps5-4-a-1.png')


%% save diff images of TestSeq
% R40 probably needs another level of Gaussian
% image size is too awkward so I didn't do it...

diff_R10 = gen_warped_RGB(append_1r1c(Shift0),append_1r1c(ShiftR10),U_R10,V_R10);
diff_R20 = gen_warped_RGB(append_1r1c(Shift0),append_1r1c(ShiftR20),U_R20,V_R20);
diff_R40 = gen_warped_RGB(append_1r1c(Shift0),append_1r1c(ShiftR40),U_R40,V_R40);

figure(11)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(1,3,1);
imshow(diff_R10)
vl_tightsubplot(1,3,2);
imshow(diff_R20)
vl_tightsubplot(1,3,3);
imshow(diff_R40)

% print(gcf, '-dpng', './output/ps5-4-a-2.png')


%% Hierarchical LK optical flow for Yosemite

yos_1 = double(imread('input/DataSeq1/yos_img_01.jpg'))/255;
yos_2 = double(imread('input/DataSeq1/yos_img_02.jpg'))/255;
yos_3 = double(imread('input/DataSeq1/yos_img_03.jpg'))/255;

% need to be resized for the pyramid purpose:

yos_1 = yos_1(6:end-6,6:end-6);
yos_2 = yos_2(6:end-6,6:end-6);
yos_3 = yos_3(6:end-6,6:end-6);

a = 0.4;
w = kernel_for_pyramid(a);
h4 = fspecial('gauss', 25,3);

% this sequence does not have a large displacement

[U_12, V_12] = run_hierarchical_LK(yos_1,yos_2,w,h4,2);
[U_23, V_23] = run_hierarchical_LK(yos_2,yos_3,w,h4,2);
[U_13, V_13] = run_hierarchical_LK(yos_1,yos_3,w,h4,3);


% some pixel's U, V blow up, so manually choose a range
total_min = -10;
total_max = 5;

figure(12)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(2,3,1,'Margin',0.02,'MarginTop',0.06);
imagesc(U_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos1 vs Yos2 U map');

vl_tightsubplot(2,3,2,'Margin',0.02,'MarginTop',0.06);
imagesc(U_23)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos2 vs Yos3 U map');

vl_tightsubplot(2,3,3,'Margin',0.02,'MarginTop',0.06);
imagesc(U_13)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos1 vs Yos3 U map');

vl_tightsubplot(2,3,4,'Margin',0.02,'MarginTop',0.06);
imagesc(V_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos1 vs Yos2 V map');

vl_tightsubplot(2,3,5,'Margin',0.02,'MarginTop',0.06);
imagesc(V_23)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos2 vs Yos3 V map');

vl_tightsubplot(2,3,6,'Margin',0.02,'MarginTop',0.06);
imagesc(V_13)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Yos1 vs Yos3 V map');


% print(gcf, '-dpng', './output/ps5-4-b-1.png')

%% save diff images of Yosemite

% Looking good!

diff_12 = gen_warped_RGB(yos_1,yos_2,U_12,V_12);
diff_23 = gen_warped_RGB(yos_2,yos_3,U_23,V_23);
diff_13 = gen_warped_RGB(yos_1,yos_3,U_13,V_13);
figure(13)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(1,3,1);
imshow(diff_12)
vl_tightsubplot(1,3,2);
imshow(diff_23)
vl_tightsubplot(1,3,3);
imshow(diff_13)

% print(gcf, '-dpng', './output/ps5-4-b-2.png')


%% Hierarchical LK optical flow for the girl-and-dog sequence

clc;

gd0 = double(imread('input/DataSeq2/0.png'))/255;
gd1 = double(imread('input/DataSeq2/1.png'))/255;
gd2 = double(imread('input/DataSeq2/2.png'))/255;

% convert to grayscale
gd0 = mean(gd0,3);
gd1 = mean(gd1,3);
gd2 = mean(gd2,3);

% append image to make its size fit the paradigm; 
gd0 = append_1r1c(gd0);
gd1 = append_1r1c(gd1);
gd2 = append_1r1c(gd2);

a = 0.4;
w = kernel_for_pyramid(a);
h4 = fspecial('gauss', 25,3);

[U_01, V_01] = run_hierarchical_LK(gd0,gd1,w,h4,5);
[U_12, V_12] = run_hierarchical_LK(gd1,gd2,w,h4,5);

% UUVV = {U_01, V_01,U_12, V_12};
% [total_min, total_max] = get_UV_min_max(UUVV);
% manually setting the c_range for better visualisation
total_min = -20;
total_max = 40;

% the motion on girl's left foot is kind of captured

figure(14)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(2,2,1,'Margin',0.03,'MarginTop',0.06);
imagesc(U_01)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('girl-and-dog-00 vs girl-and-dog-01 U map');

vl_tightsubplot(2,2,2,'Margin',0.03,'MarginTop',0.06);
imagesc(U_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('girl-and-dog-01 vs girl-and-dog-02 U map');

vl_tightsubplot(2,2,3,'Margin',0.03,'MarginTop',0.06);
imagesc(V_01)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('girl-and-dog-00 vs girl-and-dog-01 V map');

vl_tightsubplot(2,2,4,'Margin',0.03,'MarginTop',0.06);
imagesc(V_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('girl-and-dog-01 vs girl-and-dog-02 V map');

% print(gcf, '-dpng', './output/ps5-4-c-1.png')

%% save diff images of girl-and-dog sequence

% Look alright. Dog's tail is still too fuzzy

diff_01 = gen_warped_RGB(gd0,gd1,U_01,V_01);
diff_12 = gen_warped_RGB(gd1,gd2,U_12,V_12);

figure(13)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(1,2,1);
imshow(diff_01)
vl_tightsubplot(1,2,2);
imshow(diff_12)

% print(gcf, '-dpng', './output/ps5-4-c-2.png')


%% part 5a  the juggle sequence


clc;

jg0 = double(imread('input/Juggle/0.png'))/255;
jg1 = double(imread('input/Juggle/1.png'))/255;
jg2 = double(imread('input/Juggle/2.png'))/255;

% convert to grayscale
jg0 = mean(jg0,3);
jg1 = mean(jg1,3);
jg2 = mean(jg2,3);

% append image to make its size fit the paradigm; 
jg0 = append_1r1c(jg0);
jg1 = append_1r1c(jg1);
jg2 = append_1r1c(jg2);

% in order to make 6+ levels pyramid, let's  upsize the original image
% further
jg0(end+32,:) = jg0(end,:);
jg1(end+32,:) = jg1(end,:);
jg2(end+32,:) = jg2(end,:);

%%

% this "a" value seems not very important(equal contribution constraint)
a = 0.4;
w = kernel_for_pyramid(a);

% what is the best filter for M matrix? not sure
h5 = fspecial('gauss', 25,3);

% I've jacked this up to 7 levels! But it still isn't great
[U_01, V_01] = run_hierarchical_LK(jg0,jg1,w,h5,7);
[U_12, V_12] = run_hierarchical_LK(jg1,jg2,w,h5,7);


%%
% UUVV = {U_01, V_01,U_12, V_12};
% [total_min, total_max] = get_UV_min_max(UUVV);
% manually setting the c_range for better visualisation
total_min = -50;
total_max = 50;


figure(15)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(2,2,1,'Margin',0.03,'MarginTop',0.06);
imagesc(U_01)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Juggle0 vs Juggle1 U map');

vl_tightsubplot(2,2,2,'Margin',0.03,'MarginTop',0.06);
imagesc(U_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Juggle1 vs Juggle2 U map');

vl_tightsubplot(2,2,3,'Margin',0.03,'MarginTop',0.06);
imagesc(V_01)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Juggle0 vs Juggle1 V map');

vl_tightsubplot(2,2,4,'Margin',0.03,'MarginTop',0.06);
imagesc(V_12)
caxis manual; caxis([total_min total_max]);colorbar('SouthOutside');
colormap(gca,jet(100))
title('Juggle1 vs Juggle2 V map');


% print(gcf, '-dpng', './output/ps5-4-d-1.png')

%%  I think the performance is limited due to the background.

diff_01 = gen_warped_RGB(jg0,jg1,U_01,V_01);
diff_12 = gen_warped_RGB(jg1,jg2,U_12,V_12);

figure(13)
ccc = gcf;
delete(ccc.Children);

vl_tightsubplot(1,2,1);
imshow(diff_01)
vl_tightsubplot(1,2,2);
imshow(diff_12)

% print(gcf, '-dpng', './output/ps5-4-d-2.png')


