function InsertNewMouse(~,~)
    
    % load up mouse and site ids, and assign hash
    disp('Enter Animal Primary Key');
    mouse_tuple.animal_id = input('Animal_id: ');
    mouse_tuple.site_id = input('Site_id: ');
    hash_key = mouse_tuple;
    hash_key.table = 'mouse.Hash';
    mouse_tuple.hash = dj.lib.DataHash(hash_key);
    
    %load up filenames and stack data for each imaging session
    disp('Enter stacks in order of date of imaging');
    stackCheck =  input('Enter Stack Number  [or enter "done"]     ','s');

    while ~strcmp(stackCheck,'done') 
        if isnumeric(str2double(stackCheck)) && ~isempty(stackCheck)
            inputNum = str2double(stackCheck);
            [filename,path] = uigetfile;
            importFile = uiimport(fullfile(path,filename));
            try
                stack_tuple.stackfileName{inputNum} = filename;
                stack_tuple.stackData{inputNum} = importFile.stackData;
            catch ME
                if strcmp(ME.identifier,'MATLAB:nonExistentField')
                    disp(ME.message)
                    warning('Invalid File.  Selected file must be struct with fields fileName and stackData')
                else
                    disp(ME.message)
                end
                rethrow(ME)
            end
        else
            warning('Invalid Input')
        end
        stackCheck = input('Enter Stack Number  [or enter "done"]     ','s');
    end

    %display stacks as entered so user can check
    disp(stack_tuple.stackfileName);

    
    stack_tuple.numStacks = size(stack_tuple.stackfileName,2);
    stack_tuple.stackKey = randperm(stack_tuple.numStacks); 
    %figData.stackKey{i} gives the true position of that shuffled data
    
end