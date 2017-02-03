function s = add_tracks_simplified(filename,d, id_offset)

%% add_tracks - Analyzes songs and stores its hashes in a database.
%
% s = add_tracks(filename, d)
%
% This function reads the file called filename that contains info about the songs 
% we want to store in the database d, and processes and stores them. 
%
% The read file must have the following format: it must have a row for each song.
% In each row, it will give us the path of the mp3 we have to read, the group that
% plays it, the album it appeared in, the year it was released, the path of its
% album cover image and the path of a text file containing its lyrics. Each one of
% this piece of information must be separed of the others with a '---'.
%
% EXAMPLE: Canciones/Target/Wonderwall.mp3---Oasis---Live_at_Earls_Court---1995---Imagenes/Wonderwall.jpg---Letra/Wonderwall.txt
%
% add_tracks will output a [#songs, 6] cell containing all the info of each one of 
% the songs stored. Besides, it will fill the db with them. 
%
% id_offset indica a partir de qué número hay que empezar a contar el id de
% las canciones que se añadan
%
% @author: Alex Gascon y Mireia Segovia

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION
% Preparing the variables
detalles = textread(filename,'%s');
l = length(detalles);
dilate_size = [20, 20];



s = cell(l, 1);
% Reading the file and obtaining the song information
for i = 1:l
    s{i,:} = detalles{i};
end

% Processing the songs
for i = 1:l

    % We read the song and convert it to its 8 KHz mono version
    [c, fs] = audioread(s{i,1}); 
    cMono = 0.5*(c(:,1) + c(:,2)); 
    c8000 = resample (cMono, 8000, fs);
    
    % Finding the landmarks and storing its hashes in the database
    [L, ~, ~] = find_landmarks(c8000, dilate_size);
    H = landmark2hash(L, i + id_offset);
    record_hashes(H,d);

    % Control output, used so we can check that everything is going well
    display('Leido')
    disp(sprintf('Número de hashes de la canción %d: %d',i, length(H)))
    
    % Freeing up memory
    clear c cMono c8000 L S maxes H
end


