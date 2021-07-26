classdef ClusterAnalyzer < handle
    %ClusterAnalyzer
    
    properties (Access = { ?classUnderTest, ?matlab.unittest.TestCase })
        
    end
    properties (Constant)
        v="1"
    end
    properties
        distType DISTTYPE
        dataSetName
        NPoints int32 {mustBePositive}
        spaceDim int32 {mustBePositive}
        rawData
        KDTree
        distNxN
        usePCVersion logical
        hasControl=false;
        controlClustering int32
        clustering int32
    end
    properties(Dependent=true)
        %clID
    end
    
    %% public interface
    methods
        function me = ClusterAnalyzer(mdistType,preCalcVersion)
            addpath("kd-tree");
            me.distType=mdistType;
            if(nargin<2)
                me.usePCVersion=true;
            else
                me.usePCVersion=preCalcVersion;
            end
        end
        function loadDataSet(me, filename,del,dim)
            %loadDataSet
            me.dataSetName=filename;
            me.rawData = importdata(filename,del);
            assert(numel(me.rawData)>0,"Error in loading data file");
            if(length(me.rawData(1,:))>dim)
                me.hasControl=true;
                me.controlClustering=me.rawData(:,dim+1);
                me.rawData=me.rawData(:,1:dim);
            end
            assert(mod(numel(me.rawData),dim)==0,"Error data file not well formatted");
            me.rawData=double(reshape(me.rawData,[],dim));
            me.spaceDim=dim;
            me.NPoints=length(me.rawData(:,1));
            %NOTE: the output of pdist can be used thought: yOut((i–1)*(m–i/2)+j–i) for i?j
            if(me.usePCVersion)
                me.preCalcDistances();
            else
                me.KDTree = kd_buildtree(me.rawData,0);
            end
        end
        function clusters = mDBScan(me,eps,minPts)
            if(me.usePCVersion)
                clusters = me.mDBScanPreCalc(eps,minPts);
            else
                clusters = me.mDBScanKDTree(eps,minPts);
            end
        end
        
        function clusters = mDBScanKDTree(me,eps,minPts)
            assert(me.NPoints>0,'No points found');
            me.clustering=int32(CLIDTYPE.UNCLASSIFIED).*int32(ones(me.NPoints,1));
            clusterID=me.nextClID(CLIDTYPE.NOISE);
            for pID=1:me.NPoints
                if(me.getClID(pID)==CLIDTYPE.UNCLASSIFIED)
                    if(me.expandCluster(pID,clusterID,eps,minPts))
                        clusterID=me.nextClID(clusterID);
                    end
                end
            end
            clusters = me.clustering;
        end
        
        function clusters = mDBScanPreCalc(me,eps,minPts)
            assert(me.NPoints>0,'No points found');
            me.clustering=int32(CLIDTYPE.UNCLASSIFIED).*int32(ones(me.NPoints,1));
            clusterID=me.nextClID(CLIDTYPE.NOISE);
            dirDenReachability=(me.distNxN<eps);
            coreSeeds=sum(dirDenReachability,2)>minPts;
            me.clustering(~coreSeeds)=CLIDTYPE.NOISE;
            for pID=find(coreSeeds,me.NPoints)'
                if(me.getClID(pID)==CLIDTYPE.UNCLASSIFIED)
                    me.clustering(pID)=clusterID;
                    dirDenReachSeeds=dirDenReachability(:,pID);
                    thisClust=me.clustering(dirDenReachSeeds);
                    while(sum(thisClust==CLIDTYPE.UNCLASSIFIED)+sum(thisClust==CLIDTYPE.NOISE)>0)
                        coreDirDenReachSeeds=dirDenReachSeeds&me.clustering==CLIDTYPE.UNCLASSIFIED;%NOTE: only core seeds can be unclassified
                        me.clustering(dirDenReachSeeds)=clusterID;
                        dirDenReachSeeds=sum(dirDenReachability(:,coreDirDenReachSeeds),2)>0;
                        thisClust=me.clustering(dirDenReachSeeds);
                    end
                    clusterID=me.nextClID(clusterID);
                end
            end
            clusters = me.clustering;
        end
        
    end
    
    %% Private methods
    methods(Access = { ?classUnderTest, ?matlab.unittest.TestCase })
        
        function isCore = expandCluster(me, pID, clID, eps, minPts)
            dirDenReachSeeds = me.regionQuery(pID,eps);
            if(length(dirDenReachSeeds) < minPts)
                me.changeClID(pID,CLIDTYPE.NOISE);
                isCore=false;
                return;
            end
            me.changeClID(pID,clID);
            isCore=true;
            %assert(dirDenReachSeedsMap.remove() == pID,'first seed must the center point');
            dirDenReachSeedsMap = ConcatMap(pID);
            dirDenReachSeedsMap.adds(dirDenReachSeeds);
            while ~dirDenReachSeedsMap.isEmpty()
                dirDenReachID = dirDenReachSeedsMap.remove();
                denReachSeeds = me.regionQuery(dirDenReachID,eps);
                if (length(denReachSeeds)>=minPts)
                    newDenReachSeeds=denReachSeeds(me.getClID(denReachSeeds)==CLIDTYPE.UNCLASSIFIED);
                    dirDenReachSeedsMap.adds(newDenReachSeeds);
                    me.changeClID(newDenReachSeeds,clID);
                    noiseDenReachSeeds=denReachSeeds(me.getClID(denReachSeeds)==CLIDTYPE.NOISE);
                    me.changeClID(noiseDenReachSeeds,clID);
                end
            end
            return;
        end
        
        function isCore = o_expandCluster(me, pID, clID, eps, minPts)
            dirDenReachSeeds = me.regionQuery(pID ,eps);
            if(dirDenReachSeeds.Nel < minPts)
                me.changeClID(pID,CLIDTYPE.NOISE);
                isCore=false;
                return;
            end
            me.changeClID(pID,clID);
            isCore=true;
            assert(dirDenReachSeeds.remove() == pID,'first seed must the center point');
            while ~dirDenReachSeeds.isEmpty()
                dirDenReachID = dirDenReachSeeds.remove();
                denReachSeeds = me.regionQuery(dirDenReachID,eps);
                if (denReachSeeds.Nel>=minPts)
                    while ~denReachSeeds.isEmpty()
                        denReachID=denReachSeeds.remove();
                        if(me.getClID(denReachID)==CLIDTYPE.UNCLASSIFIED)
                            dirDenReachSeeds.add(denReachID);
                            me.changeClID(denReachID,clID);
                        elseif(me.getClID(denReachID)==CLIDTYPE.NOISE)
                            me.changeClID(denReachID,clID);
                        end
                    end
                end
            end
            return;
        end
        
        function seeds = regionQuery(me,pID,eps)
            [seeds,~,~] = kd_rangequery(me.KDTree,me.rawData(pID,:),eps);
        end
        
        function seeds = o_regionQuery(me,pID,eps)
            seeds = ConcatMap();
            seeds.add(pID);
            if me.useKDTree
                [index_vals,~,~] = kd_rangequery(me.KDTree,me.rawData(pID,:),eps);
                seeds.adds(index_vals);
                %arrayfun(@(x) seeds.add(x),index_vals);
            else
                for qID = 1:me.NPoints
                    %handle different point with same position
                    if me.getDist(qID,pID) <= eps
                        seeds.add(qID);
                    end
                end
            end
        end
        
        function preCalcDistances(me)
            if(me.distType==DISTTYPE.euclidean)% euclidean(1), manhattan(2), cosine(3)
                me.distNxN=squareform(pdist(me.rawData,'euclidean'));
            elseif(me.distType==DISTTYPE.manhattan)% euclidean(1), manhattan(2), cosine(3)
                me.distNxN=squareform(pdist(me.rawData,'minkowski',1));
            elseif(me.distType==DISTTYPE.cosine)
                me.distNxN=squareform(pdist(me.rawData,'cosine'));
            else
                error("No handleable distType defined");
            end
        end
        
        function dist = getDist(me,pID,qID)
            %dist=me.distNxN(pID,qID);
            dist = mpdist(me.rawData(pID,:),me.rawData(qID,:),me.distType);
        end
        
        function initClusteringForTest(me)
            me.clustering=int32(CLIDTYPE.UNCLASSIFIED).*int32(ones(me.NPoints,1));
        end
        function clID = getClID(me,pID)
            clID = me.clustering(pID);
        end
        function changeClID(me,ppID,clID)
            me.clustering(ppID) = clID;
        end
        function clID = nextClID(~,clID)
            clID = clID+1;
        end
    end
end

