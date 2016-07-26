function [fighandle, maxLoc] = plotDist(data,keepbars,varargin)

if ~isempty(varargin)
    [counts,bins]=hist(data,varargin{1});%# create histogram from a normal distribution.
else
    [counts,bins]=hist(data);
end
%[fks,xi] = ksdensity(inData,bins);
bins_interp = linspace(bins(1),bins(end),500);
counts_interp = interp1(bins,counts,bins_interp, 'spline');
%normalization = 1/(bins(2)-bins(1))/sum(counts);
dx = diff(bins(1:2));
g=1/sqrt(2*pi)*exp(-0.5*bins.^2);%# pdf of the normal distribution
n = length(bins);
t = linspace(bins(1)-dx/2,bins(end)+dx/2,n+1);
Fvals = cumsum([0,counts.*dx])/sum(counts);
F = spline(t, [0, Fvals, 0]);
DF = fnder(F);  % computes its first derivative

%#METHOD 2: DIVIDE BY AREA
fighandle = figure;
if keepbars
    bar(bins,counts/sum(counts));
    hold on
end
%plot(xi,fks*length(inData), 'r')
plot(bins_interp, counts_interp/sum(counts), 'm', 'LineWidth', 3);
%plot(xvals,y,'linewidth', 2);
%fnplt(DF, 'r', 2)
%plot(x,g,'r');hold off
title('Distribution')
ylabel('Frequency')
xlabel('Value')
%ylim([0 0.3])
[z i] = max(counts);
maxLoc = bins(i);
line([bins(i) bins(i)], [0 1], 'color', 'k', 'LineWidth', 2);


set(findall(gcf,'-property','FontSize'),'FontSize',20)
end