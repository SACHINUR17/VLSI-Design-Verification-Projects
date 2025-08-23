
// boolean type
typedef enum bit {
  FALSE = 1'b0,
  TRUE  = 1'b1
} bool_e;

// unsigned 2-state int types
typedef bit [  7:0] uchar_t;
typedef bit [ 15:0] uint16_t;
typedef bit [ 31:0] uint32_t;
typedef bit [ 63:0] uint64_t;
typedef bit [127:0] uint128_t;
typedef bit [256:0] uint256_t;
