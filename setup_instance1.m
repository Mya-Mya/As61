function i1 = setup_instance1
global OPERATIONS
    
i1.N = 6;
operation_index_s = [2 3 4 1 4 3];
i1.operation_s = [];
for i=1:i1.N
    o = OPERATIONS(operation_index_s(i));
    i1.operation_s = [i1.operation_s o];
end
i1.dinit_s = [120 150 167 180 207 226];
end