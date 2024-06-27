This project is the implementation of Modular Exponentiation using the Montgomery Multiplicaiton Algorithm on verilog. 
The top module takes as input an odd modulus and its "minimal negative euclidean inverse" with respect to smallest power of 2 greater tha itself. The bit lengths of both these inputs are parametrised as "mod_bit" .
After multiple operations on the base and exponent, it returns the modular exponentiation result as required. 
This technique is immensely cruicial in the development of an RSA Cryptosystem for sharing of information. 
