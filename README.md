# Ceullar Spatial Pattern Mining
Cellular Spatial Pattern Mining via Unsupervised Clustering and Graph Modeling

## Step 1: Cell Feature Extraction & Selection
1. extract_img_cell_feas.m
- Image stain normalization
- Cell segmentation
- Cell feature extraction
2. draw_cell_seg.m
- Overlay the segmented cell on the image
3. select_cell_feas.m
- Select 10 from 24 extracted features

## Step 2: Unsupervised Cell Subtyping
1. cluster_cells.m
- Perform unsuperived cell clustering
2. build_cell_classifier.m
- Construct cell classifer based on pseudo cell types

## Step 3: SuperCell Community Detection
1. draw_supercells.m
- Generate supercells and draw on the orignal image
2. pool_supercell_feas.m
- Pooling all images' supercell's features
3. cluster_supercells.m
- Perform unsuperived supercell clustering
4. build_supercell_classifier.m
- Construct supercell classifer based on pseudo supercell types
5. draw_labeled_supercell.m
- Label each supercell and overlay on the image

## Step 4: Global Graph Construction & Diagnosis
1. extract_global_graph_info.m
- Build the Delaunay graph for each image based on all supercells' center 
coordinates, and then extract edge and node information. Build the Voronoi 
graph and extract features.
2. extract_graph_feas.m
- Combine the features from supercell Delaunay and Voronoi graphs.
3. img_graph_cls.m
- Perform classification based on the collected features.
4. cmp_graph_cls.m
- Compare with three other graph-based methods.

## Citation
Please consider `cite` the paper if you use the code for your research.
```
@article{chen2021hierarchical,
  title={Hierarchical Phenotyping and Graph Modeling of Spatial Architecture in Lymphoid Neoplasms},
  author={Chen, Pingjun and Aminu, Muhammad and El Hussein, Siba and Khoury, Joseph and Wu Jia},
  journal={International Conference on Medical Image Computing and Computer-Assisted Intervention},,
  year={2021},
  organization={Springer}
}
```
