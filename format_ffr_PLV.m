%% this script formats badaga FFR data for PLV
% created 10/30/23 by Jacie McHaney

clear all
close all

%parameters
today = date;
maindir = '/Users/myk4766/Library/CloudStorage/OneDrive-SharedLibraries-NorthwesternUniversity/SoundBrain Lab - Documents/Jacie/Pitt_CRC/NSAA/FFR_data/processed_FFR/spin';
inpath = [maindir '/FFR/sub_plv'];
outpath = [maindir '/FFR_formatted_PLV'];
if ~exist(outpath, 'dir') 
    mkdir(outpath)
end
fs = 25000;
pre= -0.025;

%get list of files
files = dir([inpath '/*.dat']);
files = cellstr(char(files.name));

%get arrays of subs, conds,stims
parts = cellfun(@(x) strsplit(x,'_'),files,'UniformOutput',false);
parts = vertcat(parts{:}); %remove nesting
sublist = intersect(parts(:,1),parts(:,1));

%create time vector
t = (1:5750)*(1/fs);
t  = t+pre;

%go through each sub
for i = 1:length(sublist)

    all_epochs = [];
    clss = [];
    conds =  [];
    pols = [];

    % find index of subject's data
    sub = char(sublist(i));
    subidx = find(contains(files,sub));

    %pull out their ffr data files
    subffr = files(subidx,:);
    
%     %get conds and stims
%     nparts = cellfun(@(x) strsplit(x,'_'),subffr,'UniformOutput',false);
%     nparts = vertcat(nparts{:}); %remove nesting
%     substim = intersect(nparts(:,2),nparts(:,2));
%     subcond = intersect(nparts(:,3),nparts(:,3));
%     subcond = cellfun(@(x) x(1:end-4), subcond, 'UniformOutput',false); %fix conds

    
    for j = 1:length(subffr)

        %pull correct file in
        fn = [inpath '/' char(subffr(j))];
        currdat = importdata(fn);

        %pull this FFR
        ffr = subffr(:,1)';
        all_epochs = [all_epochs;currdat];

        %get cond and stim and polarity
        nparts = strsplit(char(subffr(j)),'_');
        substim = nparts{2};
        subcond = nparts{3};
        subpol = nparts{4}(1:end-4);

        %make condition
        if strcmp(subcond,'SSNeeg')==1 || strcmp(subcond,'ssn')==1 || strcmp(subcond,'SSN')==1
            curcond = 2;
        elseif strcmp(subcond,'Quiet')==1 || strcmp(subcond,'quiet')==1
            curcond  = 1;
        end

        subcnd = zeros(size(currdat,1),1);
        subcnd(:) = curcond;

        conds = [conds;subcnd];

        % make class
        if strcmp(substim,'BA')==1
            curstim = 1;
        elseif strcmp(substim,'DA')==1
            curstim = 2;
        elseif strcmp(substim,'GA')==1
            curstim = 3;
        end

        subcls = zeros(size(currdat,1),1);
        subcls(:)= curstim;

        clss = [clss;subcls];

        %make polarity
        if strcmp(subpol,'pos')==1 
            curpol = 1;
        elseif strcmp(subpol,'neg')==1
            curpol  = 2;
        end

        subpls = zeros(size(currdat,1),1);
        subpls(:) = curpol;

        pols = [pols;subpls];


        
    end

    %save
    ffroutname = [outpath '/' sub '.mat'];
    save(ffroutname, 'all_epochs','clss','conds','pols','t')

end