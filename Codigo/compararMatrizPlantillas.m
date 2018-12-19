function [y] = compararMatrizPlantillas(Matriz, Plantillas)
% Funcion que se encarga de comparar si es que una matriz pertenece a la estructura de una plantilla 
% retorna 1 o 0 correspondiendo a true o false
    y = 0;
    [a,b,c] = size(Plantillas);
    for k = 1:c
        A = 0;
        B = 0;
        n = 0;
        for i=1:a
            for j=1:b
                if Plantillas(i,j,k)==-3 && Matriz(i,j)~=0
                    A = A + 1;
                end
                if Plantillas(i,j,k)==-2 && Matriz(i,j)~=0
                    B = B + 1;
                end
                if Plantillas(i,j,k) == Matriz(i,j)
                    n = n + 1;          
                end
            end
        end
        if (A>0 && (n == 3 && B>0 || n == 4 ))
            y = 1; % Retorna que si coinciden los tipos
            break;
        end
    end
end