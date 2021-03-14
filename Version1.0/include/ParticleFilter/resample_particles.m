function [X Neff Wkm1] = resample_particles(X1,X, L,Wkm1)
% resample particles for next time (t+1)
%Input:
% X: Propagated particles
% X1: Newly created particles
% L: likelihood function
if (1)
    Q = L / sum(L, 2);
    Neff=1/sum(Q.^2);    
    R = cumsum(Q, 2);    
    % Generating Random Numbers
    if ~isempty(X)
        if Neff<size(X, 2)
            N = size(X, 2);
        else
            N = round(Neff);
        end
        T = rand(1, N);
        % Resampling
        [KK, I] = histc(T, R);
        if isempty(X1)
            X = X(:, I + 1);
        else
            Xnew=[X1, X];
            X = Xnew(:, I + 1);
        end
    end
    Wkm1=1/length(L);
    
end
end