%Algoritmo utilizado para resolver o problema binário do Sudoku 9x9
%utilizando programação inteira com o solver nativo do matlab.

%Com o exemplo a ser resolvido em mãos, digite-o nas linhas abaixo no
%formato da tripla (linhas, colunas, dica).
%Por exemplo, se a tripla for B(2,5,8), significa que na linha 2, coluna 5,
%tem o número 8 como dica inicial.

% B =[2,5,8;
%     2,8,2;
%     3,6,7;
%     3,7,3;
%     3,9,4;
%     4,3,5;
%     4,9,9;
%     5,2,4;
%     5,3,9;
%     5,4,2;
%     6,2,3;
%     6,4,1;
%     6,7,8;
%     6,8,6;
%     7,1,5;
%     7,4,8;
%     7,5,2;
%     7,9,6;
%     8,2,9;
%     8,5,5;
%     8,8,1;
%     9,3,4;
%     9,5,1;
%     9,9,2];

%SUDOKU DIAGONAL:

% B =[1,3,6
%     1,8,5
%     2,1,2
%     2,3,1
%     3,4,7
%     3,8,1
%     3,9,4
%     4,7,4
%     6,3,9
%     7,1,5
%     7,2,7
%     7,6,2
%     8,7,2
%     8,9,9
%     9,2,1
%     9,7,3];

B =[1,3,8
    1,4,6
    1,8,1
    2,1,1
    2,3,2
    3,4,1
    3,5,8
    3,6,5
    3,8,6
    3,9,7
    4,3,6
    4,7,7
    4,9,9
    5,3,3
    5,7,1
    6,1,7
    6,3,5
    6,7,6
    7,1,3
    7,2,5
    7,4,9
    7,5,2
    7,6,4
    8,7,3
    8,9,1
    9,2,2
    9,6,3
    9,7,5];
    
flag = input('Para que seja computada a solução de um sudoku tradicional, digite 0.\nPara que seja computada a solução de um sudoku diagonal, digite 1: ');


%Invocada a função que plota o respectivo Sudoku inserido anteriormente.
drawSudoku(B,flag)

%Cria uma variável de otimização x binária 9x9x9
x = optimvar('x',9,9,9,'Type','integer','LowerBound',0,'UpperBound',1);

%Monta o problema de otimização cuja função objetivo é arbitrária.
sudpuzzle = optimproblem;
mul = ones(1,1,9);
mul = cumsum(mul,3);
sudpuzzle.Objective = sum(sum(sum(x,1),2).*mul);

%Monta as restrições nas quais a soma em cada dimensão da variável x é 1
sudpuzzle.Constraints.consx = sum(x,1) == 1;
sudpuzzle.Constraints.consy = sum(x,2) == 1;
sudpuzzle.Constraints.consz = sum(x,3) == 1;


%Monta a restrição do sudoku diagonal
if flag == 1
    sudpuzzle.Constraints.diag_principal = x(1,1,:) + x(2,2,:) + x(3,3,:) + x(4,4,:) + x(5,5,:) + x(6,6,:) + x(7,7,:) + x(8,8,:) + x(9,9,:) == 1;
    sudpuzzle.Constraints.diag_secundaria = x(9,1,:) + x(8,2,:) + x(7,3,:) + x(6,4,:) + x(5,5,:) + x(4,6,:) + x(3,7,:) + x(2,8,:) + x(1,9,:) == 1;
end

%Monta as restrições nas quais a soma das grades tem soma 1
majorg = optimconstr(3,3,9);
for u = 1:3
    for v = 1:3
        arr = x(3*(u-1)+1:3*(u-1)+3,3*(v-1)+1:3*(v-1)+3,:);
        majorg(u,v,:) = sum(sum(arr,1),2) == ones(1,1,9);
    end
end
sudpuzzle.Constraints.majorg = majorg;

%Inclui as dicas iniciais no vetor de solução
for u = 1:size(B,1)
    x.LowerBound(B(u,1),B(u,2),B(u,3)) = 1;
end

%Começa a contar o tempo
tic

%Resolve o problema de otimização
sudsoln = solve(sudpuzzle);

%Encerra a contagem do tempo
toc

%Arredonda todas as soluções para garantir que toda solução é inteira, caso
%a solução seja menor que a tolerância do solver.
sudsoln.x = round(sudsoln.x);

%Monta o sudoku S a partir da solução do problema de otimização.
y = ones(size(sudsoln.x));

for k = 2:9
    y(:,:,k) = k;
end

S = sudsoln.x.*y;
S = sum(S,3);

%Invocada a função que agora plota a resolução do Sudoku inserido
%inicialmente.
drawSudoku(S,flag)
