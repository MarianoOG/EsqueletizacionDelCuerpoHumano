function [ ETIQUETAS ] = descomponerFigura( BIN, varargin )
%% DESCRIPCION:
    % Regresa matriz con etiquetas de la descomposicion de la figura.
    % Dichas subdivisiones son complementarias, es decir, su suma da origen
    % a la imagen original.
    % Utiliza la funcion separarPartesConvexas hasta alcanzar en todas las
    % partes la conici?n l?mite de paro
        % BIN es la binarizacion del objeto
    	% ETIQUETAS es la imagen de etiquetas final.
        % TOL es EL valor de paro para hacer cortes. (DEFAULT = 0.85)
        % GRAF es un valor opcional de graficacion. (DEFAULT = false)

%% Valor opcional de graficacion:
    numvarargs = length(varargin);
    if numvarargs > 2
        error('myfuns:somefun2Alt:TooManyInputs', 'requires at most one optional inputs');
    end
    optargs = {0.85,false}; % Default
    optargs(1:numvarargs) = varargin;
    [TOL, GRAF] = optargs{:};
    
%% Descomponer figura:
    ETIQUETAS = zeros(size(BIN));
    N = 0; % Etiqueta actual
    p = 1; % EstadoActual
    aComprobar = {BIN};
    bandera = 0;
    while ~isempty( find(bandera == 0, 1) )
        estadoActual = length(bandera);
        if p == 11
            imshow(aComprobar{p})
        end
        [P1,P2] = separarPartesConvexas(aComprobar{p},TOL,GRAF);
        bandera(p) = 1;
        p = p + 1;
        if sum(sum(P2.*2)) == 0 % Parar rama de algoritmo
            N = N + 1;
            ETIQUETAS = ETIQUETAS + P1.*N;
        else
            aComprobar{estadoActual+1} = P1;
            aComprobar{estadoActual+2} = P2;
            bandera(estadoActual+1:estadoActual+2) = [0,0];
        end    
    end
end