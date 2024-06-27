`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2024 18:29:02
// Design Name: 
// Module Name: expo_mont
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


//MODULUS MUST BE AN ODD NUMBER

module top #(parameter in_bit = 3, mod_bit = 5, expo_bit = 3)(
input [in_bit-1:0] in,
input [mod_bit-1:0] n, n_inv, 
input [expo_bit-1:0] exp,
input rst, clk,
output [mod_bit:0] out 

    );
  localparam s_r = 0, s_r1 = 1, s_r2 = 2, s0 = 3, s1=4, s2=5, s3=6, s4=7, s5=8;
  reg [3:0] state, next_state;
    
  
  //counter design for keeping track of exponent bits
  reg [$clog2(expo_bit) - 1:0] count;
  wire [$clog2(expo_bit) - 1:0] count_next; 
  wire dec; 
      always @(posedge clk, negedge rst) begin
           if(!rst) count<= expo_bit -1;
           else if (dec) count<= count_next;  
           else count<= count;
       end 
  assign count_next = (count==0)?(expo_bit - 1):(count-1);
  assign dec = state == s1;  
   
  //exponent bit under scruitny  
  wire bit_val;
  assign bit_val = exp[count];
  
//section for doing the initial steps of montgomery algorithm
//This produces the montogomery representations of the base input and the smallest power of 2 greater than the modulus
  wire [mod_bit-1:0] unity_mont, in_mont; //representations to be calculated
  wire [mod_bit:0] rem1;
  wire [mod_bit+in_bit-1:0] rem2;
  wire done1, start1, done2, start2;
  wire [mod_bit:0] r; //Smallest power of 2 greater than the modulus 
  assign r = {1'b1, {mod_bit{1'b0}}};
  assign start1 = state==s_r| state==s_r1;
  assign start2 = state== s_r| state== s_r1| state==s_r2;  
      division #(.k(mod_bit+1)) d1 (.a(r) , .b({1'b0, n}) , .clk(clk) ,.rst(rst), .start(start1), .rem(rem1), .quo(), .done(done1));  
      division #(.k(mod_bit+in_bit)) d2 (.a({in, {mod_bit{1'b0}}}) , .b({{in_bit{1'b0}},n}) , .clk(clk) ,.rst(rst), .start(start2), .rem(rem2), .quo(), .done(done2));
  assign unity_mont = rem1[mod_bit-1:0];
  assign in_mont = rem2[mod_bit-1:0];
  
  
  //State machine 

      always @(posedge clk, negedge rst) begin
       if(!rst) state<= s_r;
       else state<=next_state;
      end
  //next state logic    
      always @(*) begin
           case (state)
           s_r: next_state = s_r1;
           s_r1: next_state = (done1)?(s_r2):(s_r1);
           s_r2: next_state = (done2)?(s0):(s_r2);
           s0: next_state = s1;
           s1: next_state = (bit_val)?(s2):(s3);
           s2: next_state = s4;
           s3: next_state = s5;
           s4: next_state = s5;
           s5: next_state = (count==expo_bit - 1)?s5:s1;
           default: next_state = state;
           endcase
      end
 
 
  //Datapath unit
  //This implements the remaining steps of montgomery algorithm and returns the output
 
  
  wire calc1, calc2, done;
  wire [mod_bit-1:0] x_mont, unity;
  wire [mod_bit:0] p_mont, q_mont, out_temp;
  assign unity = 1;
  assign calc1 = state== s1;
  assign calc2 = state == s2;
  assign done = (state==s5)&(count==expo_bit-1);
  assign x_mont = (state==s_r2)?(unity_mont):(
       state==s2?(q_mont[mod_bit-1:0]):(
                state==s3?(p_mont[mod_bit-1:0]):(x_mont)
       )
  );
  
  monpro #(.k(mod_bit)) mon1 (calc1, x_mont, x_mont, n, n_inv, p_mont);
  monpro #(.k(mod_bit)) mon2 (calc2, in_mont, p_mont[mod_bit-1:0], n, n_inv, q_mont); 
  monpro #(.k(mod_bit)) mon3 (done, x_mont, unity , n, n_inv, out_temp); 
  

//Output 
  assign out = done?(out_temp):(0);

 
endmodule
