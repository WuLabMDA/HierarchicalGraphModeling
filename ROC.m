function [Centres,IDX,Cluster2data]=ROC(data,a,M)
%%% Input
%% data    - data for clustering, each row represents a data sample
%% a       - control the sparsity of the sparse ranking matrices, the value range is (0,1).
%% M       - control the number of neighbours for local maxima identification, the value should be larger than 0.
%% The recommended values of a and M: a=0.9; M=10.
%%% Output
%% Centres - Centres of the clusters; each row is a centre.
%% IDX     - Cluster indices of data the samples; each row is the index of the data sample in the same row in the input data matrix
%% Cluster2data  - for every cluster which points are in it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[L,W]=size(data);
S=zeros(L,L,W);
Threshold=round(a*L*(L-1)/2);
R=zeros(L,L,W);
for ii=1:1:W
    [~,seq1]=sort(pdist(data(:,ii),'minkowski',1),'descend');
    [~,seq2]=sort(seq1,'ascend');
    seq3=squareform(seq2);
    R(:,:,ii)=seq3;
    seq3(find(seq3<=Threshold))=0;
    S(:,:,ii)=seq3+eye(L);
end
R=sum(R,3);
S=sum(sum(S,3),1);
[~,seq4]=sort(R,'descend');
[~,seq5]=max([S;S(seq4(1:1:M,:))]);
centerID=find(seq5==1);
Centres=data(centerID,:);
[~,IDX]=max(R(:,centerID),[],2);
IDX(centerID)=1:1:length(centerID);

numClust = length(unique(IDX));
Cluster2data = cell(numClust,1);
for cN = 1:numClust
    myMembers = find(IDX == cN);
    Cluster2data{cN} = myMembers;
end
end