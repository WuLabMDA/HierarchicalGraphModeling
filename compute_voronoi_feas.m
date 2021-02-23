function [vfeature] = compute_voronoi_feas(x, y)

% Calculate the Voronoi diagram.
[VX,VY] = voronoi(x,y);
[V, C] = voronoin([x(:),y(:)]);

% Record indices of inf and extreme values to skip these cells later
Vnew        = V;
Vnew(1,:)   = [];

% Find the data points that lie far outside the range of the data
[Vsorted,I]     = sort([Vnew(:,1);Vnew(:,2)]);
N               = length(Vsorted);
Q1              = round(0.25*(N+1));
Q3              = round(0.75*(N+1));
IQR             = Q3 - Q1;
highrange       = Q3 + 1.5*IQR;
lowrange        = Q1 - 1.5*IQR;
Vextreme        = [];
Vextreme        = [Vextreme; V(find(V > highrange))];
Vextreme        = [Vextreme; V(find(V < lowrange))];

banned = [];
for i = 1:length(C)
    if(~isempty(C{i}))
        
    if(max(any(isinf(V(C{i},:)))) == 1 || max(max(ismember(V(C{i},:),Vextreme))) == 1)
        banned = [banned, i];
    end
    end
end
% If you've eliminated the whole thing (or most of it), then only ban 
% indices that are infinity (leave the outliers)
if(length(banned) > length(C)-2)
    banned = [];
    for i = 1:length(C)
        if(max(any(isinf(V(C{i},:)))) == 1)
            banned = [banned, i];
        end
    end
end

% Voronoi Diagram Features
% Area
c = 1;
d = 1;
e = d;
for i = 1:length(C)

    if(~ismember(i,banned) && ~isempty(C{i}))
        X = V(C{i},:);
        chord(1,:) = X(:,1);
        chord(2,:) = X(:,2);
        % Calculate the chord lengths (each point to each other point)
        for ii = 1:size(chord,2)
            for jj = ii+1:size(chord,2)
                chorddist(d) = sqrt((chord(1,ii) - chord(1,jj))^2 + (chord(2,ii) - chord(2,jj))^2);
                d = d + 1;
            end
        end

        % Calculate perimeter distance (each point to each nearby point)
        for ii = 1:size(X,1)-1
            perimdist(e) = sqrt((X(ii,1) - X(ii+1,1))^2 + (X(ii,2) - X(ii+1,2))^2);
            e = e + 1;
        end
        perimdist(size(X,1)) = sqrt((X(size(X,1),1) - X(1,1))^2 + (X(size(X,1),2) - X(1,2))^2);
        
        % Calculate the area of the polygon
        area(c) = polyarea(X(:,1),X(:,2));
        c = c + 1;
        clear chord X
    end
end
if(~exist('area','var'))
    vfeature = zeros(1,51);
    return; 
end
vfeature(1) = std(area); 
vfeature(2) = mean(area);
vfeature(3) = min(area) / max(area);
vfeature(4) = 1 - ( 1 / (1 + (vfeature(1) / vfeature(2))) );

vfeature(5) = std(perimdist);
vfeature(6) = mean(perimdist);
vfeature(7) = min(perimdist) / max(perimdist);
vfeature(8) = 1 - ( 1 / (1 + (vfeature(5) / vfeature(6))) );

vfeature(9) = std(chorddist);
vfeature(10) = mean(chorddist);
vfeature(11) = min(chorddist) / max(chorddist);
vfeature(12) = 1 - ( 1 / (1 + (vfeature(9) / vfeature(10))) );