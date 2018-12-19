%% Lectura de imagen y preprocesamiento:
clc; clear all; close all;

imagen = imread('../Imagenes/cuerpo1.bmp');
bin = im2bw(imagen,0.98);
SE = strel('square',5);
bin = imerode(bin,SE);
bin = imdilate(bin,SE);
bin = not(bin);
bin = imfill(bin, 'holes');

%% Esqueleto y fontera:

skel = bwmorph(bin,'skel',inf);
frontera = edge(bin,'canny');

%% Graficas:

figure
    subplot(2,2,1)
        imshow(imagen)
        title('Imagen original')
    subplot(2,2,2)
        imshow(bin)
        title('Imagen binaria')
    subplot(2,2,3)
        imshow(skel);
        title('Esqueleto')
    subplot(2,2,4)
        imshow(frontera+skel);
        title('Frontera + squeleto')