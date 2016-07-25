function fighandle = plotDist(inData,keepbars,varargin)

if ~isempty(varargin)
    [f,x]=hist(inData,varargin{1});%# create histogram from a normal distribution.
else
    [f,x]=hist(inData);
end
dx = diff(x(1:2));
g=1/sqrt(2*pi)*exp(-0.5*x.^2);%# pdf of the normal distribution
n = length(x);
t = linspace(x(1)-dx/2,x(end)+dx/2,n+1);
Fvals = cumsum([0,f.*dx])/sum(f);
F = spline(t, [0, Fvals, 0]);
DF = fnder(F);  % computes its first derivative

%#METHOD 2: DIVIDE BY AREA
fighandle = figure;
if keepbars
    bar(x,f/sum(f));
    hold on
end
fnplt(DF, 'r', 2)
%plot(x,g,'r');hold off
title('Distribution')
ylabel('Frequency')
xlabel('Value')
ylim([0 0.3])
[z i] = max(f);
line([x(i) x(i)], [0 1], 'color', 'k', 'LineWidth', 2);

line([0.1 0.1], [0 1], 'color', 'c', 'LineWidth', 2, 'LineStyle', '--');

set(findall(gcf,'-property','FontSize'),'FontSize',20)
end