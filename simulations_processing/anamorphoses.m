function anamorphoses(Weights,varargin)
% Show the anamorphoses of the given cases.
%% Syntax
% anamorphoses(A)
% anamorphoses(A,__,___)
% 
% anamorphoses(EdgeTable)
% anamorphoses(EdgeTable,__,___)
% 
% anamorphoses(C)
% anamorphoses(C,__,___)
% 
%% Description
% anamorphoses(A) plots an anamorphosis using a square, symmetric
% adjancy matrix, A. The location of each nonzero entry in A specifies an 
% edge for the graph, and the weight of the edge is equal to the value of 
% the entry. For example, if A(2,1) = 10, then G contains an edge between
% node 2 and node 1 with a weight of 10.
% 
% anamorphoses(A,__,___) additionally specified options (see below for list of options)
% examples: anamorphoses(A,'Scale',1)
%           anamorphoses(C,'Display',0,'Scale',1)
% 
% 
% anamorphoses(EdgeTable) plots an anamorphosis using a table of edges,
% EdgeTable. (see graph help function for more information)
% 
% anamorphoses(EdgeTable,__,___) additionally specified options (see below for 
% list of options)
% 
% 
% anamorphoses(C) plots an anamorphoses using a cell vector of square,
% symmetric adjancy matrixes or of edge tables, C. Correspond to plot anamorphoses 
% of multiple cases (each cell being a different case).
% 
% anamorphoses(C,__,___) additionally specified options (see below for list of options)
%% Options
% Plot options
%   'Display'
%         0 - Unique figure (default)
%         1 - Multiple figures
%         2 - Movie (saved as an avi file) - only for multiple cases.
%   'Scale'
%         0 - No scaling (default)
%         1 - Scaling (normalized to the maximum weight of the first case)
%   'NodeColors'
%         Matrix of size number_of_nodes*3 defining nodes color in matlab
%         rgb format ([0 0 0] black, [1 1 1] white).
%         This colors will be used on all cases if a cell vector C is used
%         as first entry. 
%         !!! True only for cases of the same number of nodes !!!
%         To use different colors on all cases, a cell vector of the same 
%         size should be given (where each cell is a matrix of size 
%         number_of_nodes*3).
%         Default: bleu
%   'EdgeColors'
%         Matrix of size number_of_edges*3 defining edges color in matlab
%         rgb format ([0 0 0] black, [1 1 1] white).
%         This colors will be used on all cases if a cell vector C is used
%         as first entry.  
%         !!! True only for cases of the same number of none 
%         zero edges !!!
%         To use different colors on all cases, a cell vector of the same 
%         size should be given (where each cell is a matrix of size 
%         number_of_nodes*3).
%         Default: bleu
%   'EdgeThreshold'
%         Positive weight threshold under which edges' lines are transparent.
%         If a cell vector of single values is given, each case will use a
%         different threshold value (the same for all cases otherwise).
%         Example: 0 (default), 0.1, 1, 0.5, ...
%   'EdgeWidth'
%         Switch on or off edges thickness poundered by their weight.
%         Example: 'on' (default), 'off'
%   'Marker'
%         Marker symbol, specified as one of the values listed in Chart
%         Line Properties.
%         Examples: 'o' (default), '+', '*', '.', 'x', 's', 'd', ...
%   'MarkerSize'
%         Marker size, specified as a positive value in points.
%         Example: 6 (default), 2, 10, ..
%   'RotRefId'
%         Reference node/marker for orientation of the graph.
%         Example: 1 (default), 10, ...
%   'RotRefAngle'
%         Angle of reference in radian to which the reference node will be set
%         Example: 0 (default), pi/4, -pi/4, pi/2, -pi/2, ...
%   'FPS'
%         Number of frames per second at wich the movie is saved and
%         played (require option 'Display' at 2 to have an effect).
%         Example: 1 (default), 2, 3, ...
%   'NS'
%         Number of times/loops the movie is saved and played (require
%         option 'Display' at 2 to have an effect).
%         Example: 1 (default), 2, 3, ...
%   'Axis'
%         Make axes visible or not.
%         Example: 'on' (default), 'off'
%   'Legend'
%         Make legend visible or not.
%         Example: 'on' (default), 'off'

