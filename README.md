# Efficient Hinging Hyperplanes Neural Network

This code is for the paper "Efficient hinging hyperplanes neural network and its  application in nonlinear system identification".

If you use this code, please kindly cite this paper: Xu J, Tao Q, Li Z, et al. Efficient hinging hyperplanes neural network and its application in nonlinear system identification[J]. Automatica, 2020, 116: 108906.

If you have any questions, please contact us. Email: [hm.3839@qq.com](mailto:xiaofei_zh@foxmail.com)

# Introduction

Different from the dominant single hidden layer neural networks, the hidden layer in the EHH neural network can be seen as a directed acyclic graph (DAG) and all the nodes in the DAG contribute to the output. It is proved that for every EHH neural network, there is an equivalent adaptive hinging hyperplanes (AHH) model, which was proposed based on the model of hinging hyperplanes (HH) and finds good applications in system identification. Analog to the proof for the AHH model, the universal approximation ability of the EHH neural network is provided. Different from other neural networks, the EHH neural network has interpretability ability, which can be easily obtained through its ANOVA decomposition (or interaction matrix). The interpretability can then be used as an indication for the importance of the input variables. The construction of the EHH neural network includes initial network generalization and parameter optimization (including the structure and weights parameters). A descent algorithm for searching the locally optimal EHH neural network is proposed and the worst-case complexity of the algorithm is also provided. The EHH neural network is applied in nonlinear system identification, you can use the dataset provided in the project file to verify the performance of this network, or you can use your own dataset to get regression results.

# Efficient Hinging Hyperplanes Neural Network

## Network Structure
This fig shows a typical EHH neural network. It can be seen as a single hidden layer PWL neural network, which  
includes an input layer, a hidden layer and an output layer.
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/ehh_structure.png)

# How to Run

> You should first package the data to be processed into a .mat file

- run BoucWen_step_optimization.m

> remember to change the data file address

# Platform

- Win10
- Matlab r2020
