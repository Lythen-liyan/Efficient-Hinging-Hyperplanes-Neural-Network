# Efficient Hinging Hyperplanes Neural Network

This code is for the paper "Efficient hinging hyperplanes neural network and its  application in nonlinear system identification".

If you use this code, please kindly cite this paper: Xu J, Tao Q, Li Z, et al. Efficient hinging hyperplanes neural network and its application in nonlinear system identification[J]. Automatica, 2020, 116: 108906.

If you have any questions, please contact us. Email: [hm.3839@qq.com](mailto:xiaofei_zh@foxmail.com)

# 1 Introduction

Different from the dominant single hidden layer neural networks, the hidden layer in the EHH neural network can be seen as a directed acyclic graph (DAG) and all the nodes in the DAG contribute to the output. It is proved that for every EHH neural network, there is an equivalent adaptive hinging hyperplanes (AHH) model, which was proposed based on the model of hinging hyperplanes (HH) and finds good applications in system identification. Analog to the proof for the AHH model, the universal approximation ability of the EHH neural network is provided. Different from other neural networks, the EHH neural network has interpretability ability, which can be easily obtained through its ANOVA decomposition (or interaction matrix). The interpretability can then be used as an indication for the importance of the input variables. The construction of the EHH neural network includes initial network generalization and parameter optimization (including the structure and weights parameters). A descent algorithm for searching the locally optimal EHH neural network is proposed and the worst-case complexity of the algorithm is also provided. The EHH neural network is applied in nonlinear system identification, you can use the dataset provided in the project file to verify the performance of this network, or you can use your own dataset to get regression results.

# 2 EHH Neural Network

## 2.1 Network Structure
Fig(a) shows a typical EHH neural network. It can be seen as a single hidden layer PWL neural network, which includes an input layer, a hidden layer and an output layer. Fig(b) shows the hidden layer of EHH neural network.
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh_structure.png)

## 2.2 Pre-processing
in order to avoid computation deficiency and severe variations in the parameter space, we are supposed to preprocess the input data before sending to the hidden layer. Specifically, assume the sampled data is$(\tilde{\mathbf{x}}(k), y(k))_{k=1}^{N_s}$, this is done by normalizing each of the original input variables independently, i.e.,
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh2.2.png)
## 2.3 Input and Hidden Layer Connection
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh_input_hidden_connection.png)
As we can see in the fig, the hidden layer of the EHH neural network is divided into two types of nodes, one is the source node ${D_{i}}$ that only accepts the output from the input neurons, and the other is the intermediate node ${C_{i}}$ that accepts the output of the source node and other intermediate nodes. And the output of a source node can be expressed as
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh2.3.png)

## 2.4 Connection in Hidden Layer
The out put of a intermidiate node can be expressed as
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh2.4_1.png)
Take the fig above as an example, we can get
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh2.4_2.png)

## 2.5 Hidden and Output Layer Connection
In the EHH neural network, both the source and intermediate nodes are designed to be connected to the nodes in the output layer. Therefore, the output of the EHH neural network takes the form of the weighted sum of all neurons (with a bias) in the hidden layer, i.e.,
![image](https://github.com/Lythen-liyan/Efficient-Hinging-Hyperplanes-Neural-Network/blob/main/fig/ehh2.5.png)

# 3 How to Run

> You should first package the data to be processed into a .mat file and remember to change the address of the data file in BoucWen_Step_optimization.m

- run BoucWen_step_optimization.m
- you can change the network parameters in config.ini



# 4 Platform

- Win10
- Matlab r2020