%% Options
% Default values
type_display = 0;
type_scale = 1;
NodeColors = 'b';
EdgeColors = 'b';
EdgeColors_def = 'b';
NodeColors_def = 'b';
EdgeThreshold = 0;
EdgeWidth = 'on';
filename = 'video';
Marker = 'o';
MarkerSize = 8;
id_ref = 1; % Marker of reference
theta_ref = 0; % Angle of reference in radian
fps= 1;
ns = 1;
axis_on = 'on';
Legend = 'off';

if nargin>1
    % Paired inputs verification
    if length(varargin)==1
        varargin = varargin{1};
        %nargin = length(varargin)+1;
        if mod(length(varargin),2)
            error('Wrong number of options input')
        end
    elseif mod(nargin-1,2)
            error('Wrong number of options input')
    end
    % Given values
    n_opt = (nargin-1)/2;
    for opt=0:(n_opt-1)
        if strcmp('Display',varargin{2*opt+1})
            type_display = varargin{2*opt+2};
        elseif strcmp('Scale',varargin{2*opt+1})
            type_scale = varargin{2*opt+2};
        elseif strcmp('NodeColors',varargin{2*opt+1})
            NodeColors = varargin{2*opt+2};
        elseif strcmp('EdgeColors',varargin{2*opt+1})
            EdgeColors = varargin{2*opt+2};
        elseif strcmp('EdgeThreshold',varargin{2*opt+1})
            EdgeThreshold = varargin{2*opt+2};
        elseif strcmp('EdgeWidth',varargin{2*opt+1})
            EdgeWidth = varargin{2*opt+2};
        elseif strcmp('Filename',varargin{2*opt+1})
            filename = varargin{2*opt+2};
        elseif strcmp('Marker',varargin{2*opt+1})
            Marker = varargin{2*opt+2};
        elseif strcmp('MarkerSize',varargin{2*opt+1})
            MarkerSize = varargin{2*opt+2};
        elseif strcmp('RotRefId',varargin{2*opt+1})
            id_ref = varargin{2*opt+2};
        elseif strcmp('RotRefAngle',varargin{2*opt+1})
            theta_ref = varargin{2*opt+2};
        elseif strcmp('FPS',varargin{2*opt+1})
            fps = varargin{2*opt+2};
        elseif strcmp('NS',varargin{2*opt+1})
            ns = varargin{2*opt+2};
        elseif strcmp('Axis',varargin{2*opt+1})
            axis_on = varargin{2*opt+2};
        elseif strcmp('Legend',varargin{2*opt+1})
            Legend = varargin{2*opt+2};
        end
    end
end
%% Adapt single case input
if ~iscell(Weights)
    C = cell(1,1);
    C{1}=Weights;
    Weights=C;
end
N_tests = length(Weights);
%% Open figure
if type_display==0 && N_tests>1
    n_col_subplot = ceil(N_tests/2);
    figure
end
%% Loop over cases
Graphs = cell(N_tests,1);
for test=1:N_tests
    %% Create graph
    Graphs{test}=graph(Weights{test});
    G = Graphs{test};
    %% Set lines thickness
    if strcmp(EdgeWidth,'on')
        if type_scale==1
            if test==1
                G_ref = G;
                Weight_ref = max(G.Edges.Weight);
            end
            G.Edges.Weight = G.Edges.Weight/Weight_ref;
            LWidths = 5*G.Edges.Weight;
        else
            LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
            ids = find(LWidths==0);
            for i=ids
                LWidths(i)=10^-5;
            end
        end
    else
        LWidths = 1;
    end
    %% Open figure or subplot
    if type_display==0 && N_tests>1
        subplot(2,n_col_subplot,test)
    else
        fi=figure;
        fi.Position = [297 247 652 570];
