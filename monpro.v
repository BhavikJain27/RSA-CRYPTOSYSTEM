`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2024 18:34:06
// Design Name: 
// Module Name: monpro
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//The two operands must be in MONTGOMERY FORM
// A_mont = (A*R )modn
//Supply the k-bit odd number used for modulo and also its euclid counterpart
module monpro #(parameter k = 8)(
input calc,
input [k-1:0] a_mont, b_mont, n, n_inv,
output [k:0] prod_mon

    );
    
    wire  [2*k-1:0] w, t,p;
    wire [2*k : 0] q;
    wire [k:0] u;
    assign w = a_mont*b_mont;
    assign t = w[k-1:0] * n_inv;
    assign p = t[k-1:0] * n;
    
    assign q = w + p ; 
    assign u = q[2*k:k];
    
    assign prod_mon = calc ? ((u<n)?(u):(u-n)):(prod_mon);
    
    
    
endmodule
