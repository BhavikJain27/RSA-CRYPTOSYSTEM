`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2024 22:11:23
// Design Name: 
// Module Name: mod_div
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


module division #(parameter k = 32)(
 input [k-1:0] a, b, 
 input clk, rst, start,
 output reg [k-1:0] rem, quo, 
 output done
    );
    
  reg [$clog2(k)-1 : 0] count;
  reg[k-1:0] rem_reg, quo_reg;
  wire m_out;    
  wire [$clog2(k)-1 : 0] count_next; 
  wire[k-1:0] quo_next, rem_next, w;
  
  
  assign w = rem_reg - b;
  
  //state machine
  always @ (posedge clk, negedge rst) begin
      
    if(!rst) begin 
       rem_reg <= 0; 
       quo_reg<=0;
       count <=0; 
    end      
    else begin     
       count <= count_next;
       quo_reg<= quo_next;
       rem_reg <= rem_next;
    end  
  end
  
 //next state logic 
  assign quo_next = start?((rem_reg>=b)? ( {quo_reg[k-2:0], 1'b1}):(quo_reg<<1)):(quo_reg);
  assign rem_next = start ?((rem_reg>=b) ? ({w[k-2:0], m_out}):( {rem_reg[k-2:0], m_out})):(rem_reg);
  assign count_next = start ?((count==k-1)?(0):(count+1)):(count);   
  assign m_out = a[k - 1- count];

//output logic
  assign done =(count == 0);
  always @* begin    
      if (done & rem_reg>=b) begin
          quo = {quo_reg[k-2:0], 1'b1};
          rem = w;
      end
      else  if (done)begin 
          quo = {quo_reg[k-2:0], 1'b0};
          rem = rem_reg;
      end
   end
 
    
endmodule
