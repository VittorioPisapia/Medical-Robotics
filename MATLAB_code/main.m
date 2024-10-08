close all
clear all
clc

sim=remApi('remoteApi'); % using the prototype file (remoteApiProto.m)
sim.simxFinish(-1); % just in case, close all opened connections
clientID=sim.simxStart('127.0.0.1',19997,true,true,5000,5);

if (clientID>-1)
    sim.simxSynchronous(clientID,true)
    sim.simxStartSimulation(clientID,sim.simx_opmode_blocking)
    disp('Connected to remote API server');
    sim.simxSynchronousTrigger(clientID);
    pause(0.1)
    
    %JointHandles
    h=zeros(1,6);
    [r,h(1)]=sim.simxGetObjectHandle(clientID,'Franka_joint1',sim.simx_opmode_blocking);
    [r,h(2)]=sim.simxGetObjectHandle(clientID,'Franka_joint2',sim.simx_opmode_blocking);
    [r,h(3)]=sim.simxGetObjectHandle(clientID,'Franka_joint3',sim.simx_opmode_blocking);
    [r,h(4)]=sim.simxGetObjectHandle(clientID,'Franka_joint4',sim.simx_opmode_blocking);
    [r,h(5)]=sim.simxGetObjectHandle(clientID,'Franka_joint5',sim.simx_opmode_blocking);
    [r,h(6)]=sim.simxGetObjectHandle(clientID,'Franka_joint6',sim.simx_opmode_blocking);
    [r,h(7)]=sim.simxGetObjectHandle(clientID,'Franka_joint7',sim.simx_opmode_blocking);
    [r,ForceSensor]=sim.simxGetObjectHandle(clientID,'Franka_connection',sim.simx_opmode_blocking);

    %GlobalVariables inizialitazion
    global dx dy dz d ForceZ flag_doing_echo phi rd echo_value
    dx = 0;
    dy = 0;
    dz = 0;
    d = 0.05;
    ForceZ = 0;
    phi = 0;
    rd = zeros(6,1);
    flag_doing_echo = false;
    echo_value = 0;
    
    SAFETY_VALUE = 7; % Max jump corresponds to 15N
    threshold = 0.17;

    %% GUI
    fig = uifigure("Name", "Controller", "Position", [100, 100, 900, 500]);

    %%% gains =================================================================
    gain = uipanel(fig, "Title","Gains", "Position",[500, 150, 380, 350]);
    label_K_x = uilabel(gain, "Position", [10, 280, 100 , 22], "Text", "Gain over Kx");
    ef_gainK_x = uieditfield(gain,"numeric", "Position", [10, 250, 50, 22], "Limits", [0, 1000], "Value", 250);
    label_K_y = uilabel(gain, "Position",[10, 220, 100 , 22], "Text", "Gain over Ky");
    ef_gainK_y = uieditfield(gain,"numeric", "Position", [10, 190, 50, 22], "Limits", [0, 1000], "Value", 250);
    label_K_z = uilabel(gain, "Position",[10, 160, 100 , 22], "Text", "Gain over Kz");
    ef_gainK_z = uieditfield(gain, "numeric", "Position", [10, 130, 50, 22], "Limits", [0, 1000], "Value", 75);
    label_K_theta = uilabel(gain, "Position",[10, 100, 100 , 22], "Text", "Gain over Ktheta");
    ef_gainK_theta = uieditfield(gain, "numeric", "Position", [10, 70, 50, 22], "Limits", [0, 1000], "Value", 45);
    label_K_link4pos = uilabel(gain, "Position",[10, 40, 100 , 22], "Text", "Gain over K_link4");
    ef_gainK_link4pos = uieditfield(gain, "numeric", "Position", [10, 10, 50, 22], "Limits", [0, 1000], "Value", 250);
    
    label_D_x = uilabel(gain, "Position",[180, 280, 100 , 22], "Text", "Gain over Dx");
    ef_gainD_x = uieditfield(gain, "numeric", "Position", [180, 250, 50, 22], "Limits", [0, 1000], "Value", 500);
    label_D_y = uilabel(gain, "Position",[180, 220, 100 , 22], "Text", "Gain over Dy");
    ef_gainD_y = uieditfield(gain, "numeric", "Position", [180, 190, 50, 22], "Limits", [0, 1000], "Value", 500);
    label_D_z = uilabel(gain, "Position",[180, 160, 100 , 22], "Text", "Gain over Dz");
    ef_gainD_z = uieditfield(gain, "numeric", "Position", [180, 130, 50, 22], "Limits", [0, 1000], "Value", 500);
    label_D_theta = uilabel(gain, "Position",[180, 100, 100 , 22], "Text", "Gain over Dtheta");
    ef_gainD_theta = uieditfield(gain, "numeric", "Position", [180, 70, 50, 22], "Limits", [0, 1000], "Value", 20);
    label_D_link4pos = uilabel(gain, "Position",[180, 40, 100 , 22], "Text", "Gain over D_link4");
    ef_gainD_link4pos = uieditfield(gain, "numeric", "Position", [180, 10, 50, 22], "Limits", [0, 1000], "Value", 650);
    
    label_Dq = uilabel(gain, "Position",[300, 280, 100 , 22], "Text", "Gain over Dq");
    ef_gainDq = uieditfield(gain, "numeric", "Position", [300, 250, 50, 22], "Limits", [0, 600], "Value", 8);
    
    label_K_phi = uilabel(gain, "Position",[300, 220, 100 , 22], "Text", "Gain Kphi");
    ef_gainK_phi = uieditfield(gain, "numeric", "Position", [300, 190, 50, 22], "Limits", [0, 1000], "Value", 1);  
    label_D_phi = uilabel(gain, "Position",[300, 160, 100 , 22], "Text", "Gain Dphi");
    ef_gainD_phi = uieditfield(gain, "numeric", "Position", [300, 130, 50, 22], "Limits", [0, 1000], "Value", 1);

    label_d = uilabel(fig, "Position",[420, 320, 100 , 22], "Text", "0.01");
    label_d_name = uilabel(fig, "Position",[300, 320, 100 , 22], "Text", "Slider Magnitude:");
    slider_d = uislider(fig, "Position", [300, 100, 200, 3], "Limits", [0.001, 0.1],"Value", 0.01, "ValueChangedFcn",@(slider_d,event)updateLabel(slider_d,label_d), "Orientation", "vertical");

    label_theta = uilabel(fig, "Position",[500, 100, 100 , 22], "Text", "3.14");
    label_theta_name = uilabel(fig, "Position",[400, 100, 100 , 22], "Text", "Theta Angle:");
    slider_theta = uislider(fig, "Position", [550, 100, 200, 3], "Limits", [pi-deg2rad(30), pi],"Value", pi, "ValueChangedFcn",@(slider_theta,event)updateLabel(slider_theta,label_theta));
    
    label_phi = uilabel(fig, "Position",[500, 40, 100 , 22], "Text", "0.00");
    label_phi_name = uilabel(fig, "Position",[400, 40, 100 , 22], "Text", "Phi Angle:");
    slider_phi = uislider(fig, "Position", [550, 40, 200, 3], "Limits", [-pi+deg2rad(25), pi-deg2rad(25)],"Value", 0.00, "ValueChangedFcn",@(slider_phi,event)updateLabel(slider_phi,label_phi));
    
    label_echo_force = uilabel(fig, "Position",[100, 60, 100 , 22], "Text", "Echo Value");
    ef_echo_force = uieditfield(fig, "numeric", "Position", [100, 30, 50, 22], "Limits", [0, 10], "Value", 5);

    bg = uibuttongroup(fig, "Title","Tools", "Position",[10, 400, 450, 100]);
    check_xy = uiradiobutton(bg, "Text","Plane XY", "Position",[10, 10, 150, 25], "Value", true); 
    check_xz = uiradiobutton(bg, "Text","Plane XZ", "Position",[10, 40, 150, 25]); 
    button_home = uibutton(bg, "Position", [200, 40, 75, 25], "Text", "HOME", "ButtonPushedFcn", @(button_home, event)updateBtn_Home(slider_theta,label_theta,slider_phi,label_phi,slider_d,label_d,ef_gainK_x,ef_gainK_y,ef_gainK_z,ef_gainK_theta,ef_gainK_link4pos,ef_gainD_x,ef_gainD_y,ef_gainD_z,ef_gainD_theta,ef_gainD_link4pos,ef_gainDq,check_xy,ef_gainK_phi,ef_gainD_phi,ef_echo_force));
    button_trajectory = uibutton(bg, "Position", [290, 10, 155, 25], "Text", "EXECUTE TRAJECTORY 1", "ButtonPushedFcn", @(button_trajectory, event)trajectory_button_1(clientID,sim, button_trajectory));
    button_trajectory_2 = uibutton(bg, "Position", [290, 40, 155, 25], "Text", "EXECUTE TRAJECTORY 2", "ButtonPushedFcn", @(button_trajectory_2, event)trajectory_button_2(clientID,sim, button_trajectory_2));
    button_echo = uibutton(bg, "Position", [200, 10, 75, 25], "Text", "ECHO", "ButtonPushedFcn", @(button_echo, event)updateBtn_Echo(button_trajectory));
    
    button_up = uibutton(fig, "Position", [100, 300, 50, 50], "Text", "UP", "ButtonPushedFcn", @(button_up, event)updateBtn_Up(check_xy));
    button_down = uibutton(fig, "Position", [100, 100, 50, 50], "Text", "DOWN", "ButtonPushedFcn", @(button_down, event)updateBtn_Down(check_xy, SAFETY_VALUE));
    button_left = uibutton(fig, "Position", [50, 200, 50, 50], "Text", "LEFT", "ButtonPushedFcn", @(button_left, event)updateBtn_Left());
    button_right = uibutton(fig, "Position", [150, 200, 50, 50], "Text", "RIGHT", "ButtonPushedFcn", @(button_right, event)updateBtn_Right());

    %% INITIALIZATION

    button_trajectory.Enable = false;
    button_trajectory_2.Enable = false;
    %%%%%%%%%%%
    Dq=eye(7)*5;     
    Dr=eye(6);
    K=eye(6);
    qp=zeros(7,1); 
    dq=zeros(7);
    dqp=zeros(7);   
    Jp=zeros(6,7);
    dt=0.05;
    e=[0,0,0,0,0,0];
    u=zeros(7,1);

    %CONTROLLER INIZIALIZATION
    try
        joy = vrjoystick(1);
        controller_check = 1;
    catch
        controller_check = 0;
    end

    %%%%%%%%%%%
    %start position
    rs=[+0.42425; -0.00701; +0.83639;pi;+0.64828;0];
    rd=rs;
    
    dr=[0;0;0;0;0;0];
    rp=[0;0;0;0;0;0];

    %% FLUSH THE BUFFER

    for i=1:7
        	[r,qn(i)]=sim.simxGetJointPosition(clientID,h(i),sim.simx_opmode_streaming);
    end
    sim.simxSynchronousTrigger(clientID);

    %% READ FIRST JOINT POSITION AND SET UP STARTING JOINT TORQUE
    for i=1:7
            [r,qn(i)]=sim.simxGetJointPosition(clientID,h(i),sim.simx_opmode_streaming); 
    end
    qp=qn;
    J=EulerJacobianPose(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
    Jp=J;
    rp =EulerTaskVector(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));

    for i=1:7
        sim.simxSetJointMaxForce(clientID,h(i),100,sim.simx_opmode_streaming);
    end
    for i=1:7
        sim.simxSetJointForce(clientID,h(i),0,sim.simx_opmode_oneshot);
    end

    %% SIGNAL STREAMING
    sim.simxSetFloatSignal(clientID,'error_x',e(1),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'error_y',e(2),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'error_z',e(3),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'error_phi',e(4),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'error_z4',e(5),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'error_phi',e(6),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'rd_x',rd(1),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'rd_y',rd(2),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'rd_z',rd(3),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_1',u(1),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_2',u(2),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_3',u(3),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_4',u(4),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_5',u(5),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_6',u(6),sim.simx_opmode_streaming);
    sim.simxSetFloatSignal(clientID,'u_7',u(7),sim.simx_opmode_streaming);

    %% FORCE SENSOR 
    [r, state, force, torque] = sim.simxReadForceSensor(clientID, ForceSensor, sim.simx_opmode_streaming);

    %% SIMULATION LOOP
    
    while true

        drawnow;

        phi = str2double(label_phi.Text);
        if flag_doing_echo
            updateBtn_Echo(button_trajectory);
        end                                                                %  Xbox controller inputs
        if controller_check == 1  
            % CONTROLLER INPUT                                                 %  Right Analog Stick: Move end-effector on XY plane;
            [axes,buttons] = read(joy);                                        %  Left Analog Stick : Changes PHI;
            if axes(1)<-0.1                                                    %  RT/LT Buttons: Change Z of end-effector;
                dx = dx-0.001*abs(axes(1));                                    %  Select Button: return in HOME position;
            end                                                                %  Y Button : puts end-effector in ECHO position;                                                    
            if axes(1)>0.1                                                     %  RB/LB Buttons: Change THETA;
                dx = dx+0.001*abs(axes(1));                                    %  A Button: Starts linear trajectory;
            end                                                                %  X Button: Starts wirst trajectory;
            if axes(2)<-0.1                                                    %  B Button: Stops the trajectory;
                dy = dy+0.001*abs(axes(2));
            end
            if axes(2)>0.1
                dy = dy-0.001*abs(axes(2));
            end
            if axes(3)>0.05                                                    
                dz = dz+0.001*abs(axes(3));
            end
            if axes(3)<-0.5
                if ForceZ<SAFETY_VALUE
                    dz = dz-0.001*abs(axes(3));
                end
            end
    
            if buttons(8) == 1                                                 
                updateBtn_Home(slider_theta,label_theta,slider_phi,label_phi,slider_d,label_d,ef_gainK_x,ef_gainK_y,ef_gainK_z,ef_gainK_theta,ef_gainK_link4pos,ef_gainD_x,ef_gainD_y,ef_gainD_z,ef_gainD_theta,ef_gainD_link4pos,ef_gainDq,check_xy,ef_gainK_phi,ef_gainD_phi);
            end
            if buttons(4) == 1                                                 
                updateBtn_Echo(button_trajectory); 
            end
    
    
            if abs(axes(5))>=0.2 || abs(axes(4))>=0.2                          
    	        r3=round(-atan2(axes(5),axes(4)),2); 
                if r3>(-pi+deg2rad(25)) && r3<(pi-deg2rad(25))
                    phi = r3;
                    slider_phi.Value = r3;
                    updateLabel(slider_phi,label_phi);
                end
            end    
            
            if buttons(5) == 1                                          
                if str2double(label_theta.Text)<=pi - 0.02
                    slider_theta.Value =  slider_theta.Value + 0.01;
                    updateLabel(slider_theta,label_theta);
                end
            end
            if buttons(6) == 1
                if str2double(label_theta.Text)>=pi-deg2rad(30) + 0.02 
                    slider_theta.Value =  slider_theta.Value - 0.01;
                    updateLabel(slider_theta,label_theta);
                end
            end
        end
        %%%%%%%%%%%%%%%

        echo_value = ef_echo_force.Value;

        label_phi.Text = num2str(phi);
        d = str2double(label_d.Text);
        [r, state, force, torque] = sim.simxReadForceSensor(clientID, ForceSensor, sim.simx_opmode_buffer);
        ForceZ=-force(3);

        if ForceZ >= echo_value-0.2                         
            button_trajectory.Enable = true;
            button_trajectory_2.Enable = true;
        else
            button_trajectory.Enable = false;
            button_trajectory_2.Enable = false;
        end
        
        %Check if modified rs is not undeground;
        if rs(3)+dz < 0   
            dz=-rs(3);  
        end

        rd=rs+[dx;dy;dz;0;0;0];
        
        
        if str2double(label_theta.Text) < pi && str2double(label_theta.Text)>=pi-threshold
            rt = EulerTaskVector(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
            slider_phi.Enable = false;
            if rt(6)>=-pi && rt(6)<=-pi+deg2rad(25)
                slider_phi.Value = -pi+deg2rad(25);
                label_phi.Text = num2str(-pi+deg2rad(25));
            elseif rt(6)<pi && rt(6)>=pi-deg2rad(25)
                slider_phi.Value = pi-deg2rad(25);
                label_phi.Text = num2str(pi-deg2rad(25));
            else
                slider_phi.Value = double(rt(6));
                label_phi.Text = num2str(rt(6));
            end
        else
                 slider_phi.Enable = true;
        end



        rd(4)=str2double(label_theta.Text);
        rd(6)=str2double(label_phi.Text);
        
        %PHI control starts at THETA=2.97
        if rd(4)>pi-threshold && rd(4)<pi+threshold
            Kphi=0;
            Dphi=0;
        else
            Kphi=ef_gainK_phi.Value;
            Dphi=ef_gainD_phi.Value;
        end
        
        K=[ef_gainK_x.Value,0,0,0,0,0;
           0,ef_gainK_y.Value,0,0,0,0;
           0,0,ef_gainK_z.Value,0,0,0;
           0,0,0,ef_gainK_theta.Value,0,0;
           0,0,0,0,ef_gainK_link4pos.Value,0;
           0,0,0,0,0,Kphi];
        Dr=[ef_gainD_x.Value,0,0,0,0,0;
           0,ef_gainD_y.Value,0,0,0,0;
           0,0,ef_gainD_z.Value,0,0,0;
           0,0,0,ef_gainD_theta.Value,0,0;
           0,0,0,0,ef_gainD_link4pos.Value,0;
           0,0,0,0,0,Dphi];
        Dq=eye(7)*ef_gainDq.Value;
        %Aq=eye(7)*ef_gainAq.Value;

        for i=1:7  
             [r,qn(i)]=sim.simxGetJointPosition(clientID,h(i),sim.simx_opmode_buffer);   
        end

        dq=(qn-qp)/dt;
        ra=EulerTaskVector(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
        dr = (ra-rp)/dt;
        
        e = rd-ra;
        sim.simxSetFloatSignal(clientID,'error_x',e(1),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'error_y',e(2),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'error_z',e(3),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'error_theta',e(4),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'error_z4',e(5),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'error_phi',e(6),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'rd_x',rd(1),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'rd_y',rd(2),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'rd_z',rd(3),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_1',u(1),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_2',u(2),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_3',u(3),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_4',u(4),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_5',u(5),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_6',u(6),sim.simx_opmode_streaming);
        sim.simxSetFloatSignal(clientID,'u_7',u(7),sim.simx_opmode_streaming);

        g=get_GravityVector(qn);
        c=get_CoriolisVector(qn,dq);
        M=get_MassMatrix(qn);

        J=EulerJacobianPose(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
        dJ=(J-Jp)/dt;
        
        u=M*pinv(J)*(-dJ*transpose(dq))+c+g+transpose(J)*(K*(rd-ra)-Dr*dr)-Dq*transpose(dq);
        if controller_check == 1
            if buttons(1) == 1
                disp('Executing linear trajectory');
                trajectory_button_1(clientID,sim, button_trajectory)
                %trajectory_function(clientID,sim, button_trajectory)
                for i=1:7  
                    [r,qn(i)]=sim.simxGetJointPosition(clientID,h(i),sim.simx_opmode_buffer);   
                end
                ra = EulerTaskVector(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
                J = EulerJacobianPose(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
            end
            if buttons(3) == 1  
                disp('Executing wrist trajectory.');
                trajectory_button_2(clientID,sim, button_trajectory_2)
                %trajectory_function_2(clientID,sim, button_trajectory_2)
                for i=1:7  
                    [r,qn(i)]=sim.simxGetJointPosition(clientID,h(i),sim.simx_opmode_buffer);   
                end
                ra = EulerTaskVector(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
                J = EulerJacobianPose(qn(1),qn(2),qn(3),qn(4),qn(5),qn(6),qn(7));
            end
        end
        rp = ra;
        qp=qn;
        Jp=J;

        for i=1:7
            if u(i)>0
                sim.simxSetJointTargetVelocity(clientID,h(i),99999,sim.simx_opmode_oneshot);
            else
                sim.simxSetJointTargetVelocity(clientID,h(i),-99999,sim.simx_opmode_oneshot);
            end
            if abs(u(i))>100
                u(i)=100;
            end
            sim.simxSetJointForce(clientID,h(i),abs(u(i)),sim.simx_opmode_oneshot);
        end
    sim.simxSynchronousTrigger(clientID);
    end
end


%% FUNCTIONS
function updateBtn_Up(check_xy)
    global dz dy d
    if check_xy.Value==1
        dy = dy+d;
    else 
        dz = dz+d;
    end
end

function updateBtn_Down(check_xy,SAFETY_VALUE)
    global dz dy d ForceZ
    if check_xy.Value==1
        dy = dy-d;
    else 
        if ForceZ<SAFETY_VALUE
            dz = dz-d;
        end
    end
end

function updateBtn_Left()
    global dx d
    dx = dx-d;
end

function updateBtn_Right()
    global dx d
    dx = dx+d;
end    

function updateBtn_Home(slider_theta,label_theta,slider_phi,label_phi,slider_d,label_d,ef_gainK_x,ef_gainK_y,ef_gainK_z,ef_gainK_theta,ef_gainK_link4pos,ef_gainD_x,ef_gainD_y,ef_gainD_z,ef_gainD_theta,ef_gainD_link4pos,ef_gainDq,check_xy,ef_gainK_phi,ef_gainD_phi,ef_echo_force)
    global dx dy dz flag_doing_echo
    dx = 0;
    dy = 0;
    dz = 0;
    slider_theta.Value = pi;
    label_theta.Text = '3.14';
    slider_phi.Value = 0.00;
    updateLabel(slider_phi,label_phi);  %Ho provato a fa così
    slider_d.Value = 0.01;
    label_d.Text = '0.01';
    ef_gainK_x.Value = 250;
    ef_gainK_y.Value = 250;
    ef_gainK_z.Value = 75;
    ef_gainK_theta.Value = 50;
    ef_gainK_link4pos.Value = 250;
    ef_gainK_phi.Value = 1;
    ef_gainD_x.Value = 500;
    ef_gainD_y.Value = 500;
    ef_gainD_z.Value = 500;
    ef_gainD_theta.Value = 20;
    ef_gainD_link4pos.Value = 650;
    ef_gainD_phi.Value = 1;
    ef_gainDq.Value = 8;
    ef_echo_force.Value = 5;
    check_xy.Value = true;
    flag_doing_echo = false;
end

function updateBtn_Echo(button_trajectory)
    global dz ForceZ flag_doing_echo phi echo_value
    if ForceZ >= echo_value
        flag_doing_echo = false;
        %button_trajectory.Enable = true;
    else
        dz = dz-0.0001;

        if phi == 0.00
        elseif phi<0.00
            phi = phi+0.01;            
        elseif phi>0.00
            phi = phi-0.01;
        end

        flag_doing_echo = true;
    end    
end

function updateLabel(slider, label)
    label.Text = num2str(slider.Value, "%.2f");
end

function trajectory_button_1(clientID,sim, button_trajectory)
    trajectory_function(clientID,sim, button_trajectory)
end

function trajectory_button_2(clientID,sim, button_trajectory_2)
    trajectory_function_2(clientID,sim, button_trajectory_2)
end
