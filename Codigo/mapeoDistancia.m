function DIST = mapeoDistancia(mascara, marcadores)
%% DESCRIPCION:
    % Calcula la distancia de un marcador a cada pixel en la imagen 
    % sobre un objeto dado, si no es posible alcanzar algun pixel ya 
    % que esta fuera del objeto la respuesta es Inf.
        
    % La funcion usa un algoritmo de escaneo. Cada iteracion tiene una
    % secuencia hacia adelante y una hacia atras. Las iteraciones
    % terminan cuando la estabilidad es alcanzada.
    
    % La funcion se propaga utilizando una aproximaxion de la distancia 
    % quasi-eclidiana, un peso de 5 ortogonalmente y con un peso de
    % 7 de manera diagoal.
        
    % DIST = mapeoDeDistancia(MASCARA, MARCADORES)
        % MASCARA es la imagen binaria que contiene al objeto. 
        % MARCADORES es el origen de donde se mediran las distancias.
        % DIST es el mapeo dado en una matriz del mismo tama?o que MASCARA.
   
%% Inicio de variables:
    % Asegura binarizacion de imagen de fondo o mascara y del marcador:
    if ~islogical(mascara)
        mascara = mascara>0;
    end
    if ~islogical(marcadores)
        marcadores = marcadores>0;
    end
    % Lee el tama?o de la imagen:
    [D1 D2] = size(mascara);
    % Direcciones 'i' y 'j' hacia adelante (1) y hacia atras (2).
    di1 = [-1 -1 -1 0];
    dj1 = [-1 0 1 -1];
    di2 = [1 1 1 0];
    dj2 = [-1 0 1 1];
    % Pesos:
    w1 = 5;
    w2 = 7;
    ws =  [w2 w1 w2 w1];
    % Inicia variable de salida y da formato:
    DIST = ones(D1,D2);
    DIST(:) = inf;
    DIST(marcadores) = 0;
    
%% Iteraciones hacia delante y hacia atras hasta encontrar estabilidad:
    modificar = true;
    nIter = 1;
    while modificar
        modificar = false;
        %% Hacia adelante:
        
        % Procesar primera linea:
        for j = 2:D2
            if mascara(1,j)
                newVal = DIST(1,j);
                newVal = min(newVal, DIST(1,j-1) + w1); % Pixel izquierdo
                if newVal ~= DIST(1,j)
                    modificar = true;
                    DIST(1,j) = newVal;
                end
            end
        end

        % Iteracion de filas:
        for i = 2:D1

            % Procesamiento especial para primer pixel de la fila:
            if mascara(i, 1)
                newVal = DIST(i, 1);
                newVal = min(newVal, DIST(i-1, 1)+w1);     % top pixel
                newVal = min(newVal, DIST(i-1, 2)+w2);     % top-left diag
                if newVal~=DIST(i,1)
                    modificar = true;
                    DIST(i,1) = newVal;
                end
            end
            % Procesamiento para todos los pixeles dentro de la fila:
            for j = 2:D2-1
                % Computar solo para pixeles dentro de la estructura
                if ~mascara(i,j)
                    continue;
                end
                % Computar distancia minima:
                newVal = DIST(i, j);
                for k = 1:4
                    newVal = min( newVal, DIST(i+di1(k), j+dj1(k))+ws(k) );
                end
                % Si la distancia cambio actualizar y activar bandera:
                if newVal~=DIST(i,j)
                    modificar = true;
                    DIST(i,j) = newVal;
                end
            end
            % Procesado especial para ultimo pixel de la linea:
            if mascara(i,D2)
                newVal = DIST(i,D2);
                newVal = min(newVal, DIST(i,D2-1) + w1);  % left pixel
                newVal = min(newVal, DIST(i-1,D2-1) + w2);  % top-left pixel
                newVal = min(newVal, DIST(i-1,D2) + w1);  % top pixel
                if newVal~=DIST(i,D2)
                    modificar = true;
                    DIST(i,D2) = newVal;
                end
            end

        end % Iteracion de filas

        % Checar si hubo modificaciones, finalizar en caso negativo:
        if modificar==false && nIter ~= 1;
            break;
        end

        %% Hacia atras:
        modificar = false;

        %  Procesar ultima linea:
        for j = D2-1:-1:1
            if mascara(D1, j)
                newVal = DIST(D1,j);
                newVal = min(newVal, DIST(D1, j+1)+w1); % Pixel izquierdo
                if newVal~=DIST(D1,j)
                    modificar = true;
                    DIST(D1,j) = newVal;
                end
            end
        end

        % Iteracion de filas:
        for i = D1-1:-1:1
            
            % Procesado especial para ultimo pixel de la linea:
            if mascara(i, D2)
                newVal = DIST(i, D2);
                newVal = min(newVal, DIST(i+1,   D2) + w1); % bottom pixel
                newVal = min(newVal, DIST(i+1, D2-1) + w2); % bottom-left diag
                if newVal~=DIST(i,D2)
                    modificar = true;
                    DIST(i,D2) = newVal;
                end
            end
            % Procesamiento para todos los pixeles dentro de la fila:
            for j=D2-1:-1:2
                % Computar solo para pixeles dentro de la estructura
                if ~mascara(i, j)
                    continue;
                end
                % Computar distancia minima:
                newVal = DIST(i, j);
                for k=1:4
                    newVal = min(newVal, DIST(i+di2(k), j+dj2(k))+ws(k));
                end
                % Si la distancia cambio actualizar y activar bandera:
                if newVal~=DIST(i,j)
                    modificar = true;
                    DIST(i,j) = newVal;
                end
            end
            % Procesado especial para primer pixel de la linea:
            if mascara(i, 1)
                newVal = DIST(i, 1);
                newVal = min(newVal, DIST(i,   2) + w1);  % right pixel
                newVal = min(newVal, DIST(i+1, 2) + w2);  % bottom-right pixel
                newVal = min(newVal, DIST(i+1, 1) + w1);  % bottom pixel
                if newVal~=DIST(i,1)
                    modificar = true;
                    DIST(i,1) = newVal;
                end
            end

        end % Iteracion de filas
        
        nIter = nIter+1;
        
    end % while modificar
    
end