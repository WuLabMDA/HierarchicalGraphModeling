# Ceullar Spatial Pattern Mining
Cellular Spatial Pattern Mining via Unsupervised Clustering and Graph Modeling

## Step 1: Cell Feature Extraction & Selection
1. extract_img_cell_feas.m
- Image stain normalization
- Cell segmentation
- Cell feature extraction
2. overlay_cell2img.m
- Overlay the segmented cell on the image
3. select_cell_feas.m
- Select 10 from 24 extracted features

## Step 2: Unsupervised Cell Subtyping
1. cluster_cells.m
- Perform unsuperived cell clustering
2. build_cell_classifier.m
- Construct cell classifer based on pseudo cell types

## Step 3: SuperCell Community Detection
1. gen_supercells.m
- Generate supercells based on local graph construction
2. pool_supercell_feas.m
- Pooling all images' supercell's features
3. cluster_supercells.m
- Perform unsuperived supercell clustering
4. build_supercell_classifier.m
- Construct supercell classifer based on pseudo supercell types
5. draw_labeled_supercell.m
- Label each supercell and overlay on the image

## Step 4: Global Graph Construction
1. extract_global_graph_info.m
- Build delaunay graph for each image based on all supercells' center 
coordinates, and then extract edge and node information
2. gen_graph_cls_data.m
- Based on the extracted edge and node information, generate the dataset with
format compatible to benchmark graph classification dataset like PROTEINS.zip used
at https://github.com/cszhangzhen/HGP-SL. 

