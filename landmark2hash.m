function H = landmark2hash(L, id_song)

%% landmark2hash - Converts the given landmarks to a 20 bits hash 
%
% H = landmark2hash(L, id_song);
%
% This function gets each landmark found with the find_landmarks function
% and returns a matrix H with the hashes of each one, adding the information
% needed to know which song it belongs to and in which time instant does it
% appears.
%
% Each landmark will be comprimed into a hash in which we'll store the frequency
% of the first max of the landmark and the time and frequency difference between 
% the pair using 8 bits for the initial freq and 6 bits for each difference.
% Therefore, we'll end with a 20 bits code.
%
% H is a matrix with size [length(L), 3], whose rows have the following structure:
% Hrow = [id_song, uint32(initialTime), hashed_landmark];
% L is the landmark matrix obtained with find_landmarks, and id_song is the
% id of the song that is currently being analyzed. It must be an integer
% smaller than 2^15. 
%
%
% @author: Alex Gascon

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION

%We reserve memory for H, so we can operate with it without altering its size
%inside the loop
H = zeros([length(L), 3]);

for i = 1:length(H)
    
    %We get the values we're going to use 
    initialFreq = L(i,2);
    Fdiff = L(i,3);
    initialTime = L(i,1);
    tDiff = L(i,4);
    
    %Creating the hash
    hash = (initialFreq-1)*2^12 + Fdiff*2^6 + tDiff;
    
    %We store the row in H with all the needed values
    H(i, :) = [id_song, uint32(initialTime), hash];
end