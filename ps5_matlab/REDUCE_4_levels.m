%% only reduce 3 times, resulting in 4 levels; g0 is the original
% [g0,g1,g2,g3] = REDUCE_4_levels(im, h)
function [g0,g1,g2,g3] = REDUCE_4_levels(im, h)
    g0 = im;
    g0_fil = imfilter(g0,h);
    g1 = g0_fil(1:2:end,1:2:end);
    g1_fil = imfilter(g1,h);
    g2 = g1_fil(1:2:end,1:2:end);
    g2_fil = imfilter(g2,h);
    g3 = g2_fil(1:2:end,1:2:end);
end