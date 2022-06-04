function [mean_base,std_base] = load_base_new(Data)
%% load baseline
mean_base=[];
std_base=[];
rules=Data.Behavior.RuleEvents;
for i=2:length(rules(1,:))
    if (rules{11,1}=="reward") && (~isempty(rules{11,i})) && (rules{10,1}=="current state") && (rules{10,i}==0)
        mean_base=[mean_base [rules{end,i}(1);rules{end,i}(9)]];
        std_base=[std_base [rules{end,i}(2);rules{end,i}(10)]];
    end
    if isempty(rules{11,i}); break; end
end
end

