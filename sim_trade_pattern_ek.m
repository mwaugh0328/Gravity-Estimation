function [m, final_price] = sim_trade_pattern_ek(lambda,tau,theta,sigma,code)%#codegen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A function to simmulate a pattern of trade and then generate a trade
% share matrix and a random sample of final goods prices. It is set up 
% to work for any arbitrary distribution. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for goods and countries and the sample size for prices

Ngoods = 100000; % Adjust this number if it is running really slow (not too low though).
Ncntry = length(lambda);

% Parameters for technologies
eta = sigma;
inveta = 1./(1- eta);
invNgoods = 1./Ngoods;
low_price = 1.*10.^7;

theta = 1./theta;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw productivities and and compute unit costs to produce each good in
% each country
% rand('seed',03281978+code)
rng(03281978+code)
pconst = zeros(Ngoods,Ncntry); 

for j = 1: Ncntry
    
    u = rand(Ngoods,1);
    
    z = (log(u)./(-lambda(j))).^(theta); % No -theta because we will just multiply by z below
                                         % to compute the unit cost    
    pconst(:,j) = (z);

end

%clear u z lambda wage % clear large variables to clear up memory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop to calculate the low price and country suppliers

m = zeros(Ncntry,Ncntry);
sum_price = zeros(Ncntry,1);
rec_low_price = zeros(Ngoods,Ncntry); 

for gd = 1:Ngoods  % This is the good
    
    for im = 1:Ncntry  % This is the country importing the good
        
        cif_price = zeros(Ncntry,1);
        
        for ex = 1:Ncntry   % This is the country (potentially) exporting the good

			cif_price(ex) = tau(ex,im).*pconst(gd,ex);
            
                if (ex ~= 1) % update to figure out how has the low price
                    low_price = min(cif_price(ex),low_price);
                else
					low_price = cif_price(ex);
                end

        end
        
        if (low_price == cif_price(im)) 
        
            m(im,im) = m(im,im) + low_price.^(1-eta);
        
        else

            for ex = 1:Ncntry	% This loop is just to record who is the low cost supplier
                                % This is ineffcient, but a hold over from .for

                if (low_price == cif_price(ex))            
                    m(ex,im) = m(ex,im) + low_price.^(1-eta);
                    break 																
                end

            end
        end
        
        % Now record the low price

        sum_price(im) = low_price.^(1-eta) + sum_price(im); % I'm exploiting that eta = 2, thats why 1/low_price
        rec_low_price(gd,im) = low_price;

    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop to calculate aggregate price index and the trade shares.

g = zeros(Ncntry,1);

for im = 1:Ncntry										

	g(im) = (sum_price(im)*invNgoods).^(inveta);
															
    for ex = 1:Ncntry
    
        m(ex,im) = invNgoods.*m(ex,im)./g(im).^(1- eta);
    
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a price matrix simmilar to that in the data

final_price = rec_low_price;
