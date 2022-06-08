function ant_pheromone_trail

% this function is for the case where 15,000 ants enter into the system 


% the values of these variable are according to the paper "Adaptive growth process" 
w      = 50;   
%Width of the grid  
h      = 500;  
%Height of the grid
P  = zeros(w,h); %Pheromones
delta  = 0.1;  
%this is to prevent very weak trails from having a strong effect
ph    = 1;    
%Pheromone trails left by ant in each cells of the gird 
d      = 0.01; 
%deducted pheromone from every cell before an ant enters 
lambda = 2;   
R = 0; %Reward value
% the target is marked from 19 to 31 (12 sections)
target_Start   = 18;   
target_End   = 32;
%Probabilites
probs = zeros(3);
%Storing statics
sProbs   = 0;
stats= zeros(151,1); % for 15000 ants
%Probabilites to reach target cells (12 cells from 19 to 31)
stats(1) = 0.24; 


%stating the timer
tic 
% In this iterations 15,000 ants are going to enter the system 
for iterations = 1:15000
    %Decay pheromones after the ant leaves the cells 
    P = P.*(1 - 1/(495*R+5));
    %Subtracting d from every cell before the ant enters
    P = (P - d).*((P - d) > 0);
    %Ants starting from a random initial position to avoid the same results
    x = ceil(rand*w);

    % This for loop is for moving the ants in the system
    % step 1: Check the amount of Pheromones in the 3 nearest cells
    % step 2: Add delta (δ=0.1) to each of these three cells
    % Step 3: According to the probability distribution move to one of these cells
    % step 4:Add pheromone 1.0 to the previous travelled cell 

    for k = 1:h-1
        %Put some pheromone in the k=3 nearest position 
        % step 1+2 of the moving ants algoirthm  
        P(mod(x-2,w)+1,k+1)= P(mod(x-2,w)+1,k+1)+delta;
        P(x,k+1)= P(x,k+1)+delta;
        P(mod(x,w)+1,k+1)= P(mod(x,w)+1,k+1)+delta;
        
        %Moving ant using probability distribution  
        % step 3 of the moving ants algoirthm  
        probs(1)= P(mod(x-2,w)+1,k+1);
        probs(2)= P(x,k+1);
        probs(3)= P(mod(x,w)+1,k+1);  
        cumProb= cumsum(probs/sum(probs));
        rNum= rand;
        x = mod(x-(rNum < cumProb(1))+(rNum > cumProb(2))- 1, w)+1;
        %Putting pheromone to all the travelled cells by the ants, so that others can use this trail
        % step 4 of the moving ants algoirthm 
        P(x,k) = P(x,k) + ph;
    end
    
    %Reward function, once the anst hits the target, there is an increase
    %in the rate at which the ants enter the system 
    % Step 1 of the reward algoirthm
    S = (x > target_Start) && (x < target_End);
    sProbs = sProbs + S;
    %step 2 of the reward algoirthm
    R = R + (S-R)/lambda;
    % step 3 of the reward algoirthm
    if mod(iterations,100) == 0
        stats(iterations/100+1,1) = sProbs/100;
        sProbs = 0;
    end
end
toc % ending the timer


%Ploting Statics and Pheromone trails in the system
plot(0:100:15000,stats)
axis([0 15000 0 1])
stats(end,1)

maxP= max(max(P))
d= 1;
filteredP = P - (P - d).*(P > d);% filtering the Pheromone
figure
[exp,h] = contourf(filteredP);
daspect([2 1 1]) %data aspect ratio for the axes. hence length from 0 to 2 in the x-axis equals to the 
% lenghth from 0 to 1 in y-axis and from 0 tro 1 in Z-axis 
xlabel('Height','FontSize',14)
ylabel('Width' ,'FontSize',14)
title('Pheromone trails laid by the ants in system','FontSize',16)


