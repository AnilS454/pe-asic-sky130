module PE #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  logic               clk,
    input  logic               reset,
    input  logic               clear_acc,
    input  logic               v_a_in,
    input  logic               v_b_in,
    input  logic [DATA_W-1:0]  a_in,
    input  logic [DATA_W-1:0]  b_in,
    output logic               v_a_out,
    output logic               v_b_out,
    output logic [DATA_W-1:0]  a_out,
    output logic [DATA_W-1:0]  b_out,
    output logic [ACC_W-1:0]   psum
);
logic [ACC_W-1:0] product_reg;
logic v_pipe;
    always_ff @(posedge clk) begin
        if (reset || clear_acc) begin
            //psum    <= '0;
            product_reg <='0;
            a_out   <= '0;
            b_out   <= '0;
            v_a_out <= 1'b0;
            v_b_out <= 1'b0;
            v_pipe <= 1'b0;
        end else begin
            v_a_out <= v_a_in;
            v_b_out <= v_b_in;
            a_out   <= a_in;
            b_out   <= b_in;
            v_pipe  <= v_a_in && v_b_in;
            if (v_a_in && v_b_in)
                product_reg <= ACC_W'(a_in * b_in);
        end
    end
    
    always_ff @(posedge clk) begin
        if(reset || clear_acc)
            psum<='0;
        else if (v_pipe)
            psum <= psum + product_reg;
    end
endmodule

