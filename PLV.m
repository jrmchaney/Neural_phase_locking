%% this script calculates phase-locking values (PLV) for FFRs collected to /ba/ /da/ and /ga/
% collapses across stimuli 
% looks at quiet and SSN conditions separately
% uses custom written functions by the Systems Neuroscience of Auditory Perception Lab directed by Hari Bharadwaj
% input data must be trial-by-trial and time-locked to the onset of the auditory stimulus
% for this example, the data have already gone through standard FFR preprocessing and formatted using `format_ffr_PLV.m`
% the input data here is formatted in a structure with:
% all_epochs = trials,time
% clss = 1: BA, 2: DA, 3: GA
% conds = 1: quiet, 2: SSN
% t = time vector
% written by Jacie R. McHaney on 10/30/23


close all
clear all

%% load in FFR data 

%paths
maindir = '/Users/myk4766/Library/CloudStorage/OneDrive-SharedLibraries-NorthwesternUniversity/SoundBrain Lab - Documents/Jacie/Pitt_CRC/NSAA'; %main experiment directory
inpath = [maindir '/FFR_data/processed_FFR/spin/FFR_formatted_PLV']; %location of preprocessed FFR data
outpath = [inpath '/PLV']; %where you want the PLV data to save to
if ~exist(outpath, 'dir') 
    mkdir(outpath)
end

%list of preprocessed FFR files
files = dir(fullfile(inpath,'/*.mat'));
files= cellstr(char(files.name));

%parameters
today = date;
conds = [1 2]; %1 = quiet, 2 = SSN
stims = [1 2 3]; %1 = BA, 2 = DA, 3 = GA
pols = [1 2]; %2 = positive, 1 = negative
Fs = 25000; %sampling rate
fpass = [30 3000]; %frequency range of interest in Hz
pad = 1; %to zero pad or not to the power of 2 (1 = yes, 0 = no)
tapers = [2 3]; %uses 3 tapers with the time-half bandwidth product of 2

%build params variable
params = [];
params.Fs = Fs;
params.fpass = fpass;
params.pad = pad;
params.tapers = tapers;

%% prepare FFR data for PLV and run it

allPLV = [];

for i = 1:length(files)
    
    subtable = [];

    %pull in current subject's data
    fn = [inpath '/' files{i}];
    curr = load(fn);

    trials = curr.all_epochs; %extract their FFR trial by trial data

    for j = 1:length(conds)
    
        %get indices of trials for this condition and polarity
        posidx = find(curr.conds == conds(j) & curr.pols == 2); 
        negidx = find(curr.conds == conds(j) & curr.pols == 1);
        
        pos_trials = trials(posidx,:);
        neg_trials = trials(negidx,:);

       %does one polarity have more trials than the other? Trim if so
        npos = size(pos_trials,1);
        nneg = size(neg_trials,1);
        if npos ~= nneg == 1
            sm = min(npos,nneg);
            pos_trials = pos_trials(1:sm,:);
            neg_trials = neg_trials(1:sm,:);
        end

        trials_env = [pos_trials;neg_trials]; %trials that correspond to FFRenv
        xenv = trials_env'; %transpose data so that it is in time, trials format -- not trials, time
    
        %now get FFRtfs. Need to invert negative polarity trials
        neg_trials_inv = neg_trials* -1;
        trials_tfs = [pos_trials;neg_trials_inv];
        xtfs = trials_tfs';%transpose data so that it is in time, trials format -- not trials, time
    
        % run the PLV
        [plv_env, f_env] = mtplv(xenv,params); %env
        [plv_tfs, f_tfs] = mtplv(xtfs,params); %tfs

        %compile information together
        
        subcol = zeros(length(plv_env),1);
        subcol(:) = str2num(files{i}(4:end-4));
        condcol = cell(length(plv_env),1);
        if conds(j) == 1
            condcol(:) = cellstr('quiet');
        elseif conds(j) == 2
            condcol(:) = cellstr('SSN');
        end
        
        varnames = {'subject','condition','PLV_env','Freq_env','PLV_tfs','Freq_tfs'};
        temptable = table(subcol,condcol,plv_env',f_env',plv_tfs',f_tfs','VariableNames',varnames);
        
        %combine
        subtable = [subtable;temptable];

    end %cond

    allPLV = [allPLV;subtable];

end %sub

outname = [outpath '/NSAA_PLV_' today '.csv'];
writetable(allPLV,outname)




