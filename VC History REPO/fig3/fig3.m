% This script simulates various long-horizon returns calibrated to 
% individual stock returns, as shown in Figure 3 of the paper.
clear
close all

%------------------------------------------------------------------------
% Assumptions
%------------------------------------------------------------------------
N               = 1000000;      % # of simulations
T               = 10;           % # periods per simulation

mu              = 1.10;         % single-period return mean (e.g., 1.1 i s a 10% return)
sigma           = 0.3;          % single-period return s.d.

r_lb            = 0.25;         % lower bound on return (e.g., 0.2 is a -80% return)

rng(1);

%------------------------------------------------------------------------
% Generate single period returns
%------------------------------------------------------------------------
eps             = randn(T,N);               % normally distributed shocks
R               = max(mu + sigma*eps, 0);   % truncate returns at -100%

%------------------------------------------------------------------------
% Generate long-horizon returns without absorbing boundary
%------------------------------------------------------------------------
RT              = cumprod(R);
RT_final        = RT(end,:);
RT_final_ann    = RT_final.^(1./T);

%------------------------------------------------------------------------
% Generate long-horizon returns with absorbing boundary
%------------------------------------------------------------------------
RT_absorb       = cumprod(R);
dur             = ones(1,N)*T;              % initiate duration at full horizon
for i = 1:N
    II = find(RT_absorb(:,i) <= r_lb,1);    % II will contain the first hitting time to the bound
    if ~isempty(II)
        RT_absorb(II:end,i) = r_lb;         % if hit bound, then set all subsequent returns to the bound
        dur(i) = II;                        % period of first hitting time
    end
end
RT_final_absorb     = RT_absorb(end,:);
RT_final_absorb_ann = RT_final_absorb.^(1./dur);

%------------------------------------------------------------------------
% Show distributions
%------------------------------------------------------------------------
figure;

% distribution of single period returns (Panel A)
subplot(3,1,1)
[n_1y,x_1y] = hist((reshape(R,numel(R),1)-1)*100,-100:2.5:205);
n_1y = n_1y/1000;   % display count in 000s
bar(x_1y(1:end-1),n_1y(1:end-1));
title('Panel A: Distribution of annual returns')

% distribution of long-horizon returns (Panel B)
subplot(3,1,2)
[n_10y,x_10y] = hist((RT_final-1)*100,-100:10:1210);
n_10y = n_10y/1000;   % display count in 000s
bar(x_10y(1:end-1),n_10y(1:end-1));
title('Panel B: Distribution of 10-year returns (no absorbing bound)')

% distribution of long-horizon returns w/ absorbing boundary (Panel C)
subplot(3,1,3)
[n_10yabs,x_10yabs] = hist((RT_final_absorb-1)*100,-100:10:1210);
n_10yabs = n_10yabs/1000;   % display count in 000s
bar(x_10yabs(1:end-1),n_10yabs(1:end-1));
title('Panel C: Distribution of 10-year returns (with absorbing bound)')
