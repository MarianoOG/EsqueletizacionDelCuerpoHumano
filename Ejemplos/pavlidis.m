%% DESCRIPCION:
% Esqueletizacion por adelgazamientos iterativos, Algorithmo Pavlidis.
clc; clear all; close all; addpath('../Codigo');

%% Plantillas:

Plantillas(:,:,1) = [-3 -3 -3;  0  1  0; -2 -2 -2];
Plantillas(:,:,2) = [-3  0 -2; -3  1 -2; -3  0 -2];
Plantillas(:,:,3) = [-2 -2 -2;  0  1  0; -3 -3 -3];
Plantillas(:,:,4) = [-2  0 -3; -2  1 -3; -2  0 -3];
Plantillas(:,:,5) = [-3 -3 -3; -3  1  0; -3  0  2];
Plantillas(:,:,6) = [-3  0  2; -3  1  0; -3 -3 -3];
Plantillas(:,:,7) = [ 2  0 -3;  0  1 -3; -3 -3 -3];
Plantillas(:,:,8) = [-3 -3 -3;  0  1 -3;  2  0 -3];
Plantillas(:,:,9) = [-3 -3 -3; -3  1  0; -3  0  1];
Plantillas(:,:,10) = [-3  0  1; -3  1  0; -3 -3 -3];
Plantillas(:,:,11) = [ 1  0 -3;  0  1 -3; -3 -3 -3];
Plantillas(:,:,12) = [-3 -3 -3;  0  1 -3;  1  0 -3];

%% Obtencion de imagen y preprocesado:

imagen = rgb2gray(imread('Imagenes/figura2.png'));
bin = im2bw(imagen,0.98);
SE = strel('square',5);
bin = imerode(bin,SE);
bin = imdilate(bin,SE);
bin = not(bin);
[x,y] = size(bin);
a = x+2;
b = y+2;
img = zeros(a,b);
img(2:x+1,2:y+1) = double(bin);

%% Adelgazaimiento de la imagen:

% Iniciar variables:
REMAIN = 1; % Se usa para denotar la existencia de pixeles esqueletales
SKEL = 0; % Se usa cuando alguna vecindad de un pixel es similar a alguna de las plantillas

% Iteraciones:
while(REMAIN == 1)
    REMAIN = 0;
    for k = 1:4   % Vecinos 
        for i = 2:a-1
            for j = 2:b-1
                if k==1
                    vecino = img(i,j+1);
                elseif k==2
                    vecino = img(i-1,j);
                elseif k==3
                    vecino = img(i,j-1);
                elseif k==4
                    vecino = img(i+1,j);
                else
                    vecino = 0;
                end
                if vecino == 0 && img(i,j)==1
                    SKEL = compararMatrizPlantillas(img(i-1:i+1,j-1:j+1),Plantillas); % Compara si se asemeja a la plantilla
                    if SKEL == 1
                        img(i,j) = 2;
                    else
                        img(i,j) = 3;
                        REMAIN = 1;
                    end
                end
            end
        end
        for i=1:a
            for j=1:b
                if img(i,j)==3
                    img(i,j)=0;
                end
            end
        end
    end
end
img = img(2:x+1,2:y+1);

%% Graficas:

figure
    subplot(1,3,1)
        imshow(imagen)
        title('Imagen Original')
        text(0,a+10,{'Aspecto de la pata posterior del raton de campo'})
    subplot(1,3,2)
        imshow(bin)
        title('Imagen Binarizada')
    subplot(1,3,3)
        imshow(img)
        title('Imagen Esqueletizada')