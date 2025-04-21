function LIFDashboardScript
% LIFDashboardScript - Interactive LIF neuron GUI from a .m file
% Note: Threshold > -54 mV yields no spikes

%% Model parameters and time vector
t = 0:0.1:500;  % ms
params.t        = t;
params.tau      = 10;
params.V_rest   = -65;
params.V_reset  = -70;
params.R        = 1;
params.V_thresh = -50;
params.noise_amp= 1;
params.I_base   = 5;
params.I_amp    = 5;

%% Create UI figure
fig = uifigure('Name','LIF Neuron Dashboard','Position',[100 100 1400 600]);
% Enable data cursor mode for inspecting (x,y) on plots
dcm = datacursormode(fig);
dcm.Enable = 'on';
dcm.SnapToDataVertex = 'off';
dcm.DisplayStyle = 'window';

% Left controls panel
panel = uipanel(fig,'Title','Controls','Position',[10 10 300 580]);

% Control definitions
labels = {'Spike Threshold (mV)', 'Noise Amplitude', 'Base Current', 'Sine Amplitude'};
fields = {'V_thresh','noise_amp','I_base','I_amp'};
limits = [-70 -40; 0 10; 0 10; 0 20];
initVals = [params.V_thresh, params.noise_amp, params.I_base, params.I_amp];
yPos = [480, 380, 280, 180];

% Create sliders, numeric inputs, and help buttons
for i = 1:4
    y = yPos(i);
    % Label
    uilabel(panel,'Position',[10 y 140 22],'Text',labels{i});
    % Slider
    sld = uislider(panel,'Position',[10 y-30 180 3],...
        'Limits',limits(i,:),'Value',initVals(i));
    sld.UserData = fields{i};
    sld.ValueChangedFcn = @(s,e) syncAndUpdate(s,fig);
    % Numeric edit
    edt = uieditfield(panel,'numeric','Position',[200 y-35 80 22],...
        'Limits',limits(i,:),'Value',initVals(i));
    edt.UserData = fields{i};
    edt.ValueChangedFcn = @(e,e2) syncAndUpdate(e,fig);
    % Help button
    btn = uibutton(panel,'push','Text','?','Position',[285 y 22 22]);
    btn.UserData = i;
    btn.ButtonPushedFcn = @(b,e) showHelp(b,labels,limits);
end

% Export button
uibutton(panel,'push','Text','Export CSV','Position',[10 50 270 30],...
    'ButtonPushedFcn',@(b,e) exportData(fig));

% Note label
uilabel(panel,'Position',[10 10 280 30],'Text','Note: Threshold > -54 mV yields no spikes.','FontWeight','bold');

%% Right axes
axV   = uiaxes(fig,'Position',[320 380 1060 200]); title(axV,'Membrane Potential');
axSpk = uiaxes(fig,'Position',[320 200 1060 160]); title(axSpk,'Spike Train');
axFFT = uiaxes(fig,'Position',[320 10 1060 160]); title(axFFT,'Frequency Spectrum');

% Store in UserData
fig.UserData.params = params;
fig.UserData.axes = struct('V',axV,'spike',axSpk,'fft',axFFT);

%% Initial plot
drawPlots(fig);

%% Callback functions
function syncAndUpdate(src, figHandle)
    ud = figHandle.UserData;
    key = src.UserData; val = src.Value;
    ud.params.(key) = val;
    % Sync slider and edit
    ctrls = panel.Children;
    for c = ctrls'
        if isprop(c,'UserData') && isequal(c.UserData,key) && c~=src
            c.Value = val;
        end
    end
    figHandle.UserData = ud;
    drawPlots(figHandle);
end

function showHelp(btn, labels, limits)
    idx = btn.UserData;
    msgs = { ...
        'Voltage threshold for spike generation (mV).';
        'Standard deviation of additive Gaussian noise.';
        'Baseline constant input current.';
        'Amplitude of sinusoidal input current.'};
    uialert(fig, sprintf('%s\nRange: [%g, %g]', msgs{idx}, limits(idx,1), limits(idx,2)), labels{idx});
end

function drawPlots(figHandle)
    ud = figHandle.UserData; p = ud.params;
    t = p.t; dt = t(2)-t(1);
    V = zeros(size(t)); V(1)=p.V_rest; spikes=[];
    for k=2:numel(t)
        I = p.I_base + p.I_amp*sin(2*pi*0.01*t(k)) + p.noise_amp*randn();
        dV = (-(V(k-1)-p.V_rest) + p.R*I)/p.tau * dt;
        V(k)=V(k-1)+dV;
        if V(k)>=p.V_thresh, V(k)=p.V_reset; spikes(end+1)=t(k); end
    end
    ud.spikes=spikes; ud.V=V; figHandle.UserData=ud;
    % Membrane
    plot(ud.axes.V,t,V,'LineWidth',1.5);
    xlabel(ud.axes.V,'Time (ms)'); ylabel(ud.axes.V,'V_m (mV)');
    % Spike train
    stem(ud.axes.spike,spikes,ones(size(spikes)),'Marker','none');
    xlabel(ud.axes.spike,'Time (ms)'); ylabel(ud.axes.spike,'Spikes'); ylim(ud.axes.spike,[0 1.2]);
    % FFT
    train=zeros(size(t)); idxs=round((spikes-t(1))/dt)+1; idxs(idxs<1|idxs>numel(train))=[]; train(idxs)=1;
    N=numel(train); Y=fft(train); P2=abs(Y/N); P1=P2(1:floor(N/2)+1); f=(0:floor(N/2))/(dt*N);
    plot(ud.axes.fft,f,P1,'LineWidth',1.5);
    xlabel(ud.axes.fft,'Frequency (Hz)'); ylabel(ud.axes.fft,'Amplitude'); xlim(ud.axes.fft,[0 5]);
end

function exportData(figHandle)
    ud = figHandle.UserData;
    spikes = ud.spikes; t = ud.params.t; dt = t(2)-t(1);
    train = zeros(size(t)); idxs = round((spikes - t(1))/dt)+1;
    idxs(idxs<1|idxs>numel(train))=[]; train(idxs)=1;
    T1 = table(spikes','VariableNames',{'SpikeTime_ms'});
    [f1,p1] = uiputfile('spike_train.csv','Save Spike Train'); if ischar(f1), writetable(T1,fullfile(p1,f1)); end
    N = numel(train); Y = fft(train); P2 = abs(Y/N); P1 = P2(1:floor(N/2)+1);
    f = (0:floor(N/2))/(dt*N);
    T2 = table(f',P1','VariableNames',{'Frequency_Hz','Amplitude'});
    [f2,p2] = uiputfile('fft.csv','Save FFT'); if ischar(f2), writetable(T2,fullfile(p2,f2)); end
end
end
