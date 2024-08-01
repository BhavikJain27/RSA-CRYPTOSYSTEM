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
 output reg  [k-1:0] rem, quo, 
 output done
    );
    
  reg [$clog2(k)-1 : 0] count;
  reg[k-1:0] rem_Reg, quo_Reg;
  wire m_out;    
  wire [$clog2(k)-1 : 0] count_next; 
  wire[k-1:0] quo_next, rem_next, w;
  
  
  assign w = rem_Reg - b;
  
  //state machine
  always @ (posedge clk, negedge rst) begin
      
    if(!rst) begin 
       rem_Reg <= 0; 
       quo_Reg<=0;
       count <=0; 
    end      
    else begin     
       count <= count_next;
       quo_Reg<= quo_next;
       rem_Reg <= rem_next;
    end  
  end
  
 //next state logic 
  assign quo_next = start?((rem_Reg>=b)? ( {quo_Reg[k-2:0], 1'b1}):(quo_Reg<<1)):(quo_Reg);
  assign rem_next = start ?((rem_Reg>=b) ? ({w[k-2:0], m_out}):( {rem_Reg[k-2:0], m_out})):(rem_Reg);
  assign count_next = start ?((count==k-1)?(0):(count+1)):(count);   
  assign m_out = a[k - 1- count];

//output logic
  assign done =(count == 0);
 // assign quo = (done)?((rem_reg>=b)?({quo_reg[k-2:0], 1'b1}):({quo_reg[k-2:0], 1'b0})):(0);
 //assign rem = (done)?((rem_reg>=b)?(w):(rem_reg)):(0);
 
  always @(posedge clk) begin    
      if (done & rem_Reg>=b) begin
          quo <= {quo_Reg[k-2:0], 1'b1};
          rem <= w;
      end
      else  if (done)begin 
          quo <= {quo_Reg[k-2:0], 1'b0};
          rem <= rem_Reg;
      end
      
   end
   
   
   /* wire ce1, ce2;
   reg [k-1:0] quo1, rem1, quo2, rem2;
   
   always @(posedge clk) begin
    if (ce1) begin
       quo1 <= {quo_Reg[k-2:0], 1'b1};
       rem1 <= w;
       end
    end 
    assign ce1 == (done & rem_Reg>=b); 
    
    always @(posedge clk) begin 
      if (ce2) begin
       quo2 <= {quo_Reg[k-2:0], 1'b0};
       rem2 <= rem_Reg;
      end
    end
    
    assign ce2 == done; 
    
    
   
   */
   
   
 
    
endmodule