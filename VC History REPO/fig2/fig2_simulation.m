% This script produces the distribution of simulated returns on Dutch East
% India Company voyages that is shown in Figure 2 of the paper. 
clear
close all

%------------------------------------------------------------------------
% Assumptions (see Gelderblom, De Jong and Jonker (2019), Table 3)
%------------------------------------------------------------------------
N_sims                  = 10000;        % total number of simulated voyages

p_loss_toAsia           = 3/92;         % prob of loss on outbound voyage
p_stay_Asia             = 66/89;        % prob of a stay in Asia, conditional on arrival (no immediate return)
p_loss_home_nostay      = 1/23;         % prob of loss on homebound voyage if immediate return
p_loss_home_stay        = 39/66;        % prob of loss after stay in Asia

dur_nostay_mean         = 669.84;       % in days
dur_nostay_std          = 209.62;
dur_nostay_min          = 246;
dur_stay_mean           = 1270.41;
dur_stay_std            = 245.39;
dur_stay_min            = 941;

perc_silver             = .446;         % silver as a percentage of cargo (based on Gelderblom et al. 2013 Appendix Table 1)

rng(1);                                 % set random number generator seed

%------------------------------------------------------------------------
% Simulate arrival and stay indicators
%------------------------------------------------------------------------
I_arriveAsia            = rand(N_sims,1) > p_loss_toAsia;                   %=1 if make it to Asia
I_stayinAsia            = rand(N_sims,1) <= p_stay_Asia;                    %=1 if staying in Asia
I_returnnostay          = rand(N_sims,1) > p_loss_home_nostay;              %=1 if make it home after immediate return
I_returnafterstay       = rand(N_sims,1) > p_loss_home_stay;                %=1 if make it home after stay in Asia

I_roundtrip_nostay      = I_arriveAsia.*(1-I_stayinAsia).*I_returnnostay;   % successful round trip, no stay in Asia
I_roundtrip_afterstay   = I_arriveAsia.*I_stayinAsia.*I_returnafterstay;    % successful round trip, with stay in Asia

%------------------------------------------------------------------------
% Simulate return multiple: 2.5, 3 or 3.5 with 1/3 probability each
%------------------------------------------------------------------------
mult                    = ones(N_sims,1)*3;      
multrand                = rand(N_sims,1);
mult(multrand<=.3333)   = 2.5;
mult(multrand>.6667)    = 3.5;

%------------------------------------------------------------------------
% Compute realized returns
%------------------------------------------------------------------------
mult_realized           = zeros(N_sims,1);
II                      = I_roundtrip_nostay | I_roundtrip_afterstay;
mult_realized(II)       = mult(II);

%------------------------------------------------------------------------
% Simulate voyage durations (in years)
%------------------------------------------------------------------------
dur                         = zeros(N_sims,1);
dur(I_roundtrip_nostay>0)   = max(dur_nostay_min, dur_nostay_mean + randn(sum(I_roundtrip_nostay),1)*dur_nostay_std)/365;
dur(I_roundtrip_afterstay>0) = max(dur_stay_min, dur_stay_mean + randn(sum(I_roundtrip_afterstay),1)*dur_stay_std)/365;

%------------------------------------------------------------------------
% Compute IRRs
%------------------------------------------------------------------------
IRR                     = (perc_silver*mult_realized).^(1./dur) - 1;

%------------------------------------------------------------------------
% Generate histogram 
%------------------------------------------------------------------------
[n,x]                   = hist(IRR*100,-100:5:200);   % n and x are the counts and bin centers of the histogram in Figure 2
