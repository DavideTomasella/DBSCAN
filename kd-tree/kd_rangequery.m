function [index_vals,dist_vals,vector_vals] = kd_rangequery(tree,point,radius,pointIDx,distMatrixNxN,node_number)

    % Davide Tomasella 12/12/2020
    % original version: pramod vemulapalli 02/07/2010
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INPUTS
    % tree           --- the cell array that contains the tree
    % point          --- the point of interest
    % range          --- radius of hypersphere centered on point
    % pointIDx       --- index of distMatrixNxN with the distances from point
    % distMatrixNxN  --- square matrix with pre computed distances,
    %                    the indexes are node.index or pointIDx
    % none_number    --- Internal Variable, Donot Define
    %                    first call is recognized by only 4 parameters

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OUTPUTS
    % index_vals  --- the index value in the original matrix that was used to
    %                 build the tree
    % vector_vals --- the feature vector closest to the given vector
    % final_node  --- the node that contains the closest vector

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Donot define the node_number variable -- it is used for internal
    % referencing



    % check for sufficient number of inputs
    if(nargin<3)
        error('Not enough input arguments ...');
    end

    %global tree_cell;
    %global safety_check;

    % in the first iteration make sure that the data is in the right shape
    if(nargin<6)

        %safety_check=0;
        node_number=1;
        %tree_cell=tree;
        %clear tree;

        %dim=size(tree_cell(1).nodevector,2);

        %size_range=size(range);
        size_point=size(point);

        % transpose the point data if it is given as a single column instead of
        % a single row
        if (size_point(1)>size_point(2))
            point=point';
        end

        if ~(length(radius)==1 && radius>0)
            %if ~(size_range(2)==dim && size_range(1)==2 && (sum(range(1,:)<=range(2,:))==dim) )
            error('radius input not in correct format ...');
        end
        if (nargin==5)
            if ~(pointIDx>0 && pointIDx<=length(distMatrixNxN))
                error('pointIDx for look-up in distMatrixNxN non correct ...');
            elseif ~(length(distMatrixNxN)==length(tree))
                error('ditance matrix non correct ...');
            end
        else
            pointIDx=0;
            distMatrixNxN=0;
        end
        
    end

    %if (isempty(safety_check))
    %    error ('Insufficient number of input variables ... please check ');
    %end

    % find dimension of feature vector
    %dim=size(tree_cell(1).nodevector,2);
    
    %get current node of the tree
    treenode=tree(node_number);
    
    % if the current node is with in the range ... then store the data in the output
    index_vals=[]; dist_vals=[]; vector_vals=[];
    if(pointIDx>0)
        dist=distMatrixNxN(pointIDx,tree(node_number).index);
    else
        dist=mpdist(treenode.nodevector,point,DISTTYPE.euclidean);
    end
    if dist<=radius
        %if (sum(tree_cell(node_number).nodevector>=point+range(1,:))==dim && ...
        %        sum(tree_cell(node_number).nodevector<=point+range(2,:))==dim)
        index_vals=treenode.index;
        dist_vals=dist;
        vector_vals=treenode.nodevector;  
    end

    % if the current node is a leaf then return
    if(treenode.isLeaf==1)
        return;
    end


    % if the current node is not a leaf
    % check to see if the range hypercuboid is to the left of the split
    % and in that case send the left node out for inquiry
    index_vals1=[];dist_vals1=[];vector_vals1=[];
    if (point(treenode.splitdim)-radius) <= treenode.splitval
        if (~isempty(treenode.left))
            [index_vals1,dist_vals1,vector_vals1]=kd_rangequery(tree,point,radius,pointIDx,distMatrixNxN,treenode.left);
        end
        %index_vals=[index_vals;index_vals1];
        %dist_vals=[dist_vals;dist_vals1];
        %vector_vals=[vector_vals;vector_vals1];
    end

    % if the current node is not a leaf
    % check to see if the range hypercuboid is to the right of the split
    % and in that case send the right node out for inquiry
    index_vals2=[];dist_vals2=[];vector_vals2=[];
    if (point(treenode.splitdim)+radius)>treenode.splitval
        if (~isempty(treenode.right))
            [index_vals2,dist_vals2,vector_vals2]=kd_rangequery(tree,point,radius,pointIDx,distMatrixNxN,treenode.right);
        end
        %index_vals=[index_vals;index_vals2];
        %dist_vals=[dist_vals;dist_vals2];
        %vector_vals=[vector_vals;vector_vals2];
    end


    %     % if the current node is not a leaf
    %     % check to see if the range hypercuboid stretches from the left to the
    %     % right of the split
    %     % in that case send the left and the right node out for inquiry
    %     if  ((point(tree_cell(node_number).splitdim)-radius)<=tree_cell(node_number).splitval) &&...
    %             ((point(tree_cell(node_number).splitdim)+radius)>tree_cell(node_number).splitval)
    %
    %         if (~isempty(tree_cell(node_number).left))
    %             [index_vals1,dist_vals1,vector_vals1]=kd_rangequery(0,point,radius,distType,tree_cell(node_number).left);
    %         else
    %             index_vals1=[];dist_vals1=[];vector_vals1=[];
    %         end
    %         if (~isempty(tree_cell(node_number).right))
    %             [index_vals2,dist_vals2,vector_vals2]=kd_rangequery(0,point,radius,distType,tree_cell(node_number).right);
    %         else
    %             index_vals2=[];dist_vals2=[];vector_vals2=[];
    %         end
    %index_vals=[index_vals;index_vals1;index_vals2];
    %dist_vals=[dist_vals;dist_vals1;dist_vals2];
    %vector_vals=[vector_vals;vector_vals1;vector_vals2];
    %    end
    
    %append 
    index_vals=[index_vals;index_vals1;index_vals2];
    dist_vals=[dist_vals;dist_vals1;dist_vals2];
    vector_vals=[vector_vals;vector_vals1;vector_vals2];

    % after everything is done clear out the global variables
    if(nargin==5)
        %clear global tree_cell;
        %clear global safety_check;
    end

end