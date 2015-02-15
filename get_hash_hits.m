function R = get_hash_hits(H, database)

%% get_hash_hits - Gets the hashes that appear both in the db and in the query
%
% R = get_hash_hits(H, database) finds the coincidences within the hashes
% stored in H (which has been returned by landmark2hash) and the ones in
% the database database. The matrix R that is returned contains a row for
% each found collision, and whose structure is the following:
%
% Rrow = [collided_id_song, time_difference, collided_hash]
%
%
% @author: Alex Gascón

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION

% We declare the variables that we're going to use
R = zeros(length(H)*3,3);
count = 0;
hashes = H(:,3);

% We go hash by hash looking for coincidences
for i = 1:length(hashes)
    
    currentHash = hashes(i);
    
   % If the current hash exists, we get the data associated to it
   if(database.isKey(currentHash))
       data = database(currentHash);
       
       % We add a row to R for every song that has that hash
       for j = 1:length(data)
           
           count = count+1;
           tQuery = H(i,2); % The time at which the hash appears on the query
           tTarget = data(j);
           while(tTarget > 2^17) % We get the time at which the hash appears in our db
                tTarget = tTarget - 2^17;
           end
           
           
            R(count, 1) = data(j)/2^17; % id_song of the song that coincides
            R(count, 2) = abs(tTarget - tQuery); % Time difference of the coincidence 
            R(count, 3) = currentHash; % Hash that has collided
            
      end
   end
end

% We get rid of the unused rows and sort the rest.
R = R(1:count,:);
R = sortrows(R, [1, 2]);

