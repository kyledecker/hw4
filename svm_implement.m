% Hard-margin SVM

%% Load data
load('fisheriris.mat')
x = meas(1:100,:);
y = zeros(100,1);
y(1:50) = 1;
y(51:end) = -1;

%% Random Permutation then split into tranining and testing
rand_index = randperm(size(y,1));
x_shuffle = x(rand_index,:);
y_shuffle = y(rand_index);

train_size = 9*round(size(y,1)/10);
x_train = x_shuffle(1:train_size,:);
x_test = x_shuffle(train_size+1:end,:);
y_train = y_shuffle(1:train_size);
y_test = y_shuffle(train_size+1:end);

%% Set up Solver
n = size(x_train,1);
for i = 1:n
    for j = 1:n
        X(i,j) = x_train(i,:)*x_train(j,:)';
    end
end

Y = y_train*y_train';
I = eye(n);
zero = zeros(1,n);
D = Y.*X;

%% Solve for alpha
H = D;
f = ones(size(zero));
A = I;
b = zero;
Aeq = Y;
beq = zero;
lb = zero;
ub = f*10;
alpha = quadprog(H,-f,-A,b,Aeq,beq);

%% SVM
sv_index = alpha>1e-5;
sv_index1 = find(sv_index);
alpha = alpha.*sv_index;

lambda = zeros(1,size(x_train,2));
for i = 1:size(y_train,1)
    lambda = lambda + (alpha(i)*y_train(i)*x_train(i,:));
end
lambda_0 = 1 - lambda*x_train(sv_index1(1),:)';


%% Predict
y_pred = (lambda*x_test' + lambda_0)';
index = y_pred>0;
y_pred(index) = 1;
index = y_pred<0;
y_pred(index) = -1;