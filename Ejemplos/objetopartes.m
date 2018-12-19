%% Leer imagen y tratamiento de la imagen:
clc; clear all; close all;

A = rgb2gray(imread('../Imagenes/cuerpo1.bmp'));
A1 = not(im2bw(A,0.5));
A2 = not(im2bw(A,0.75));
A3 = and(not(A1),A2);
SE = strel('square',3);
extremidades = imerode(A1,SE);
extremidades = imdilate(extremidades,SE);
extremidades = imfill(extremidades,'holes');
torso = imerode(A3,SE);
torso = imdilate(torso,SE);
torso = imfill(torso,'holes');

%% Graficar extremidades y torso:

figure
    subplot(1,2,1)
        imshow(A)
    subplot(2,2,2)
        imshow(extremidades)
    subplot(2,2,4)
        imshow(torso)

%% Obtener etiquetado de partes:

[etiquetas,num] = bwlabel(extremidades);
etiquetas = etiquetas + torso*(num+1);

%% Graficar extremidades y torso:

figure
for i = 1:num+1
    subplot(2,3,i)
        imshow(etiquetas == i)
end