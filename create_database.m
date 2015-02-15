function d = create_database()

%% create_database - Creates a Map that we can use to store the hashes
% 
% d = create_database() creates a map d with KeyType = uint32 and 
% ValueType = any
%
% @author: Alex Gascon

%% CHANGELOG 
% 1.0 (2015/02/07): Initial version

%% FUNCTION 

% Mapa vacío con tipo de claves uint32 y apto para cualquier valor
d = containers.Map('KeyType', 'uint32', 'ValueType', 'any'); 
