classdef Trayecto_Proyectil < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GraficarButton                 matlab.ui.control.Button
        ValoresPanel                   matlab.ui.container.Panel
        IntervalodetiempoEditField     matlab.ui.control.NumericEditField
        IntervalodetiempoEditFieldLabel  matlab.ui.control.Label
        AreatransversalEditField       matlab.ui.control.NumericEditField
        AreatransversalEditFieldLabel  matlab.ui.control.Label
        CoefdearrastreEditField        matlab.ui.control.NumericEditField
        CoefdearrastreEditFieldLabel   matlab.ui.control.Label
        MasaEditField                  matlab.ui.control.NumericEditField
        MasaEditFieldLabel             matlab.ui.control.Label
        DensidadEditField              matlab.ui.control.NumericEditField
        DensidadEditFieldLabel         matlab.ui.control.Label
        AlturainicialmEditField        matlab.ui.control.NumericEditField
        AlturainicialmEditFieldLabel   matlab.ui.control.Label
        AngulogradosEditField          matlab.ui.control.NumericEditField
        AngulogradosEditFieldLabel     matlab.ui.control.Label
        VelocidadinicialmsEditField    matlab.ui.control.NumericEditField
        VelocidadinicialmsEditFieldLabel  matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        v = [] % Velocidad inicial
        angulo % angulo inicial
        masa % Masa del proyectil
        area % Área transversal del proyectil
        coef_arrastre % Coeficiente de arrastre
        densidad % Densidad del proyectil
        y = [] % Altura inicial
        y_SR = [] % Alturas sin resistencia del aire
        x = [0] % Posicion inicial
        x_SR = [0] % Posiciones sin resistencia del aire
        delta_t % Intervalo de tiempo      
        vx = [] % velocidad en x
        vy = [] % velocidad en y
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: VelocidadinicialmsEditField
        function VelocidadinicialmsEditFieldValueChanged(app, event)
            value = app.VelocidadinicialmsEditField.Value;
            app.v(1) = value;
        end

        % Button pushed function: GraficarButton
        function GraficarButtonPushed(app, event)
            VelocidadinicialmsEditFieldValueChanged(app, event);
            AngulogradosEditFieldValueChanged(app,event);
            AlturainicialmEditFieldValueChanged(app,event);
            MasaEditFieldValueChanged(app,event);
            DensidadEditFieldValueChanged(app,event);
            CoefdearrastreEditFieldValueChanged(app,event);
            AreatransversalEditFieldValueChanged(app,event);
            IntervalodetiempoEditFieldValueChanged(app,event);
            
            
            app.vx(1) = app.v(1)*cosd(app.angulo);
            app.vy(1) = app.v(1)*sind(app.angulo);
            app.x(1) = 0;
            gravedad = -9.81;
            coef_total = app.densidad * app.coef_arrastre * app.area / 2;
            
            
            % con resistencia del aire
            i_previo = 0;
            i_actual = 1;
            while app.y(end)>=0
                i_previo = i_previo + 1; % inicial=1
                i_actual = i_actual + 1; % inicial=2
                
                app.v(i_previo) = sqrt((app.vx(i_previo))^2 + (app.vy(i_previo))^2);
                
                ax(i_previo) = -((coef_total / app.masa) * app.v(i_previo) * app.vx(i_previo));
                ay(i_previo) = gravedad - (coef_total/app.masa) * app.v(i_previo) * app.vy(i_previo);

                delta_vx(i_actual) = ax(i_previo)*app.delta_t;
                delta_vy(i_actual) = ay(i_previo)*app.delta_t;
                
                app.vx(i_actual) = app.vx(i_previo)+delta_vx(i_actual);
                app.vy(i_actual) = app.vy(i_previo)+delta_vy(i_actual);
                
                app.x(i_actual) = app.x(i_previo) + app.vx(i_previo) * app.delta_t + 0.5 * ax(i_previo) * app.delta_t^2;
                app.y(i_actual) = app.y(i_previo) + app.vy(i_previo) * app.delta_t + 0.5 * ay(i_previo) * app.delta_t^2;              
            end
            app.y(end) = 0;
            
            
            % sin resistencia del aire
            indice = 1;
            t(1) = 0;
            app.x_SR(1) = app.x(1);
            app.y_SR(1) = app.y(1);
            while app.y_SR(end)>=0
                indice = indice + 1; % inicial=1
                t = t + app.delta_t;
                
                app.x_SR(indice) = app.vx(1) * t;
                app.y_SR(indice) = (app.vy(1) * t) + 0.5 * gravedad * (t^2) + app.y_SR(1);
            end
            app.y_SR(end) = 0;
            
            
            plot(app.UIAxes,app.x,app.y)
            hold(app.UIAxes,'on')
            plot(app.UIAxes,app.x_SR,app.y_SR)
            hold(app.UIAxes,'off')
            
            clearvars;
