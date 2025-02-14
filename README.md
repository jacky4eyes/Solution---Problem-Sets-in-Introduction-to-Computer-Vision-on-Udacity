# Overview

<mark>**All completed!**</mark>

The code is in MATLAB. Problem set source files included. (template scripts and input images.)

Remember to enable the parallel computing toolbox for the parallel for loops etc. You may need to download and install the package if your MATLAB distribution does not come with it.

Below  are the comments and highlights for some PS's. It probably is too lengthy.. 

(More technical details are in the comments in the codes. But more of them are in my study notes. Use this a quick brush-up and reminder of what this course is about.)



# PS1

Nothing important to say..




# PS2 

### Ground-true disparity data

Very helpful training set, such as `./ps2_matlab/input/pair1-L.png` vs `./ps2_matlab/input/pair1-D_L.png`.

### Disparity with SSE (sum of squared errors) method 

1. Matching original image pairs using different window sizes (20 vs. 10)
	- It is clear that with larger window size, the results become "smoother", which is good for indicating main object groups. However, the edges look more distorted and some fine/small objects are missing.
	- By contrast, a small window size will capture many more small objects. It also defines edges more clearly. However, it introduces more "noises".
2. Matching image pairs after adding moderate Gaussian noises ($\sigma = 0.1$)
	- The impact is heavier on smaller window size.
3. Matching image pairs with brightness misalignment ($I_L\times1.1$)
	- Performance decreases, i.e. the mismatch of the overall intensity between the images has significant negative impact on matching results. Both big and small window sizes are largely affected.
	- The implication is that you probably want to adjust the brightness of the images beforehand, so that they match.

### Disparity with NCC (normalized cross-correlation) method

1. Runtime increased. From my experience at work (using Python), this is largely due to the normalisation process with moving  windows.
2.  Matching original images (window size 20 vs. 10)
	- Generally improvement over the SSE method. 
	- For small window size, noticeable improvement. Much less noises, greater smoothness in the inner area of large objects.
	- For big window size, subtle improvement.
3. Matching image pairs after adding moderate Gaussian noises ($\sigma = 0.1$)
	- The results show very low usability.
	- With big window size, some objects can be vaguely identified, while with small window size, matching fails completely.
4. Matching image pairs with brightness misalignment ($I_L\times1.1$)
	- Under this condition, the results are superior than those obtained via SSE.
	- Both big and small window sizes are satisfactory.

### Potentiality of adaptive window size

For SSE method, the disparity results are highly dependent on the actual scene. For a scene that contains both large low-contrast objects and clear-cut small objects, the best window sizes are different. Big objects needs big windows, and likewise for small objects.

Perhaps running a prior round with big kernel to establish a contrast profile in the images would be helpful. Of course, since the regions of the same object are different in the two images, some smoothing is necessary.

The NCC method inherently handles such situation with better tolerance. <mark>Therefore, for less noisy images, a small-window NCC arguably serves better as the default method.</mark>





# PS3

### Projective matrix via DLT (Direct Linear Transformation)

To solve the M matrix, the easiest way is using SVD, i.e. $A = UDV^T$. 

The solution will be the 12th column of the V matrix, which corresponds to the least non-zero singular value of A.

Using this method, you generally prefer more data points than less, but to a moderate extent. With more than 16 points the numerical result already tends to have very low uncertainly and low square error.

### Fundamental matrix

1. Remember there are two SVD to perform. To check your sanity, remember the final result should be the estimated fundamental matrix, usually denoted as $\hat{F}$, which should have rank 2. However, the result from the first SVD should have a F of rank 3.
2. To draw the epipolar lines on images, here is a trick based on the point-line duality:
  1. If we have the two end points of a line, we can easily draw it. 
  2. Intuitively, finding two end points from the leftmost and the rightmost, which are the intersects between the epipolar line and the edge lines of the frame.
  3. These two intersects can be computed via cross product, e.g. $p_1 = L_{left}\times L_{epipolar}$, where $L_{left}$ is just (1,0,0). Similarly, $L_{right}$ would be (1,0,width).
  4. Obtain $p_1$ and $p_2$ and then draw the line at ease.
3. What is slightly confusing is the different equations for epipolar lines. In the $p^TFp'=0$ relationship, the two lines are $L^T= p^TF$ and $L=Fp'$ respectively.
4. Normalising the pixel location values beforehand brings about significant improvement. But remember to handle it with a normalisation matrix, not some random dividing and subtraction constants...





# PS4

### Harris Corner

##### Overall procedure: #####

