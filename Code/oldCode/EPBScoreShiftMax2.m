function [voxel, voxelmax, maxint, dx, dy] = shiftDendriteMax(voxel,imageArray,restricted)

    %fix the neurite so it coincides with the maximal intensity in the perpendicular plane

    maxx=size(imageArray,2);
    maxy=size(imageArray,1);
    maxz=size(imageArray,3);
    

    %calculate the instantaneous slope in X-Y plane use neighborhood of 5 pixels to each side

    %calculate the normal direction of the axon based on 3 pixels on each side

    voxel=single(voxel);
    oldvoxel=voxel;
    newvoxel=round(voxel);
    
    [dx,dy] = normalDirection(voxel);
    dx=smooth(dx,21)';
    dy=smooth(dy,21)';

%     if (maxpath)
%             
%             %define the search region
%             mask = zeros(size(imageArray),'uint8');
%             mask(newvoxel(1,:)+(newvoxel(2,:)-1)*maxy+(newvoxel(3,:)-1)*maxy*maxx)=1;
% 
%             neighborhood=35;
%             height=4;
%             se=strel(ones(neighborhood*2+1,neighborhood*2+1,height*2+1,'uint8'));
%             mask=imdilate(mask,se);
%             
%             o=find(mask);
%             mlength=length(o);
%             tlength=length(imageArray);
%             graph_crop=sparse([],[],[],tlength,tlength,mlength);
%      
%             % assume 26 connectivity
%             for di=[-1 0 1]
%                 for dj=[-1 0 1]
%                     for dk=[-1 0 1]
%                         if (dk>0) || (dk==0 && dj>0) || (dk==0 && dj==0 && di>0)
% 
%                             indblock=zeros(size(mask),'uint8');
% 
%                             indblock(max(1,1-di):(end+min(-di,0)),max(1,1-dj):(end+min(-dj,0)),max(1,1-dk):(end+min(-dk,0)))=1;
%                             indblock=indblock & mask;
%                             o=find(indblock);
% 
%                             offset=di+dj*size(mask,1)+dk*size(mask,1)*size(mask,2);
% 
%                             % add distance for existing nodes need to figure
%                             % out right metric here
%                             %d=sqrt(di.*di+dj.*dj+dk.*dk);
%                             graph_crop=graph_crop+sparse(o,o+offset,10000-double(min([imageArray(o) imageArray(o+offset)],[],2)),tlength,tlength);
%                         end
%                     end
%                 end
%             end
% 
%             graph_crop=graph_crop+graph_crop';
% 
%             ind=newvoxel(:,end);
%             ending=sub2ind(size(imageArray),ind(1),ind(2),ind(3));
%             p = ending;
%             
%             ind=newvoxel(:,1);
%             starting=sub2ind(size(imageArray),ind(1),ind(2),ind(3));
% 
% 
%             % first do mst based path, this uses only diagonal
%             % connections
%             [d pred] = shortest_paths(graph_crop,starting);
% 
% 
%             % trace from end to start
% 
%             while p~=starting
%                 [yi,xi,zi]=ind2sub(size(imageArray),p);
%                 x=[x xi];
%                 y=[y yi];
%                 z=[z zi];
%                 p=pred(p);
%             end
% 
%             maxint=imageArray(y+(x-1)*maxy+(z-1)*maxy*maxx);
%             voxel=[y; x; z];
%             voxel=fliplr(voxel);
%             maxint=fliplr(maxint);
%             voxelmax=voxel;
%         else
        voxel(1,:)=smooth(voxel(1,:),7)';
        voxel(2,:)=smooth(voxel(2,:),7)';
        voxel(3,:)=smooth(voxel(3,:),7)';

        %iterate this process

        [maxint,~] = findMaxInt(voxel,imageArray);
        

        plane = [];
        line = [];
        inds=[];
        zs=[];
        
%         if (restricted)
%             neighborhood=3;
%             height=1;
%         else
%             neighborhood=15;
%             height=5;
%         end

            neighborhood = 5;
            height = 2;
            
            for j=-height:height   %five focal section up and three plane down
                for k=1:neighborhood*2+1  %crosssection; neighborhood pixels away on each side
                    crossdx= -(k-neighborhood-1).*dy;
                    crossdy=  (k-neighborhood-1).*dx;
                    
                    x=round(min(max(voxel(2,:)-1+crossdx,0),maxx-1));
                    y=round(min(max(voxel(1,:)-1+crossdy,0),maxy-1));
                    z=round(min(max(voxel(3,:)-1+j,0),maxz-1));
                    
                    plane=[plane; imageArray(y+x*maxy+z*maxy*maxx+1)];
                end
                
                [maxinplane,ind]=max(plane);
                line=[line; maxinplane]; %obj.data.filteredArray(y+x*maxy+z*maxy*maxx+1)];
                inds=[inds; ind];
                zs=[zs; z];
                
            end

            if (height>2)
                %find the closest local minima
                line=double(line);
                minima=imregionalmax(imhmin(line,median(double(maxint))/3,[0 1 0; 0 1 0; 0 1 0]),[0 1 0; 0 1 0; 0 1 0]);
                indz=zeros(1,size(voxel,2));
                for j=0:height
                    [maxv,ind]=max([minima(height-j+1,:).*line(height-j+1,:);minima(height+j+1,:).*line(height+j+1,:)]);
                    ind=(maxv>0).*floor(height+j*2*(ind-1.5)+1);
                    indz=indz+(indz==0).*ind;
                end
            else                    
                [~,indz]=max(line,[],1);
            end


            inds=inds';
            ind=inds((indz-1)*size(line,2)+(1:size(line,2)));
            
            
            indx=-(ind-neighborhood-1).*dy;
            indy=(ind-neighborhood-1).*dx;
            indz=indz-height-1;
            
            voxel(2,:)=round(min(max(voxel(2,:)+indx,1),maxx));
            voxel(1,:)=round(min(max(voxel(1,:)+indy,1),maxy));
            voxel(3,:)=round(min(max(voxel(3,:)+indz,1),maxz));
            voxelmax=voxel;
            
            voxel(2,:)=min(max(voxel(2,:),1),maxx);
            voxel(1,:)=min(max(voxel(1,:),1),maxy);
            voxel(3,:)=min(max(voxel(3,:),1),maxz);
            
            [maxint,~] = findMaxInt(voxel,imageArray);
            
%             RMS=sqrt(mean((smoothmaxint-smooth(double(maxint),7)).^2));
%             disp(['RMS error for step 1 : ' num2str(RMS)]);
%             smoothmaxint=smooth(double(maxint),7);

        end
%     end
    
    [dx,dy] = normalDirection(voxel);
end

function [dx,dy] = normalDirection(voxel)
    dx = voxel(1,:)-voxel(1,1);
    dy = voxel(2,:)-voxel(2,1);
    
    dr = sqrt(dx.^2 + dy.^2);
    dr(dr==0) = 1;
    
    dx = dx./dr;
    dy = dy./dr;
end

function [maxint,smoothmaxint] = findMaxInt(voxel, imageArray)
    % find maxint as center of line
    maxx=size(imageArray,2);
    maxy=size(imageArray,1);
    maxz=size(imageArray,3);
    
    x=round(min(max(voxel(2,:)-1,0),maxx-1));
    y=round(min(max(voxel(1,:)-1,0),maxy-1));
    z=round(min(max(voxel(3,:)-1,0),maxz-1));

    maxint=imageArray(y+x*maxy+z*maxy*maxx+1);
    smoothmaxint=smooth(double(maxint),7);
end