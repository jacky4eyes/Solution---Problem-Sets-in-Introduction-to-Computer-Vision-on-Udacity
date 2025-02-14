function hough_lines_draw(img, outfile, peaks, rho, theta)
    % Draw lines found in an image using Hough transform.
    %
    % img: Image on top of which to draw lines
    % outfile: Output image filename to save plot as
    % peaks: Qx2 matrix containing row, column indices of the Q peaks found in accumulator
    % rho: Vector of rho values, in pixels
    % theta: Vector of theta values, in degrees

    % TODO: Your code here
    % Jacky: plotting a good line is difficult here, because you want to
    % make sure the cases when theta is close to 0 or 180 degrees
    figure(77)
    imshow(img);
    hold on
    x_range = size(img,1);
    for i = 1:(size(peaks,1))
        d = rho(peaks(i,1));
        ta = theta(peaks(i,2))/180*pi;
        cx = d*cos(ta);
        cy = d*sin(ta);
%         p1 = ([max(1,cx+500*sin(ta)) min(cy-500*cos(ta),x_range)]);
%         p2 = ([max(1,cx-500*sin(ta)) min(cy+500*cos(ta),x_range)]);
        p1 = ([cx+1000*sin(ta) cy-1000*cos(ta)]);
        p2 = ([cx-1000*sin(ta) cy+1000*cos(ta)]);
%         y = round((d-x.*cos(ta))./sin(ta));
        plot(round(linspace(p1(1),p2(1),100)),round(linspace(p1(2),p2(2),100)),'m','linewidth',2);
    end
    saveas(gcf, fullfile('output', outfile))
end
