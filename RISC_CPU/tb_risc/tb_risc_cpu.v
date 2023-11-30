// Description: RISC-CPU 测试程序
// -----------------------------------------------------------------------------
`include "top_module.v"
`include "RAM.v"
`include "ROM.v"
`include "addr_decode.v"

`timescale 1ns/1ns

`define PERIOD 100 // matches clk_gen.v

module cputop;
  reg [( 3 * 8 ): 0 ] mnemonic; // array that holds 3 8 bits ASCII characters
  reg  [ 12 : 0 ] PC_addr, IR_addr;
  reg  reset_req, clock;
  wire [ 12 : 0 ] ir_addr, pc_addr; // for post simulation.
  wire [ 12 : 0 ] addr;
  wire [  7 : 0 ] data;
  wire [  2 : 0 ] opcode;           // for post simulation.
  wire fetch;                       // for post simulation.
  wire rd, wr, halt, ram_sel, rom_sel;
  integer test;
  
  //-----------------DIGITAL LOGIC----------------------
  RISC_CPU t_cpu (.clk( clock ),.reset( reset_req ),.halt( halt ),.rd( rd ),.wr( wr ),.addr( addr ),.data( data ),.opcode( opcode ),.fetch( fetch ),.ir_addr( ir_addr ),.pc_addr( pc_addr ));
  ram t_ram (.addr ( addr [ 9 : 0 ]),.read ( rd ),.write ( wr ),.ena ( ram_sel ),.data ( data ));
  rom t_rom (.addr ( addr          ),.read ( rd ),              .ena ( rom_sel ),.data ( data ));
  addr_decoder t_addr_decoder (.addr( addr ),.ram_sel( ram_sel ),.rom_sel( rom_sel ));
  
  //-------------------SIMULATION-------------------------
  initial begin
    clock = 0;
    // display time in nanoseconds
    $timeformat ( -9, 1, "ns", 12 );
    display_debug_message;
    sys_reset;
    test1; $stop;
    test2; $stop;
    test3;
    $finish; // simulation is finished here.
  end // initial
  
  task display_debug_message;
    begin
      $display ("\n************************************************"  );
      $display (  "* THE FOLLOWING DEBUG TASK ARE AVAILABLE:      *"  );
      $display (  "* \"test1;\" to load the 1st diagnostic program. *");
      $display (  "* \"test2;\" to load the 2nd diagnostic program. *");
      $display (  "* \"test3;\" to load the     Fibonacci  program. *");
      $display (  "************************************************\n");
    end
  endtask // display_debug_message
  
  task test1;
    begin
      test = 0;
      disable MONITOR;
      $readmemb ("test1.pro", t_rom.memory );
      $display ("rom loaded successfully!");
      $readmemb ("test1.dat", t_ram.ram );
      $display ("ram loaded successfully!");
      #1 test = 1;
      #14800;
      sys_reset;
    end
  endtask // test1
  
  task test2;
    begin
      test = 0;
      disable MONITOR;
      $readmemb ("test2.pro", t_rom.memory );
      $display ("rom loaded successfully!");
      $readmemb ("test2.dat", t_ram.ram );
      $display ("ram loaded successfully!");
      #1 test = 2;
      #11600;
      sys_reset;
    end
  endtask // test2
  
  task test3;
    begin
      test = 0;
      disable MONITOR;
      $readmemb ("test3.pro", t_rom.memory );
      $display ("rom loaded successfully!");
      $readmemb ("test3.dat", t_ram.ram );
      $display ("ram loaded successfully!");
      #1 test = 3;
      #94000;
      sys_reset;
    end
  endtask // test1
  
  task sys_reset;
    begin
      reset_req = 0;
      #( `PERIOD * 0.7 ) reset_req = 1;
      #( 1.5 * `PERIOD ) reset_req = 0;
    end
  endtask // sys_reset
  
  //--------------------------MONITOR--------------------------------
  always@( test ) begin: MONITOR
    case( test )
      1: begin // display results when running test 1
        $display("\n*** RUNNING CPU test 1 - The Basic CPU Diagnostic Program ***");
        $display("\n        TIME      PC      INSTR      ADDR      DATA          ");
        $display("         ------    ----    -------    ------    ------         ");
        while( test == 1 )@( t_cpu.pc_addr ) begin // fixed
          if(( t_cpu.pc_addr % 2 == 1 )&&( t_cpu.fetch == 1 )) begin // fixed
            #60  PC_addr <= t_cpu.pc_addr - 1;
                 IR_addr <= t_cpu.ir_addr;
            #340 $strobe("%t %h %s %h %h", $time, PC_addr, mnemonic, IR_addr, data ); // Here data has been changed t_cpu.m_register.data
          end // if t_cpu.pc_addr % 2 == 1 && t_cpu.fetch == 1
        end // while test == 1 @ t_cpu.pc_addr
      end
        
      2: begin // display results when running test 2
        $display("\n*** RUNNING CPU test 2 - The Basic CPU Diagnostic Program ***");
        $display("\n        TIME      PC      INSTR      ADDR      DATA          ");
        $display("         ------    ----    -------    ------    ------         ");
        while( test == 2 )@( t_cpu.pc_addr ) begin // fixed
          if(( t_cpu.pc_addr % 2 == 1 )&&( t_cpu.fetch == 1 )) begin // fixed
            #60  PC_addr <= t_cpu.pc_addr - 1;
                 IR_addr <= t_cpu.ir_addr;
            #340 $strobe("%t %h %s %h %h", $time, PC_addr, mnemonic, IR_addr, data ); // Here data has been changed t_cpu.m_register.data
          end // if t_cpu.pc_addr % 2 == 1 && t_cpu.fetch == 1
        end // while test == 2 @ t_cpu.pc_addr
      end
        
      3: begin // display results when running test 3
        $display("\n*** RUNNING CPU test 3 - An Executable Program **************");
        $display("***** This program should calculate the fibonacci *************");
        $display("\n        TIME      FIBONACCI NUMBER          ");
        $display("         ------    -----------------_         ");
        while( test == 3 ) begin
          wait( t_cpu.opcode == 3'h 1 ) // display Fib. No. at end of program loop
          $strobe("%t     %d", $time, t_ram.ram [ 10'h 2 ]);
          wait( t_cpu.opcode != 3'h 1 );
        end // while test == 3
      end
    endcase // test
  end // MONITOR: always@ test
  
  //-------------------------HALT-------------------------------
  always@( posedge halt ) begin // STOP when HALT intruction decoded
    #500 $display("\n******************************************");
         $display(  "** A HALT INSTRUCTION WAS PROCESSED !!! **");
         $display(  "******************************************");
  end // always@ posedge halt
  
  //-----------------------CLOCK & MNEMONIC-------------------------
  always#(`PERIOD / 2 ) clock = ~ clock;
  
  always@( t_cpu.opcode ) begin // get an ASCII mnemonic for each opcode
    case( t_cpu.opcode )
      3'b 000 : mnemonic = "HLT";
      3'b 001 : mnemonic = "SKZ";
      3'b 010 : mnemonic = "ADD";
      3'b 011 : mnemonic = "AND";
      3'b 100 : mnemonic = "XOR";
      3'b 101 : mnemonic = "LDA";
      3'b 110 : mnemonic = "STO";
      3'b 111 : mnemonic = "JMP";
      default : mnemonic = "???";
    endcase 
  end 
endmodule 
