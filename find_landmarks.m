function [L, S, maxes] = find_landmarks(song_data, dilate_size)

%% find_landmarks - Pairs the maxes found in the song data
%
% [L, S, maxes] = find_landmarks(song_data, dilate_size)
%
% 
% Function that gets the data of a 8KHz-sampled song, represents it in an
% spectrogram and finds the maxes that spectrogram has and makes pairs
% between them. This pairs can be used as a footprint for the song if
% stored properly.
%
% INPUTS: 
% 
% song_data - Array containing the values of the song that whose maxes we
% want to pair. It must have only one column.
%
% dilate_size - Size of the structuring element used on the dilatation
% step. It must be a two-dimensional array, as we're using a rectangular
% one.
%
%
% OUTPUTS:
%
% L - Matrix that contains the obtained landmarks. size(L) = [#hashes, 4]
% Each row of L is formed by [start_time, start_freq, freq_diff, time_diff]
% 
% S - Preprocessed spectrogram
% 
% maxes - Matrix containing the position of the maxes in the spectrogram. 
% First column indicates the row, second column indicates the column.
%
% @author: Alex Gascon
%

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION 

%% GETTING THE SPECTROGRAM

% First of, all, we instantiate the parameters we're going to use to get the
% spectrogram. These parameters are defined in the instructions of the
% project

Fs = 8000; % All the songs we'll be working on will be sampled at an 8KHz rate

tWindow = 64e-3; % The window must be long enough to get 64ms of the signal
NWindow = Fs*tWindow; % Number of elements the window must have
window = hamming(NWindow); % Window used in the spectrogram

NFFT = 512;
NOverlap = NWindow/2; % We want a 50% overlap

[S, F, T] = spectrogram(song_data, window, NOverlap, NFFT, Fs);

S = S(1:end-1,:);
F = F(1:end-1,:);


%% PROCESSING THE SPECTROGRAM
% Now, we're going to pre-process the spectrogram, in order to make it
% easier to work with. 

% First of all, we're going to take small peaks out
S = max(S, max(S(:))/1e6);

% Then, we get the logarithmic value
S = 10*log10(abs(S));

%Now, we substract the average of the image
S = S - mean(S(:));

% Finally, we filter it
B = [1 -1]; A = [1 -0.98];
S = filter(B, A, S');
S = S';


%% FINDING THE MAXES

% The next step will be to locate the maxes on the spectrogram. In order to
% do this, we'll get the dilatation of the spectrogram and then look for the
% points whose value is the same in both the pre-dilated and the processed
% spectrogram

% We begin by creating the Structuring Element. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% IMPORTANT: We should try different shapes and see which one gives %%%%
%%%% the best results. The rectangular one works pretty well with a    %%%%
%%%% size of approximately [30, 30]                                    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

se = strel('rectangle', dilate_size); 

% Now we dilate the image using MATLAB's imdilate
SDilated = imdilate(S,se);

% And finally, we get the coordinates whose values coincide using the find
% command.
[I, J] = find(SDilated == S);

% It's important to realise that [I, J] are the row and the column where the
% maxes are, but what we want to know is its value. Therefore, we'll get the
% time and the frequency corresponding to each row and column and store it
% them
maxes = [F(I), T(J)'];



%% PAIRING THE MAXES
% Now that we have the maxes, it's time to pair them. 
% We want to find all the pairs whose time difference is less than 64
% columns (~2 seconds) and whose frequency differs is less than 32 (500 Hz).
% Besides, if for a maximum we find more than 3 pairs, we'll store only the
% 3 that are closer in time. 
%
% We'll store all this data in a matrix L, in which we'll use a row for each
% pair and whose structure will be the following:
% Lrow = [initialTime, initialFreq, finalFreq-initialFreq, finalTime-initialTime]

%As we'll store up to three pairs for each point, the maximum length L can
%have is 3*#maxes.
L = zeros(length(maxes)*3,4);
pairs = 0; %Number of pairs found

% For each max that we've found, we'll look for the ones whose frequency isn't 
% more than 500Hz or 2.048 seconds away from it. In case that we found more than
% three maxes that meet these conditions, we'll get only the nearest three. 
for i = 1:length(maxes)-1
    f1 = I(i);
    t1 = J(i);
    
    [R, C] = find((abs(I - f1) < 32) & ((J - t1) > 0) & ((J - t1) < 64), 3);
        
    % We store [initial_time, initial_frequency, freq_diff, time_diff] in the matrix L.
    for j = 1:length(R)
         Lrow = [t1, f1, I(R(j)) - f1, J(R(j)) - t1];
         pairs = pairs+1;
         L(pairs,:) = Lrow;       
    end 
end

% We'll return only those rows of L that contain a pair, and get rid of those
% that we've created with zeros at the beginning of this part but haven't
% been used
L = L(1:pairs,:);









