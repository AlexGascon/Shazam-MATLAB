function record_hashes(H,d)

%% record_hashes - Stores the hashes in a database
%
% record_hashes(H, d)
%
% Function that gets a matrix H with the format given by landmark2hash and a
% database d. It will store the info that the hashes in H contain into the 
% database, creating new entries for the hashes that haven't appeared yet
% and editing the existing ones for those that have been found in previous songs
%
% @author: Alex Gascon y Adrián Alemán

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION 

% We'll use the hashes as the key of the db 
keys = H(:,3); %keys.
lkeys = length(keys) ; % Number of keys

ids_song = H(:,1); % Contains id_songs 
t_initials = H(:,2); % Contains the initial time at which each hash appears

% Storing the hashes
for n = 1:lkeys
    
    % We create a 32-bit value with the info of the song and the initial time
    value = (2^17)*ids_song(n) + t_initials(n);
    
    if d.isKey(keys(n)) % Checks if the hash has been already used  
       
        % Read,concatenate and store
        d(keys(n)) = [d(keys(n)) uint32(value)];
        
    else
        d(keys(n)) = uint32(value);
    end
end
