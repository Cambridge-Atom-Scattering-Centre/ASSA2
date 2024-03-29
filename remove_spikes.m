function meas = remove_spikes(meas,keepIlength)

if meas.numloops > 1
    Preal_mat = []; Pimag_mat = [];
    for i=1:meas.numloops
        Preal_mat = [Preal_mat;meas.loop(i).Preal];
        Pimag_mat = [Pimag_mat;meas.loop(i).Pimag];
    end
    med_Preal = repmat(median(Preal_mat),size(Preal_mat,1),1); spike_Preal = abs(Preal_mat-med_Preal)>0.02;
    med_Pimag = repmat(median(Pimag_mat),size(Pimag_mat,1),1); spike_Pimag = abs(Pimag_mat-med_Pimag)>0.02;

    Preal_mat(spike_Preal)=med_Preal(spike_Preal);
    Pimag_mat(spike_Pimag)=med_Pimag(spike_Pimag);

    for i=1:meas.numloops
        meas.loop(i).Preal = Preal_mat(i,:);
        meas.loop(i).Pimag = Pimag_mat(i,:);
        meas.loop(i).Pmag = sqrt(meas.loop(i).Pimag.^2+meas.loop(i).Preal.^2);
    end
end

% Remove spikes by neighbours
% The idea here is to find outliers in each loop and exclude
% them from the data. Two iteration are used. First,
% find potential outliers automatically using the hampel
% function, then, confirm manually. Following that, reassign
% and calculate relevant fields such as Preal, Pimage, and Pmag.
% TODO: It is not necessary to exclude points, better just to
% make them as 'not for use' using a dedicated field. Then the
% fitting can ignore them using the 'Exclude' field.

maxstd = 5;
numOfNeighbours = 5;

cutoff_Bl = 0.2; % in milliteslametre
indx = ~((abs(meas.Bl)) < cutoff_Bl);
Bl = []; Preal = []; Pimag = []; deltaPhase = []; deltaI0 = [];
if keepIlength
    Bl_orig = [];
end

for i=1:meas.numloops
    loop = meas.loop(i);

    % Auto spike removal

    [~,tmp_excld_frm_imag,~,~] = hampel(loop.Pimag(indx),numOfNeighbours,maxstd);
    excld_frm_imag = zeros(size(indx)); excld_frm_imag(indx) = tmp_excld_frm_imag;
    [~,tmp_excld_frm_real,~,~] = hampel(loop.Preal(indx),numOfNeighbours,maxstd);
    excld_frm_real = zeros(size(indx)); excld_frm_real(indx) = tmp_excld_frm_real;

    excld_frm_real = peakPointsFromFigure('dataX',meas.Bl,'dataY',meas.loop(i).Preal,'chosenPointsIndx',find(excld_frm_real),'titleStr',['Real, loop #' num2str(i)]);
    excld_frm_imag = peakPointsFromFigure('dataX',meas.Bl,'dataY',meas.loop(i).Pimag,'chosenPointsIndx',find(excld_frm_imag),'titleStr',['Imaginary, loop #' num2str(i)]);

    Preal = [Preal loop.Preal(~(excld_frm_real | excld_frm_imag))];
    Pimag = [Pimag loop.Pimag(~(excld_frm_real | excld_frm_imag))];
    deltaPhase = [deltaPhase loop.deltaPhase(~(excld_frm_real | excld_frm_imag))];
    deltaI0 = [deltaI0 loop.deltaI0(~(excld_frm_real | excld_frm_imag))];
    Bl = [Bl meas.Bl(~(excld_frm_real | excld_frm_imag))];

    if keepIlength, Bl_orig = [Bl_orig meas.Bl]; end

end

[meas.Bl, meas.mean.Preal,meas.mean.Pimag,meas.mean.deltaPhase,meas.mean.deltaI0] = merge_similar_points(Bl,Preal,Pimag,deltaPhase,deltaI0);

