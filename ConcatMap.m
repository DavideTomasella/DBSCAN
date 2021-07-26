classdef ConcatMap < handle
    properties
       
    end
    properties (Access = { ?classUnderTest, ?matlab.unittest.TestCase })
        elements
        %removedElements
        edgeKey = uint32(0)
        arbConst = true
        removeKey %int32{mustBeNonnegative}
        insertKey %int32{mustBeNonnegative}
        N = uint32(0)
    end
    
    properties ( Dependent = true )
        %N %int32{mustBeNonnegative}
    end
    
    methods
        function cm = ConcatMap(fKey)            
            if (nargin==1)                
                mustBePositive(fKey)
                cm.elements = containers.Map({fKey}, {cm.edgeKey});
                cm.insertKey = fKey;
                cm.removeKey = fKey;
                cm.N = uint32(1);
            else
                cm.elements = containers.Map({cm.edgeKey}, {cm.edgeKey});
                cm.insertKey = cm.edgeKey;
                cm.removeKey = cm.edgeKey;
            end
            %cm.removedElements = containers.Map({cm.edgeKey}, {cm.arbConst});
            %cm.elements(cm.edgeKey) = cm.edgeKey;
        end
        function add(cm, nKey)
            mustBePositive(nKey)
            if ~isKey(cm.elements, nKey) %&& ~isKey(cm.removedElements, nKey)
                cm.elements(cm.insertKey) = nKey;
                cm.elements(nKey) = cm.edgeKey;
                cm.insertKey = nKey;
                cm.N = cm.N + 1;
            end
        end
        function adds(cm, keys)
            mustBePositive(keys)
            keys=num2cell(keys(:));
            %1
            keys=keys(~isKey(cm.elements, keys));
            keys=[cm.insertKey,[keys{:}],cm.edgeKey]; %&& ~isKey(cm.removedElements, nKey)
            for i=1:length(keys)-1            
                cm.elements(keys(i))=keys(i+1);
            end
            %2
            %keys=[cm.insertKey;keys(~isKey(cm.elements, keys));cm.edgeKey];
            %tmap=containers.Map(keys(1:end-1), keys(2:end));            
            %cm.elements = [cm.elements;tmap];
            cm.insertKey=keys(end-1);
            cm.N = cm.N + length(keys) - 2;
            
        end
        %improve performance
        function oKey = remove(cm)
            %if cm.isEmpty()
            %    error('Concatenated elements is empty');
            %else
            oKey = cm.removeKey;
            cm.N = cm.N - 1;
            if cm.N>0
                cm.removeKey = cm.elements(cm.removeKey);        
            end
            %cm.elements(cm.edgeKey) = cm.elements(oKey);
            %remove(cm.elements,oKey);
            %cm.removedElements(oKey) = cm.arbConst;
            %end
        end
        function oKey = o_remove(cm)
            if cm.isEmpty()
                error('Concatenated elements is empty');
            else
                oKey = cm.elements(cm.edgeKey);
                cm.elements(cm.edgeKey) = cm.elements(oKey);
                remove(cm.elements,oKey);
                cm.removedElements(oKey) = cm.arbConst;
            end
        end
        function tf = isEmpty(cm)
            tf = (cm.N==0);%(cm.elements(cm.removeKey) == cm.edgeKey);
        end
        function n = Nel(cm)
            n = max(cm.N, 0);
        end
        function keys = o_getElements(cm)
            kk=cm.elements.keys;
            keys = [kk{2:end}];
        end
    end
end