1. Compute Gaussian derivative at each pixel
2. Compute second moment matrix (M matrix) with a customised Gaussian Window
3. Compute the R value; threshold it for corner points (my approach is a 0.995 quantile value)
4. Apply non-local-minima filter (9x9 window etc.)

##### Strengths: #####

- Rotation invariant
- A commonly perceived problem is the scale variability. But it isn't as serious as I expect. So the scale invariant methods aren't always necessary, e.g. Harris-Laplacian method.
- However, if you are going to use SIFT descriptor later, you will need to manually specify the scale as a parameter.

##### Some corner points that a generic approach won't pick up

- low contrast region, such as white roof-top with greyish sky as background
- fine details, such as legs of chairs in a far distance.

### SIFT descriptor

Using the ```VLFeat``` library for SIFT descriptor to avoid fiddly work.

Two main functions are used here:

1. ```vl_sift```, which takes the interest points' locations and the gradient directions as inputs, and it returns 2 variables, ```f``` and ```d```.
   - ```f``` is known as "a frame", whose elements are x, y coordinates, scale and orientation.
   - Each column of ```d``` is a 128-vector for that point.
2. ```vl_ubcmatch```, which performs the matching algorithm.
   - Inputs are the descriptors from both images.
   - Output is the match array ```matches```.

Call help function for more detailed explanations.

### RANSAC

##### Translation images pair:

- The unknown parameter ```p``` is a 2-vector.
- Easier way is just treat each image pair's translation as (x_i, y_i), and fit a line on it.
- In the matches obtained by ``vl_ubcmatch``, a scatter plot may show multiple clusters, which is result of having different translations in different regions of the image (e.g. two separate objects). In this case, when you run RANSAC, the results tend to diverge.
- Be patient with the data structure. I advise this:
  - Treat the consensus set C as an array of indices of the match array, namely ```matches```.
  - The match array should contain the indices of the feature array , namely ```f```.
- When the (local) scene really is translation, this method is very stable. 

##### Similarity images pair: #####

- The unknown parameter ```p``` is a 4-vector.
- Use 2 pairs of images to explicitly solve ```p```, and then use ```p``` the transform the points from image A (i.e. ```X``` to ```X_prime```) , and then compare their distances against the predefined distance cutoff. Count the number falling within the cutoff and form a consensus set ```C_i```. As the last step, keep the largest ```C_i```.
- My choice for the cutoff is 9.
- It is worthwhile to start with more interest points. (500+?)

##### Affine for the similarity pair #####

- The unknown parameter ```p``` is a 6-vector.
- Compared with the previous approach, this one is almost surely giving you more accurate results, but it may require more interests points in order to be more stable. 
- To handle noise better, increase to distance cut-off level.

##### Image warping #####

- Helpful for sanity check.
- Will contain quite a few high frequency noises.
- My experience is that affine performs slightly better in the building facet, but not by much.
- Easiest way is this:
  1. Create blank image the same size as A
  2. For each row i and column j, apply transform (similarity/affine matrix etc.) and get the index supposed to be on image B. Sample that.
  3. Now that you have a B-warped, take advantage of the colour channels and make overlay image for visualisation.

##### Some further comments #####

- When checking the RANSAC results, you may realise that the previous parameters used in running Harris detector or SIFT descriptor have to be improved. So prepare for <mark>some iterative work</mark>, and make your code's instructions clean and clear.





# PS5

### Basic Lucas-Kanade

##### <mark> window size and Gaussian sigma </mark>

- For the pre-gradient filter, a 15x15 Gaussian kernel with sigma=1 is good. But It doesn't matter too much.
- There is a window function in the M matrix summation step as well. (mentioned Harris detector chapter). Ideally, you should do some trial and error. Nonetheless, I found that larger and heavier filters tend to be more consistent.  As a simple first attempt, go for 25x25 Gaussian kernel with sigma=3.

##### Applicable scenarios

- It works fine if the displacement is just 1~2 pixels.

- If the displacement is more than 2 pixels, then this method cannot work. Blurring heavily can help find smoother optical flow fields, but the displacement magnitude will be significantly skewed. 

- By heavy, I mean sigma = 9. It feels quite excessive. But without it, the motion vector result is so noisy.

- To solve this, hierarchical approach is needed.


### Gaussian and Laplacian Pyramids implementation

##### REDUCE operator