%         if strcmp(Legend,'on')
%             fi.Position(4) = fi.Position(4) + 0.5;
%         end
    end
    %% Plot undirected graph
    f=plot(G,'LineWidth',LWidths,'Layout','force');
    
    %% Color the markers
    if iscell(NodeColors)
        if size(NodeColors{test})==[size(f.NodeLabel,2),3]
            set(f,'NodeColor',NodeColors{test})
        else
            set(f,'NodeColor',NodeColors_def)
        end
    elseif size(NodeColors)==[size(f.NodeLabel,2),3]
        set(f,'NodeColor',NodeColors)
    else
        set(f,'NodeColor',NodeColors_def)
    end
    set(f,'MarkerSize',MarkerSize)
    set(f,'Marker',Marker)
    %% Color the lines
    if iscell(EdgeColors)
        EdgeColors_now = EdgeColors{test};
    else
        EdgeColors_now = EdgeColors;
    end
    if size(EdgeColors_now)==[size(G.Edges.Weight,1),3]
        set(f,'EdgeColor',EdgeColors_now)
    else
        set(f,'EdgeColor',EdgeColors_def)
    end
    %% Threshold
    if iscell(EdgeThreshold)
        Threshold_now = EdgeThreshold{test};
    else
        Threshold_now = EdgeThreshold;
    end
    if Threshold_now<0
        error('Threshold value must be positive')
    end
    if Threshold_now>0
        edgecol=get(f,'EdgeColor');
        ids = find(G.Edges.Weight<Threshold_now);
        edgecol(ids,:)=ones(length(ids),3);
        set(f,'EdgeColor',edgecol)
    end
    %% Rotation of the figure
    theta_agent = atan2(f.YData(id_ref),f.XData(id_ref));
    theta_rot = -(theta_agent-theta_ref);
    f=rotation(f,theta_rot);
    %% Axes limits
    if type_scale==1
        ax = gca;
        if test==1
            scale_x = ax.XLim;
            scale_y = ax.YLim;
        else
            ax.XLim = scale_x;
            ax.YLim = scale_y;
        end
    end
    if strcmp(axis_on,'off')
        axis off
    end
    %% Legend
    if strcmp(Legend,'on')
%         ax.YLim(2) = ax.YLim(2)+0.5;
        text(ax.XLim(2)-1.6,ax.YLim(2)-0.4,'Trade intra-zone','FontName','CMU Concrete','FontSize',10)
        text(ax.XLim(2)-1.6,ax.YLim(2)-0.65,'Trade extra-zone','FontName','CMU Concrete','FontSize',10)
        text(ax.XLim(2)-1.6,ax.YLim(2)-0.9,'Agent','FontSize',8)
        hold on
        plot([ax.XLim(2)-1.9 ax.XLim(2)-1.7],[ax.YLim(2)-0.4 ax.YLim(2)-0.4],'Color',[40,40,40]/250,'LineWidth',2)
        plot([ax.XLim(2)-1.9 ax.XLim(2)-1.7],[ax.YLim(2)-0.65 ax.YLim(2)-0.65],'Color',[51, 153, 255]/255,'LineWidth',2)
        plot([ax.XLim(2)-1.8],[ax.YLim(2)-0.9],'Color',[0.749019607843137,0.564705882352941,0],'Marker','.','MarkerSize',MarkerSize*3.5)
        plot([ax.XLim(2)-2 ax.XLim(2)-0.005 ax.XLim(2)-0.005 ax.XLim(2)-2 ax.XLim(2)-2],[ax.YLim(2)-1.1 ax.YLim(2)-1.1 ax.YLim(2)-0.25 ax.YLim(2)-0.25 ax.YLim(2)-1.1],'k-')
        hold off
    end
    %% Register frames
    if type_display==2 && N_tests>1
        Figs(test) = gcf;
        Frames(test) = getframe(gcf);
    end
end
%% Create movie from regitered frames
if type_display==2 && N_tests>1
    frames2avi(Figs,filename,ns,fps)
    f=figure;
    movie(f,Frames,ns,fps)
end