%             app.v = [];   
%             app.y = []; 
%             app.y_SR = []; 
%             app.x = [0]; 
%             app.x_SR = [0];    
%             app.vx = []; 
%             app.vy = [];
        end

        % Value changed function: AngulogradosEditField
        function AngulogradosEditFieldValueChanged(app, event)
            value = app.AngulogradosEditField.Value;
            app.angulo = value;
        end

        % Value changed function: AlturainicialmEditField
        function AlturainicialmEditFieldValueChanged(app, event)
            value = app.AlturainicialmEditField.Value;
            app.y(1) = value;
        end

        % Value changed function: MasaEditField
        function MasaEditFieldValueChanged(app, event)
            value = app.MasaEditField.Value;
            app.masa = value;
        end

        % Value changed function: DensidadEditField
        function DensidadEditFieldValueChanged(app, event)
            value = app.DensidadEditField.Value;
            app.densidad = value;
        end

        % Value changed function: CoefdearrastreEditField
        function CoefdearrastreEditFieldValueChanged(app, event)
            value = app.CoefdearrastreEditField.Value;
            app.coef_arrastre = value;
        end

        % Value changed function: AreatransversalEditField
        function AreatransversalEditFieldValueChanged(app, event)
            value = app.AreatransversalEditField.Value;
            app.area = value;
        end

        % Value changed function: IntervalodetiempoEditField
        function IntervalodetiempoEditFieldValueChanged(app, event)
            value = app.IntervalodetiempoEditField.Value;
            app.delta_t = value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 957 448];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Trayecto de proyectil')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [290 11 658 425];

            % Create ValoresPanel
            app.ValoresPanel = uipanel(app.UIFigure);
            app.ValoresPanel.ForegroundColor = [1 1 1];
            app.ValoresPanel.TitlePosition = 'centertop';
            app.ValoresPanel.Title = 'Valores';
            app.ValoresPanel.BackgroundColor = [0.0745 0.6235 1];
            app.ValoresPanel.Position = [14 140 260 296];

            % Create VelocidadinicialmsEditFieldLabel
            app.VelocidadinicialmsEditFieldLabel = uilabel(app.ValoresPanel);
            app.VelocidadinicialmsEditFieldLabel.HorizontalAlignment = 'right';
            app.VelocidadinicialmsEditFieldLabel.FontColor = [1 1 1];
            app.VelocidadinicialmsEditFieldLabel.Position = [11 237 122 22];
            app.VelocidadinicialmsEditFieldLabel.Text = 'Velocidad inicial (m/s)';

            % Create VelocidadinicialmsEditField
            app.VelocidadinicialmsEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.VelocidadinicialmsEditField.ValueChangedFcn = createCallbackFcn(app, @VelocidadinicialmsEditFieldValueChanged, true);
            app.VelocidadinicialmsEditField.Position = [148 237 100 22];
            app.VelocidadinicialmsEditField.Value = 25;

            % Create AngulogradosEditFieldLabel
            app.AngulogradosEditFieldLabel = uilabel(app.ValoresPanel);
            app.AngulogradosEditFieldLabel.HorizontalAlignment = 'right';
            app.AngulogradosEditFieldLabel.FontColor = [1 1 1];
            app.AngulogradosEditFieldLabel.Position = [42 207 91 22];
            app.AngulogradosEditFieldLabel.Text = 'Angulo (grados)';

            % Create AngulogradosEditField
            app.AngulogradosEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.AngulogradosEditField.ValueChangedFcn = createCallbackFcn(app, @AngulogradosEditFieldValueChanged, true);
            app.AngulogradosEditField.Position = [148 207 100 22];
            app.AngulogradosEditField.Value = 30;

            % Create AlturainicialmEditFieldLabel
            app.AlturainicialmEditFieldLabel = uilabel(app.ValoresPanel);
            app.AlturainicialmEditFieldLabel.HorizontalAlignment = 'right';
            app.AlturainicialmEditFieldLabel.FontColor = [1 1 1];
            app.AlturainicialmEditFieldLabel.Position = [41 174 92 22];
            app.AlturainicialmEditFieldLabel.Text = 'Altura inicial (m)';

            % Create AlturainicialmEditField
            app.AlturainicialmEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.AlturainicialmEditField.ValueChangedFcn = createCallbackFcn(app, @AlturainicialmEditFieldValueChanged, true);
            app.AlturainicialmEditField.Position = [148 174 100 22];

            % Create DensidadEditFieldLabel
            app.DensidadEditFieldLabel = uilabel(app.ValoresPanel);
            app.DensidadEditFieldLabel.HorizontalAlignment = 'right';
            app.DensidadEditFieldLabel.FontColor = [1 1 1];
            app.DensidadEditFieldLabel.Position = [77 113 56 22];
            app.DensidadEditFieldLabel.Text = 'Densidad';

            % Create DensidadEditField
            app.DensidadEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.DensidadEditField.ValueChangedFcn = createCallbackFcn(app, @DensidadEditFieldValueChanged, true);
            app.DensidadEditField.Position = [148 113 100 22];
            app.DensidadEditField.Value = 1.275;

            % Create MasaEditFieldLabel
            app.MasaEditFieldLabel = uilabel(app.ValoresPanel);
            app.MasaEditFieldLabel.HorizontalAlignment = 'right';
            app.MasaEditFieldLabel.FontColor = [1 1 1];
            app.MasaEditFieldLabel.Position = [98 143 35 22];
            app.MasaEditFieldLabel.Text = 'Masa';

            % Create MasaEditField
            app.MasaEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.MasaEditField.ValueChangedFcn = createCallbackFcn(app, @MasaEditFieldValueChanged, true);
            app.MasaEditField.Position = [148 143 100 22];
            app.MasaEditField.Value = 0.145;

            % Create CoefdearrastreEditFieldLabel
            app.CoefdearrastreEditFieldLabel = uilabel(app.ValoresPanel);
            app.CoefdearrastreEditFieldLabel.HorizontalAlignment = 'right';
            app.CoefdearrastreEditFieldLabel.FontColor = [1 1 1];
            app.CoefdearrastreEditFieldLabel.Position = [37 79 96 22];
            app.CoefdearrastreEditFieldLabel.Text = 'Coef. de arrastre';

            % Create CoefdearrastreEditField
            app.CoefdearrastreEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.CoefdearrastreEditField.ValueChangedFcn = createCallbackFcn(app, @CoefdearrastreEditFieldValueChanged, true);
            app.CoefdearrastreEditField.Position = [148 79 100 22];
            app.CoefdearrastreEditField.Value = 0.5;

            % Create AreatransversalEditFieldLabel
            app.AreatransversalEditFieldLabel = uilabel(app.ValoresPanel);
            app.AreatransversalEditFieldLabel.HorizontalAlignment = 'right';
            app.AreatransversalEditFieldLabel.FontColor = [1 1 1];
            app.AreatransversalEditFieldLabel.Position = [40 44 93 22];
            app.AreatransversalEditFieldLabel.Text = 'Area transversal';

            % Create AreatransversalEditField
            app.AreatransversalEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.AreatransversalEditField.ValueChangedFcn = createCallbackFcn(app, @AreatransversalEditFieldValueChanged, true);
            app.AreatransversalEditField.Position = [148 44 100 22];
            app.AreatransversalEditField.Value = 0.004208352;

            % Create IntervalodetiempoEditFieldLabel
            app.IntervalodetiempoEditFieldLabel = uilabel(app.ValoresPanel);
            app.IntervalodetiempoEditFieldLabel.HorizontalAlignment = 'right';
            app.IntervalodetiempoEditFieldLabel.FontColor = [1 1 1];
            app.IntervalodetiempoEditFieldLabel.Position = [25 11 108 22];
            app.IntervalodetiempoEditFieldLabel.Text = 'Intervalo de tiempo';

            % Create IntervalodetiempoEditField
            app.IntervalodetiempoEditField = uieditfield(app.ValoresPanel, 'numeric');
            app.IntervalodetiempoEditField.ValueChangedFcn = createCallbackFcn(app, @IntervalodetiempoEditFieldValueChanged, true);
            app.IntervalodetiempoEditField.Position = [148 11 100 22];
            app.IntervalodetiempoEditField.Value = 0.1;

            % Create GraficarButton
            app.GraficarButton = uibutton(app.UIFigure, 'push');
            app.GraficarButton.ButtonPushedFcn = createCallbackFcn(app, @GraficarButtonPushed, true);
            app.GraficarButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.GraficarButton.FontSize = 18;
            app.GraficarButton.FontWeight = 'bold';
            app.GraficarButton.FontColor = [1 1 1];
            app.GraficarButton.Position = [15 62 258 51];
            app.GraficarButton.Text = 'Graficar';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Trayecto_Proyectil

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end