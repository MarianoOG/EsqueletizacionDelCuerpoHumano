function path = trayectoriaGeodesica(img, inicio, fin, varargin)
%% DESCRIPCION:
    % Computa una trayectoria geodesica minima entre dos marcadores 
    % (inicio y fin) dentro de una imagen (img).
    
    % PATH = imGeodesicPath(IMG, INICIO, FIN)
        % INICIO y FIN pueden ser matrices N-by-2 con coordenadas (x,y) o 
        % imagenes binarias del mismo tama?o que IMG.
        % PATH es una imagen binaria que une INICIO Y FIN con la distancia
        % geodesica mas corta. El resultado no es unico, es tan solo una de
        % las posibles soluciones.
        % GRAF grafica el mapeo de distancias (DEFAULT = )

%% Valor opcional de graficacion:
    numvarargs = length(varargin);
    if numvarargs > 1
        error('myfuns:somefun2Alt:TooManyInputs', 'requires at most one optional inputs');
    end
    optargs = {false}; % Default
    optargs(1:numvarargs) = varargin;
    [GRAF] = optargs{:};
        
%% Inicio de variables:
    % Asegura entrada binaria:
    if ~islogical(img)
        img = img>0;
    end
    % Inicia marcadores inicio y fin desde imagen o desde set de puntos:
    if sum(size(fin)~=size(img)) == 0
        marcadorfin = fin > 0;
    else
        marcadorfin = false(size(img));
        for i = 1:size(fin, 1)
            marcadorfin(fin(i,2), fin(i,1)) = true;
        end
    end
    % Inicia salida:
    path = false(size(img));
    
%% Mapeo de distancias:
    dist = mapeoDistancia(img, marcadorfin);
    if GRAF
        figure, imshow(dist,[]);
    end
%% Distancia minima entre marcadores:
    % Encuentra posicion de el punto mas cercano perteneciente a inicio:
    if sum(size(inicio) ~= size(img)) == 0 % En mascara binaria.
        if ~islogical(inicio) % Asegura imagen binaria tipo logical.
            inicio = inicio>0;
        end
        [distMin, indice] = min(dist(inicio));
        [ys xs] = ind2sub(size(inicio), indice);
    else % En set de puntos:
        distMin = inf;
        for i = 1:size(inicio, 1)
            valor = dist(inicio(i,2), inicio(i,1));
            if valor < distMin
                xs = inicio(i,1);
                ys = inicio(i,2);
                distMin = valor;
            end
        end
    end
    
%% Verifica existencia de un camino:
    if isempty(distMin)
        warning([mfilename ':NoPathFound'], ...
            'No path could be found between the two marcadorfin');
        path = [];
        return;
    end

%% Crea el camino regresando al marcador de destino:
    % A?ade un borde de un pixel de valores Inf al rededor de la imagen:
    tmp = dist;
    dist = Inf(size(dist)+2);
    dist(2:end-1, 2:end-1) = tmp;
    % Ajuste de coordenadas:
    x = xs + 1;
    y = ys + 1;
    % Obtencion del camino:
    path(ys,xs) = true;
    while true
        % Revisa al rededor del punto y encuentra el minimo:
        neigh = dist(y-1:y+1, x-1:x+1);
        [mini ind] = min(neigh(:));
        % Verifica si el minimo es el valor actual:
        if mini == dist(y, x)
            break;
        end
        % Convertir indice a sub y actualizar coordenada actual:
        [iy ix] = ind2sub([3 3], ind);
        x = x + ix - 2;
        y = y + iy - 2;
        % Almacena resultado:
        path(y-1,x-1) = true;
    end

end