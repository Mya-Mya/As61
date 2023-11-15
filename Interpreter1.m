function [new_c,message,updated] = Interpreter1(prompt,c)
arguments
    prompt string
    c AdditionalConstraints
end
message = "Did not understand the prompt.";
new_c = c;
updated = false;

hquery_pattern = "(lower|raise) the (min|max) height of (ip1|ip2) on the flight (\d*)";
[mat,tok,~] = regexp(prompt, hquery_pattern, "match", "tokens");
if ~isempty(mat)
    % H-Query

    index = str2num(tok{1}(4));
    delta = 0;
    operation = tok{1}(1);
    if strcmp(operation,"lower")
        delta = -1000;
    elseif strcmp(operation,"raise")
        delta = +1000;
    end

    boundary_type = tok{1}(2);
    ip_type = tok{1}(3);
    if strcmp(boundary_type,"min")
        if strcmp(ip_type,"ip1")
            newvalue = max(0,c.delta_h1_min_s(index)+delta);
            new_c.delta_h1_min_s(index) = newvalue;
        elseif strcmp(ip_type,"ip2")
            newvalue = max(0,c.delta_h2_min_s(index)+delta);
            new_c.delta_h2_min_s(index) = newvalue;
        end
    elseif strcmp(boundary_type,"max")
        if strcmp(ip_type,"ip1")
            newvalue = min(0,c.delta_h1_max_s(index)+delta);
            new_c.delta_h1_max_s(index) = newvalue;
        elseif strcmp(ip_type,"ip2")
            newvalue = min(0,c.delta_h2_max_s(index)+delta);
            new_c.delta_h2_max_s(index) = newvalue;                
        end
    end

    message = "Updated an additional height range constraint.";
    updated = true;

    return
end

tquery_pattern = "(increase|decrease) the gap between the flight (\d*) and the (next|previous) one";
[mat,tok,~] = regexp(prompt, tquery_pattern, "match", "tokens");
if ~isempty(mat)
    % T-Query
    direction = tok{1}(1);
    referring = str2num(tok{1}(2));
    comparator = tok{1}(3);

    i = referring;
    if strcmp(comparator,"next")
        i = referring;
    elseif strcmp(comparator,"previous")
        i = referring - 1;
    end

    delta = 0;
    if strcmp(direction,"increase")
        delta = +5;
    elseif strcmp(direction,"decrease")
        delta = -5;
    end

    if 1<=i && i<= length(c.deltatmin_s)
        new_c.deltatmin_s(i) = max(0, c.deltatmin_s(i)+delta);
        message = "Updated an additional arrivaltime gap.";
        updated = true;
    end
    
    return
end



end