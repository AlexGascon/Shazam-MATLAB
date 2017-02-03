function show_landmarks(L, S, maxes, T)

%% show_landmarks(L, S, maxes, T)
%
% @author: Alex Gascon
% 
% Function used as a complement for find_landmarks. It gets the outputs of
% that function as inputs, and represents them graphically. This way, we
% can test if the maxes have been found and paired correctly.

%We begin plotting the spectrogram. We will also make it fullscreen
figure('units','normalized','outerposition',[0 0 1 1])
pcolor(S); shading('interp');
hold on; 

%Now, we'll draw the points representing the maxes coordinates
%scatter(maxes(:,1), maxes(:,2), 75, 'filled', 'MarkerFaceColor', [0.8, 0.8, 0.8],...
%    'LineWidth', 2, 'MarkerEdgeColor', [0 0 0]);
scatter(L(:,1), L(:,2), 75, 'filled', 'MarkerFaceColor', [0.8, 0.8, 0.8],...
    'LineWidth', 2, 'MarkerEdgeColor', [0 0 0]);


%And finally, we'll plot the lines between them
for i = 1:length(L)
   
    %We store the values in variables in order to make our code more
    %legible
    x0 = L(i,1);
    x1 = L(i,1)+L(i,4);
    y0 = L(i,2);
    y1 = L(i,2)+L(i,3);
   
    %We plot a line for each landmark
    line([x0, x1], [y0, y1], 'LineWidth', 2, 'Color', [0 0 0]);
end
    