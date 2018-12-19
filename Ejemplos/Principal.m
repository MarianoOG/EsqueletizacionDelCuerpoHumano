%% Agrega funciones para que sean disponibles en este c?digo
clc; clear all; close all; addpath('../Codigo');

%% Leer y procesar imagenes:

% Leer imagen (cambiar nombre de la imagen si se quiere)
img = imread('Imagenes/cuerpo13.jpg');

% Convierte a escala de grises
if size(img,3) == 3
    gris = rgb2gray(img);
else
    gris = img;
end

% Preprocesamiento
SE = strel('disk',5);
bin = not(im2bw(gris,0.9));
bin = imdilate(bin,SE);
bin = imerode(bin,SE);
bin = imfill(bin,'holes');
bin = imerode(bin,SE);
bin = imdilate(bin,SE);
    
%% Separar de 2 en 2:

tic
[L] = descomponerFigura(bin,0.8);
esqueleto = esqueletoGeodesico(L);
t = toc;
disp(['Tiempo: ', num2str(t)])

%% Graficas:

figure
    imshow(img)
    title('Imagen original')
figure
    imshow(L,[])
    title('Etiquetado de partes aproximadamente convexas')
figure
    imshow(esqueleto+bin,[])
    title('Esqueleto sobre imagen binaria')