% if we would like to keep the length of Bl, Preal, Pimag,
% deltaPhase, and deltaI0 unchanged, we can interpolate them.
if keepIlength
    Bl_orig = uniquetol(Bl_orig);
    meas.mean.Preal = interp1(meas.Bl,meas.mean.Preal,Bl_orig,'linear','extrap');
    meas.mean.Pimag = interp1(meas.Bl,meas.mean.Pimag,Bl_orig,'linear','extrap');
    meas.mean.deltaPhase = interp1(meas.Bl,meas.mean.deltaPhase,Bl_orig,'linear','extrap');
    meas.mean.deltaI0 = interp1(meas.Bl,meas.mean.deltaI0,Bl_orig,'linear','extrap');
    meas.Bl = Bl_orig;
end
meas.mean.Pmag = sqrt(meas.mean.Preal.^2+meas.mean.Pimag.^2);
end

function chosenPoints = peakPointsFromFigure(varargin)
% peakPointsFromFigure will allow the user to choose points
% using the mouse from a figure. The figure can either be supplied or created
% 'on-the-fly' using the input data (if supplied).
% Left click - Add the nearest point to the pointer position to the chosen list.
% Right click - Remove the nearest point to the pointer position form the chosen list.
% Middle click - return

% parse varargin
prsdArgs = inputParser;   % Create instance of inputParser class.
prsdArgs.addParameter('dataX', [], @isnumeric);
prsdArgs.addParameter('dataY', [], @isnumeric);
prsdArgs.addParameter('chosenPointsIndx', [], @isnumeric);
prsdArgs.addParameter('figHandle', [], @isnumeric);
prsdArgs.addParameter('closefig', 0, @isnumeric);
prsdArgs.addParameter('titleStr', 'Exclude (left click), re-include(right click), finish (middle button)', @ischar);
prsdArgs.parse(varargin{:});
figHandle = prsdArgs.Results.figHandle;
chosenPointsIndx = prsdArgs.Results.chosenPointsIndx;
dataX = prsdArgs.Results.dataX;
dataY = prsdArgs.Results.dataY;
titleStr = prsdArgs.Results.titleStr;

% Open a figure if needed (using supplied data). In that case,
% also close it on return
if isempty(figHandle)
    closefig=1;
    figHandle = figure;
    plot(dataX,dataY,'o');
else
    closefig=0;
    [data]=CustomFuncs.extract_figure_data(figHandle);
    dataX = data.x; dataY = data.y;
end
if isrow(dataX), dataX = dataX'; end
if isrow(dataY), dataY = dataY'; end

figure(figHandle)
XScale=diff(get(gca,'XLim'));
YScale=diff(get(gca,'YLim'));
title(titleStr)
xlabel('Solenoid current/A'); ylabel('Spin polarisation')
i=length(find(chosenPointsIndx));
hold on;
for j=1:i
    if j==0, continue; end
    h_tmp(j) = plot(dataX(chosenPointsIndx(j)),dataY(chosenPointsIndx(j)),'ro');
end
figure(figHandle)
while 1
    [x, y, button] = ginput(1);
    if button == 1
        i=i+1;
        r=sqrt(((dataX-x)./XScale).^2+((dataY-y)./YScale).^2);
        [~, chosenPointsIndx(i)] = min(r);
        h_tmp(i) = plot(dataX(chosenPointsIndx(i)),dataY(chosenPointsIndx(i)),'ro');
    elseif button == 3
        r=sqrt(((dataX(chosenPointsIndx)-x)./XScale).^2+((dataY(chosenPointsIndx)-y)./YScale).^2);
        [~, pointToExcludeIndx] = min(r);
        delete(h_tmp(pointToExcludeIndx))
        chosenPointsIndx = chosenPointsIndx(chosenPointsIndx(:)~=chosenPointsIndx(pointToExcludeIndx));
        h_tmp = h_tmp(1:length(h_tmp) ~= pointToExcludeIndx);
        i = i-1;
    else
        %chosenPointsIndx = chosenPointsIndx(chosenPointsIndx(:)~=chosenPointsIndx(tmpchosenPointsIndx));
        break
    end
end

chosenPoints = zeros(1,length(dataX));
chosenPoints(chosenPointsIndx) = 1;

if closefig, close(figHandle); end
end