function [ P1, P2 ] = separarPartesConvexas( BIN, varargin )
%% DESCRIPCION:
    % Regresa dos matrices cada una con una subdivision de la original.
    % Dichas subdivisiones son complementarias, es decir, su suma da origen
    % a la imagen original.
    % Utiliza el criterio de partes aproximadas convexas y la regla de la
    % distancia mas corta para realizar el corte.
        % BIN es la binarizacion del objeto
    	% P1 y P2 las partes de dicho objeto
        % TOL es el valor de paro para hacer cortes. (DEFUALT = 0.85)
        % Todas las matrices son imagenes binarias de tipo logical

%% Valor opcional de graficacion:
    numvarargs = length(varargin);
    if numvarargs > 2
        error('myfuns:somefun2Alt:TooManyInputs', 'requires at most one optional inputs');
    end
    optargs = {0.85,false}; % Default
    optargs(1:numvarargs) = varargin;
    [TOL, GRAF] = optargs{:};
        
%% INICIO DE VARIABLES:
    if ~islogical(BIN)    
        BIN = BIN > 0;
    end
    
%% Crea caparazon convexo de la imagen:
    % Obtiene caparazon de propiedades de la imagen:
    propbin = regionprops(BIN, 'BoundingBox', 'ConvexImage','Area','Solidity');
    area = propbin.Area;
    bx = round(propbin.BoundingBox(2));
    by = round(propbin.BoundingBox(1));
    % Ajusta al tamano original:
    [a,b] = size(propbin.ConvexImage);
    convex = false(size(BIN));
    convex(bx:bx+a-1,by:by+b-1) = propbin.ConvexImage;
    if GRAF
        figure
            imshow(convex+BIN,[])
    end

%% Comproacion de tolerancia:
    tol = propbin.Solidity;
    if tol < TOL && area > 2500

    %% Obtener exceso y etiquetar:
        resta = convex - BIN;
        SE = strel('disk',1);
        dil = imdilate(resta,SE);
        perimbin = bwperim(BIN);
        interes = and(perimbin,dil);
        resta = or(resta,interes);
        [L,N] = bwlabel(resta);

    %% Mapeo de distancias y encontrar muesca maxima (punto mas concavo):
        perimconvex = bwperim(convex);
        dist = mapeoDistancia(resta,perimconvex);
        distinteres = interes.*dist;
        maximo = max(max(distinteres));
        indice = find(distinteres == maximo);
        [x,y] = ind2sub(size(dist),indice);
        x = x(1);
        y = y(1);
        muesca = false(size(BIN));
        muesca(x,y) = true;
        
    %% Encontrar distancia minima de punto a borde que corte imagen:
        valor = L(x,y);
        
        if valor == 0
            error('El punto no pertenece al exceso');
        else
            region = L == valor;
            zonaInteres = and(perimbin,not(region));
        end

    %% Mapeo de punto mas concavo a zona de interes:
        dist2 = mapeoDistancia(BIN,muesca);
        infinitos = dist2 == Inf;
        dist2(infinitos) = 0;
        dist3 = zonaInteres.*dist2;
        ceros = dist3 == 0;
        dist3(ceros) = Inf;
        valorminimo = min(min(dist3));
        ind = find(dist3 == valorminimo);
        [x2,y2] = ind2sub(size(BIN),ind);
        x2 = x2(1);
        y2 = y2(1);
        
    %% Crear camino entre estos dos puntos:
        camino1 = trayectoriaGeodesica(BIN, [y,x], [y2,x2]);

    %% Encontrar puntos mas convexos (muescas) por region:
        muescas = zeros(N,2);
        for i = 1:N
            mask = L==i;
            propmask = regionprops(mask,'Area');
            areamask = propmask.Area;
            if areamask > area/100;
                region = dist.*mask;
                maximolocal = max(max(region));
                indice = find(region == maximolocal);
                [x,y] = ind2sub(size(region),indice);
                x = round(mean(x));
                y = round(mean(y));
                muescas(i,:) = [x,y];
            else
                muescas(i,:) = [Inf,Inf];
            end
        end

    %% Encontrar dos muescas mas cercanas:
        minima = Inf;
        p = [];
        for i = 1:N
            for j = i+1:N
                d = norm(muescas(i,:)-muescas(j,:));
                if d < minima
                    minima = d;
                    p = [i,j];
                end
            end
        end
    
    %% Crear camino entre estos dos puntos:
        blanco = true(size(BIN));
        if length(p) == 2
            camino2 = trayectoriaGeodesica(blanco,muescas(p(1),end:-1:1),muescas(p(2),end:-1:1));
            camino2 = and(BIN,camino2);
        else
            camino2 = Inf;
        end
        
        
	%% Camino mas corto:
        C1 = sum(sum(camino1));
        C2 = sum(sum(camino2));
        if C1 < C2
            union = camino1;
        else
            union = camino2;
        end
        if C1 == 0
            union = camino2;
        end
        if C2 == 0
            union = camino1;
        end

    %% Graficar:
        if GRAF
            figure
                imshow(BIN+union,[])
        end

    %% Partir objeto:
        partes = and(BIN,not(union));
        L = bwlabel(partes,4);
        P1 = L == 1;
        P2 = L == 2;
        propsP1 = regionprops(P1,'Area');
        propsP2 = regionprops(P2,'Area');
        A1 = propsP1.Area;
        A2 = propsP2.Area;
        if A1 < A2
            P1 = or(P1,union);
        else
            P2 = or(P2,union);
        end
    else
        P1 = BIN;
        P2 = false(size(BIN));
    end
    
end