%Creamos la base de datos e indicamos en qué archivo se encuentra la
%información de las canciones a leer y con dichos parámetros llamamos a
%add_tracks, que se encarga de leerlas, fingerprint-earlas y añadirlas a la
%BBDD. Una vez terminemos este paso tan sólo tendremos que realizar las
%pruebas que queramos utilizando match_query.
d = create_database();
filename = 'canciones.txt';
detalles = add_tracks_simplified(filename, d);


