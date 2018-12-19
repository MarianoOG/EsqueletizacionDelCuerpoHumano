function [ C ] = centroideGeodesico( BIN )
%% DESCRIPCION:
    % Regresa el centroide por distancia geodesica de un objeto.
        % BIN es la binarizacion del objeto
    	% x es la cordenada abscisa del objeto
        % y es la cordenada ordenanda del objeto

%% Inicio de variables:
    if ~islogical(BIN)
        BIN = BIN > 0;
    end
    neg = not(BIN);

%% Busqueda de centro:
    % Obtiene el mapeo del borde externo hacia el centro:
    dist = mapeoDistancia(BIN,neg);
    % Obtiene el valor maximo (centro):
    M = max(max(dist));
    B = find(dist == M);
    [x,y] = ind2sub(size(BIN),B);
    % Promedia si hay mas de un valor:
    x = mean(x);
    y = mean(y);
    C = [y,x];

end