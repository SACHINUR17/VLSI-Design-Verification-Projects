`ifndef _AHB_TYPES_SVH
`define _AHB_TYPES_SVH

typedef bit [`AHB_AWIDTH -1 : 0] addr_t;
typedef bit [`AHB_DWIDTH -1 : 0] data_t;

// read or write
typedef enum bit {
  READ  = 1'b0,
  WRITE = 1'b1
} kind_e;


// transfer type
typedef enum bit [1:0] {
  IDLE   = 2'b00,
  BUSY   = 2'b01,
  NONSEQ = 2'b10,  // single transfer or the first transfer of a burst
  SEQ    = 2'b11   // remaining transfers in a burst
} htrans_e;


// transfer size
typedef enum bit [2:0] {
  BYTE   = 3'b000,  // byte
  HWORD  = 3'b001,  // half word or 16-bits
  WORD   = 3'b010,  // word or 32-bits
  DWORD  = 3'b011,  // double word or 64-bits
  WORD4  = 3'b100,  // 4-word or 128-bits
  WORD8  = 3'b101,  // 8-word or 256-bits
  WORD16 = 3'b110,  // 16-word or 512-bits
  WORD32 = 3'b111   // 32-word or 1024-bits
} hsize_e;


// burst operation
typedef enum bit [2:0] {
  SINGLE  = 3'b000,  // single burst
  INCR    = 3'b001,  // incrementing burst of undefinded length
  WRAP4   = 3'b010,  // 4-beat wrapping burst
  INCR4   = 3'b011,  // 4-beat incrementing burst
  WRAP8   = 3'b100,  // 8-beat wrapping burst
  INCR8   = 3'b101,  // 8-beat incrementing burst
  WRAP16  = 3'b110,  // 16-beat wrapping burst
  INCR16  = 3'b111   // 16-beat incrementing burst
} hburst_e;


// protection control
typedef struct packed {
  bit data;
  bit privileged;
  bit bufferable;
  bit cacheable;
} hprot_e;


// response
typedef enum bit {
  OKAY  = 1'b0,
  ERROR = 1'b1
} hresp_e;



`endif // _AHB_TYPES_SVH
