classdef ClusterAnalyzerTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        filename={'g2-2-10.txt','g2-2-20.txt'}
        NData={int32(2048),int32(2048)}
        value1949={[593, 608],[581, 626]}
        distType={DISTTYPE.euclidean,DISTTYPE.manhattan,DISTTYPE.cosine}
        dist835_1543={112.432202,159,0.000719}
        usePreCalc={false,false,false,false,false,false,false,false,false,...
                true,true,true,true,true,true,true,true,true}
        eps={2,2,2,5,5,5,20,20,20,...
            2,2,2,5,5,5,20,20,20}
        minPts={4,8,20,4,8,20,4,8,20,...
            4,8,20,4,8,20,4,8,20}
        nseeds375={10,10,10,...
                    89,89,89,...
                    816,816,816,...
                    10,10,10,...
                    89,89,89,...
                    816,816,816}
        seed2_375={584,584,584,...
                    79,79,79,...
                    8,8,8,...
                    584,584,584,...
                    79,79,79,...
                    8,8,8}
        random={1,3}
        dist_3535={[0.0585947; 0.0797993; 0.0767335; 0.0900362; 0.0331325; 0.0824724],...
            [0.0908077; 0.0598473; 0.0889545; 0.0771034; 0.0972653; 0.0901320; 0.1168383; 0.0936311; 0.0971495]}
    end
    properties
        EPS6=1e-6;
        TestFigure
        DIR='./g2-txt';
        def_filename='g2-2-10.txt';
        def_filename_control='Aggregation.txt';
        def_clID=int32(1);
        def_distType=DISTTYPE.euclidean;
        none_distType=DISTTYPE.none;
        delimiter=" ";
        dimensions=int32(2);
    end
    
    properties(MethodSetupParameter)
        
    end
    
    methods(TestMethodSetup)
        function createFigure(testCase)
            testCase.TestFigure = figure;
        end
        function choseDataset(testCase)
            addpath kd-tree
        end
    end
    
    methods(TestMethodTeardown)
        function closeFigure(testCase)
            close(testCase.TestFigure)
        end
    end
    
    %% Loading data tests
    methods(Test, ParameterCombination = 'sequential')        
        function tLoadDataSet(testCase,filename,NData,value1949)
            import matlab.unittest.constraints.IsEmpty
            
            analyzer= ClusterAnalyzer(testCase.none_distType);
            testCase.verifyThat(analyzer.rawData,IsEmpty,...
                'DataSet should be empty');
            try
                analyzer.loadDataSet(fullfile(testCase.DIR,filename),testCase.delimiter,testCase.dimensions);
            catch
            end
            testCase.verifyEqual(analyzer.NPoints,NData,...
                'Number of points loaded incorrect');
            testCase.verifyEqual(analyzer.rawData(1949,:),value1949,...
                'Wrong loaded data element');
        end
    end
    
    %% clustering tests
    methods(Test, ParameterCombination = 'sequential')
        function tDBscanPreCalc(testCase,eps,minPts)
            analyzer=ClusterAnalyzer(testCase.def_distType,true);
            analyzer.loadDataSet(fullfile(testCase.DIR,testCase.def_filename),testCase.delimiter,testCase.dimensions);
            analyzer.mDBScan(eps,minPts);
            if(eps==2 && minPts==20)
                testCase.verifyEqual(analyzer.getClID(689),CLIDTYPE.NOISE,...
                    'Start point must be in final cluster');
            else
                testCase.verifyEqual(analyzer.getClID(689),testCase.def_clID,...
                    'Start point must be in final cluster');
            end
            if(eps==2 && minPts==4)
                testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID+1,...
                    'Start point must be in final cluster');
            elseif(eps==2 && minPts>7)
                testCase.verifyEqual(analyzer.getClID(10),CLIDTYPE.NOISE,...
                    'Start point must be in final cluster');
            else
                testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID,...
                    'Start point must be in final cluster');
            end
            if(eps==2 && minPts==20)
                testCase.verifyEqual(analyzer.getClID(5),CLIDTYPE.NOISE,...
                    'Start point must be in final cluster');
            else
            testCase.verifyEqual(analyzer.getClID(5),testCase.def_clID,...
                'Start point must be in final cluster');
            end
            
        end
        function tDBscanKDTree(testCase,eps,minPts)
            analyzer=ClusterAnalyzer(testCase.def_distType,false);
            analyzer.loadDataSet(fullfile(testCase.DIR,testCase.def_filename),testCase.delimiter,testCase.dimensions);
            analyzer.mDBScan(eps,minPts);
            if(eps==2 && minPts==20)
                testCase.verifyEqual(analyzer.getClID(689),testCase.def_clID+2,...
                    'Start point must be in final cluster');
            else
                testCase.verifyEqual(analyzer.getClID(689),testCase.def_clID,...
                    'Start point must be in final cluster');
            end
            if(eps==2 && minPts==4)
                testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID+1,...
                    'Start point must be in final cluster');
            elseif(eps==2 && minPts>7)
                testCase.verifyEqual(analyzer.getClID(10),CLIDTYPE.NOISE,...
                    'Start point must be in final cluster');
            else
                testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID,...
                    'Start point must be in final cluster');
            end
            
            testCase.verifyEqual(analyzer.getClID(5),testCase.def_clID,...
                'Start point must be in final cluster');
            
        end
        function tExpandCluster(testCase,usePreCalc,eps,minPts)
            if ~usePreCalc
                analyzer=ClusterAnalyzer(testCase.def_distType,usePreCalc);
                analyzer.loadDataSet(fullfile(testCase.DIR,testCase.def_filename),testCase.delimiter,testCase.dimensions);
                analyzer.initClusteringForTest();
                isCore=analyzer.expandCluster(689,testCase.def_clID,eps,minPts);
                testCase.verifyEqual(isCore,true,...
                    'ExpandCluster not found a core');
                testCase.verifyEqual(analyzer.getClID(689),testCase.def_clID,...
                    'Start point must be in final cluster');
                if(eps==2)
                    testCase.verifyEqual(analyzer.getClID(10),CLIDTYPE.UNCLASSIFIED,...
                        'Start point must be in final cluster');
                else
                    testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID,...
                        'Start point must be in final cluster');
                end
                if(minPts==20 && eps==2)
                    testCase.verifyEqual(analyzer.getClID(5),CLIDTYPE.UNCLASSIFIED,...
                        'Start point must be in final cluster');
                else
                    testCase.verifyEqual(analyzer.getClID(5),testCase.def_clID,...
                        'Start point must be in final cluster');
                end
                %sovrascrivo valore
                isCore=analyzer.expandCluster(10,testCase.def_clID+1,eps,minPts);
                if(minPts>7 && eps==2)
                    testCase.verifyEqual(isCore,false,...
                        'ExpandCluster not found a core');
                    testCase.verifyEqual(analyzer.getClID(10),CLIDTYPE.NOISE,...
                        'Start point must be in final cluster');
                else
                    testCase.verifyEqual(isCore,true,...
                        'ExpandCluster not found a core');
                    testCase.verifyEqual(analyzer.getClID(10),testCase.def_clID+1,...
                        'Start point must be in final cluster');
                end
            end
        end
        
        function tRegionQuery(testCase,usePreCalc,eps,nseeds375,seed2_375)
            if ~usePreCalc
                analyzer=ClusterAnalyzer(testCase.def_distType,usePreCalc);
                analyzer.loadDataSet(fullfile(testCase.DIR,testCase.def_filename),testCase.delimiter,testCase.dimensions);
                seedsArr=analyzer.regionQuery(375,eps);
                seeds = ConcatMap(uint32(375));
                seeds.adds(seedsArr);
                testCase.verifyEqual(seeds.isEmpty(),false,...
                    'RegionQuery-Queue not filled');
                testCase.verifyEqual(seeds.Nel(),uint32(nseeds375),...
                    'Wrong n seeds found');
                testCase.verifyEqual(seeds.remove(),uint32(375),...
                    'First seed must be the center one');
                testCase.verifyEqual(seeds.remove(),uint32(seed2_375),...
                    'Wrong seed found. RegionQuery may not be deterministic');
            end
        end
    end
    
    %% kd-tree tests
    methods(Test, ParameterCombination = 'sequential')        
        function tKDTree(testCase,random,dist_3535)
            addpath("kd-tree");
            plot_stuff=1;
            rng('default')
            rng(random)
            X=rand(200,testCase.dimensions);
            tree = kd_buildtree(X,plot_stuff);
            point=0.35*ones(1,testCase.dimensions);
            radius=0.12;
            %range=[-radius*ones(1,dimen); radius*ones(1,dimen)];
            [index_vals,dist_vals,vector_vals] = kd_rangequery(tree,point,radius);
            if (plot_stuff)
                plot(point(1),point(2),'k*','MarkerSize',10)
                plot(X(index_vals,1),X(index_vals,2),'k*')                
                plot(point(1)+radius*cos(0:0.1:2*pi+0.1),point(2)+radius*sin(0:0.1:2*pi+0.1),'g-','LineWidth',1.5)
            end
            %NOTE: rnd1) sqrt((0.35-0.2398)^2+(0.35-0.3002)^2)=0.1209>0.12
            %      rnd=3) sqrt((0.35-0.4355)^2+(0.35-0.2704)^2)=0.1168<0.12
           testCase.verifyEqual(dist_vals,dist_3535,'AbsTol',testCase.EPS6,...
                'Wrong distance calc');
        end
    end
    
    %% Dist type tests
    methods(Test, ParameterCombination = 'sequential')
        
        function tDistance(testCase,distType,dist835_1543)
            analyzer=ClusterAnalyzer(distType);
            analyzer.loadDataSet(fullfile(testCase.DIR,testCase.def_filename),testCase.delimiter,testCase.dimensions);
            distance=analyzer.getDist(835,1543);
            testCase.verifyEqual(distance,dist835_1543,'AbsTol',testCase.EPS6,...
                'Wrong distance calc');
        end
        
        
    end
    
    %% Compile test functions
    methods(Test)
        function defaultCurrentPoint(testCase)
            
            cp = testCase.TestFigure.CurrentPoint;
            testCase.verifyEqual(cp, [0 0], ...
                'Default current point is incorrect')
        end
        
        function defaultCurrentObject(testCase)
            import matlab.unittest.constraints.IsEmpty
            
            co = testCase.TestFigure.CurrentObject;
            testCase.verifyThat(co, IsEmpty, ...
                'Default current object should be empty')
        end
        
    end
    
end