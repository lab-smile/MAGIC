thresholds = (1:70)/100;
averageDices = zeros(1, length(thresholds));
medianDices = zeros(1, length(thresholds));

for i=1:70
   [avgDice, medDice] = generate_dice('../../data/aug_inference_results', i/100);
   averageDices(i) = avgDice; medianDices(i) = medDice;
   %display(strcat(num2str(i/100),': ', num2str(tempDice)))
end

scatter(thresholds, averageDices);
xlabel('Thresholds');
ylabel('Average Dice');
scatter(thresholds, medianDices);
xlabel('Thresholds');
ylabel('Median Dice');