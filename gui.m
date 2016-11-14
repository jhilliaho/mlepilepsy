% GUI TODO:
% Clear network weights
% Edit training function

function gui
    close all
    object_to_save = [];
    network_object = [];
    training_target_data = [];
    training_input_data = [];
    test_target_data = [];
    test_input_data = [];
    
    % Create the GUI window
    f = figure('Visible','off', 'Resize','off', 'Position',[0,0,600,400]); f.Name = 'Prediction and detection of epileptic seizures';
    movegui(f, 'northwest')

    % Create GUI item
    left_panel = uipanel('Title','Testing and training','FontSize',16,'Position',[0.02 0.02 0.45 0.98]);
    right_panel = uipanel('Title','Results','FontSize',16,'Position',[0.53 0.02 0.45 0.98]);
    
    save_network_button       = uicontrol(left_panel,'Position',[170,345,75,25],'Style','pushbutton','String','Save network','Callback',@save_network_button_callback);
    create_network_button     = uicontrol(left_panel,'Position',[10,345,75,25],'Style','pushbutton','String','Create network','Callback',@create_network_button_callback);
    view_network_button       = uicontrol(left_panel,'Position',[90,345,75,25],'Style','pushbutton','String','View network','Callback',@view_network_button_callback);
    
    select_network_text       = uicontrol(left_panel,'Position',[10,320,200,25],'Style','text','String','Select the network:','HorizontalAlignment','left');  
    select_network            = uicontrol(left_panel,'Position',[10,300,200,25],'Style','popupmenu','String',{'', 'NN1','NN2','NN3'},'HorizontalAlignment','left','Callback',@select_network_callback);
    network_name_text         = uicontrol(left_panel,'Position',[10,280,200,25],'Style','text','String','Name:','HorizontalAlignment','left');  
    select_training_data_text = uicontrol(left_panel,'Position',[10,240,200,25],'Style','text','String','Select training data','HorizontalAlignment','left');  
    select_training_data      = uicontrol(left_panel,'Position',[10,220,200,25],'Style','popupmenu', 'String',{'', 'NN1','NN2','NN3'},'HorizontalAlignment','left','Callback',@select_training_data_callback);
    train_network_button      = uicontrol(left_panel,'Position',[10,200,75,25],'Style','pushbutton','String','Train network','Callback',@train_network_button_callback);
    select_test_data_text     = uicontrol(left_panel,'Position',[10,140,200,25],'Style','text','String','Select test data','HorizontalAlignment','left');  
    select_test_data          = uicontrol(left_panel,'Position',[10,120,200,25],'Style','popupmenu','String',{'', 'NN1','NN2','NN3'},'HorizontalAlignment','left','Callback',@select_test_data_callback);
    test_network_button       = uicontrol(left_panel,'Position',[10,100,75,25],'Style','pushbutton','String','Test network','Callback',@test_network_button_callback);
    error_text                = uicontrol(left_panel,'Position',[10,0,100,80],'ForegroundColor', 'red', 'Style','text','String','','HorizontalAlignment','left');

    specificity_text  = uicontrol(right_panel,'Position',[10,300,200,25],'Style','text','String','Specificity:','HorizontalAlignment','left');  
    specificity_value = uicontrol(right_panel,'Position',[70,300,200,25],'Style','text','String','','HorizontalAlignment','left');  
    sensitivity_text  = uicontrol(right_panel,'Position',[10,280,200,25],'Style','text','String','Sensitivity:','HorizontalAlignment','left');  
    sensitivity_value = uicontrol(right_panel,'Position',[70,280,200,25],'Style','text','String','','HorizontalAlignment','left');  
    f_text            = uicontrol(right_panel,'Position',[10,260,200,25],'Style','text','String','F-value:','HorizontalAlignment','left');  
    f_value           = uicontrol(right_panel,'Position',[70,260,200,25],'Style','text','String','','HorizontalAlignment','left');  
    t_p_text          = uicontrol(right_panel,'Position',[130,300,200,25],'Style','text','String','True positives:','HorizontalAlignment','left');  
    t_p_value         = uicontrol(right_panel,'Position',[220,300,200,25],'Style','text','String','','HorizontalAlignment','left');  
    t_n_text          = uicontrol(right_panel,'Position',[130,280,200,25],'Style','text','String','True negatives:','HorizontalAlignment','left');  
    t_n_value         = uicontrol(right_panel,'Position',[220,280,200,25],'Style','text','String','','HorizontalAlignment','left');  
    f_p_text          = uicontrol(right_panel,'Position',[130,260,200,25],'Style','text','String','False positives:','HorizontalAlignment','left');  
    f_p_value         = uicontrol(right_panel,'Position',[220,260,200,25],'Style','text','String','','HorizontalAlignment','left');  
    f_n_text          = uicontrol(right_panel,'Position',[130,240,200,25],'Style','text','String','False negatives:','HorizontalAlignment','left');  
    f_n_value         = uicontrol(right_panel,'Position',[220,240,200,25],'Style','text','String','','HorizontalAlignment','left');  
    result_text       = uicontrol(right_panel,'Position',[10,200,200,35],'Style','text','String','Green: Result, Red: Target','HorizontalAlignment','left');  
    result_plot       = axes(right_panel, 'Units','Pixels','Position',[20,20,230,150],'YLim',[-0.2 1.2]); 

    
    f.Visible = 'on';

    get_network_list();
    get_training_data_list();
    get_test_data_list();
    
    select_network_callback(select_network);
    select_training_data_callback(select_training_data);
    select_test_data_callback(select_test_data);
    
