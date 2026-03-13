module PE_tb;
  parameter DATA_W=8;
  parameter ACC_W=32;
logic clk, reset, clear_acc, v_a_in;
      logic               v_b_in;
      logic  [DATA_W-1:0]  a_in;
      logic [DATA_W-1:0]  b_in;
     logic               v_a_out;
     logic               v_b_out;
     logic [DATA_W-1:0]  a_out;
     logic [DATA_W-1:0]  b_out;
     logic [ACC_W-1:0]   psum;

PE #(.DATA_W(8), .ACC_W(32)) dut (
    .clk(clk), .reset(reset), .clear_acc(clear_acc),
    .v_a_in(v_a_in), .v_b_in(v_b_in),
    .a_in(a_in), .b_in(b_in),
    .v_a_out(v_a_out), .v_b_out(v_b_out),
    .a_out(a_out), .b_out(b_out),
    .psum(psum)
);

logic [31:0] expected_psum;
always #2.5 clk = ~clk; //period =5n

initial begin
$dumpfile("dump.vcd");
$dumpvars();
end

initial begin 
clk=1'b1;
reset=1'b1;  #10; reset=1'b0;
v_a_in=1'b1;
v_b_in=1'b1;
expected_psum=32'd0;
clear_acc=0;
  for(int i=0; i<5; i++) begin
    a_in=$urandom_range(1, 255);
    b_in=$urandom_range(1, 255);
    expected_psum=expected_psum + a_in*b_in;
    @(posedge clk) #1;
  end
  v_a_in=0; v_b_in=0;
  @(posedge clk) #1;
  @(posedge clk) #1;
if(expected_psum==psum) 
    $display("PASS: psum=%0d expected=%0d", psum, expected_psum);
else
    $display("FAIL: psum=%0d expected=%0d", psum, expected_psum);
  
  #20;
  $finish;
end
initial begin
$display("time \t a_in \t B_in \t a_out \t b_out \t expected_psum \t psum:");
$monitor("%0t \t %0d \t %0d \t %0d \t %0d \t %0d \t \t %0d", $time, a_in, b_in, a_out, b_out, expected_psum, psum);
end
endmodule