- Apply smoothing kernel and then take every other pixels' value.
- The kernel can be different from Gaussian function (don't know why Burt and Adelson used the term Gaussian) .

##### EXPAND operator

- Create an empty array double the size of the current level, and then sample the values from this layer when appropriate.
- Read the paper or my note to brush exactly how this works.

##### Size of the original image

- if you decide you want to create a four-level pyramid, then check whether all these are integers:
  - n_1 = (n_0+1)/2
  - n_2 = (n_1+1)/2
  - n_3 = (n_2+1)/2
  - n_4 = (n_3+1)/2

### Image warping

##### What do we do after obtaining the velocity?

- Say we have im1 and im2, and we have finished the LK optical flow computation. Now we have ```[u12, v12]```.

- Warp it via ```interp2``` function is the easiest way in MATLAB.

  ```matlab
  [x_grid,y_grid] = meshgrid(1:size(im1,2),1:size(im1,1));
  im2_warped = interp2(x_grid,y_grid,im2,x_grid+U12,y_grid+V12,'*linear');
  im2_warped(isnan(im2_warped)) = 0;
  ```

- The 4th and 5th argument to the function ```interp2``` are the so-called query grid.  Basically, we request the values from this location: the old grid plus the displacement. 

- Later, we compare this pixel value with the corresponding value in im1 based on the old grid.

##### Measuring warping quality (or velocity accuracy)

- I think a simple RMSE over the whole image area will do.

### Hierarchical Lucas-Kanade

##### general comments

- Excessive levels of  Gaussian downsampling are unfavourable.
- Recommended number of levels: for displacement x, use N = log_2(x). 
- From later chapters, it is learned that translation models usually aren't very good for large displacements

##### problem set related

- The size of the images in TestSeq is too awkward to perform 6-level pyramid...
- My Yosemite sequence motion looks pretty good! (judging by the warping result)
- The girl-and-dog sequence also looks alright.
- The juggle sequence is very difficult. I've tried 7-level pyramid, and all sorts of weights in the window. No significant improvement. Could come back in the future.

# PS6

### Particle filter

There are a couple of issues worth mentioning.

##### 1. Similarity (likelihood function) parameter

Commonly expressed as the sigma in a Gaussian PDF, I think we could perhaps regard it as the sensor noise. Importantly, whenever using a small patch size and the image is not very noisy, the sigma value should be kept low because:

1. High reward for the correct matches. This will dramatically increase the speed your tracker in terms of following the objects fast movement, as well as recovery after occlusion.
2. Also the precision is better, e.g. face contour is as close to the original as possible.

##### 2. Full-colour tracking vs. grayscale tracking

In certain regions, comparing 3 channels does feel more informative than comparing the luminance only.

How you combine the three likelihood function for RGB is quite flexible. I have tried a few options and found this is acceptable:

```matlab
abs_error = abs(template-patch);
mse_RGB = zeros([3 1]);
mse_RGB(1) = mean(mean(abs_error(:,:,1)));
mse_RGB(2) = mean(mean(abs_error(:,:,2)));
mse_RGB(3) = mean(mean(abs_error(:,:,3)));
likelihood_RGB = exp(-mse_RGB./(2.*sigma_MSE.^2));
likelihood = norm(likelihood_RGB, 2)/3;      % how I combine them for now
```

##### 3. Weighted sampling

MATLAB ```randsample``` provides this functionalities directly. 

- ```y = randsample(n,k,true,w)``` uses a vector of non-negative weights, `w`, whose length is `n`, to determine the probability that an integer `i` is selected as an entry for `y`.
- If you want to perform faster re-sampling, check my OneNote -> fixed-shape pointer on Roulette 

##### 4. Window size 

1. Larger size tend to take longer to locate the object; but once it is on track, it is way more robust (less "jittery"). But this also means when the particles are cramped at a wrong location, they tend to get stuck there.
2. Smaller window size will improve runtime because of the SSE-based similarity function etc. This effect is not very significant. Therefore, <mark>for quickly-moving objects, a moderately small window is better</mark>, in order to keep up with the object's speed.

##### 5. Number of particles

If runtime is of concern, this obviously would have to be small. In general, trackers with more particles tends to be more robust and "smooth". Around 1000 particles will be considered not small for 2-state models.

Meanwhile, if you must run the algorithm with very few particles, consider increase sensor noises - otherwise it is easy to lose track of the object for too long. But be careful, overdoing so will lead to a shipwreck.

##### 6. Dynamic uncertainty

This is a way of introducing new locations for your particles along during tracking. Basically a Gaussian noise over the states at the end of each iteration (i.e. come into effect when reading a new frame).

##### 7. Window size  as a state variable

This is necessary for an object moving away from the camera or approaching it, namely change of perspective. But implementing this is a bit trickier! You need to handle the margin of the frame etc. properly. 

##### 8. Handling occlusion

<mark>My solution for occlusions is to use a MSE threshold to decide whether or not we shall update the state in this iteration</mark>. Don't use the likelihood function due to numerical instability. If the best patch gives a very high MSE, then we neither update the particle weights nor do resampling.

Of course, the threshold needs to be found and defined by you...

```matlab
% normalisation
w_arr_norm = w_arr./norm(w_arr,1);  
[best_val,best_ind] = max(w_arr);  
best_mse = -log(best_val)*(2*sigma_MSE(1)^2);

% resampling only if the best patch makes sense
if best_mse<0.2
    i_new = randsample(size(S,1),N,true,w_arr_norm);
    S = S(i_new,:);         
end
```



### Appearance Model Update

##### Patch update

For an object whose shape is not constant, you need to update the template by new images. This can be done by combining old and new patches by simple linear equations. (The idea is similar to an IIR filter) .

Some tips:

- If the object is not a square, you'd better use smaller window sizes. This will help you include as many pixels that belong to the object as possible, and less of the background.
- Remember to update your patch after calculating the new weights but <mark>before injecting the dynamic uncertainties</mark>!

Also, I added a histogram threshold to the likelihood function: for patch matching purposes, only calculate the SSE of the pixels that meet the histogram criteria.

##### Strategies for noisy video 

Having tried quite a few methods, none is really meaningful. 

1. Slightly increase window size
2. Adjust similarity parameter
3. Use more particles



### Mean-shift tracking

This is an interesting technique, not difficult to implement. However, it is generally slower.

My approach is to create 3D histograms for each patch, and use chi-squared test to perform similarity check.  

```                matlab
% hist_patch and hist_template are both of size (6, 6, 2)
% Test score
hist_template(hist_template==0) = nan;  % this is necessary
T = nansum(nansum(nansum((hist_template - hist_patch).^2./hist_template)));
```

Ideally, search a neighbourhood based on a Gaussian kernel. The window doesn't have to be too large.

Maybe I haven't tuned the hyperparameter sufficiently, so the performance isn't as good as the particle filter. 



# PS7

### Motion history image (MHI)

#### Binary sequence 

If a pure background image is not available, we have subtract consecutive images, in order to establish a binary sequence. You would probably see some unwanted objects standing out, although <mark> it doesn't need to be perfect</mark>, as the MHI usually will end up very smooth. 

To address this issue, some pre-processing steps are recommended:

1. A moderate Gaussian blur.
2. Morphological operations, e.g. opening or closing (```imopen``` or ```imclose``` in MATLAB). 
3. Threshold selection - use histogram to have a rough idea before fine tuning.

All of these require trial and error. Also, I personally think more sophisticated filtering can be done to make this more automatic.

#### Obtaining MHI

Very straightforward, just follow this:

```matlab
t0 = 2;
tau = 90;
M_tau = zeros([size(binary_sequence,2) size(binary_sequence,3)]);
for t = t0:t0+tau-1
	Bt = binary_sequence(t,:,:);
    Bt = reshape(Bt,[size(Bt,2) size(Bt,3)]);  % clean up the obsolete dimension
    M_tau(Bt~=1) = (M_tau(Bt~=1)-1);
    M_tau(M_tau<0) = 0;
    M_tau(Bt==1) = tau;
end
```

#### Recognition via MHI

The key is to create a good feature vector, so that you can compare the MHI of different image sequences.

- At least use scale invariant image moments. 
- Most people use Hu moments.
- Euclidean distance measurement is commonly used.





# MATLAB plotting tips

#### Tight subplots

```VLFeat``` has a very nice tight subplot function ```vl_tightsubplot```:

```matlab
figure(1)
vl_tightsubplot(1,2,1);
imshow(img1)
vl_tightsubplot(1,2,2);
imshow(img2)
```

#### refresh stuff in the same figure window without old stuff sticking around

```matlab
% this will remove all the colorbars and etc. existing in your figure
% it won't crash even if you haven't created any figure object.
ccc = gcf;
delete(ccc.Children);

figure(1);
subplot(1,1,1);
imshow(im1);
colorbar('SouthOutside');
colormap(gca,jet(100));

```

#### two subplots sharing the same scale of colormap

```matlab
% first determine the range
% then set the color axis to manual before running the colorbar function
U_min = min(min(U));
U_max = max(max(U));
V_min = min(min(V));
V_max = max(max(V));

bottom = min(U_min,V_min);
top = max(U_max,V_max);

figure(2);

subplot(1,2,1);
imagesc(U)
caxis manual;
caxis([bottom top]);
colorbar('SouthOutside');
colormap(gca,jet(100))

subplot(1,2,2);
imagesc(V)
caxis manual;
caxis([bottom top]);
colorbar('SouthOutside');
colormap(gca,jet(100))

```

#### resize image

``` matlab
% halve the size
img_1_new = imresize(img_1, 0.5);
```





