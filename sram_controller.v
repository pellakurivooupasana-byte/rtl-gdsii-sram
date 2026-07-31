module sram_controller (

    input  wire        clk,
    input  wire        rst_n,

    input  wire [7:0]  addr,
    input  wire [7:0]  data_in,
    output reg  [7:0]  data_out,

    input  wire        we,       // Write Enable
    input  wire        re,       // Read Enable
    input  wire [7:0]  password,

    output wire        access_denied,
    output wire        power_save_mode
);

    // Fixed Values
    localparam CORRECT_PASSWORD = 8'hA5;
    localparam ENCRYPTION_KEY   = 8'h3C;

    
    // Internal SRAM Wrapper (256 x 8)
 
    reg [7:0] mem [0:255];

   
    // Controller Registers
   
    reg access_granted;
    reg power_save;

    assign access_denied = ~access_granted;
    assign power_save_mode = power_save;

    integer i;

 
    // Controller + Memory Wrapper
  
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            access_granted <= 1'b0;
            power_save     <= 1'b1;
            data_out        <= 8'd0;

            // Initialize memory
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 8'd0;
        end
        else
        begin
            // Password Verification
            if (password == CORRECT_PASSWORD)
                access_granted <= 1'b1;
            else
                access_granted <= 1'b0;

            // Memory Operations
            if (access_granted)
            begin
                power_save <= 1'b0;

                // Write Operation
                if (we)
                    mem[addr] <= data_in ^ ENCRYPTION_KEY;

                // Read Operation
                if (re)
                    data_out <= mem[addr] ^ ENCRYPTION_KEY;

                // Idle State
                if (!we && !re)
                    power_save <= 1'b1;
            end
            else
            begin
                power_save <= 1'b1;
                data_out   <= 8'd0;
            end
        end
    end

endmodule
