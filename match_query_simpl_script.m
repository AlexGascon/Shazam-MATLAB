
%% match_query - Guesses the given song 
%
% [song, offset] = match_query(query, database, canciones, reproducir)
%
% match_query guesses the song that is passed to it in the variable query 
% and returns all the information it has about it. 
%
% query can be an string containing the path of the song we want to analyse, 
% a 1-column array containing its 8KHz-sampled data, or a number that will
% indicate the amount of seconds that we'll be recording audio (because the
% song we want to analyse its playing in the background, for example). If
% query = 0, it will record audio until we stop it manually.
%
% database must be a db created with create_database, and that should been have
% filled with the record_hash function. 
%
% canciones is a cell containing the info of all the songs stored in database.
% It must have 4 or 6 columns (depending on the info we want to show) and a row
% for each song in the db. Besides, the number of the row in which each song is
% stored must match its song_id.
% Each row must contain:
% {MP3 path, artist, album, release year, album cover path, lyrics path}
%
% reproducir is a boolean variable that indicates if the matched song will be 
% played and if the album cover and the lyrics should be displayed. 
%
% @author: Alex Gascón

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION

% IMPORTANT: This dilate_size must be the same than the one passed to find_landmarks
% when we filled the db 
dilate_size = [20, 20];

%% INPUT QUERY PROCESSING

% If the input is a char array, we read and process the song on that path
if(ischar(query))
    [y, Fs] = audioread(query);
    yMono = y(:,1);
    y8000 = resample(yMono, 8000, Fs);
    
    
% If the query is an array, we analyse the info that it contains supposing
% its a song
else if(length(query) > 1)
        y8000 = query;
        if(size(query, 2) == 2)
            y8000 = (y8000(:,1) + y8000(:,2))/2;
        end

    % If the query is a number, we'll record audio the amount of seconds it
    % specifies. If its equal to 0, it will record until we stop it
    else if(query ~= 0)
            grabador = audiorecorder(8000, 16, 2);
            disp(sprintf('Estaremos grabando durante %d segundos', query))
            recordblocking(grabador, query);
            y8000 = getaudiodata(grabador);
            y8000 = (y8000(:,1) + y8000(:,2))/2;
        else
            grabador = audiorecorder(8000, 16, 2);
            record(grabador);
            disp('Pulse cualquier tecla para dejar de grabar')
            pause();
            stop(grabador);
            y8000 = getaudiodata(grabador);
            y8000 = (y8000(:,1) + y8000(:,2))/2;
        end
    end
end




%% OBTAINING HASHES OF THE QUERY


% We get the hashes of the audio data
[L, ~, ~] = find_landmarks(y8000, dilate_size);
Hquery = landmark2hash(L, 1);

% Getting the coincidences
sortedHits = get_hash_hits(Hquery, database);




%% LOOKING FOR THE SONG

% We discretize the values where coincidences can be found. We use this 
% considering that if we found values that collide but the time doesn't
% coincide, although it's very close, it probably pertains to the same
% guessing
grouping = 5;
sortedHits(:,2) = grouping*floor(sortedHits(:,2)/grouping);

% We obtain a matrix where each coincident id_song appears only once and
% another one that indicates us the first row in which that coincidence
% appears. 
[track_ids, track_ids_firstRow] = unique(sortedHits(:,1), 'first');

% As we're working on a sorted matrix, the difference between the first row
% appearance of each index indicates us the number of times that it
% appears.
number_rows = size(sortedHits,1);
uniquetrkcounts = diff([track_ids_firstRow', number_rows+1]);

% Now, we sort the appearances and get the index at which each one appears
% in the original array
[sortedUTC, UniqueTrackCountIndex] = sort(uniquetrkcounts,'descend');



% This variable indicates in how many songs we're going to search for
% coincidences. We'll only examine the maxesExamined song whose id_song
% appears the most
maxesExamined = 10;

% If there are less than maxesExamined songs with collision, we'll examine
% all of them
maxesExamined = min(maxesExamined, length(UniqueTrackCountIndex));

% Reserving memory space for the song-time coincidences histogram
R = zeros(maxesExamined,3);

for i = 1:maxesExamined
    
    %We obtain the rows corresponding to the id that we're going to examine
    wantedROWs = find(sortedHits(:,1) == track_ids(UniqueTrackCountIndex(i)));
    if(~numel(wantedROWs)) continue; end 
    
    %Number of hits of that song
    hitsSong = sortedHits(wantedROWs(1):wantedROWs(end),:);
    
    %We get the amount of coincidences for each time offset and sort them
    [utime, xt] = unique(hitsSong(:,2), 'first');
    ntime = size(hitsSong,1);
    utimecounts = diff([xt', ntime+1]);
    [sortedUTiC, UTiCindex] = sort(utimecounts,'descend');
    
    %COEFICIENTE DEL ESTRIBILLO
    coef_estribillo = 1;
    if(numel(sortedUTiC) > 1 && sortedUTiC(2) > 2 && sortedUTiC(1)/sortedUTiC(2) > 4/3 ) coef_estribillo = 1.5*coef_estribillo;
    else coef_estribillo = coef_estribillo*1;
    end
    
    %We write a row in the R matrix, storing the information about the most
    %possible match of this song
    R(i,:) = [track_ids(UniqueTrackCountIndex(i)), utime(UTiCindex(1)), ceil(coef_estribillo*sortedUTiC(1))];
end

%% PRINTING THE RESULT

% We sort R depending on the coincidences found and get the info of the one in the
% first row.
R = sortrows(R, -3);
song = R(1,1);
offset = R(1,2);

% TOLERANCE: If the most commmon match isn't, at least, toleranceRatio times more occurrent 
% than the second most common one, it will conclude that any song matches the query.
% Nonetheless, it will mention the two most probable matches.
toleranceRatio = 2;
% if(R(1,3)/R(2,3) < toleranceRatio)
%     disp(sprintf('No hay ninguna canción dominante. Las más probables son %s y %s', ...
%         canciones{song}(1:end-4), canciones{R(2,1)}(1:end-4)))


% If it has found a probable enough coincidence, it will show the song's
% title
%else
     disp(sprintf('El fragmento analizado pertenece a %s', canciones{song,1}(1:end-4)))
