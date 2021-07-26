function dist = mpdist(p,q,distType)
    %GETDIST return distance from 2 k-dim points
    if(distType==DISTTYPE.euclidean)
        dist = norm(p-q,2);
    elseif(distType==DISTTYPE.manhattan)
        dist = norm(p-q,1);
    elseif(distType==DISTTYPE.cosine)
        dist = acos(sum(p.*q)/...
            (norm(p)*norm(q)));
    else
        assert(false,'Distance calc method not implemented');
        dist=0;
    end
end
