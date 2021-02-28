function [voroimage,sub_image]=voronoizone(x,y,img)

% Voronoi diagram based image zoning

% [voroimage,sub_image]=voronoizone(x,y,img)
% For a defined number of points on an image plane, voronoizone computes
% the voronoi diagram on the image space and divide the image into sub
% images according to the zones.

% Coded by Kalyan S Dash, IIT Bhubaneswar

szImg=size(img);
dis=[];

for i=1:szImg(1)
    for j=1:szImg(2)
        
        for k=1:length(x)
    
            dis(k)= (i-y(k))^2 + (j-x(k))^2;
            
        end
        
        [dis,index]=sort(dis,'ascend');
        
        optk=index(1);
        
        voroimage(i,j)=optk;
        
    end
end


for k=1:length(x)
     
     sub_image{k}=img(find(voroimage==optk));
     
end

end