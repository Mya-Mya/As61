setup;
inst = setup_instance1;
c = AdditionalConstraints(inst.N);
a = Advisor(inst.operation_s, inst.dinit_s);

%%

disp("◆Flights:")
display_instance(inst)
disp(newline)

disp("◆Arrivaltime in CDO Policy:")
[t_cdo_s, dt_cdo_s] = a.calc_cdo_policy;
for i=1:a.N
    disp(string(i)+"."+a.name_s(i)+": "+string(t_cdo_s(i)))
    if i~=a.N
        dt = dt_cdo_s(i);
        warn_message = "";
        if dt<legal_tmin
            warn_message = "(!!)";
        end
        disp("△"+newline+"□ "+string(dt)+warn_message+newline+"▽")
    end
end
disp(newline)

%%

quit_flag = false;
prompt = "";
loop_count = 1;
r = [];

while ~quit_flag
    disp("Loop "+string(loop_count)+newline)
    disp("◆Additional Constraints:")
    disp(c)
    disp(newline)

    disp("◆Optimal Inputs:")
    r_before = r;
    r = a.optimize_u(c);
%%
    draw_optimize_result2( ...
        "Loop"+num2str(loop_count)+":"+prompt, a,c,r,r_before);
%%
    for i=1:a.N
        disp(string(i)+"."+a.name_s(i)+": "+ ...
            "t="+string(r.t_opt_s(i))+" "+ ...
            "h1="+string(r.h1_s(i))+" "+ ...
            "h2="+string(r.h2_s(i))+" "...
        )
        if i~=a.N
            dt = r.dt_opt_s(i);
            warn_message = "";
            if dt<legal_tmin
                warn_message = "(!!)";
            end
            disp("△"+newline+"□ "+string(dt)+warn_message+newline+"▽")
        end
    end

    updated = false;
    while true
        prompt = input("◆Type Prompt: ","s");
        quit_flag = strcmp(prompt,"quit");
        if quit_flag
            disp("◆Quit")
            break
        else
            [c,message,updated] = Interpreter1(prompt,c);
            disp("◆Message:")
            disp(message)
            if updated
                break
            end
        end
    end
    
    loop_count = loop_count+1;
end