%Creamos la base de datos e indicamos en qu� archivo se encuentra la
%informaci�n de las canciones a leer y con dichos par�metros llamamos a
%add_tracks, que se encarga de leerlas, fingerprint-earlas y a�adirlas a la
%BBDD. Una vez terminemos este paso tan s�lo tendremos que realizar las
%pruebas que queramos utilizando match_query.
d = create_database();
filename = 'canciones.txt';
detalles = add_tracks_simplified(filename, d);


