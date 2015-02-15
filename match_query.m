function [song, offset] = match_query(query, database, canciones, reproducir)

%% match_query - Guesses the given song 
%
% [song, offset] = match_query(query, database, canciones, reproducir)
%
% match_query guesses the song that is passed to it in the variable query 
% and returns all the information it has about it. 
%
% query can be an string containing the path of the song we want to analyse, 
% a 1-column array containing its 8KHz-sampled data, or a number that will
% indicate the amount of seconds that we'll be recording audio (because the)
% song we want to analyse its playing in the background, for example. If
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
% played and if the album cover and the lyrics should be displayed. If its false,
%
% @author: Alex Gascón

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION

% IMPORTANT: This dilate_size must be the same than the one passed to find_landmarks
% when we filled the db 
dilate_size = [30, 30];

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


    % If the query is a number, we'll record audio the amount of seconds it
    % specifies. If its equal to 0, it will record until we stop it
    else if(query ~= 0)
            grabador = audiorecorder(8000, 16, 1);
            disp('Estaremos grabando durante %d segundos', query)
            recordblocking(grabador, query);
            y8000 = getaudiodata(grabador);
        else
            grabador = audiorecorder(8000, 16, 1);
            disp('Pulse cualquier tecla para dejar de grabar')
            pause();
            stop(grabador);
            y8000 = getaudiodata(grabador);
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
[utracks, xx] = unique(sortedHits(:,1), 'first');

% As we're working on a sorted matrix, the difference between the first row
% appearance of each index indicates us the number of times that it
% appears.
nr = size(sortedHits,1);
utrkcounts = diff([xx', nr+1]);

% Now, we sort the appearances and get the index at which each one appears
% in the original array
[sortedUTC, UTCindex] = sort(utrkcounts,'descend');



% This variable indicates in how many songs we're going to search for
% coincidences. We'll only examine the maxesExamined song whose id_song
% appears the most
maxesExamined = 10;

% If there are less than maxesExamined songs with collision, we'll examine
% all of them
maxesExamined = min(maxesExamined, length(UTCindex)-1)

% Reserving memory space for the song-time coincidences histogram
R = zeros(maxesExamined,3);

for i = 1:maxesExamined
    wantedROWs = find(sortedHits(:,1) == utracks(UTCindex(i)));
    if(~numel(wantedROWs)) continue; end 
    hitsSong = sortedHits(wantedROWs(1):wantedROWs(end),:);
    [utime, xt] = unique(hitsSong(:,2), 'first');
    ntime = size(hitsSong,1);
    utimecounts = diff([xt', ntime+1]);
    [sortedUTiC, UTiCindex] = sort(utimecounts,'descend');
    
    %COEFICIENTE DEL ESTRIBILLO
    if(numel(sortedUTiC) > 1 && sortedUTiC(1)/sortedUTiC(2) > 4/3 && sortedUTiC(2) > 2) coef_estribillo = 1.5;
    else coef_estribillo = 1;
    end
    
    R(i,:) = [utracks(UTCindex(i)), utime(UTiCindex(1)), ceil(coef_estribillo*sortedUTiC(1))];
end

%% PRINTING THE RESULT

% We sort R depending on the coincidences found and get the info of the one in the
% first row.
R = sortrows(R, -3);
song = R(1,1);
offset = R(1,2);

% TOLERANCE: If the most commmon match isn't, at least, toleranceRatio times as occurrent 
% than the second most common one, it will conclude that any song matches the query.
% Nonetheless, it will mention the two most probable matches.
toleranceRatio = 2;
if(R(1,3)/R(2,3) < toleranceRatio)
    disp(sprintf('No hay ninguna canción dominante. Las más probables son %s y %s', ...
        canciones{song}(1:end-4), canciones{R(2,1)}(1:end-4)))


% If it has found a probable enough coincidence, it will give all the info about
% its title, author, album and releasing year. 
%
% Moreover, if reproducir = 1, it will also show the album cover and the lyrics,
% and will play the song.
else
    if(reproducir) [y, Fs] = audioread(canciones{song,1}); 
    portada = imread(canciones{song,5});
    letra = textread(canciones{song,6},'%s');
    end

    grupo = canciones{song, 2};
    disco = canciones{song, 3};
    anyo = canciones{song, 4};
    disp(sprintf('El fragmento analizado pertenece a %s, una canción del grupo %s perteneciente al disco %s y publicada en el año %s',...
        canciones{song,1}(1:end-4), grupo, disco, anyo))

    if(reproducir)
    imshow(portada);
    disp(letra);
    sound(y, Fs); end
end