%%%% GUI CALLBACKS %%%%
    function select_network_callback(source,eventdata)
        disp('Select network');
        try
            filename = source.String{source.Value};
            network_name = strsplit(filename, '.');
            network_name = char(network_name(1));
            path = strcat(['networks/' filename]);
            loaded = load(path);
            network_object = loaded.(network_name);
            network_name_text.String = ['Description: ' char(network_object.name)];
        catch ME
            print_error(ME);
        end
    end

    function select_training_data_callback(source,eventdata)
        disp('Select training data');
        try
            filename = source.String{source.Value};
            data_name = strsplit(filename, '.');
            data_name = char(data_name(1));
            path = strcat(['data/' filename]);
            loaded = load(path);
            training_target_data = loaded.(data_name);

            input_data_name = strsplit(data_name, 'trg');
            input_data_name = strcat([char(input_data_name(1)) 'input']);
            input_data_path = strcat(['data/' input_data_name '.mat']);
            loaded = load(input_data_path);
            training_input_data = loaded.(input_data_name);
            
        catch ME
            print_error(ME);
        end
    end

    function select_test_data_callback(source,eventdata)
        disp('Select test data');
        try
            filename = source.String{source.Value};
            data_name = strsplit(filename, '.');
            data_name = char(data_name(1));
            path = strcat(['data/' filename])
            loaded = load(path);
            test_target_data = loaded.(data_name);

            input_data_name = strsplit(data_name, 'trg');
            input_data_name = strcat([char(input_data_name(1)) 'input']);
            input_data_path = strcat(['data/' input_data_name '.mat']);
            loaded = load(input_data_path);
            test_input_data = loaded.(input_data_name);
        catch ME
            print_error(ME);
        end
    end

%%%% OTHER FUNCTIONS %%%%
   
    function get_training_data_list()
        disp('Get training data list');
        try
            names = {};
            list = dir(fullfile('data/', 'train*trg*.mat'));
            file_count   = length(list);
            for k = 1:file_count
                file = list(k).name;
                names{k} = file;
            end
            select_training_data.String = names;
        catch ME
            print_error(ME);
        end
    end
    
    function get_test_data_list()
        disp('Get test data list');
        try
            names = {};
            list = dir(fullfile('data/', 'test*trg*.mat'));
            file_count   = length(list);
            for k = 1:file_count
                file = list(k).name;
                names{k} = file;
            end
            select_test_data.String = names;
        catch ME
            print_error(ME);
        end
    end

    function get_network_list()
        disp('Get network list');
        try
            names = {};
            list = dir(fullfile('networks/', '*.mat'));
            file_count   = length(list);
            for k = 1:file_count
                file = list(k).name;
                names{k} = file;
            end
            select_network.String = names;
        catch ME
            print_error(ME);
        end
    end

    function print_error(exception)
        disp(exception);
        %error_text.String = getReport(exception);
    end

%%%% NEURAL NETWORK FUNCTIONS %%%%

    function train_network_button_callback(source,eventdata)        
        disp('Train network');
        try
            network_object = configure(network_object, training_input_data, training_target_data);
            network_object = init(network_object);
            network_object = train(network_object, training_input_data, training_target_data);
        catch ME
            error_text.String = getReport(ME)
        end
        disp('Network trained');
    end

    function test_network_button_callback(source,eventdata)
        disp('Test network');
        try
            test_input_data;
            result = network_object(test_input_data);
            %qu90 = quantile(result, 0.9)
            %qu_result = result - (qu90 - 0.5);
            round_result = round(result);
            
            if max(test_target_data) ~= 1 || min(test_target_data) ~= 0
                disp('Something wrong with target data');
            end
            
            [se, sp, f, t_p, t_n, f_p, f_n, fts, ffs, nfs] = calculate_performance(round_result, test_target_data);
            specificity_value.String = sp;
            sensitivity_value.String = se;
            f_value.String = f;
            t_p_value.String = t_p;
            t_n_value.String = t_n;
            f_p_value.String = f_p;
            f_n_value.String = f_n;
            cla
            hold on
            plot(result,'g');
            plot(test_target_data,'r');
        catch ME
            print_error(ME);
        end
        disp('Network tested');
    end

    function create_network_button_callback(source,eventdata)
        [net, name] = create_network();
        network_object = net;
        object_to_save.(name) = network_object;
        save(strcat(['networks/' name]), '-struct', 'object_to_save')
        get_network_list();
        index = find(strcmp(select_network.String, strcat([name '.mat'])))
        select_network.Value = index;
    end

    function save_network_button_callback(source,eventdata)
        disp('Save the network data');
        
        old_filename = select_network.String{select_network.Value};
        old_network_name = strsplit(old_filename, '.');
        old_network_name = char(old_network_name(1));

        prompt = {'Enter new file name:'};
        dlg_title = 'Input';
        num_lines = 1;
        new_name = inputdlg(prompt,dlg_title,num_lines)
        
        if isempty(new_name)
            return;
        else
            new_name_str = char(new_name{1});
            object_to_save.(new_name_str) = network_object;
            save(strcat(['networks/' new_name_str]), '-struct', 'object_to_save')
        end
    end
    function view_network_button_callback(source,eventdata)
        view(network_object)
    end
end