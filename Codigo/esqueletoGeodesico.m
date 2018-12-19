function [ESQUELETO] = esqueletoGeodesico( ETIQUETAS, varargin )
%% DESCRIPCION:
    % Regresa el ESQUELETO de una figura utilizando distancias geodesicas
        % ETIQUETAS es la matriz de entrada con las partes de la imagen
    	% ESQUELETO es la matriz de salida con el esqueleto de la imagen
    	% GRAF grafica cada una de las intersecciones (Default = false)
        
%% Valor opcional de graficaci?n:
    numvarargs = length(varargin);
    if numvarargs > 1
        error('myfuns:somefun2Alt:TooManyInputs', 'requires at most one optional inputs');
    end
    optargs = {false}; % Default
    optargs(1:numvarargs) = varargin;
    [GRAF] = optargs{:};

%% Obtener centros de partes:
    N = max(max(ETIQUETAS));
    centros = zeros(N,2);
    for i = 1:N
        centros(i,:) = centroideGeodesico(ETIQUETAS==i);
    end
    centros = round(centros);
    
%% Obtener dilataciones de cada parte:
    SE = strel('disk',3);
    dilatadas = cell(1,N);
    for i = 1:N
        dilatadas{i} = imdilate(ETIQUETAS==i,SE);
    end
    
%% Obtener intersecciones:
    bin = ETIQUETAS > 0;
    ESQUELETO = false(size(bin));
    for i = 1:N
        for j = i+1:N
            interseccion = and(dilatadas{i},dilatadas{j});
            if (max(max(interseccion)) == 1)
                intprop = regionprops(interseccion,'Centroid');
                c = round(intprop.Centroid);
                trayectoriai = trayectoriaGeodesica(bin, c, centros(i,:),GRAF);
                ESQUELETO = or(trayectoriai,ESQUELETO);
                trayectoriaj = trayectoriaGeodesica(bin, c, centros(j,:),GRAF);
                ESQUELETO = or(trayectoriaj,ESQUELETO);
                if GRAF
                    figure
                        imshow(interseccion + bin + trayectoriai + trayectoriaj , [])
                        hold on
                        plot(c(1),c(2),'rd')
                        plot(centros(i,1),centros(i,2),'rd')
                        plot(centros(j,1),centros(j,2),'rd')
                end
            end
        end
    end
    
end